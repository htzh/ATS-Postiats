(*
**
** Ats2srcgen:
** for static meta-programming
**
** Author: Hongwei Xi
** Authoremail: hwxiATgmhwxiDOTcom
** Start time: the 10th of August, 2015
**
*)

(* ****** ****** *)

staload
STDIO = "libc/SATS/stdio.sats"

(* ****** ****** *)
//
dynload "src/pats_error.dats"
dynload "src/pats_utils.dats"
dynload "src/pats_global.dats"
dynload "src/pats_basics.dats"
dynload "src/pats_errmsg.dats"
dynload "src/pats_comarg.dats"
dynload "src/pats_symbol.dats"
//
dynload "src/pats_filename.dats"
dynload "src/pats_filename_reloc.dats"
//
dynload "src/pats_location.dats"
//
dynload "src/pats_label.dats"
dynload "src/pats_fixity_prec.dats"
dynload "src/pats_fixity_fxty.dats"
//
dynload "src/pats_effect.dats"
//
dynload "src/pats_symmap.dats"
dynload "src/pats_symenv.dats"
//
dynload "src/pats_reader.dats"
dynload "src/pats_lexbuf.dats"
dynload "src/pats_lexing.dats"
dynload "src/pats_lexing_token.dats"
dynload "src/pats_lexing_print.dats"
dynload "src/pats_lexing_error.dats"
//
(* ****** ****** *)

dynload "src/pats_syntax.dats"
dynload "src/pats_syntax_print.dats"

(* ****** ****** *)

dynload "src/pats_tokbuf.dats"
dynload "src/pats_parsing.dats"
dynload "src/pats_parsing_util.dats"
dynload "src/pats_parsing_kwds.dats"
dynload "src/pats_parsing_base.dats"
dynload "src/pats_parsing_error.dats"
dynload "src/pats_parsing_e0xp.dats"
dynload "src/pats_parsing_sort.dats"
dynload "src/pats_parsing_staexp.dats"
dynload "src/pats_parsing_p0at.dats"
dynload "src/pats_parsing_dynexp.dats"
dynload "src/pats_parsing_decl.dats"
dynload "src/pats_parsing_toplevel.dats"

(* ****** ****** *)

dynload "src/pats_staexp1.dats"
dynload "src/pats_staexp1_print.dats"

(* ****** ****** *)

dynload "src/pats_dynexp1.dats"
dynload "src/pats_dynexp1_print.dats"

(* ****** ****** *)

dynload "src/pats_e1xpval.dats"
dynload "src/pats_e1xpval_error.dats"

(* ****** ****** *)

dynload "src/pats_trans1_env.dats"
dynload "src/pats_trans1_e0xp.dats"
dynload "src/pats_trans1_error.dats"
dynload "src/pats_trans1_effect.dats"
dynload "src/pats_trans1_sort.dats"
dynload "src/pats_trans1_staexp.dats"
dynload "src/pats_trans1_p0at.dats"
dynload "src/pats_trans1_syndef.dats"
dynload "src/pats_trans1_dynexp.dats"
dynload "src/pats_trans1_decl.dats"

(* ****** ****** *)
//
staload "src/pats_comarg.sats"
//
staload "./../SATS/ats2srcgen.sats"
//
(* ****** ****** *)
//
vtypedef
comarglst (n: int) = list_vt (comarg, n)
//
(* ****** ****** *)

datatype
waitkind =
  | WTKnone of ()
  | WTKoutput of () // -o ...
  | WTKinput_sta of () // -s ...
  | WTKinput_dyn of () // -d ...
  | WTKdefine of () // -DATS ...
  | WTKinclude of () // -IATS ...
// end of [waitkind]

(* ****** ****** *)

fun
waitkind_get_stadyn
  (knd: waitkind): int =
(
//
case+ knd of
| WTKinput_sta () => 0
| WTKinput_dyn () => 1
| _ (*erroneous*) => ~1 // not a valid input kind
//
) (* end of [cmdkind_get_stadyn] *)

(* ****** ****** *)

datatype OUTCHAN =
  | OUTCHANref of (FILEref) | OUTCHANptr of (FILEref)
// end of [OUTCHAN]

fun outchan_get_fileref
  (x: OUTCHAN): FILEref = (
  case+ x of
  | OUTCHANref (filr) => filr | OUTCHANptr (filp) => filp
) // end of [outchan_get_fileref]

(* ****** ****** *)

typedef
cmdstate = @{
  comarg0= comarg
, ncomarg= int // number of arguments
, waitkind= waitkind
// number of processed input files;
, ninputfile= int // waiting for STDIN if it is 0
, outchan= OUTCHAN // current output channel
, nerror= int // number of accumulated errors
} // end of [cmdstate]

