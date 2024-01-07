open Riot

module Stats = struct
  type Message.t += Print_stats

  let rec print_stats () =
    (match receive () with
    | Print_stats ->
        let accept, recv, send, connect = Runtime.syscalls () in
        Logger.error (fun f ->
            f "accept=%d recv=%d send=%d connect=%d" accept recv send connect)
    | _ -> ());
    print_stats ()

  let start () =
    let pid = spawn_link (fun () -> print_stats ()) in
    Ok pid
end

module Endpoint = struct
  let trail =
    Trail.
      [
        logger ~level:Debug ();
        request_id { kind = Uuid_v4 };
        (fun conn -> conn |> Conn.send_response `OK "hello world!");
      ]

  let start_link () =
    let handler = Nomad.trail trail in
    Nomad.start_link ~acceptors:10 ~port:8080 ~handler ()
end

module BazaarApp = struct
  open Supervisor

  let start () =
    Logger.set_log_level (Some Info);
    start_link ~child_specs:[ child_spec Endpoint.start_link () ] ()
end

let () =
  Riot.start
    ~apps:[ (module Riot.Logger); (module BazaarApp); (module Stats) ]
    ()
