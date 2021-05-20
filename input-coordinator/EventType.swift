//
//  EventType.swift
//  SimulatorsManager
//
//  Created by Tomasz Bartkowski on 11/05/2021.
//

enum EventType {
    case touch
    case key
    case simulator(SimulatorEventType)
    
    enum SimulatorEventType {
        case launch
        case shutdown
    }
}