(* ****** ****** *)

fun
cmdstate_set_outchan
(
  state: &cmdstate, chan_new: OUTCHAN
) : void = let
//
val chan_old = state.outchan
val ((*void*)) = state.outchan := chan_new
//
in
  case+ chan_old of
  | OUTCHANref (filr) => ()
  | OUTCHANptr (filp) => let
      val err = $STDIO.fclose0_err (filp) in (*nothing*)
    end // end of [OUTCHANptr]
end // end of [cmdstate_set_outchan]

(* ****** ****** *)

fun
cmdstate_set_outchan_basename
(
  state: &cmdstate, basename: string
) : void = let
//
val [l:addr] (pfopt | p) =
  $STDIO.fopen_err (basename, file_mode_w)
// end of [val]
in
//
if p > null then let
  prval Some_v (pf) = pfopt
  val filp = __cast (pf | p) where {
    extern castfn __cast (pf: FILE w @ l | p: ptr l):<> FILEref
  } // end of [val]
in
  cmdstate_set_outchan (state, OUTCHANptr (filp))
end else let
  prval None_v () = pfopt
  val () = state.nerror := state.nerror + 1
in
  cmdstate_set_outchan (state, OUTCHANref (stderr_ref))
end // end of [if]
//
end // end of [cmdstate_set_outchan_basename]

(* ****** ****** *)

fn isoutwait
  (state: cmdstate): bool =
  case+ state.waitkind of
  | WTKoutput () => true | _ => false
// end of [isoutwait]

fn isinpwait
  (state: cmdstate): bool =
  case+ state.waitkind of
  | WTKinput_sta () => true
  | WTKinput_dyn () => true
  | _ (*non-WTKinput*) => false
// end of [isinpwait]

fn isdatswait
  (state: cmdstate): bool =
  case+ state.waitkind of
  | WTKdefine () => true | _ => false
// end of [isdatswait]

fn isiatswait
  (state: cmdstate): bool =
  case+ state.waitkind of
  | WTKinclude () => true | _ => false
// end of [isiatswait]

(* ****** ****** *)

fn
ats2srcgen_usage
  (cmd: string): void = {
//
val () =
printf("usage: %s <command> ... <command>\n\n", @(cmd))
val () =
printf("where each <command> is of one of the following forms:\n\n", @())
//
} (* end of [ats2srcgen_usage] *)

(* ****** ****** *)

fn*
process_cmdline
  {i:nat} .<i,0>. (
  state: &cmdstate
, arglst: comarglst (i)
) :<fun1> void = let
in
//
case+ arglst of
//
| ~list_vt_cons
    (arg, arglst) => let
    val () =
      state.ncomarg := state.ncomarg + 1
    // end of [val]
  in
    process_cmdline2 (state, arg, arglst)
  end (* end of [list_vt_cons] *)
//
| ~list_vt_nil () => let
    val nif = state.ninputfile
  in
    if nif = 0
      then let
        val stadyn =
          waitkind_get_stadyn (state.waitkind)
        // end of [val]
      in
        case+ 0 of
        | _ when
            stadyn >= 0 => {
            val inp = stdin_ref
(*
            val ((*void*)) =
              ats2srcgen_state_fileref (state, inp)
            // end of [val]
*)
          } // end of [_ when ...]
        | _ (*non-wait*) =>
          (
            if state.ncomarg = 0 then ats2srcgen_usage ("ats2srcgen")
          )
      end // end of [then]
      else () // end of [else]
    // end of [if]
  end // end of [list_vt_nil]
//
end // end of [process_cmdline]

and
process_cmdline2
  {i:nat} .<i,2>. (
  state: &cmdstate
, arg: comarg
, arglst: comarglst (i)
) :<fun1> void = let
in
//
case+ arg of
//
| _ when isinpwait(state) => let
//
// HX: the [inpwait] state stays unchanged
//
    val nif = state.ninputfile
  in
    case+ arg of
    | COMARGkey (1, key) when nif > 0 =>
        process_cmdline2_COMARGkey1 (state, arglst, key)
    | COMARGkey (2, key) when nif > 0 =>
        process_cmdline2_COMARGkey2 (state, arglst, key)
    | COMARGkey (_, basename) => let
        val () = state.ninputfile := nif + 1
(*
        val () = ats2srcgen_state_basename (state, basename)
*)
      in
        process_cmdline (state, arglst)
      end (* end of [_] *)
  end // end of [_ when isinpwait]
