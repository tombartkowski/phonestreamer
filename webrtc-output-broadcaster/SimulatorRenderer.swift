//
//  SimulatorRenderer.swift
//  SimulatorRenderer
//
//  Created by Tomasz Bartkowski on 17/05/2021.
//

import Foundation

@objc class SimulatorRenderer: NSObject {
    
    private let socketClient: SocketClient
    private let webRTCClient: WebRTCClient

    override init() {
        socketClient = SocketClient.shared
        webRTCClient = WebRTCClient.shared
        super.init()
        webRTCClient.runTimer()
        socketClient.sendInit()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
            self?.webRTCClient.offer()
        }
        
        

    }
}
