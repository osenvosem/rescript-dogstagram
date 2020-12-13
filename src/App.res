@val external doc: 'a = "document"

// global styles
let styleElem = doc["createElement"]("style")
styleElem["innerText"] = `
  body {
    margin: 0;
    font-family: "Alegreya Sans", sans-serif;
  }
`
doc["head"]["appendChild"](styleElem)

// font
let linkElem = doc["createElement"]("link")
linkElem["rel"] = "stylesheet"
linkElem["href"] = `https://fonts.googleapis.com/css2?family=Alegreya+Sans:wght@100&display=swap`
doc["head"]["appendChild"](linkElem)

let url = "https://dog.ceo/api/breeds/image/random/12"

type dogApiResponse = {
  status: string,
  message: array<string>,
}

type requestStatus =
  | Loading
  | ReqError
  | Success(dogApiResponse)

module Decode = {
  open Json.Decode
  let dogData = data => {
    status: field("status", string, data),
    message: field("message", array(string), data),
  }
}

@react.component
let make = () => {
  open Components

  let (data, setData) = React.useState(() => Loading)

  React.useEffect0(() => {
    Fetch.fetch(url)->Js.Promise.then_(Fetch.Response.json, _)->Js.Promise.then_(data => {
      let decodedData = data->Decode.dogData
      setData(_ => Success(decodedData))
      Js.Promise.resolve()
    }, _)->ignore

    None
  })

  switch data {
  | Loading => <LoadingPage message="Loading dogs..." />
  | ReqError => <div> {"Can't get dogs :("->React.string} </div>
  | Success(data) => <section> <Header /> <Content imageUrls=data.message /> </section>
  }
}
