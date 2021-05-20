

# PhoneStreamer

https://user-images.githubusercontent.com/82748596/118924323-35b30380-b93d-11eb-835e-8da898fc8830.mp4

PhoneStreamer is a proof of concept of a high performance, low latency cloud iOS Simulator. Under the hood it uses [WebRTC](https://webrtc.org/) for screen streaming, WebSockets for passing input and low level macOS API to communicate with the Simulator process. 

# How it works

### React web client

The entry point is a React web client set up with [create-react-app](https://create-react-app.dev/). 

Here's how it works.

1. Connect to `webrtc-signaling-server` using WebSockets and signal readiness to estabilish a peer-to-peer connection. 
2. Connect to `socket-server` to deliver input events using Socket.io.
3. Wait for WebRTC `offer` from `webrtc-output-broadcaster` to estabilish a data channel connection.
4. Listen for mouse and keyboard events on the Simulator DOM element and push them to `socket-server`.
5. Draw frames broadcasted from `webrtc-output-broadcaster`. 

### Input socket server

Input socket server is a NodeJS server based on [Express.js](https://expressjs.com/) and [Socket.io](https://socket.io/) responsible for transfering data from a React client to the `input-coordinator` process.

Here's how it works.

1. Spawn and keep a reference to the `input-coordinator` process. 
2. Listen for input events from React client. The event has a `SIMULATOR_ID{0,1,2,3}{PAYLOAD}` format.
  - `SIMULATOR_ID` is a 6 characters-long identifier of a simulator that the event should be delivered to,
  - `{0,1,2,3}` specifies the event type. It translates to either `TOUCH_DOWN`, `TOUCH_UP`, `TOUCH_MOVE` or `KEY_DOWN`,
  - `{PAYLOAD}` can be for example `0200.500300.00` to specify a x=200.50 y=300 coordinate of a touch, or `056` to specify a key code of pressed key.
4. Transform the coordinates of React client to correct coordinates of the Simulator's window.
5. Pipe the input event to `stdin` of the `input-coordinator`.

### Input coordinator

Input coordinator is a macOS command line tool written in Swift responsible for spawning `input-bridges` and making sure the incoming events are correctly delivered.

Here's how it works.

1. Listen for input events delivered by `input-socket-server`.
2. Launch simulators by executing a `xcrun simctl boot {SIMULATOR_ID}` command if needed.
3. Spawn `input-bridge` and store the `stdin` Pipe reference if needed.
4. On a touch event pass the input event directly to the `input-bridge` `stdin`.
5. Keyboard events require Simulator app to be active and the specific Simulator window to be the `main` window.
  - Activate the Simulator `NSRunningApplication` if it isn't already active by calling 
  ```swift
  func activate(options: NSApplication.ActivationOptions = []) -> Bool
  ```
  - Make the window a main window by using the accessiblity API
  ```swift
  AXUIElementSetAttributeValue(
    window,
    kAXMainAttribute as CFString,
    kCFBooleanTrue as CFTypeRef
  )
   ```
  - Deliver the keyboard input event to the `input-bridge`.

### Input bridge

Input bridge is a macOS command line tool written in Swift responsible for delivering input events to the Simulator. Each running Simulator has it's own bridge.

Here's how it works.

1. Listen for input events delivered by `input-coordinator`.
2. Parse and send the `CGEvent` to the Simulator process. 
  - For keyboard events:
  ```swift
  let source = CGEventSource(stateID: .hidSystemState)
  let event = CGEvent(
    keyboardEventSource: source,
    virtualKey: CGKeyCode(keyCode),
    keyDown: true
  )
  event?.postToPid({SIMULATOR_PID})
  ```
  - For touch events:
  ```swift
  let nsEvent = NSEvent.mouseEvent(
    with: touchType.eventType,
    location: NSPoint(x: location.x, y: location.y),
    modifierFlags: .init(rawValue: 0),
    timestamp: ProcessInfo.processInfo.systemUptime,
    windowNumber: windowNumber,
    context: nil,
    eventNumber: 0,
    clickCount: touchType.clickCount,
    pressure: touchType.pressure
  )
  nsEvent?.cgEvent?.postToPid({SIMULATOR_PID})
   ```

