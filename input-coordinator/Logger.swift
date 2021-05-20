//
//  Logger.swift
//  SimulatorsManager
//
//  Created by Tomasz Bartkowski on 11/05/2021.
//

import Foundation

struct Logger {
    enum LogStyle: Equatable {
        case normal
        case verbose
    }
    
    enum LogType {
        case info
        case warning
        case error
        
        var logType: String {
            switch self {
            case .info:
                return "INFO"
            case .warning:
                return "WARNING"
            case .error:
                return "ERROR"
            }
        }
    }

    static var formatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.timeStyle = .medium
        return dateFormatter
    }()

    static func log(content: String, type: LogType = .info, style: LogStyle = .normal) {
        return 
        let time = formatter.string(from: Date())
        
        guard let data = "\(time) [SimulatorManager] \(type.logType) - \(content)\n".data(using: .utf8) else {
            return
        }
        
        switch type {
        case .error:
            FileHandle.standardError.write(data)
        default:
            FileHandle.standardOutput.write(data)
        }
    }
}
