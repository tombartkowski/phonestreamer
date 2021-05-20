const express = require("express");
const app = express();
const http = require("http");
const printf = require("printf");
const cors = require("cors");
app.use(cors());

const { spawn } = require("child_process");
const simulatorsManager = spawn("SimulatorsManager");
simulatorsManager.stdout.on("data", (data) => {
  console.log(`${data}`);
});
simulatorsManager.stderr.on("error", (data) => {
  console.log(`${data}`);
});
simulatorsManager.stdin.write("yCN5_u9\n");

const server = http.createServer(app);
const { Server } = require("socket.io");
const io = new Server(server, {
  cors: {
    origin: "*",
  },
});

const SimulatorWindowSize = {
  width: 360,
  height: 677,
};
const MainScreenHeight = 1050;

const transformXCoordinate = (x) => printf("%07.2f", x);
const transformYCoordinate = (y) =>
  printf("%07.2f", y + (MainScreenHeight - SimulatorWindowSize.height));

const transformYCoordinateDrag = (y) =>
  printf("%07.2f", y - 23 + (MainScreenHeight - SimulatorWindowSize.height));

io.on("connection", (socket) => {
  console.log("Connected socket client");
  socket.on("event", (rawPayload) => {
    const payload = JSON.parse(rawPayload);
    let event = "";
    switch (payload.e) {
      case "0":
        event =
          "yCN5_u0" +
          transformXCoordinate(payload.x) +
          transformYCoordinate(payload.y);
        break;
      case "1":
        event =
          "yCN5_u1" +
          transformXCoordinate(payload.x) +
          transformYCoordinate(payload.y);
        break;

      case "2":
        event =
          "yCN5_u2" +
          transformXCoordinate(payload.x) +
          transformYCoordinateDrag(payload.y);
        break;
      case "3":
        event = "yCN5_u3" + payload.k + payload.s + payload.a;
        break;
    }

    simulatorsManager.stdin.write(event + "\n");
  });
});

server.listen(3333, () => {
  console.log("Listening on *:3333");
});
