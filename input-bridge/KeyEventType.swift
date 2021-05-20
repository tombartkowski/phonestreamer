//
//  KeyEventType.swift
//  PhoneStreamerMac
//
//  Created by Tomasz Bartkowski on 08/05/2021.
//

import Foundation

typealias HasShift = Bool
typealias HasAlt = Bool

// MARK: - KeyEventType

enum KeyEventType: Equatable {
    case keyDown(UInt16, HasShift, HasAlt)
}

struct KeyEventData {
    let keyCode: UInt16
    let hasShift: Bool
    let hasAlt: Bool
}
