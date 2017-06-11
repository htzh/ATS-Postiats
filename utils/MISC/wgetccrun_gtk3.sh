#!/bin/bash

######

WGET=wget
TCCRUN='tcc -run'

######

MY_CFLAGS_LIBS=`pkg-config gtk+-3.0 --cflags --libs`

######
#
${WGET} -q -O - $1 | \
${TCCRUN} \
-DATS_MEMALLOC_LIBC \
-I${PATSHOME} \
-I${PATSHOME}/ccomp/runtime \
-I${PATSHOME}/contrib \
-I${PATSHOME}/npm-utils/contrib \
-I${PATSCONTRIB}/contrib \
  $MY_CFLAGS_LIBS - >& /dev/null
#
######
#
# HX-2014-03-31: Here are some examples:
#
# ./wgetccrun_gtk3.sh http://ats-lang.sourceforge.net/COMPILED/doc/PROJECT/MEDIUM/Algorianim/quicksort/GTK/quicksort_anim_dats.c
# ./wgetccrun_gtk3.sh http://ats-lang.sourceforge.net/COMPILED/doc/PROJECT/MEDIUM/Algorianim/insertsort/GTK/insertsort_anim2_all_dats.c
# ./wgetccrun_gtk3.sh http://ats-lang.sourceforge.net/COMPILED/doc/PROJECT/MEDIUM/Algorianim/QueenPuzzle/GTK/QueenPuzzle-breadth-all_dats.c
#
######

###### end of [wgetccrun_gtk3.sh] ######
