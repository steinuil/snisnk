module Message = {
  type token = Js.Json.t

  type handshakeRequest = {
    protocol: string,
    version: int,
  }

  type invocation = {
    invocationId: option<string>,
    target: string,
    arguments: array<token>,
    streamIds: option<array<string>>,
  }

  type streamItem = {
    invocationId: string,
    item: token,
  }

  type completion = {
    invocationId: string,
    value: option<result<token, string>>,
  }

  type close = {
    error: option<string>,
    allowReconnect: option<bool>,
  }

  type t =
    | Invocation(invocation)
    | StreamInvocation(invocation)
    | StreamItem(streamItem)
    | Completion(completion)
    | CancelInvocation({invocationId: string})
    | Ping
    | Close(close)

  let handshakeRequest = Jzon.object2(
    ({protocol, version}) => (protocol, version),
    ((protocol, version)) => Ok({protocol: protocol, version: version}),
    Jzon.field("protocol", Jzon.string),
    Jzon.field("version", Jzon.int),
  )

  let handshakeResponse = Jzon.object1(
    error => error,
    error => Ok(error),
    Jzon.field("error", Jzon.string)->Jzon.optional,
  )

  let invocation = Jzon.object4(
    ({invocationId, target, arguments, streamIds}) => (invocationId, target, arguments, streamIds),
    ((invocationId, target, arguments, streamIds)) => Ok({
      invocationId: invocationId,
      target: target,
      arguments: arguments,
      streamIds: streamIds,
    }),
    Jzon.field("invocationId", Jzon.string)->Jzon.optional,
    Jzon.field("target", Jzon.string),
    Jzon.field("arguments", Jzon.array(Jzon.json)),
    Jzon.field("streamIds", Jzon.array(Jzon.string))->Jzon.optional,
  )

  let streamItem = Jzon.object2(
    ({invocationId, item}) => (invocationId, item),
    ((invocationId, item)) => Ok({invocationId: invocationId, item: item}),
    Jzon.field("invocationId", Jzon.string),
    Jzon.field("item", Jzon.json),
  )

  let completion = Jzon.object3(
    ({invocationId, value}) =>
      switch value {
      | Some(Ok(result)) => (invocationId, Some(result), None)
      | Some(Error(error)) => (invocationId, None, Some(error))
      | None => (invocationId, None, None)
      },
    ((invocationId, result, error)) => Ok(
      switch (result, error) {
      | (None, None) => {invocationId: invocationId, value: None}
      | (Some(result), _) => {invocationId: invocationId, value: Some(Ok(result))}
      | (_, Some(error)) => {invocationId: invocationId, value: Some(Error(error))}
      },
    ),
    Jzon.field("invocationId", Jzon.string),
    Jzon.field("result", Jzon.json)->Jzon.optional,
    Jzon.field("error", Jzon.string)->Jzon.optional,
  )

  let cancelInvocation = Jzon.object1(
    invocationId => invocationId,
    invocationId => Ok(invocationId),
    Jzon.field("invocationId", Jzon.string),
  )

  let close = Jzon.object2(
    ({error, allowReconnect}) => (error, allowReconnect),
    ((error, allowReconnect)) => Ok({error: error, allowReconnect: allowReconnect}),
    Jzon.field("error", Jzon.string)->Jzon.optional,
    Jzon.field("allowReconnect", Jzon.bool)->Jzon.optional,
  )

  let message: Jzon.codec<t> = Jzon.object2(
    type_ =>
      switch type_ {
      | Invocation(v) => (1, v->Jzon.encodeWith(invocation))
      | StreamInvocation(v) => (4, v->Jzon.encodeWith(invocation))
      | StreamItem(v) => (2, v->Jzon.encodeWith(streamItem))
      | Completion(v) => (3, v->Jzon.encodeWith(completion))
      | CancelInvocation({invocationId}) => (5, invocationId->Jzon.encodeWith(cancelInvocation))
      | Ping => (6, Js.Json.parseExn("{}"))
      | Close(v) => (7, v->Jzon.encodeWith(close))
      },
    ((type_, json)) =>
      switch type_ {
      | 1 => json->Jzon.decodeWith(invocation)->Belt.Result.map(i => Invocation(i))
      | 4 => json->Jzon.decodeWith(invocation)->Belt.Result.map(i => StreamInvocation(i))
      | 2 => json->Jzon.decodeWith(streamItem)->Belt.Result.map(i => StreamItem(i))
      | 3 => json->Jzon.decodeWith(completion)->Belt.Result.map(c => Completion(c))
      | 5 =>
        json
        ->Jzon.decodeWith(cancelInvocation)
        ->Belt.Result.map(v => CancelInvocation({invocationId: v}))
      | 6 => Ok(Ping)
      | 7 => json->Jzon.decodeWith(close)->Belt.Result.map(v => Close(v))
      | n => Error(#UnexpectedJsonValue([Field("type")], n->Belt.Int.toString))
      },
    Jzon.field("type", Jzon.int),
    Jzon.self,
  )
}
