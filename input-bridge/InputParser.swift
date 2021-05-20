//
//  InputParser.swift
//  PhoneStreamerMac
//
//  Created by Tomasz Bartkowski on 10/05/2021.
//

import Foundation

struct InputParser {
    //td0200.500200.50
    //kd00211
    
    private static func point(`for` input: String) -> CGPoint {
        return CGPoint(x: Double(input[String.Index(utf16Offset: 1, in: input)...String.Index(utf16Offset: 7, in: input)]) ?? 0, y:Double(input[String.Index(utf16Offset: 8, in: input)...String.Index(utf16Offset: 14, in: input)]) ?? 0)
    }
    
    static func event(for input: String) -> Event? {
        let eventName = input[String.Index(utf16Offset: 0, in: input)]
        switch eventName {
        case "0":
            return .touchDown(point(for: input))
        case "1":
            return .touchUp(point(for: input))
        case "2":
            return .touchMove(point(for: input))
        case "3":
            let key: UInt16 = UInt16(input[String.Index(utf16Offset: 1, in: input)...String.Index(utf16Offset: 3, in: input)])!
            let hasShift = input[String.Index(utf16Offset: 4, in: input)] == "1"
            let hasAlt = input[String.Index(utf16Offset: 5, in: input)] == "1"
            return .keyDown(key, hasShift, hasAlt)
        default:
            return nil
        }
    }
}
