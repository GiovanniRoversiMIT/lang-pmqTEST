#!/bin/bash

# Run the grammar checker tester using the default pipeline, and store the
# output in an html file in this directory.

# For debugging, uncomment this command:
# set -x

# Language being tested, ISO 639-1 code if available:
giella_lang=crk
giella2c_lang=crk

# Directory variables from configure:
top_srcdir=/Users/giovanniroversi/Documents/Scuola/Research/GiellaT/langtech_PMQ_TEST/lang-crk
top_builddir=/Users/giovanniroversi/Documents/Scuola/Research/GiellaT/langtech_PMQ_TEST/lang-crk
giella_core=/Users/giovanniroversi/Documents/Scuola/Research/GiellaT/langtech_PMQ_TEST/lang-crk/./../giella-core

# Other directory variables:
SCRIPT_DIR=$top_srcdir/devtools
gramcheckfile=$top_builddir/tools/grammarcheckers/${giella2c_lang}.zcheck
htmlfile=gramcheck-output.html

if test "x$GTFREE" == x && "x$GTBOUND" == x ; then
    echo "ERROR: at least one of $$GTFREE or $$GTBOUND must be defined."
    exit 1
fi

$giella_core/devtools/gramcheck_tester.py $gramcheckfile $SCRIPT_DIR/$htmlfile

echo "Done!"
echo
echo "Open $SCRIPT_DIR/$htmlfile in a browser to see the output!"
echo
