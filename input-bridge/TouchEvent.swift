//
//  TouchEvent.swift
//  PhoneStreamerMac
//
//  Created by Tomasz Bartkowski on 08/05/2021.
//

import Foundation
import Quartz

class TouchEvent {
    static func send(
        _ touchType: TouchEventType,
        location: CGPoint,
        windowNumber: Int,
        to pid: pid_t
    ) {
        let mouseEvent = NSEvent.mouseEvent(
            with: touchType.eventType,
            location: NSPoint(x: location.x, y: location.y),
            modifierFlags: .init(rawValue: 0),
            timestamp: ProcessInfo.processInfo.systemUptime,
            windowNumber: windowNumber,
            context: nil,
            eventNumber: 0,
            clickCount: touchType.clickCount,
            pressure: touchType.pressure
        )
        guard let event = mouseEvent else { return }
        guard let cgEvent = event.cgEvent else { return }
        cgEvent.flags = CGEventFlags(rawValue: 0)
        cgEvent.postToPid(pid)

        Logger.log(content: "Sent Touch Event \(touchType) at \(cgEvent.location).")
    }
}
