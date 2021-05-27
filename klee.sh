echo sanghu
#This shell script is written by Sangharatna Godboley
export BENCHMARK=$1
export toolValue=$2
rm -r klee-last

#The below command is to generate llvm .bc file from C program
/home/sanghu/TracerX/llvm/Release/bin/clang -I /home/sanghu/TracerX/tracerx/include -c -emit-llvm -g ${BENCHMARK}.c

#The below command is to run KLEE which is DSE
#KLEE = 1
if [ $toolValue -eq 1 ]; then
/home/sanghu/TracerX/tracerx/Release+Asserts/bin/klee --max-memory=30000 --max-time=600 --watchdog --search=random-path --search=nurs:covnew -write-BB-cov=4 -debug-print-instructions=all:file -emit-all-errors-in-same-path=true ${BENCHMARK}.bc
fi

#The below command is to run TracerX which is DSE with pruning
#Original TX = 2
if [ $toolValue -eq 2 ]; then
/home/sanghu/TracerX/tracerx/Release+Asserts/bin/klee --max-memory=30000 --max-time=300 --watchdog -solver-backend=z3 --search=dfs -output-tree=true -allow-external-sym-calls -debug-subsumption=3 ${BENCHMARK}.bc
fi

#Extraction of status details and appending them into info file
mkdir $BENCHMARK-$toolValue
/home/sanghu/TracerX/tracerx/Release+Asserts/bin/klee-stats klee-out-0 >> klee-out-0/info
mv klee-out-0 $BENCHMARK-$toolValue

#Below code is to print the C Lines covered
sed 's/.*c://' $BENCHMARK-$toolValue/klee-out-0/instructions.txt > temp1.txt
sed 's/:.*//' temp1.txt > temp2.txt
sort -u -V -o $BENCHMARK-$toolValue/klee-out-0/LinesCovered.txt temp2.txt

rm -r temp*

