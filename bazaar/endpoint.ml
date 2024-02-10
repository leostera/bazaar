open Trail
open Sidewinder
open Router

let trail =
  [
    use (module CORS) CORS.(config ~origin:"*" ());
    use (module Logger) Logger.(args ~level:Debug ());
    use
      (module Memory)
      Memory.(config ~prefix:"/static" [ (module Bazaar_assets) ]);
    router
      [
        get "/" Sidewinder_trail.(live Layout.root (module Index_live));
        socket "/live" (module Sidewinder_socket) ();
        live "/counter" (module Counter);
        socket "/playground" (module Playground) ();
      ];
  ]

let start_link () =
  let handler = Nomad.trail trail in
  Nomad.start_link ~port:8080 ~handler ()
