open Js

module DOM = struct
  external magic : 'a -> 'b = "%identity"

  module Location = struct
    type t

    external protocol : t -> string = "protocol" [@@mel.get]
    external host : t -> string = "host" [@@mel.get]
  end

  module Window = struct
    type t

    external window : t = "window"
    external location : t -> Location.t = "location" [@@mel.get]
  end

  module Event = struct
    type t

    external data : t -> string = "data" [@@mel.get]
    external parse : string -> 'a = "JSON.parse"
    external getAttribute : t -> string -> string = "getAttribute" [@@mel.send]
  end

  module WebSocket = struct
    type t

    external make : string -> t = "WebSocket" [@@mel.new]
    external send : t -> string -> unit = "send" [@@mel.send]

    external addEventListener : t -> string -> (Event.t -> unit) -> unit
      = "addEventListener"
    [@@mel.send]
  end

  module Element = struct
    type t

    external innerHTML : t -> string -> unit = "innerHTML" [@@mel.set]

    external addEventListener : t -> string -> (Event.t -> unit) -> unit
      = "addEventListener"
    [@@mel.send]

    external querySelectorAll : t -> string -> t array = "querySelectorAll"
    [@@mel.send]

    external getAttribute : t -> string -> string = "getAttribute" [@@mel.send]
  end

  module Document = struct
    type t

    external document : t = "document"
    external readyState : t -> string = "readyState" [@@mel.get]

    external addEventListener : t -> string -> (unit -> unit) -> unit
      = "addEventListener"
    [@@mel.send]

    external getElementById : t -> string -> Element.t = "getElementById"
    [@@mel.send]

    external querySelector : t -> string -> Element.t = "querySelector"
    [@@mel.send]
  end

  module MutationObserver = struct
    type t
    type mutation_list
    type observer
    type config = { attributes : bool; childList : bool; subtree : bool }

    external make : ((mutation_list -> observer -> unit)[@u]) -> t
      = "MutationObserver"
    [@@mel.new]

    external observe : t -> Element.t -> config -> unit = "observe" [@@mel.send]
  end
end

module Trail = struct
  module type Sock = sig
    type t

    val init : (string -> t[@u])
    val connect : (t -> unit[@u])
    val send : (t -> string -> unit[@u])
  end

  module WebSocket = struct
    type t = { ws : DOM.WebSocket.t ref; url : string }

    let init = fun [@u] url -> { ws = ref (DOM.magic 0); url }
    let connect = fun [@u] t -> t.ws := DOM.WebSocket.make t.url
    let send = fun [@u] t data -> DOM.WebSocket.send t.ws.contents data
  end

  module LongPolling = struct
    type t

    external init : (string -> t[@u]) = "init"
    external connect : (t -> unit[@u]) = "connect"
  end
end

module Sidewinder = struct
  open DOM

  module LiveSocket = struct
    type t =
      | LS : {
          sock : (module Trail.Sock with type t = 't);
          state : 't;
          url : string;
        }
          -> t

    let endpoint path =
      let location = Window.(location window) in
      let protocol =
        let protocol = Location.protocol location in
        String.replace "http" "ws" protocol
      in
      let host = Location.host location in
      protocol ^ "//" ^ host ^ path
    ;;

    let make =
     fun [@u] url (module S : Trail.Sock) ->
      let url = endpoint url in
      LS { sock = (module S); url; state = S.init url [@u] }
    ;;

    let connect =
     fun [@u] (LS { sock = (module S); state; _ }) ->
      let readyState = Document.(readyState document) in
      let do_connect () = (S.connect state [@u]) in
      if Array.indexOf readyState [| "complete"; "loaded"; "interactive" |] >= 0
      then do_connect ()
      else Document.(addEventListener document "DOMContentLoaded" do_connect)
    ;;

    let send (LS { sock = (module S); state; _ }) data =
      (S.send state data [@u])
    ;;
  end

  let bind socket root =
    let elements = Element.(querySelectorAll root "[data-sw-event]") in
    Array.forEach
      (fun el ->
        let id = Element.getAttribute el "data-sw-el-id" in
        let event = Element.getAttribute el "data-sw-event" in
        let data =
          {%raw| function (id) { return JSON.stringify({ "Event": [id, ""] }) } |}
        in
        let data = data id in
        Element.addEventListener el event @@ fun _ev ->
        LiveSocket.send socket data)
      elements
  ;;

  let setup socket =
    let root = Document.(querySelector document "[sw-root]") in
    let observer =
      MutationObserver.make (fun [@u] mut_list _obs -> Js.log mut_list)
    in
    let config =
      MutationObserver.{ attributes = true; childList = true; subtree = true }
    in
    MutationObserver.observe observer root config;
    bind socket root
  ;;
end
