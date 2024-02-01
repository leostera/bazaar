open Riot

open Riot.Logger.Make (struct
  let namespace = [ "bazaar" ]
end)

open Supervisor

let start () =
  (* Runtime.set_log_level (Some Debug); *)
  set_log_level (Some Debug);
  (* Runtime.Stats.start ~every:1_000_000L (); *)
  start_link
    ~child_specs:
      [
        child_spec Endpoint.start_link ();
        child_spec Channel_manager.start_link ();
      ]
    ()
