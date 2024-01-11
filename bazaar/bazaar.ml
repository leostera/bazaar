open Riot

module Endpoint = struct
  let trail =
    Trail.
      [
        logger ~level:Debug ();
        request_id { kind = Uuid_v4 };
        (fun conn -> conn |> Conn.send_response `OK {%b|"hello world!"|});
      ]

  let start_link () =
    let handler = Nomad.trail trail in
    Nomad.start_link ~port:8080 ~handler ()
end

module BazaarApp = struct
  open Supervisor

  let start () =
    Logger.set_log_level (Some Info);
    start_link ~child_specs:[ child_spec Endpoint.start_link () ] ()
end

let () =
  Riot.start
    ~apps:[ (module Riot.Logger); (module BazaarApp)]
    ()
