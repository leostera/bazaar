open Riot

val start_link : unit -> (Pid.t, 'a) result
val register : Pid.t -> channel:string -> unit
val broadcast : Message.t -> channel:string -> unit
