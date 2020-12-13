module Spread = {
  @react.component
  let make = (~props, ~children) => React.cloneElement(children, props)
}

module LoadingPage = {
  open ReactDOM
  let containerStyle = Style.make(
    ~height="100vh",
    ~width="100vw",
    ~display="flex",
    ~justifyContent="center",
    ~marginTop="16px",
    (),
  )

  @react.component
  let make = (~message) => {
    <section style=containerStyle> <h2> {message->React.string} </h2> </section>
  }
}

module Header = {
  open ReactDOM

  let headerStyle = Style.make(
    ~display="flex",
    ~alignItems="center",
    ~padding="4px 16px",
    ~backgroundColor="white",
    ~borderBottom="1px solid #eee",
    (),
  )

  let imageStyle = Style.make(~height="40px", ~width="40px", ())

  let logoTextStyle = Style.make(~fontSize="22px", ~color="black", ())

  @react.component
  let make = () => {
    <div style=headerStyle>
      <img src="/src/assets/logo.svg" style=imageStyle />
      <span style=logoTextStyle> {"-stagram"->Js.String2.toUpperCase->React.string} </span>
    </div>
  }
}

module PostListItem = {
  open ReactDOM

  let containerStyle = Style.make(~padding="4px", ~margin="4px", ())
  let imageStyle = Style.make(
    ~width="100%",
    ~height="100%",
    ~objectFit="cover",
    ~borderRadius="8px",
    (),
  )

  @react.component
  let make = (~url, ~id) => {
    <article style=containerStyle>
      <Spread props={"data-id": id}> <img src=url style=imageStyle /> </Spread>
    </article>
  }
}

module SinglePost = {
  open ReactDOM

  let containerStyle = Style.make(
    ~width="100%",
    ~height="100%",
    ~padding="8px 16px",
    ~boxSizing="border-box",
    (),
  )
  let imageStyle = Style.make(
    ~objectFit="cover",
    ~width="100%",
    ~height="100%",
    ~borderRadius="8px",
    (),
  )
  let buttonStyle = Style.make(
    ~padding="8px 16px",
    ~backgroundColor="white",
    ~border="1px solid #ccc",
    ~borderRadius="8px",
    ~marginBottom="8px",
    (),
  )

  @react.component
  let make = (~imageUrl) => {
    <article style=containerStyle>
      <button style=buttonStyle onClick={_ => {ReasonReactRouter.push("/")}}>
        {"Go back"->React.string}
      </button>
      <img src=imageUrl style=imageStyle />
    </article>
  }
}

module PostList = {
  open ReactDOM

  let containerStyle = Style.make(
    ~display="grid",
    ~gridTemplateColumns="repeat(auto-fit, minmax(200px, 1fr))",
    ~gridTemplateRows="repeat(4, 200px)",
    ~padding="8px",
    (),
  )

  @react.component
  let make = (~imageUrls, ~handleClick) => {
    <section style=containerStyle onClick=handleClick>
      {imageUrls
      ->Js.Array2.mapi((imageUrl, idx) =>
        <PostListItem url=imageUrl key={idx->Js.Int.toString} id=idx />
      )
      ->React.array}
    </section>
  }
}

module Content = {
  @react.component
  let make = (~imageUrls) => {
    let currentUrl = ReasonReactRouter.useUrl()

    let handleClick = React.useCallback(event => {
      let targetElem = event->ReactEvent.Mouse.target
      let idx = targetElem["dataset"]["id"]
      let tagName = targetElem["tagName"]

      if tagName === "IMG" {
        ReasonReactRouter.push(`/post/${idx}`)
      }
    })

    <section>
      {switch currentUrl.path {
      | list{"post", idx} =>
        <SinglePost
          imageUrl={imageUrls[
            switch Belt.Int.fromString(idx) {
            | Some(idx) => idx
            | None => Js.Exn.raiseError("Could not convert string to integer")
            }
          ]}
        />
      | list{} => <PostList imageUrls handleClick />
      | _ => <div> {"404 Not Found"->React.string} </div>
      }}
    </section>
  }
}
