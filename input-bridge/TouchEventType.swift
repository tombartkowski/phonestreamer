//
//  TouchType.swift
//  PhoneStreamerMac
//
//  Created by Tomasz Bartkowski on 08/05/2021.
//

import Foundation
import Quartz

enum TouchEventType: Equatable {
    case move
    case touchDown
    case touchUp

    // MARK: Internal

    var eventType: NSEvent.EventType {
        switch self {
        case .move:
            return .leftMouseDragged
        case .touchDown:
            return .leftMouseDown
        case .touchUp:
            return .leftMouseUp
        }
    }

    var clickCount: Int {
        switch self {
        case .move:
            return 1
        case .touchDown:
            return 1
        case .touchUp:
            return 1
        }
    }

    var pressure: Float {
        switch self {
        case .move:
            return 1
        case .touchDown:
            return 1
        case .touchUp:
            return 0
        }
    }
}
