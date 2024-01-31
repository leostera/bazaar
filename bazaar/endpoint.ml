open Trail
open Sidewinder
open Router

let trail =
  [
    use (module Logger) Logger.(args ~level:Debug ());
    use (module Sidewinder.Static) ();
    router [ get "/" Index.show; live "/counter" (module Counter) () ];
  ]

let start_link () =
  let handler = Nomad.trail trail in
  Nomad.start_link ~port:8080 ~handler ()
