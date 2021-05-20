//
//  WebRTCClient.swift
//  SimulatorRenderer
//
//  Created by Tomasz Bartkowski on 17/05/2021.
//

import Foundation
import WebRTC

protocol WebRTCClientDelegate: class {
    func webRTCClient(_ client: WebRTCClient, sendData data: Data)
}

@objc class WebRTCClient: NSObject {
    static let shared = WebRTCClient()
    
    override init() {
        super.init()
        setup()
    }

    let factory = RTCPeerConnectionFactory()
    weak var delegate: WebRTCClientDelegate?

    func setup() {
        let constraints = RTCMediaConstraints(
            mandatoryConstraints: nil,
            optionalConstraints: ["DtlsSrtpKeyAgreement": "true"]
        )
        let config = generateRTCConfig()
        peerConnection = factory.peerConnection(
            with: config,
            constraints: constraints,
            delegate: self
        )
        createMediaSenders()
    }

    func offer() {
        guard let peerConnection = peerConnection else {
            return
        }
        peerConnection.offer(
            for: RTCMediaConstraints(
                mandatoryConstraints: nil,
                optionalConstraints: nil
            ),
            completionHandler: { [weak self] sdp, _ in
                guard let self = self, let sdp = sdp else { return }
                self.setLocalSDP(sdp)
            }
        )
    }

    func disconnect() {
        hasReceivedSdp = false
        peerConnection?.close()
        peerConnection = nil
    }

    private var candidateQueue = [RTCIceCandidate]()
    private var peerConnection: RTCPeerConnection?

    private var dataChannel: RTCDataChannel!
    private var hasReceivedSdp = false
    private var simulatorWindowStreamer: SimulatorWindowStreamer!

    private func setLocalSDP(_ sdp: RTCSessionDescription) {
        guard let peerConnection = peerConnection else {
            return
        }
        peerConnection.setLocalDescription(sdp, completionHandler: { error in
            if let error = error {
                debugPrint(error)
            }
        })
        SocketClient.shared.sendOffer(sdp: sdp)
    }
}

extension WebRTCClient {
    private func generateRTCConfig() -> RTCConfiguration {
        let config = RTCConfiguration()
        config.iceServers = [RTCIceServer(urlStrings:["stun:stun.l.google.com:19302"])]
        config.sdpSemantics = RTCSdpSemantics.unifiedPlan
        return config
    }

    private func createMediaSenders() {
        guard let peerConnection = peerConnection else {
            return
        }
        let config = RTCDataChannelConfiguration()
        config.isOrdered = true
        config.channelId = 2137
        
        dataChannel = peerConnection.dataChannel(forLabel: "dataC", configuration: config)
        simulatorWindowStreamer = SimulatorWindowStreamer(withWindowId: 248, dataChannel: dataChannel)
    }
    
    public func runTimer() {
        simulatorWindowStreamer.start()
    }
}

extension WebRTCClient {
    func handleCandidateMessage(_ candidate: RTCIceCandidate) {
        candidateQueue.append(candidate)
    }

    func handleRemoteDescription(_ desc: RTCSessionDescription) {
        guard let peerConnection = peerConnection else {
            return
        }
        hasReceivedSdp = true
        peerConnection.setRemoteDescription(desc, completionHandler: { [weak self] _ in
//            self?.simulatorWindowStreamer.start()
        })
    }

    func drainMessageQueue() {
        guard
            let peerConnection = peerConnection,
            hasReceivedSdp
        else {
            return
        }

        for candidate in candidateQueue {
            peerConnection.add(candidate)
        }

        candidateQueue.removeAll()
    }
}

extension WebRTCClient: RTCPeerConnectionDelegate {
    func peerConnection(_: RTCPeerConnection, didChange _: RTCSignalingState) {}
    func peerConnection(_: RTCPeerConnection, didAdd _: RTCMediaStream) {}
    func peerConnection(_: RTCPeerConnection, didRemove _: RTCMediaStream) {}
    func peerConnectionShouldNegotiate(_: RTCPeerConnection) {}
    func peerConnection(_: RTCPeerConnection, didChange _: RTCIceConnectionState) {}
    func peerConnection(_: RTCPeerConnection, didChange _: RTCIceGatheringState) {}
    func peerConnection(_: RTCPeerConnection, didGenerate candidate: RTCIceCandidate) {
        let message = candidate.JSONData()
        SocketClient.shared.sendIce(data: message)
    }
    func peerConnection(_: RTCPeerConnection, didRemove _: [RTCIceCandidate]) {}
    func peerConnection(_: RTCPeerConnection, didOpen _: RTCDataChannel) {}
}

