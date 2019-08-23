import {Socket} from "phoenix"

let socket = new Socket("ws://localhost:4100/socket", {
  params: {token: window.userToken},
  logger: (kind, msg, data) => { console.log(`${kind}: ${msg}`, data) }
})
export default socket
