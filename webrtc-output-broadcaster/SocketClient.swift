//
//  SocketClient.swift
//  SimulatorRenderer
//
//  Created by Tomasz Bartkowski on 17/05/2021.
//

import Starscream
import WebRTC

@objc class SocketClient: NSObject {
    static let shared = SocketClient()
    
    override init() {
        var request = URLRequest(url: URL(string: "http://localhost:8000")!)
        request.timeoutInterval = 5
        socket = WebSocket(request: request)
        socket.connect()
        super.init()
        socket.delegate = self
    }

    // MARK: Internal

    let socket: WebSocket
    var isConnected = false
    
    func sendInit() {
        socket.write(string: "{\"inst\":\"init\",\"id\":\"Simulator\"}")
    }
    
    func sendOffer(sdp: RTCSessionDescription) {
        let typeStr = RTCSessionDescription.string(for: sdp.type)
        let dict = [
            "message": [
                "type": typeStr,
                "sdp": sdp.sdp,
            ],
            "inst": "send",
            "peerId": "React",
            "id": "Simulator"
        ] as [String : Any]
        
        guard let data = dict.JSONData else { return }
        socket.write(data: data)
    }
    
    func sendIce(data: [String: Any]) {
        let dict = [
            "message":data,
            "inst": "send",
            "peerId": "React",
            "id": "Simulator"
        ] as [String : Any]
        
        guard let data = dict.JSONData else { return }
        socket.write(data: data)
    }
}

// MARK: WebSocketDelegate

extension SocketClient: WebSocketDelegate {
    func didReceive(event: WebSocketEvent, client _: WebSocket) {
        switch event {
        case .connected(_):
            isConnected = true
        case .disconnected(_, _):
            isConnected = false
        case let .text(string):
            print(string)
            let signalMessage = SignalMessage.from(message: string)
            switch signalMessage {
            case let .answer(sdp):
                WebRTCClient.shared.handleRemoteDescription(sdp)
            case let .candidate(candidate):
                WebRTCClient.shared.handleCandidateMessage(candidate)
            case .offer(_):
                break
            default:
                break
            }
            break
        default:
            break
        }
    }
}

extension RTCSessionDescription {
    func JSONData() -> Data? {
        let typeStr = RTCSessionDescription.string(for: type)
        let dict = [
            "type": typeStr,
            "sdp": sdp,
        ]
        return dict.JSONData
    }
}

extension RTCIceCandidate {
    func JSONData() -> [String: Any] {
        let dict = [
            "type": "candidate",
            "label": "\(sdpMLineIndex)",
            "id": sdpMid!,
            "candidate": sdp,
        ]
        return dict
    }

    static func candidate(from: [String: Any]) -> RTCIceCandidate? {
        let sdp = from["candidate"] as? String
        let sdpMid = from["id"] as? String
        let labelStr = from["label"] as? String
        let label = (from["label"] as? Int32) ?? 0

        return RTCIceCandidate(
            sdp: sdp ?? "",
            sdpMLineIndex: Int32(labelStr ?? "") ?? label,
            sdpMid: sdpMid
        )
    }
}

extension String {
    func convertToDictionary() -> [String: Any]? {
        if let data = self.data(using: .utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            } catch {
                debugPrint(error.localizedDescription)
            }
        }
        return nil
    }
}

extension Dictionary {
    var JSONData: Data? {
        guard
            let data = try? JSONSerialization.data(
                withJSONObject: self,
                options: [.prettyPrinted]
            )
        else {
            return nil
        }
        return data
    }
}

