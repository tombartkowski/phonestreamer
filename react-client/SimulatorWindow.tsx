import React, { useRef, useEffect } from "react";

type SimulatorWindowProps = {
  onMouseDown: (element: React.MouseEvent<HTMLDivElement>) => void;
  onMouseUp: (element: React.MouseEvent<HTMLDivElement>) => void;
  onMouseMove: (element: React.MouseEvent<HTMLDivElement>) => void;
  onMouseLeave: (element: React.MouseEvent<HTMLDivElement>) => void;
  onKeyDown: (element: React.KeyboardEvent<HTMLDivElement>) => void;
};

const SimulatorWindow = ({
  onMouseDown,
  onMouseMove,
  onMouseUp,
  onMouseLeave,
  onKeyDown,
}: SimulatorWindowProps) => {
  const imageRef = useRef<HTMLImageElement | null>(null);
  useEffect(() => {
    const websocket = new WebSocket("ws://192.168.0.101:8000");
    const rtcpeerconn = new RTCPeerConnection({
      iceServers: [{ urls: ["stun:stun.l.google.com:19302"] }],
    });
    let dataChannel: RTCDataChannel;

    rtcpeerconn.onicecandidate = (event) => {
      if (!event || !event.candidate) return;
      websocket.send(
        JSON.stringify({
          inst: "send",
          peerId: "Simulator",
          message: event,
        })
      );
    };

    rtcpeerconn.ondatachannel = (event) => {
      dataChannel = event.channel;
      dataChannel.onmessage = (event) => {
        const image = imageRef.current;
        if (!image) {
          return;
        }
        image.src = URL.createObjectURL(
          new Blob([event.data], { type: "image/png" } /* (1) */)
        );
      };
      dataChannel.onopen = () => {};
      dataChannel.onclose = () => {};
    };
    websocket.onopen = () => {
      websocket.send(
        JSON.stringify({
          inst: "init",
          id: "React",
        })
      );
    };

    websocket.onmessage = (input) => {
      const message = JSON.parse(input.data);
      if (message.type && message.type === "offer") {
        const offer = new RTCSessionDescription(message);
        rtcpeerconn.setRemoteDescription(offer).then(() => {
          rtcpeerconn.createAnswer().then((answer) => {
            rtcpeerconn.setLocalDescription(answer).then(() => {
              const temp = new RTCSessionDescription(answer).toJSON();
              websocket.send(
                JSON.stringify({
                  inst: "send",
                  peerId: "Simulator",
                  message: temp,
                })
              );
            });
          });
        });
      } else if (rtcpeerconn.remoteDescription) {
        rtcpeerconn.addIceCandidate({
          candidate: String(message.candidate),
          sdpMid: String(message.id),
          sdpMLineIndex: message.label,
        });
      }
    };

    return () => {};
  }, []);

  return (
    <img
      onMouseDown={onMouseDown}
      onMouseMove={onMouseMove}
      onMouseLeave={onMouseLeave}
      onMouseUp={onMouseUp}
      ref={imageRef}
      onKeyDown={onKeyDown}
      style={{ width: 360, height: 640 }}
      className=" shadow-2xl bg-gray-700 rounded-2xl cursor-pointer focus:outline-none focus:bg-gray-600 transition duration-75"
      tabIndex={-1}
    ></img>
  );
};

export default SimulatorWindow;
