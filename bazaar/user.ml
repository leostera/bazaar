type t = { name : string; avatar_url : string }

let make ~name ~avatar_url () = { name; avatar_url }
let guest = make ~name:"guest" ~avatar_url:"about:blank" ()
