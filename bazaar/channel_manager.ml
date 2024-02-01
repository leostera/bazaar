open Riot

let chan_mgr = "bazaar.channelmanager"

open Logger.Make (struct
  let namespace = [ "bazaar"; "channel_manager" ]
end)

type channel = {
  name : string; [@warning "-69"]
  clients : Pid.t list;
  users : User.t list;
}

type state = { channels : (string, channel) Hashtbl.t }

type Message.t +=
  | Register of { user : User.t; channel : string; client : Pid.t }
  | User_joined of { user : User.t; channel : string }

let rec loop state =
  match receive () with
  | Register { user; channel; client } ->
      handle_register state user channel client
  | _ -> loop state

and handle_register state user channel_name client =
  let channel =
    match Hashtbl.find_opt state.channels channel_name with
    | None -> { name = channel_name; clients = [ client ]; users = [ user ] }
    | Some chan ->
        {
          chan with
          clients = client :: chan.clients;
          users = user :: chan.users;
        }
  in
  Hashtbl.replace state.channels channel_name channel;

  let backfill_msgs =
    channel.users
    |> List.map (fun user -> User_joined { user; channel = channel.name })
  in
  List.iter (fun msg -> send client msg) backfill_msgs;

  let new_user_msg = User_joined { user; channel = channel.name } in
  List.iter (fun client -> send client new_user_msg) channel.clients;

  loop state

let init () =
  let state = { channels = Hashtbl.create 0 } in
  loop state

let start_link () =
  let pid = spawn_link init in
  register chan_mgr pid;
  Ok pid

let join ~user ~channel =
  let client = self () in
  send_by_name ~name:chan_mgr (Register { user; channel; client })
