let stringEqual = (~message=?, a: string, b: string) =>
  Test.assertion(~message?, ~operator="stringEqual", (a, b) => a == b, a, b)
