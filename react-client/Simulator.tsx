import React, { useRef, useEffect, useMemo, useState } from "react";
import socketIOClient from "socket.io-client";
import SimulatorWindow from "../components/SimulatorWindow";
import Status from "../components/Status";
import throttle from "lodash.throttle";
const ENDPOINT = "http://192.168.0.101:3333";
const FRAMERATE = 41; //24FPS

const Simulator = () => {
  let socket = useRef<SocketIOClient.Socket | null>(null);

  const [isMouseDown, setIsMouseDown] = useState(false);

  useEffect(() => {
    socket.current = socketIOClient(ENDPOINT);
    return () => {
      socket.current?.disconnect();
    };
  }, []);

  const onMouseMove = useMemo(() => {
    const throttled = throttle((element: React.MouseEvent<HTMLDivElement>) => {
      if (!isMouseDown) {
        return;
      }
      element.preventDefault();
      if (
        element.nativeEvent.offsetX === 0 &&
        element.nativeEvent.offsetY === 0
      ) {
        return;
      } //HACK!

      const payload =
        '{"e":"2","x":' +
        element.nativeEvent.offsetX +
        ',"y":' +
        (640 - element.nativeEvent.offsetY) +
        "}";
      // console.log(payload);
      socket.current?.emit("event", payload);
    }, FRAMERATE);
    return (element: React.MouseEvent<HTMLDivElement>) => {
      element.persist();
      return throttled(element);
    };
  }, [isMouseDown]);

  const onMouseDown = (element: React.MouseEvent<HTMLDivElement>) => {
    element.preventDefault();
    setIsMouseDown(true);
    const payload =
      '{"e":"0","x":' +
      element.nativeEvent.offsetX +
      ',"y":' +
      (640 - element.nativeEvent.offsetY) +
      "}";
    socket.current?.emit("event", payload);
  };

  const onMouseUp = (element: React.MouseEvent<HTMLDivElement>) => {
    setIsMouseDown(false);
    const payload =
      '{"e":"1","x":' +
      element.nativeEvent.offsetX +
      ',"y":' +
      (640 - element.nativeEvent.offsetY) +
      "}";
    socket.current?.emit("event", payload);
  };

  const onMouseLeave = (element: React.MouseEvent<HTMLDivElement>) => {
    setIsMouseDown(false);
    const payload =
      '{"e":"1","x":' +
      element.nativeEvent.offsetX +
      ',"y":' +
      (640 - element.nativeEvent.offsetY) +
      "}";
    socket.current?.emit("event", payload);
  };

  // KeyCodes to skip
  // shift	16
  // ctrl	17
  // alt	18
  // pause/break	19
  // caps lock	20
  // escape	27
  // page up	33
  // page down	34
  // end	35
  // home	36
  // print screen	44
  // insert	45
  // delete	46
  // left window key	91
  // right window key	92
  // meta	93

  const skipEventKeys = [
    16, 17, 18, 27, 93, 91, 92, 19, 20, 33, 34, 35, 36, 44, 45, 46,
  ];
  const skipLookup = Object.assign(
    {},
    ...skipEventKeys.map((num) => ({ [num]: true }))
  );
  type Dict = { [key: string]: string };
  const keysMap: Dict = {
    Digit0: "029",
    Digit1: "018",
    Digit2: "019",
    Digit3: "020",
    Digit4: "021",
    Digit5: "023",
    Digit6: "022",
    Digit7: "026",
    Digit8: "028",
    Digit9: "025",
    KeyA: "000",
    KeyB: "011",
    KeyC: "008",
    KeyD: "002",
    KeyE: "014",
    KeyF: "003",
    KeyG: "005",
    KeyH: "004",
    KeyI: "034",
    KeyJ: "038",
    KeyK: "040",
    KeyL: "037",
    KeyM: "046",
    KeyN: "045",
    KeyO: "031",
    KeyP: "035",
    KeyQ: "012",
    KeyR: "015",
    KeyS: "001",
    KeyT: "017",
    KeyU: "032",
    KeyV: "009",
    KeyW: "013",
    KeyX: "007",
    KeyY: "016",
    KeyZ: "006",
    SectionSign: "010",
    Backquote: "050",
    Minus: "027",
    Equal: "024",
    BracketLeft: "033",
    BracketRight: "030",
    Semicolon: "041",
    Quote: "039",
    Comma: "043",
    Period: "047",
    Slash: "044",
    Backslash: "042",
    Numpad0: "082",
    Numpad1: "083",
    Numpad2: "084",
    Numpad3: "085",
    Numpad4: "086",
    Numpad5: "087",
    Numpad6: "088",
    Numpad7: "089",
    Numpad8: "091",
    Numpad9: "092",
    NumpadDecimal: "065",
    NumpadMultiply: "067",
    NumpadPlus: "069",
    NumpadDivide: "075",
    NumpadMinus: "078",
    NumpadEquals: "081",
    NumpadClear: "071",
    NumpadEnter: "076",
    Space: "049",
    Enter: "036",
    Tab: "048",
    LeftArrow: "123",
    RightArrow: "124",
    DownArrow: "125",
    UpArrow: "126",
  };

  const onKeyDown = (element: React.KeyboardEvent<HTMLDivElement>) => {
    if (skipLookup[element.keyCode]) {
      return;
    }
    const keyCode = keysMap[element.code];
    if (!keyCode) {
      return;
    }

    const payload =
      '{"e":"3","k":"' +
      keyCode +
      '","s":' +
      (element.shiftKey ? '1,"a":' : '0,"a":') +
      (element.altKey ? "1}" : "0}");
    socket.current?.emit("event", payload);
  };

  return (
    <main className="max-w-screen-xl m-auto">
      <div className="flex flex-col items-center">
        <SimulatorWindow
          onMouseDown={onMouseDown}
          onMouseUp={onMouseUp}
          onMouseMove={onMouseMove}
          onMouseLeave={onMouseLeave}
          onKeyDown={onKeyDown}
        />
        <Status />
      </div>
    </main>
  );
};

export default Simulator;