//
| _ when isoutwait(state) => let
    val () = state.waitkind := WTKnone ()
    val COMARGkey (_, fname) = arg
    val () = cmdstate_set_outchan_basename (state, fname)
  in
    process_cmdline (state, arglst)
  end // end of [_ when isoutwait]
//
| _ when isdatswait(state) => let
    val () = state.waitkind := WTKnone ()
    val COMARGkey (_, def) = arg
    val () = process_DATS_def (def)
  in
    process_cmdline (state, arglst)
  end // end of [_ when isdatswait]
//
| _ when isiatswait(state) => let
    val () = state.waitkind := WTKnone ()
    val COMARGkey (_, dir) = arg
    val () = process_IATS_dir (dir)
  in
    process_cmdline (state, arglst)
  end
//
| COMARGkey (1, key) =>
    process_cmdline2_COMARGkey1 (state, arglst, key)
| COMARGkey (2, key) =>
    process_cmdline2_COMARGkey2 (state, arglst, key)
| COMARGkey (_, key) => let
    val () = comarg_warning (key)
    val () = state.waitkind := WTKnone ()
  in
    process_cmdline (state, arglst)
  end // end of [COMARGkey]
//
end // end of [process_cmdline2]

and
process_cmdline2_COMARGkey1
  {i:nat} .<i,1>. (
  state: &cmdstate
, arglst: comarglst (i)
, key: string // the string following [-]
) :<fun1> void = let
//
val () = (
//
case+ key of
//
| "-o" => {
    val () = state.waitkind := WTKoutput ()
  } (* -o *)
//
| "-s" => {
    val () = state.ninputfile := 0
    val () = state.waitkind := WTKinput_sta
  } (* -s *)
| "-d" => {
    val () = state.ninputfile := 0
    val () = state.waitkind := WTKinput_dyn
  } (* -d *)
//
| "-h" => {
    val () = state.waitkind := WTKnone ()
    val () = ats2srcgen_usage ("ats2srcgen")
  } (* -h *)
//
| _ when
    is_DATS_flag (key) => let
    val def = DATS_extract (key)
    val issome = stropt_is_some (def)
  in
    if issome then let
      val def = stropt_unsome (def)
      val () = state.waitkind := WTKnone ()
    in
      process_DATS_def (def)
    end else let
      val () = state.waitkind := WTKdefine ()
    in
      // nothing
    end // end of [if]
  end
| _ when
    is_IATS_flag (key) => let
    val dir = IATS_extract (key)
    val issome = stropt_is_some (dir)
  in
    if issome then let
      val dir = stropt_unsome (dir)
      val () = state.waitkind := WTKnone ()
    in
      process_IATS_dir (dir)
    end else let
      val () = state.waitkind := WTKinclude ()
    in
      // nothing
    end // end of [if]
  end
| _ (*unrecognized*) => comarg_warning (key)
//
) : void // end of [val]
//
in
  process_cmdline (state, arglst)
end // end of [process_cmdline2_COMARGkey1]

and
process_cmdline2_COMARGkey2
  {i:nat} .<i,1>. (
  state: &cmdstate
, arglst: comarglst (i)
, key: string // the string following [--]
) :<fun1> void = let
//
val () = (
//
case+ key of
//
| "--output" =>
    state.waitkind := WTKoutput ()
//
| "--static" =>
    state.waitkind := WTKinput_sta
| "--dynamic" =>
    state.waitkind := WTKinput_dyn
//
| "--help" => let
    val () =
      state.waitkind := WTKnone ()
    // end of [val]
  in
    ats2srcgen_usage ("ats2srcgen")
  end // end of ["--help"]
//
| _ (*unrecognized*) => comarg_warning (key)
//
) : void // end of [val]
//
in
  process_cmdline (state, arglst)
end // end of [process_cmdline2_COMARGkey2]

(* ****** ****** *)

(*
implement
main((*void*)) =
{
//
val () = println! ("Hello from [ats2srcgen]!")
//
} (* end of [main] *)
*)

(* ****** ****** *)

implement
main(argc, argv) = let
//
val
arglst =
comarglst_parse(argc, argv)
//
val+~list_vt_cons(arg0, arglst) = arglst
//
var
state = @{
  comarg0= arg0
, ncomarg= 0 // counting from 0
, waitkind= WTKnone ()
// number of prcessed
, ninputfile= 0 // input files
, outchan= OUTCHANref (stdout_ref)
, nerror= 0 // number of accumulated errors
} : cmdstate // end of [var]
//
val () = process_cmdline (state, arglst)
//
in
  // nothing
end // end of [main]

(* ****** ****** *)

(* end of [ats2srcgen_main.dats] *)
