@react.component
let make = (~padding=?, ~backgroundColor=?, ~style=?, ~children) => {
  let style = ReactDOM.Style.combine(
    ReactDOM.Style.make(~padding?, ~backgroundColor?, ()),
    style->Belt.Option.getWithDefault(ReactDOM.Style.make()),
  )

  <div style> {children} </div>
}
