//
//  KeyboardEvent.swift
//  PhoneStreamerMac
//
//  Created by Tomasz Bartkowski on 08/05/2021.
//

import Foundation
import Quartz

class KeyEvent {
    static func send(keyEvent: KeyEventData, to pid: pid_t) {
        let src = CGEventSource(stateID: .hidSystemState)

        let mainKeyDownEvent = CGEvent(
            keyboardEventSource: src,
            virtualKey: CGKeyCode(keyEvent.keyCode),
            keyDown: true
        )
        let mainKeyUpEvent = CGEvent(
            keyboardEventSource: src,
            virtualKey: CGKeyCode(keyEvent.keyCode),
            keyDown: false
        )
        
        var shiftDownEvent: CGEvent?
        var shiftUpEvent: CGEvent?
        var altDownEvent: CGEvent?
        var altUpEvent: CGEvent?

        if !keyEvent.hasShift, !keyEvent.hasAlt {
        } else if !keyEvent.hasAlt {             // shift

            shiftDownEvent = CGEvent(
                keyboardEventSource: src,
                virtualKey: CGKeyCode(56),
                keyDown: true
            )
            shiftUpEvent = CGEvent(
                keyboardEventSource: src,
                virtualKey: CGKeyCode(56),
                keyDown: false
            )
            mainKeyDownEvent?.flags = .maskShift
            mainKeyUpEvent?.flags = .maskShift
        } else if !keyEvent.hasShift { // alt
            
            altDownEvent = CGEvent(
                keyboardEventSource: src,
                virtualKey: CGKeyCode(58),
                keyDown: true
            )
            altUpEvent = CGEvent(
                keyboardEventSource: src,
                virtualKey: CGKeyCode(58),
                keyDown: false
            )
            mainKeyDownEvent?.flags = .maskAlternate
            mainKeyUpEvent?.flags = .maskAlternate
        } else {            // shift i alt
            shiftDownEvent = CGEvent(
                keyboardEventSource: src,
                virtualKey: CGKeyCode(56),
                keyDown: true
            )
            shiftUpEvent = CGEvent(
                keyboardEventSource: src,
                virtualKey: CGKeyCode(56),
                keyDown: false
            )
            altDownEvent = CGEvent(
                keyboardEventSource: src,
                virtualKey: CGKeyCode(58),
                keyDown: true
            )
            altUpEvent = CGEvent(
                keyboardEventSource: src,
                virtualKey: CGKeyCode(58),
                keyDown: false
            )
            mainKeyDownEvent?.flags = CGEventFlags([.maskShift, .maskAlternate])
            mainKeyUpEvent?.flags = CGEventFlags([.maskShift, .maskAlternate])

        }

        if shiftDownEvent != nil {
            shiftDownEvent?.postToPid(pid)
            usleep(1000)
        }
        if altDownEvent != nil {
            altDownEvent?.postToPid(pid)
            usleep(1000)
        }
        
        mainKeyDownEvent?.postToPid(pid)
        usleep(1000)
        mainKeyUpEvent?.postToPid(pid)
        usleep(1000)
        
        if altUpEvent != nil {
            altUpEvent?.postToPid(pid)
            usleep(1000)
        }
        if shiftUpEvent != nil {
            shiftUpEvent?.postToPid(pid)
            usleep(1000)
        }
        

        Logger.log(content: "Sent Key Event: \(keyEvent)")
    }
}
