let tryMap = (array, f) => {
  let out = []

  let break = ref(false)
  let i = ref(0)

  while i.contents < Js.Array.length(array) && !break.contents {
    switch f(array[i.contents]) {
    | Some(item) => out->Js.Array2.push(item)->ignore
    | None => break := true
    }
    incr(i)
  }

  if break.contents {
    None
  } else {
    Some(out)
  }
}
