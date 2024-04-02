local frame = require'lib.websocket.frame'

return {
  client = require'lib.websocket.client',
  server = require'lib.websocket.server',
  CONTINUATION = frame.CONTINUATION,
  TEXT = frame.TEXT,
  BINARY = frame.BINARY,
  CLOSE = frame.CLOSE,
  PING = frame.PING,
  PONG = frame.PONG
}
