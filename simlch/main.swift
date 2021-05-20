//
//  main.swift
//  WindowsInfo
//
//  Created by Tomasz Bartkowski on 17/05/2021.
//

import Foundation
import Quartz

struct Window: Hashable {
    let isOnScreen: Bool
    let number: Int
    let ownerName: String
    let ownerPID: Int
    let bounds: CGRect

    func hash(into hasher: inout Hasher) {
        hasher.combine(number)
    }
}

func launchSimulator(named name: String, on pid: pid_t) -> Int? {
    let currentWindows = windowsList(pid: pid)
    let bootSimulatorProcess = Process()
    let outputPipe = Pipe()
    bootSimulatorProcess.executableURL = URL(fileURLWithPath: "/usr/bin/xcrun")
    bootSimulatorProcess.arguments = ["simctl", "boot", name]
    bootSimulatorProcess.standardOutput = outputPipe
    bootSimulatorProcess.standardError = outputPipe

    bootSimulatorProcess.launch()
    bootSimulatorProcess.waitUntilExit()

    usleep(200_000)
    let windowsAfterBoot = windowsList(pid: pid)
    let newWindow = windowsAfterBoot.difference(from: currentWindows).insertions.first
    switch newWindow {
    case .insert(offset: _, element: let window, associatedWith: _):
        return window.number
    default:
        break
    }
    return nil
}


func windowsList(pid: pid_t) -> [Window] {
    guard let windowsList = CGWindowListCopyWindowInfo(.optionAll, kCGNullWindowID) else { exit(0) }
    let step1 = NSArray(object: windowsList)
    let step2 = step1.compactMap { $0 as? NSArray }
    let step3 = step2.reduce([], +)
    let step4 = step3.compactMap { $0 as? [CFString: Any] }
    let step5 = step4.compactMap { (dictionary) -> Window? in
        let isOnScreen = dictionary[kCGWindowIsOnscreen] as? Int
        let window = dictionary[kCGWindowBounds] as! CFDictionary

        guard
            let number = dictionary[kCGWindowNumber] as? Int,
            let ownerName = dictionary[kCGWindowOwnerName] as? String,
            let bounds = CGRect(dictionaryRepresentation: window),
            let ownerPID = dictionary[kCGWindowOwnerPID] as? Int else { return nil }

        return Window(
            isOnScreen: isOnScreen == 1,
            number: number,
            ownerName: ownerName,
            ownerPID: ownerPID,
            bounds: bounds
        )
    }
    let step6 = step5.filter { $0.isOnScreen }
    let windows = step6.filter { $0.ownerPID == pid }
    return windows
}

// MARK: - Window

if CommandLine.arguments.count < 3 {
    FileHandle.standardError.write("Failed to launch the Simulator.\n".data(using: .utf8)!)
    exit(0)
}

guard let pid = Int32(CommandLine.arguments[1]) else {
    FileHandle.standardError.write("Failed to launch the Simulator.\n".data(using: .utf8)!)
    exit(0)
}

let name = CommandLine.arguments[2]

if let windowId = launchSimulator(named: name, on: pid) {
    FileHandle.standardOutput.write(String("\(windowId)\n").data(using: .utf8)!)
    exit(1)
} else {
    FileHandle.standardError.write("Failed to launch the Simulator.\n".data(using: .utf8)!)
    exit(0)
}
