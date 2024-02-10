open Ffi
open Trail
open Sidewinder

let main () =
  let socket = (LiveSocket.make "/live" (module WebSocket) [@u]) in
  LiveSocket.connect socket [@u];
  Sidewinder.setup socket
;;

main ()
