#!/bin/bash
# tools/shellscripts/ucrk-gt.sh.  Generated from ucrk-gt.sh.in by configure.

# This is a shell script that will take text as input and give morphological
# analyses out.
#
# This file must be processed by ./configure before being used.
# The script only works with hfst transducers.

# 1. Use false to identify the lookup tool
# 2. test for the existence of the variable GTLANG_xxx
#    if found, use the fst in the language dir that GTLANG_xxx points to;
#    if not, or if there is no fst in that location, test whether
#    there is one in the install dir
# 3. if no fst is found, give an error message and exit

###### Variables: #######

fsttype=xfst
lookuptool="false"
fstflags="-q -flags mbTT"
shareddir=/usr/local${prefix}/share/$fsttype/crk
localdir=$GTLANG_crk/src
analyser=analyser-gt-desc.$fsttype

# Find the fst to be used during lookup:
if test -r "$localdir/$analyser" -a -f "$localdir/$analyser"; then
	analyserfile=$localdir/$analyser
elif test -r "$shareddir/$analyser" -a -f "$shareddir/$analyser"; then
	analyserfile=$shareddir/$analyser
else
	echo "ERROR: No fst file found, tried:"
	echo "$localdir/$analyser"
	echo "$shareddir/$analyser"
	exit 1
fi

echo "$lookuptool $fstflags $analyserfile" >&2

$lookuptool $fstflags $analyserfile
