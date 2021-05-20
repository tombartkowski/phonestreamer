const server = require("http").createServer();
const express = require("express");
const app = express();
const WebSocketServer = require("ws").Server;
const wss = new WebSocketServer({ server: server, port: 8000 });

let clientMap = {};

wss.on("connection", function (ws) {
  console.log("connected client");
  ws.on("message", function (inputStr) {
    var input = JSON.parse(inputStr);
    if (input.inst == "init") {
      clientMap[input.id] = ws;
    } else if (input.inst == "send") {
      clientMap[input.peerId].send(JSON.stringify(input.message));
    }
  });
});

server.on("request", app);
server.listen(8888, function () {
  console.log("Listening on " + server.address().port);
});
