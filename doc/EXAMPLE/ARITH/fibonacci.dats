(*
** Copyright (C) 2012 Hongwei Xi, Boston University
**
** Permission is hereby granted, free of charge, to any person
** obtaining a copy of this software and associated documentation
** files (the "Software"), to deal in the Software without
** restriction, including without limitation the rights to use,
** copy, modify, merge, publish, distribute, sublicense, and/or sell
** copies of the Software, and to permit persons to whom the
** Software is furnished to do so, subject to the following
** conditions:
**
** The above copyright notice and this permission notice shall be
** included in all copies or substantial portions of the Software.
**
** THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
** EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
** OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
** NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
** HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
** WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
** FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
** OTHER DEALINGS IN THE SOFTWARE.
*)

(* ****** ******)
//
// Author: Hongwei Xi (2012-03)
//
(* ****** ****** *)

staload "./basics.sats"
staload "./fibonacci.sats"

(* ****** ******)

primplmnt
fib_istot{n}() = let
//
prfun
istot{n:nat} .<n>.
  (): [r:nat] FIB (n, r) =
(
//
sif
n == 0
then FIBbas0()
else (
  sif n == 1
    then FIBbas1()
    else FIBind2(istot{n-2}(), istot{n-1}())
  // end of [sif]
) (* end of [else] *)
//
) (* end of [istot] *)
//
in
  istot{n}((*void*))
end // end of [fib_istot]

(* ****** ****** *)

primplmnt
fib_isfun(pf1, pf2) = let
//
prfun isfun
  {n:nat}{r1,r2:int} .<n>. (
  pf1: FIB (n, r1), pf2: FIB (n, r2)
) : [r1==r2] void =
  case+ (pf1, pf2) of
  | (FIBbas0 (), FIBbas0 ()) => ()
  | (FIBbas1 (), FIBbas1 ()) => ()
  | (FIBind2 (pf11, pf12),
     FIBind2 (pf21, pf22)) => let
      prval () = isfun (pf11, pf21)
      prval () = isfun (pf12, pf22)
    in
      (*nothing*)
    end // end of [FIBind2, FIBind2]
// end of [isfun]
//
in
  isfun (pf1, pf2)
end // end of [fib_isfun]

primplmnt
fib_isfun2(pf1, pf2) = let
  prval () = fib_isfun (pf1, pf2) in eqint_make ()
end // end of [fib_isfun2]

(* ****** ****** *)
//
// HX-2012-03:
// fib(m+n+1)=fib(m)*fib(n)+fib(m+1)*fib(n+1)
//
primplmnt
fibeq1
  (pf1, pf2, pf3, pf4) = let
//
prfun
lemma{m,n:nat}
  {r1,r2,r3,r4:int} .<m>. (
  pf1: FIB (m, r1) // r1 = fib(m)
, pf2: FIB (n, r2) // r2 = fib(n)
, pf3: FIB (m+1, r3) // r3 = fib(m+1)
, pf4: FIB (n+1, r4) // r4 = fib(n+1)
) : FIB (m+n+1, r1*r2+r3*r4) = let
//
// HX: it is by standard mathematical induction
//
in
//
sif
m > 0
then let
  prval
  FIBind2(pf30, pf31) = pf3
  prval EQINT() = fib_isfun2 (pf1, pf31)
in
  lemma{m-1,n+1}(pf30, pf4, pf31, FIBind2(pf2, pf4))
end // end of [then]
else let
  prval FIBbas0() = pf1; prval FIBbas1() = pf3 in pf4
end // end of [else]
//
end // end of [lemma]
//
in
//
lemma (pf1, pf2, pf3, pf4)
//
end // end of [fibeq1]

