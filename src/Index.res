@val @scope("document") external getElementById: string => Dom.element = "getElementById"

let rootElem = getElementById("root")

ReactDOMRe.render(<App />, rootElem)
