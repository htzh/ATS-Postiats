(*
** Game Development with SDL2
*)

(* ****** ****** *)

#define ATS_DYNLOADFLAG 0

(* ****** ****** *)

#include
"share/atspre_define.hats"
#include
"share/atspre_staload.hats"

(* ****** ****** *)

staload "{$SDL2}/SATS/SDL.sats"

(* ****** ****** *)

local
//
vtypedef
objptr(l:addr) = SDL_Window_ptr(l)
//
in (* in of [local] *)

#include "{$HX_GLOBALS}/HATS/gobjptr.hats"

end // end of [local]

(* ****** ****** *)

(* end of [Hello_Window.dats] *)
