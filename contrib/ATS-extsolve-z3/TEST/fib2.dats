(* ****** ****** *)
//
#include
"share/atspre_staload.hats"
//
(* ****** ****** *)
//
stacst fib: int -> int
//
(* ****** ****** *)
//
extern
praxi
fib_bas0(): [fib(0)==0] unit_p
extern
praxi
fib_bas1(): [fib(1)==1] unit_p
extern
praxi
fib_ind2{n:int | n >= 2}(): [fib(n)==fib(n-1)+fib(n-2)] unit_p
//
(* ****** ****** *)

fun
fib
{n:nat} .<>.
(
  n: int(n)
) : int(fib(n)) = let
//
prval () = $solver_assert(fib_bas0)
prval () = $solver_assert(fib_bas1)
prval () = $solver_assert(fib_ind2)
//
fun
loop
{i:nat|i <= n} .<n-i>.
(
  ni: int(n-i)
, f0: int(fib(i)), f1: int(fib(i+1))
) : int(fib(n)) = (
//
if
ni >= 2
then (
  loop{i+1}(ni-1, f1, f0+f1)
) (* end of [then] *)
else (
  if ni >= 1 then f1 else f0
) (* end of [else] *)
//
) (* end of [loop] *)
//
in
  loop{0}(n, 0, 1)
end // end of [fib]

(* ****** ****** *)

implement
main0(argc, argv) =
{
//
val n =
(
if (argc >= 2)
  then g0string2int(argv[1]) else 10
// end of [if]
) : int // end of [val]
//
val n = g1ofg0(n)
val n = (if n >= 0 then n else 0): intGte(0)
//
val () = println! ("fib(", n, ") = ", fib(n))
//
} (* end of [main0] *)

(* ****** ****** *)

(* end of [fib2.dats] *)
