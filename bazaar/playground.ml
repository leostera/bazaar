open Serde
open Trail
include Trail.Sock.Default

open Riot.Logger.Make (struct
  let namespace = [ "bazaar"; "playground" ]
end)

type user_joined = { name : string; avatar_url : string }
[@@deriving deserializer, serializer]

type state = { current_user : User.t }
type args = unit

let init () = `ok { current_user = User.guest }

let handle_frame frame _conn state =
  match frame with
  | Frame.Ping -> `push ([ Frame.pong ], state)
  | Frame.Text { payload; _ } -> (
      match Serde_json.of_string deserialize_user_joined payload with
      | Ok { name; avatar_url } ->
          let user = User.make ~name ~avatar_url () in
          Channel_manager.join ~user ~channel:"twitch";
          `ok { current_user = user }
      | Error reason ->
          error (fun f ->
              f "error deserializing frame: %S" (Marshal.to_string reason []));
          `ok state)
  | _ -> `ok state

let handle_message msg state =
  match msg with
  | Channel_manager.User_joined { user; _ } ->
      let msg = { name = user.name; avatar_url = user.avatar_url } in
      let json =
        Serde_json.to_string_pretty serialize_user_joined msg |> Result.get_ok
      in
      let frame = Frame.text ~fin:true json in
      `push ([ frame ], state)
  | _ -> `ok state
