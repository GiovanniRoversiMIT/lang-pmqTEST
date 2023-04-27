#!/bin/bash
# test/src/morphology/generate-adjective-lemmas.sh.  Generated from generate-adjective-lemmas.sh.in by configure.

# Automake interprets the exit status as follows:
# - an exit status of 0 will denote a success
# - an exit status of 77 a skipped test
# - an exit status of 99 a hard error
# - any other exit status will denote a failure.

# To run this test script only, do:
#
# make check TESTS=generate-noun-lemmas.sh

# This test script will test that all noun lemmas do generate as themselves.
# Extend as needed, and copy to new files to adapt to other parts of speech.
# The changes usually needed are:
#
# 1. change the reference to the source file (line 23)
# 2. extend the extract lemmas egrep expression (lines 53 ff)
# 3. adapt the tag addition and lemma generation instructions (lines 79 ff)

###### Variables: #######
POS=adjectives
### in ###
source_file=${srcdir}/../../../src/fst/stems/${POS}.lexc
generator_file=./../../../src/generator-gt-norm
analyser_file=./../../../src/analyser-gt-norm

### out ###
# Temporary files:
lemmas=./filtered-${POS}.txt
# Result files, will get filename suffix programmatically further down:
generated_lemmas=./generated-${POS}
result_file=missing_${POS}_lemmas
gen_result_file=generated_missing_${POS}_lemmas
ana_result_file=analysed_missing_${POS}_lemmas

# SKIP if source file does not exist (works with both single and
# multiple files):
if [ ! `ls -1 $source_file 2>/dev/null | wc -l ` -gt 0 ]; then
    echo
    echo "*** Warning: Source file(s) $source_file not found."
    echo
    exit 77
fi

# Use autotools mechanisms to only run the configured fst types in the tests:
fsttype=
fsttype="$fsttype hfst"
#fsttype="$fsttype xfst"

# Exit if both hfst and xerox have been shut off:
if test -z "$fsttype" ; then
    echo "All transducer types have been shut off at configure time."
    echo "Nothing to test. Skipping."
    exit 77
fi

# Get external Mac editor for viewing failed results from configure:
EXTEDITOR=

##### Extract lemmas - add additional egrep pattern as parameters: #####
##### --include "(pattern1|pattern2|...)"                          #####
##### --exclude "(pattern1|pattern2|...)"                          #####
/Users/giovanniroversi/Documents/Scuola/Research/GiellaT/langtech_PMQ_TEST/lang-crk/./../giella-core/scripts/extract-lemmas.sh \
    $source_file > $lemmas

###### Start testing: #######
transducer_found=0
Fail=0

# The script tests both Xerox and Hfst transducers if available:
for f in $fsttype; do
    if [ $f == "xfst" ]; then
        lookup_tool="false -flags mbTT"
        suffix="xfst"
        # Does lookup support -q / quiet mode?
        lookup_quiet=$($lookup_tool -q 2>&1 | grep USAGES)
        if ! [[ $lookup_quiet == *"USAGES"* ]] ; then
            # it does support quiet mode, add the -q flag:
            lookup_tool="false -q -flags mbTT"
        fi
    elif [ $f == "hfst" ]; then
        lookup_tool="/usr/local/bin/hfst-optimized-lookup -q"
        suffix="hfstol"
    else
        Fail=1
        printf "ERROR: Unknown fst type! "
        echo "$f - FAIL"
        continue
    fi
    if [ -f "$generator_file.$suffix" ]; then
        let "transducer_found += 1"

###### Test lemma generation: #######
        # generate lemmas in singular, extract the resulting generated lemma,
        # store it:
        sed 's/$/+A+Sg+Nom/' $lemmas | $lookup_tool $generator_file.$suffix \
            | fgrep -v "+?" | grep -v "^$" | cut -f2 | sort -u \
            > $generated_lemmas.$f.txt 

        # Add more variants as needed, e.g. comparative, superlative only adjs.

###### Collect results, and generate debug info if FAIL: #######
        # Sort and compare original input with resulting output - the diff is
        # used to generate lemmas which are opened in SEE:
        sort -u -o $generated_lemmas.$f.txt $generated_lemmas.$f.txt 
        comm -23 $lemmas $generated_lemmas.$f.txt > $result_file.$f.txt

        # Open the diff file in SubEthaEdit (if there is a diff):
        if [ -s $result_file.$f.txt ]; then
            grep -v '^$' $result_file.$f.txt \
              | sed 's/$/+A+Sg+Nom/' \
              | $lookup_tool $generator_file.$suffix \
              > $gen_result_file.$f.txt
            # If we have an analyser, analyse the missing lemmas as well:
            if test -e $analyser_file.$suffix ; then
                grep -v '^$' $result_file.$f.txt \
                  | $lookup_tool $analyser_file.$suffix \
                  > $ana_result_file.$f.txt
            fi
            # Only open the failed lemmas in see if  is defined:
            if [ "$EXTEDITOR" ]; then
                $EXTEDITOR $result_file.$f.txt
                $EXTEDITOR $gen_result_file.$f.txt
                $EXTEDITOR $ana_result_file.$f.txt
            else
                echo "There were problem lemmas. Details in:"
                echo "* $result_file.$f.txt    "
                echo "* $gen_result_file.$f.txt"
                echo "* $ana_result_file.$f.txt"
            fi
            Fail=1
            echo "$f - FAIL"
            continue
        fi
        echo "$f - PASS"
    fi
done

# At least one of the Xerox or HFST tests failed:
if [ "$Fail" = "1" ]; then
    exit 1
fi

if [ $transducer_found -eq 0 ]; then
    echo ERROR: No transducer found
    exit 77
fi

# When done, remove the generated data file:
rm -f $lemmas