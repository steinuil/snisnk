open Test
open SignalR.Message

let encode = (codec, val) => Jzon.encodeString(codec, val)
let decode = (codec, str) => Jzon.decodeString(codec, str)->Belt.Result.getExn

let equal = (~message=?, a, b) =>
  Test.assertion(~message?, ~operator="equal", (a, b) => a == b, a, b)

test("encode", () => {
  Handshake.request->Assert.stringEqual(
    ~message="HandshakeRequest",
    `{"protocol":"json","version":1}\x1E`,
  )

  message->encode(Ping)->Assert.stringEqual(~message="Ping", `{"type":6}`)
})

test("decode", () => {
  Handshake.decode(`{"error":"Requested protocol 'messagepack' is not available."}\x1E`)
  ->Belt.Result.getExn
  ->equal(~message="HandshakeResponse", Some("Requested protocol 'messagepack' is not available."))

  message
  ->decode(`{
    "type": 1,
    "invocationId": "123",
    "target": "Send",
    "arguments": [
        42,
        "Test Message"
    ]
	}`)
  ->equal(
    ~message="Invocation",
    Invocation({
      invocationId: Some("123"),
      target: "Send",
      arguments: [Js.Json.number(42.0), Js.Json.string("Test Message")],
      streamIds: None,
    }),
  )

  message
  ->decode(`{
    "type": 1,
    "target": "Send",
    "arguments": [
        42,
        "Test Message"
    ]
	}`)
  ->equal(
    ~message="Invocation Non-Blocking",
    Invocation({
      invocationId: None,
      target: "Send",
      arguments: [Js.Json.number(42.0), Js.Json.string("Test Message")],
      streamIds: None,
    }),
  )

  message
  ->decode(`{
    "type": 1,
    "invocationId": "123",
    "target": "Send",
    "arguments": [
        42
    ],
    "streamIds": [
        "1"
    ]
	}`)
  ->equal(
    ~message="Invocation with stream from Caller",
    Invocation({
      invocationId: Some("123"),
      target: "Send",
      arguments: [Js.Json.number(42.0)],
      streamIds: Some(["1"]),
    }),
  )

  message
  ->decode(`{
    "type": 4,
    "invocationId": "123",
    "target": "Send",
    "arguments": [
        42,
        "Test Message"
    ]
	}`)
  ->equal(
    ~message="StreamInvocation",
    StreamInvocation({
      invocationId: Some("123"),
      target: "Send",
      arguments: [Js.Json.number(42.0), Js.Json.string("Test Message")],
      streamIds: None,
    }),
  )

  message
  ->decode(`{
    "type": 2,
    "invocationId": "123",
    "item": 42
	}`)
  ->equal(
    ~message="StreamItem",
    StreamItem({
      invocationId: "123",
      item: Js.Json.number(42.0),
    }),
  )

  message
  ->decode(`{
    "type": 3,
    "invocationId": "123"
	}`)
  ->equal(
    ~message="Completion with no result or error",
    Completion({
      invocationId: "123",
      value: None,
    }),
  )

  message
  ->decode(`{
    "type": 3,
    "invocationId": "123",
		"result": 42
	}`)
  ->equal(
    ~message="Completion with a result",
    Completion({
      invocationId: "123",
      value: Some(Ok(Js.Json.number(42.0))),
    }),
  )

  message
  ->decode(`{
    "type": 3,
    "invocationId": "123",
    "error": "It didn't work!"
	}`)
  ->equal(
    ~message="Completion with an error",
    Completion({
      invocationId: "123",
      value: Some(Error("It didn't work!")),
    }),
  )

  message
  ->decode(`{
    "type": 5,
    "invocationId": "123"
	}`)
  ->equal(~message="CancelInvocation", CancelInvocation({invocationId: "123"}))

  message
  ->decode(`{
    "type": 6
	}`)
  ->equal(~message="Ping", Ping)

  message
  ->decode(`{
    "type": 7
	}`)
  ->equal(~message="Close without an error", Close({error: None, allowReconnect: None}))

  message
  ->decode(`{
    "type": 7,
    "error": "Connection closed because of an error!"
	}`)
  ->equal(
    ~message="Close with an error",
    Close({error: Some("Connection closed because of an error!"), allowReconnect: None}),
  )

  message
  ->decode(`{
    "type": 7,
    "error": "Connection closed because of an error!",
    "allowReconnect": true
	}`)
  ->equal(
    ~message="Close with an error that allows automatic client reconnects",
    Close({error: Some("Connection closed because of an error!"), allowReconnect: Some(true)}),
  )
})
