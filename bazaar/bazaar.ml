open Riot
open Trail

open Riot.Logger.Make (struct
  let namespace = [ "bazaar" ]
end)

module Echo_server = struct
  type args = unit
  type state = int

  let init _args =
    info (fun f -> f "initialized echo server");
    Channel_manager.register (self ()) ~channel:"twitch";
    `ok 0

  type Message.t += Broadcast of Frame.t

  let handle_frame frame _conn state =
    info (fun f -> f "handling frame: %a" Trail.Frame.pp frame);
    Channel_manager.broadcast (Broadcast frame) ~channel:"twitch";
    `push ([], state)

  let handle_message msg state =
    match msg with
    | Broadcast frame -> `push ([ frame ], state)
    | _ -> `ok state
end

module SearchEngine = struct
  open Serde

  type search_response = { query : string; results : int }
  [@@deriving serializer]

  let run_query query = { query = Bytestring.to_string query; results = 0 }
end

module SearchController = struct
  let[@warning "-8"] search conn =
    let (Conn.Ok (conn, body)) = conn |> Conn.read_body in
    let results = SearchEngine.run_query body in
    let json =
      results
      |> Serde_json.to_string_pretty SearchEngine.serialize_search_response
      |> Result.get_ok |> Bytestring.of_string
    in
    conn |> Conn.send_response `OK json
end

module TestStore = Store.Make (struct
  type key = string
  type value = string
end)

module StoreController = struct
  open Serde

  type store_get_result = { value : string } [@@deriving serializer]

  let get (conn : Conn.t) =
    let store = Process.where_is "store" |> Option.get in
    let key = conn.params |> List.assoc "key" in
    let value =
      { value = TestStore.get store key |> Option.value ~default:"" }
    in
    let json =
      value
      |> Serde_json.to_string_pretty serialize_store_get_result
      |> Result.get_ok |> Bytestring.of_string
    in
    conn |> Conn.send_response `OK json

  let put (conn : Conn.t) =
    let store = Process.where_is "store" |> Option.get in
    let key = conn.params |> List.assoc "key" in
    let[@warning "-8"] (Conn.Ok (conn, value)) = Conn.read_body conn in
    TestStore.put store key (Bytestring.to_string value);
    conn |> Conn.send_response `OK {%b||}
end

module Endpoint = struct
  let hello_world = {%b|"hello world!"|}

  let trail =
    let open Router in
    [
      use (module Logger) Logger.(args ~level:Debug ());
      router
        [
          get "/" (fun conn -> Conn.send_response `OK hello_world conn);
          post "/search" SearchController.search;
          socket "/ws" (module Echo_server) ();
          scope "/store"
            [ get "/:key" StoreController.get; put "/:key" StoreController.put ];
          scope "/api"
            [
              get "/version" (fun conn ->
                  Conn.send_response `OK {%b|"none"|} conn);
            ];
        ];
    ]

  let start_link () =
    let store = TestStore.start_link () |> Result.get_ok in
    register "store" store;
    let handler = Nomad.trail trail in
    Nomad.start_link ~port:8080 ~handler ()
end

module BazaarApp = struct
  open Supervisor

  let start () =
    set_log_level (Some Trace);
    (* Runtime.Stats.start ~every:1_000_000L (); *)
    start_link
      ~child_specs:
        [
          child_spec Endpoint.start_link ();
          child_spec Channel_manager.start_link ();
        ]
      ()
end

let () = Riot.start ~apps:[ (module Riot.Logger); (module BazaarApp) ] ()
