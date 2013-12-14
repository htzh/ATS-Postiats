//
// A simple example for testing hiredis
//
(* ****** ****** *)
//
// Author: Hongwei Xi
// Authoremail: gmhwxiATgmailDOTcom
//
(* ****** ****** *)
//
#include "share/atspre_staload.hats"
//
(* ****** ****** *)
//
staload "./../SATS/hiredis.sats"
staload "./../SATS/hiredis_ML.sats"
//
staload _(*anon*) = "./../DATS/hiredis.dats"
//
(* ****** ****** *)

val () =
{
//
var err: int = 0
//
val ip = "127.0.0.1"
//
val ctx =
redisConnectWithTimeout (ip, 6379, 1.0)
val ((*void*)) = assertloc (ptrcast(ctx) > 0)
//
val () = println! ("test03_2: connected!")
//
val rdsv = redis_brpop (ctx, "test03_list", 0u, err)
val ((*void*)) = println! ("test03_2: brpop: rdsv = ", rdsv)
//
val rdsv = redis_brpop (ctx, "test03_list", 0u, err)
val ((*void*)) = println! ("test03_2: brpop: rdsv = ", rdsv)
//
val rdsv = redis_brpop (ctx, "test03_list", 0u, err)
val ((*void*)) = println! ("test03_2: brpop: rdsv = ", rdsv)
//
val-RDSstatus("OK") = redis_quit (ctx)
//
} (* end of [val] *)

(* ****** ****** *)

implement main0 () = ()

(* ****** ****** *)

(* end of [test03_2.dats] *)
