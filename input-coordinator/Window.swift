//
//  Window.swift
//  SimulatorsManager
//
//  Created by Tomasz Bartkowski on 10/05/2021.
//

import Foundation

struct Window: Hashable {
    let isOnScreen: Bool
    let number: Int
    let ownerName: String
    let ownerPID: Int
    let bounds: CGRect

    static func fetchSimulatorWindows(_ simulatorPid: pid_t) -> [Window] {
        Logger.log(content: "Fetching Simulator CGWindows.")
        guard let windowsList = CGWindowListCopyWindowInfo(.optionAll, kCGNullWindowID) else {
            Logger.log(content: "Could not copy Window Info.", type: .warning)
            return []
        }
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
        let result = step6.filter { $0.ownerPID == simulatorPid }
        Logger.log(content: "Fetching Simulator CGWindows completed. Windows = \(result)")
        return result
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(number)
    }
}
