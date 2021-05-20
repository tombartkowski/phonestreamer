//
//  SimulatorDevice.swift
//  SimulatorsManager
//
//  Created by Tomasz Bartkowski on 10/05/2021.
//

import Foundation

struct SimulatorDevice {
    let name: String
    let uuid: String
    var isBooted: Bool
}

extension SimulatorDevice {
    static func availableDevices() -> [SimulatorDevice] {
        let listDevicesProcess = Process()
        let outputPipe = Pipe()
        listDevicesProcess.executableURL = URL(fileURLWithPath: "/usr/bin/xcrun")
        listDevicesProcess.arguments = ["simctl", "list", "devices"]
        listDevicesProcess.standardOutput = outputPipe

        do {
            try listDevicesProcess.run()
        } catch {
            return []
        }

        let outputData = outputPipe.fileHandleForReading.readDataToEndOfFile()
        let output = String(data: outputData, encoding: .utf8)?
            .components(separatedBy: "\n")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            ?? []
            .filter { !$0.isEmpty }

        let indexStart = output.lastIndex(of: "-- iOS 14.4 --") ?? 0
        let indexEnd = output.firstIndex(of: "-- tvOS 14.3 --") ?? 0

        let deviceStrings = Array(output.suffix(from: indexStart + 1).prefix(upTo: indexEnd))
        let devices: [SimulatorDevice] = deviceStrings.compactMap {
            let udidRegex =
                "[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}"
            guard let udidRegexMatch = $0.range(of: udidRegex, options: .regularExpression)
            else { return nil }

            let lowerBoundIncludingParentheses = $0.index(before: udidRegexMatch.lowerBound)
            let parenthesesUdid = $0[lowerBoundIncludingParentheses ... udidRegexMatch.upperBound]
            let components = $0.components(separatedBy: parenthesesUdid)
                .map { $0.trimmingCharacters(in: .whitespaces) }
            guard components.count == 2 else { return nil }

            let deviceName = components[0]
            let udid = $0[udidRegexMatch.lowerBound ..< udidRegexMatch.upperBound]
            let deviceStatus = components[1]

            return SimulatorDevice(
                name: deviceName,
                uuid: String(udid),
                isBooted: deviceStatus == "(Booted)"
            )
        }
        return devices
    }
}
