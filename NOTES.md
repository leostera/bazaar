* routing:

```ocaml
let api_trail = Trail.[
  accept json;
  auth tokens;
]
in

scope "/api" ~pipe_through:api_trail [
  scope "/v1" [
    get "/hello/:name" Hello_controller.hello;
    post "/customer" Customer_controller.create;
    resources "/posts" (module Post_controller)
  ]
  any "/" Api.help
]
```

```sh
; curl 0.0.0.0:2112/api/v1/hello/world
```

```ocaml

type route =
    | Home of home_routes option
    | Secure
    | NotFound

and home_routes = 
    | My_profile
    | Settings

```

## Tue Jan 23 03:11:39 CET 2024

https
listen on 12121

files:
    /video_overlay.html
    /config.html

