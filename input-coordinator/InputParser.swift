//
//  InputParser.swift
//  SimulatorsManager
//
//  Created by Tomasz Bartkowski on 10/05/2021.
//

import Foundation

// MARK: - InputParser

struct InputParser {
    //yCN5_utu0200.500200.50
    //yCN5_utd0200.500200.50
    //yCN5_utd0200.500200.50
    //yCN5_ukd00200
    static func event(for input: String) -> Event? {
        let eventName = input[String.Index(utf16Offset: 6, in: input)]
        return Event(
            simulatorName: String(input.prefix(6)),
            simulatorCommand: String(input.suffix(from: String.Index(utf16Offset: 6, in: input))),
            eventType: eventName == "3" ? .key :  eventName != "9" ? .touch : .simulator(.launch)
        )
    }
}
