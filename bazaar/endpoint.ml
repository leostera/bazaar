open Trail
open Sidewinder
open Router

let trail =
  [
    use (module CORS) CORS.(config ~origin:"*" ());
    use (module Logger) Logger.(args ~level:Debug ());
    use (module Sidewinder.Static) ();
    router
      [
        get "/" Index.show;
        live "/counter" (module Counter) ();
        socket "/playground" (module Playground) ();
      ];
  ]

let start_link () =
  let handler = Nomad.trail trail in
  Nomad.start_link ~port:8080 ~handler ()
