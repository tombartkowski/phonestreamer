//
//  main.swift
//  PhoneStreamerMac
//
//  Created by Tomasz Bartkowski on 07/05/2021.
//

import Foundation

if CommandLine.argc < 3 {
    Logger.log(content: "Not enough launch arguments. Quitting.", type: .error)
    exit(0)
}

guard let windowId = Int(CommandLine.arguments[1]) else {
    Logger.log(content: "Could not parse windowId. Quitting.", type: .error)
    exit(0)
}

guard let pid: pid_t = Int32(CommandLine.arguments[2]) else {
    Logger.log(content: "Could not pid from \(CommandLine.arguments[2]). Quitting.", type: .error)
    exit(0)
}

func sendEvent(_ event: Event?) {
    guard let event = event else { return }
    switch event {
    case let .touchDown(inputPoint):
        TouchEvent.send(
            .touchDown,
            location: inputPoint,
            windowNumber: windowId,
            to: pid
        )
    case let .touchUp(inputPoint):
        TouchEvent.send(
            .touchUp,
            location: inputPoint,
            windowNumber: windowId,
            to: pid
        )
    case let .touchMove(inputPoint):
        TouchEvent.send(
            .move,
            location: inputPoint,
            windowNumber: windowId,
            to: pid
        )
    case let .keyDown(key, isShift, hasAlt):
        KeyEvent.send(keyEvent: KeyEventData(keyCode: key, hasShift: isShift, hasAlt: hasAlt), to: pid)
    default:
        break
    }
}

let runLoop = RunLoop.current
Logger.log(content: "Started listening for events for window \(windowId).")
while let command = readLine() {
    sendEvent(InputParser.event(for: command))
}

Logger.log(content: "Exited while loop.", type: .error)
runLoop.run(until: .distantFuture)
