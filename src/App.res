@react.component
let make = () => {
  let (state, setState) = React.useState(() => "")

  React.useEffect0(() => {
    Webapi.Fetch.fetch("http://192.168.1.24:5000/session")
    ->Promise.then(Webapi.Fetch.Response.text)
    ->Promise.thenResolve(resp => {
      Js.log(resp)
    })
    ->ignore

    None
  })

  <Box> {React.string("ayy lmao")} </Box>
}
