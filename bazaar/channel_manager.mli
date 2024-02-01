open Riot

type Message.t += User_joined of { user : User.t; channel : string }

val start_link : unit -> (Pid.t, 'a) result
val join : user:User.t -> channel:string -> unit
