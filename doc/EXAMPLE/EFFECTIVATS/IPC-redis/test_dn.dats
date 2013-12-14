(*
** downloading messages
*)
(* ****** ****** *)
//  
// Author: Hongwei Xi
// Authoremail: gmhwxiATgmailDOTcom
// Start time: December, 2013
//
(* ****** ****** *)
//
#include
"share/atspre_define.hats"
#include
"share/atspre_staload.hats"
//
(* ****** ****** *)

staload "./msgchan.sats"

(* ****** ****** *)

staload UN = "prelude/SATS/unsafe.sats"

(* ****** ****** *)

staload "{$HIREDIS}/SATS/hiredis.sats"
staload "{$HIREDIS}/SATS/hiredis_ML.sats"
staload _(*anon*) = "{$HIREDIS}/DATS/hiredis.dats"

(* ****** ****** *)

#include "./redisContextSetup.hats"

(* ****** ****** *)

extern
fun
msgchan_takeout2
  (chan: msgchan, err: &int >> _) : stropt
implement
msgchan_takeout2
  (chan, err) = msg where
{
//
  var msg: stropt = stropt_none ()
//
  val err0 = err
  val msg = msgchan_takeout (chan, err)
  val () =
  if err > err0 then
  {
    val () = err := err0
    val () = the_redisContext_reset ()
    val msg = msgchan_takeout (chan, err)
  } (* end of [val] *)
//
} (* end of [msgchan_takeout2] *)

(* ****** ****** *)

extern
fun
msgchan_dnload_fileref
  (chan: msgchan, inp: FILEref): void
implement
msgchan_dnload_fileref
(
  chan, out
) : void = let
//
var err: int = 0
val opt =
  msgchan_takeout2 (chan, err)
//
val issome = stropt_is_some (opt)  
//
in
//
if issome then let
  val str = stropt_unsome (opt)
in
  case+ str of
  | _ when str = "\n" => ((*exit*))
  | _ (*regular*) => let
      val () = fprintln! (out, str)
    in
      msgchan_dnload_fileref (chan, out)
    end (* end of [_] *)
end else ((*error*))
//
end // end of [msgchan_dnload_fileref]

(* ****** ****** *)

dynload "msgchan.dats"

(* ****** ****** *)

implement
main0 (argc, argv) =
{
//
var out: FILEref = stdout_ref
//
val opt =
(
if argc >= 2
  then fileref_open_opt (argv[1], file_mode_w)
  else None_vt(*void*)
) : Option_vt (FILEref)
//
val () =
(
case+ opt of
| ~Some_vt (filr) => out := filr | ~None_vt () => ()
) : void // end of [val]
//
val ip = "127.0.0.1"
val ctx =
redisConnectWithTimeout (ip, 6379, 1.0)
val ((*void*)) = assertloc (ptrcast(ctx) > 0)
//
val () = the_redisContext_set (ctx)
//
val-~Some_vt(chan) =
  msgchan_create_opt ("TOPSECRET6379")
//
val ((*void*)) =
  msgchan_dnload_fileref (chan, out)
//
val () = fileref_close (out)
val () = the_redisContext_unset ((*void*))
//
} (* end of [main0] *)

(* ****** ****** *)

(* end of [test_dn.dats] *)
