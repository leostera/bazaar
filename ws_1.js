const WebSocket = require("ws")

let ws = new WebSocket("ws://0.0.0.0:8080/ws")

ws.on("open", () => {
  console.log("opened");
  setInterval(() => {
    console.log(".");
    ws.send("goobye world 🌸")
  }, 500);
})

ws.on("close", () => {
  console.log("closed")
})

ws.on("error", (err) => {
  console.error("error", err);
})

ws.on("message", (msg) => {
  console.log("recv: ", msg.toString());
})
