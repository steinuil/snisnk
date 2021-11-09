@react.component
let make = () => {
  React.useEffect0(() => {
    Webapi.Fetch.fetch("http://192.168.1.24:5000/session")
    ->Promise.then(Webapi.Fetch.Response.text)
    ->Promise.thenResolve(resp => {
      Js.log(resp)
    })
    ->ignore

    let (_, _) = SignalR.connectHub("ws://192.168.1.24:5000/hub/application")

    None
  })

  <Box> {React.string("ayy lmao")} </Box>
}
