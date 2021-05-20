//
//  SimulatorsManager.swift
//  SimulatorsManager
//
//  Created by Tomasz Bartkowski on 09/05/2021.
//

import Cocoa
import Foundation
import Quartz

// MARK: - SimulatorsManager

@objc
class SimulatorsManager: NSObject {
    // MARK: Lifecycle

    override init() {
        Logger.log(content: "Initializing.")
        simulatorProcess = SimulatorProcess.create()
        availableDevices = SimulatorDevice.availableDevices().filter { $0.isBooted }
        super.init()
        guard let simulatorProcess = simulatorProcess else {
            Logger.log(content: "Quitting.")
            return
        }
       Window.fetchSimulatorWindows((simulatorProcess.pid))
        windowsManager = SimulatorWindowsManager(simulatorPid: simulatorProcess.pid)
        start()
    }

    // MARK: Internal

    var windowsManager: SimulatorWindowsManager?
    var simulatorProcess: SimulatorProcess!
    var availableDevices: [SimulatorDevice] = []
    var simulatorBridges = [String: SimulatorBridge]()

    // MARK: Private

    private let keyboardEventsQueue =
        DispatchQueue(label: "simulators-manager.keyboard-events-queue")
    private let simulatorsHandlingQueue =
        DispatchQueue(label: "simulators-manager.simulators-handling-queue")
    private let eventsListeningQueue =
        DispatchQueue(label: "simulators-manager.events-listening-queue")

    private func executeEvent(_ event: Event, activateWindow: Bool) {
        Logger.log(content: "Executing event \(event).")
        if
            let bridge = simulatorBridges[event.simulatorName],
            let input = (event.simulatorCommand + "\n").data(using: .utf8)
        {
            if activateWindow {
                DispatchQueue.main.async { [weak self] in
                    self?.windowsManager?.activateWindow(event.simulatorName) {
                        bridge.inputPipe.fileHandleForWriting.write(input)
                    }
                }
            } else {
                bridge.inputPipe.fileHandleForWriting.write(input)
            }
        } else {
            Logger.log(content: "Executing failed. No bridge found or incorrect data.", type: .warning)
        }
    }

    private func start() {
        Logger.log(content: "Started.")
        
        eventsListeningQueue.async { [weak self] in
            guard let self = self else { return }

            while true {
                while let command = readLine() {
                    Logger.log(content: "Recieved stdin - \(command)")
                    
                    if let event = InputParser.event(for: command) {
                        switch event.eventType {
                        case .key:
                            self.simulatorProcess.activate()
                            self.executeEvent(event, activateWindow: true)
                        case .touch:
                            self.executeEvent(event, activateWindow: false)
                        case let .simulator(type):
                            switch type {
                            case .launch:
                                SimulatorBridge.launchSimulator(
                                    named: event.simulatorName,
                                    on: self.simulatorProcess.pid,
                                    queue: self.simulatorsHandlingQueue
                                ) { [weak self] bridge in
                                    guard let self = self, let bridge = bridge else { return }
                                    self.simulatorBridges[event.simulatorName] = bridge
                                    self.windowsManager?.updateWindows()
                                }
                            default:
                                break
                            }
                        }
                    }
                }
            }
        }
    }
}

// SIM=dupa,EVENT=KEY_DOWN,CODE=d
// SIM=yCN5_u,EVENT=TOUCH_DOWN,x=223.5,y=750
// SIM=yCN5_u,EVENT=LAUNCH

//11:40:26 [SimulatorManager] INFO - Fetching Simulator CGWindows completed. Windows = [SimulatorsManager.Window(isOnScreen: true, number: 1887, ownerName: "Simulator", ownerPID: 3627, bounds: (968.0, 42.0, 454.0, 923.0)), SimulatorsManager.Window(isOnScreen: true, number: 1921, ownerName: "Simulator", ownerPID: 3627, bounds: (398.0, 23.0, 447.0, 916.0))]
