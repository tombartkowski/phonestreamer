//
//  EventType.swift
//  PhoneStreamerMac
//
//  Created by Tomasz Bartkowski on 08/05/2021.
//

import Foundation

// MARK: - Event

enum Event {
    case touchDown(CGPoint)
    case touchMove(CGPoint)
    case touchUp(CGPoint)
    case keyDown(UInt16, HasShift, HasAlt)
    case keyUp(UInt16, HasShift, HasAlt)

    // MARK: Internal

    enum EventType {
        case keyboard
        case mouse
    }

    var eventType: EventType {
        switch self {
        case .keyDown, .keyUp:
            return .keyboard
        case .touchDown(_), .touchUp(_), .touchMove:
            return .mouse
        }
    }
}
