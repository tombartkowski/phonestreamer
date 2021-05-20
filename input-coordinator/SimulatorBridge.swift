//
//  SimulatorBridge.swift
//  SimulatorsManager
//
//  Created by Tomasz Bartkowski on 10/05/2021.
//

import Foundation
import Quartz

@objc class SimulatorBridge: NSObject {
    let window: Window
    let simulatorName: String
    let inputPipe: Pipe

    init(window: Window, simulatorName: String, inputPipe: Pipe) {
        Logger.log(content: "Created SimulatorBridge for \(simulatorName).")
        self.window = window
        self.simulatorName = simulatorName
        self.inputPipe = inputPipe
        super.init()
    }
    
    static func launchSimulator(named name: String, on pid: pid_t, queue: DispatchQueue, _ completion: @escaping (SimulatorBridge?) -> ())  {
        Logger.log(content: "Launching Simulator \(name).")
        let currentWindows = Window.fetchSimulatorWindows(pid)
        let bootSimulatorProcess = Process()
        let outputPipe = Pipe()
        bootSimulatorProcess.executableURL = URL(fileURLWithPath: "/usr/bin/xcrun")
        bootSimulatorProcess.arguments = ["simctl", "boot", name]
        bootSimulatorProcess.standardOutput = outputPipe
        bootSimulatorProcess.standardError = outputPipe

        bootSimulatorProcess.launch()
        bootSimulatorProcess.waitUntilExit()

        queue.asyncAfter(deadline: .now() + .microseconds(200_000)) {
            let windowsAfterBoot = Window.fetchSimulatorWindows(pid)
            #if DEBUG
            let newWindow = currentWindows.first
            #else
            let newWindow = windowsAfterBoot.difference(from: currentWindows).first
            #endif
           
            if newWindow == nil {
                Logger.log(content: "Could not find the newly created Simulator window.", type: .error)
                completion(nil)
                return
            }

            let windowId = newWindow!.number
            let simulatorBridgeProcess = Process()
            let inputPipe = Pipe()
            
//            simulatorBridgeProcess.executableURL = URL(fileURLWithPath: "/Users/tomek/simbridge")
            simulatorBridgeProcess.executableURL = URL(fileURLWithPath: "/Users/tomek/Library/Developer/Xcode/DerivedData/PhoneStreamerMac-glrplgazprnvjaglqhafneaebrht/Build/Products/Debug/PhoneStreamerMac")
            simulatorBridgeProcess.arguments = [String(windowId), String(pid)]
            simulatorBridgeProcess.standardInput = inputPipe
            simulatorBridgeProcess.standardOutput = FileHandle.standardOutput
            
            simulatorBridgeProcess.launch()
            completion(SimulatorBridge(window: newWindow!, simulatorName: name, inputPipe: inputPipe))
        }
    }
}
