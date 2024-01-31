open Riot
open Trail
open Sidewinder

open Riot.Logger.Make (struct
  let namespace = [ "bazaar" ]
end)

module Endpoint = struct
  let trail =
    let open Router in
    [
      use (module Logger) Logger.(args ~level:Debug ());
      use (module Sidewinder.Static) ();
      router
        [ 
          get "/" Index.show;
          live "/counter" (module Counter) ()
        ];
    ]

  let start_link () =
    let handler = Nomad.trail trail in
    Nomad.start_link ~acceptors:1 ~port:8080 ~handler ()
end

module BazaarApp = struct
  open Supervisor

  let start () =
    (* Runtime.set_log_level (Some Debug); *)
    set_log_level (Some Debug);
    (* Runtime.Stats.start ~every:1_000_000L (); *)
    start_link ~child_specs:[ child_spec Endpoint.start_link () ] ()
end

let () = Riot.start ~apps:[ (module Riot.Logger); (module BazaarApp) ] ()
