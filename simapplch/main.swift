//
//  main.swift
//  Simwindow
//
//  Created by Tomasz Bartkowski on 18/05/2021.
//

import Foundation

if CommandLine.arguments.count < 2 {
    FileHandle.standardError.write("Failed to launch the Simulator.\n".data(using: .utf8)!)
    exit(0)
}

guard let windowId = Int(CommandLine.arguments[1]) else {
    FileHandle.standardError.write("Failed to launch the Simulator.\n".data(using: .utf8)!)
    exit(0)
}

guard let windowsList = CGWindowListCopyWindowInfo(.optionIncludingWindow, CGWindowID(windowId)) else {
    FileHandle.standardError.write("Failed to launch the Simulator.\n".data(using: .utf8)!)
    exit(0)
}
let step1 = NSArray(object: windowsList)
let step2 = step1.compactMap { $0 as? NSArray }
let step3 = step2.reduce([], +)
let step4 = step3.compactMap { $0 as? [CFString: Any] }
let step5 = step4.compactMap { (dictionary) -> CGRect? in
    let window = dictionary[kCGWindowBounds] as! CFDictionary
    guard let bounds = CGRect(dictionaryRepresentation: window) else { return nil }
    return bounds
}
guard let windowFrame = step5.first else {
    FileHandle.standardError.write("Failed to launch the Simulator.\n".data(using: .utf8)!)
    exit(0)
}

FileHandle.standardOutput.write(String("\(windowFrame)\n").data(using: .utf8)!)
exit(1)