(* ****** ****** *)
//
// HX-2012-03:
// fib(n)*fib(n+2) + (-1)^n = (fib(n+1))^2
//
primplmnt
fib_cassini{n}
(
  pf0, pf1, pf2, pf3
) = let
//
prfun
fibeq2
{n:nat}{i:int}
{f0,f1,f2:int} .<n>.
(
  pf0: FIB (n, f0)
, pf1: FIB (n+1, f1)
, pf2: FIB (n+2, f2)
, pf3: SGN (n, i) // i = (-1)^n
) :
[
  f0*f2 + i == f1*f1
] void = (
//
sif
n > 0
then let
  prval
  SGNind(pf31) = pf3
  prval
  FIBind2(pf11, pf12) = pf1
  prval EQINT() = fib_isfun2(pf0, pf12)
  prval pf_n_n = fibeq1(pf0, pf0, pf1, pf1)
  prval pf_1n_n1 = fibeq1(pf11, pf1, pf0, pf2)
  prval () = fib_isfun(pf_n_n, pf_1n_n1)
  prval () = fibeq2{n-1}(pf11, pf12, pf1, pf31) // IH
in
  // nothing
end // end of [then]
else let
  prval SGNbas() = pf3
  prval FIBbas0() = pf0
  prval FIBbas1() = pf1
  prval FIBind2(FIBbas0(), FIBbas1()) = pf2
in
  // nothing
end // end of [else]
//
) (* end of [fibeq2] *)
//
in
  fibeq2{n}(pf0, pf1, pf2, pf3)
end // end of [fib_cassini]

(* ****** ****** *)
//
primplmnt
fib_catalan
  (pf_n, pf_r, pf_rn, pf_nr, sgn) =
(
//
fib_vajda(pf_rn, pf_r, pf_r, pf_n, pf_n, pf_nr, sgn)
//
) (* end of [fib_catalan] *)
//
(* ****** ****** *)

primplmnt
fib_vajda
{n}{i,j}{...}{sgn}
(
  pf_n, pf_i, pf_j, pf_ni, pf_nj, pf_nij, sgn
) = let
//
prfun
lemma
{j:nat}
{f_j,f_n,f_n1,f_nj,f_nj1:int} .<j>.
(
  pf_j: FIB(j, f_j)
, pf_n: FIB(n, f_n)
, pf_n1: FIB(n+1, f_n1)
, pf_nj: FIB(n+j, f_nj)
, pf_nj1: FIB(n+j+1, f_nj1)
) :
[
  f_n1*f_nj-f_n*f_nj1==sgn*f_j
] void = let
in
//
sif
j==0
then let
//
prval
FIBbas0() = pf_j
prval EQINT() = fib_isfun2(pf_n, pf_nj)
prval EQINT() = fib_isfun2(pf_n1, pf_nj1)
//
in
  // nothing
end // end of [then]
else (
sif
j==1
then let
//
prval
FIBbas1() = pf_j
prval EQINT() = fib_isfun2(pf_n1, pf_nj)
prval ((*void*)) = fib_cassini (pf_n, pf_n1, pf_nj1, sgn)
in
  // nothing
end // end of [then]
else let
//
prval
FIBind2(pf_j_2, pf_j_1) = pf_j
prval
FIBind2(pf_nj_2, pf_nj_1) = pf_nj
prval
FIBind2(pf_nj1_2, pf_nj1_1) = pf_nj1
//
prval ((*void*)) =
  lemma{j-2}(pf_j_2, pf_n, pf_n1, pf_nj_2, pf_nj1_2)
prval ((*void*)) =
  lemma{j-1}(pf_j_1, pf_n, pf_n1, pf_nj_1, pf_nj1_1)
//
in
  // nothing
end // end of [else]
) (* end of [else] *)
//
end // end of [lemma]
//
in
//
sif
i==0
then let
//
prval
FIBbas0() = pf_i
//
prval EQINT() = fib_isfun2 (pf_n, pf_ni)
prval EQINT() = fib_isfun2 (pf_nj, pf_nij)
//
in
  // nothing
end // end of [then]
else (
//
sif
i==1
then let
//
prval
FIBbas1() = pf_i
prval () = lemma{j}(pf_j, pf_n, pf_ni, pf_nj, pf_nij)
//
in
end // end of [then]
else let
//
prval
FIBind2(pf_i_2, pf_i_1) = pf_i
prval
FIBind2(pf_ni_2, pf_ni_1) = pf_ni
prval
FIBind2(pf_nij_2, pf_nij_1) = pf_nij
//
prval ((*void*)) =
fib_vajda{n}{i-2,j}
  (pf_n, pf_i_2, pf_j, pf_ni_2, pf_nj, pf_nij_2, sgn)
//
prval ((*void*)) =
fib_vajda{n}{i-1,j}
  (pf_n, pf_i_1, pf_j, pf_ni_1, pf_nj, pf_nij_1, sgn)
//
in
  // nothing
end // end of [else]
//
) (* end of [else] *)
//
end // end of [fib_vajda]

(* ****** ****** *)

(* end of [fibonacci.dats] *)
