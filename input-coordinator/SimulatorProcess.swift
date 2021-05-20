//
//  SimulatorProcess.swift
//  SimulatorsManager
//
//  Created by Tomasz Bartkowski on 09/05/2021.
//

import Quartz

@objc
class SimulatorProcess: NSObject {
    // MARK: Lifecycle

    private init(_ runningApplication: NSRunningApplication) {
        self.runningApplication = runningApplication
    }

    // MARK: Internal

    var pid: pid_t {
        runningApplication.processIdentifier
    }

    static func create() -> SimulatorProcess? {
        Logger.log(content: "Fetching Simulator process.")
        guard
            let simulatorProcess = NSWorkspace.shared.runningApplications.first(where: {
                ($0.bundleIdentifier ?? "") == "com.apple.iphonesimulator"
            }) else {
            Logger.log(content: "Could not find a Simulator process.", type: .error)
            return nil
        }

        Logger.log(content: "Simulator process found. PID = \(simulatorProcess.processIdentifier).")
        let returnValue = SimulatorProcess(simulatorProcess)
        return returnValue
    }

    func activate() {
        if !runningApplication.isActive {
            Logger.log(content: "Activating Simulator process.")
            runningApplication.activate(options: .activateIgnoringOtherApps)
            usleep(250_000)
        }
//        else {
            Logger.log(content: "Simulator process already active.")
//        }
    }

    // MARK: Private

    private let runningApplication: NSRunningApplication
}
//yCN5_u,td,0200.50,0200.50
