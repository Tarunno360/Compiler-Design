#!/bin/bash

yacc -d -y --debug --verbose 22101576.y
echo 'Generated the parser C file as well the header file'
g++ -w -c -o y.o y.tab.c
echo 'Generated the parser object file'
flex 22101576.l
echo 'Generated the scanner C file'
g++ -fpermissive -w -c -o l.o lex.yy.c
# if the above command doesn't work try g++ -fpermissive -w -c -o l.o lex.yy.c
echo 'Generated the scanner object file'
g++ y.o l.o
echo 'All ready, running the two-pass compiler...'

# Run the compiler on the input file
./two_pass_compiler input3.c
echo 'Compilation completed.'

# Display output files
echo '------------ Log output ------------'
cat log.txt
echo '------------ Error output ------------'
cat error.txt
echo '------------ Three Address Code ------------'
cat code.txt