#!/bin/ksh
export BENCHMARK=$1
rm a.out
export LD_LIBRARY_PATH=/home/sanghu/TracerX/tracerx/Release+Asserts/lib/:$LD_LIBRARY_PATH

#The below code is to run tests on Original Program
gcc -I /home/sanghu/TracerX/tracerx/include -L /home/sanghu/TracerX/tracerx/Release+Asserts/lib/ ${BENCHMARK}.c -lkleeRuntest

mkdir ${BENCHMARK}-Original
let a=1
for b in `ls -v ${BENCHMARK}-1/klee-out-0/*.ktest`; 
do 
KTEST_FILE=${b} ./a.out > op-${a}.txt
mv op-${a}.txt ${BENCHMARK}-Original
((a =a+1));
done
rm a.out

#The below code is to run tests on all mutants
let c=1
let t=0
let k=0
for y in `ls -v $BENCHMARK-ReachedMutants/*.c`;
do
gcc -I /home/sanghu/TracerX/tracerx/include -L /home/sanghu/TracerX/tracerx/Release+Asserts/lib/ ${y} -lkleeRuntest
if [ $? == 0 ]
then
echo "${y}: MUTANT IS COMPILABLE \n" >> Mutant-compilable-check.txt
else
echo "${y}: MUTANT IS NOT-COMPILABLE \n" >> Mutant-compilable-check.txt
fi
mkdir ${BENCHMARK}-OP-${c}
((t =t+1));
let r=1
for z in `ls -v ${BENCHMARK}-1/klee-out-0/*.ktest`; 
do 
KTEST_FILE=${z} ./a.out > op-${r}.txt
mv op-${r}.txt ${BENCHMARK}-OP-${c}
diff ${BENCHMARK}-Original/op-${r}.txt ${BENCHMARK}-OP-${t}/op-${r}.txt
if [ $? == 0 ]
then
echo "Mutant Alive"
else
echo "Mutant Killed"
echo $y "killed due to" $z >> killed-Mutants-report.txt
((k =k+1));
break;
fi
((r =r+1));
done
rm a.out
rm -r ${BENCHMARK}-OP-${t}
((c =c+1));
done
rm -r ${BENCHMARK}-Original
((a = ${t} - ${k} ))
((mscore = (${k} * 100) / ${t}))
let dead=0
if [ -f "${BENCHMARK}-DeadMutantsList.txt" ]; then
dead=$(wc -l < ${BENCHMARK}-DeadMutantsList.txt)
fi
if [ $dead == 0 ]
then
dead=0
((total =$t+$dead));
else
((total =$t+$dead));
fi

mkdir ${BENCHMARK}-KLEE-FILES 
mv ${BENCHMARK}-1/klee-out-0/assembly.ll ${BENCHMARK}-KLEE-FILES
mv ${BENCHMARK}-1/klee-out-0/*.txt ${BENCHMARK}-KLEE-FILES
mv ${BENCHMARK}-1/klee-out-0/info ${BENCHMARK}-KLEE-FILES
mv ${BENCHMARK}-1/klee-out-0/run.istats ${BENCHMARK}-KLEE-FILES
mv ${BENCHMARK}-1/klee-out-0/run.stats ${BENCHMARK}-KLEE-FILES
rm -r ${BENCHMARK}-1
((a = ${t} - ${k} ))
((mscore = (${k} * 100) / ${t}))

echo "============Mutation Score Report============"
echo "============Mutation Score Report============" >> $BENCHMARK-report.txt
echo "Total number of Alive Mutants =: ${a}"
echo "Total number of Alive Mutants =: ${a}" >> $BENCHMARK-report.txt 
echo "Total number of Killed Mutants =: ${k}"
echo "Total number of Killed Mutants =: ${k}" >> $BENCHMARK-report.txt 
echo "Total number of Reached Mutants =: ${t}"
echo "Total number of Reached Mutants =: ${t}" >> $BENCHMARK-report.txt 
echo "Total number of Dead Mutants =: ${dead}"
echo "Total number of Dead Mutants =: ${dead}" >> $BENCHMARK-report.txt 
echo "Total number of Total Mutants =: ${total}"
echo "Total number of Total Mutants =: ${total}" >> $BENCHMARK-report.txt 
echo "Mutation Score (Killed/Reached) =: ${mscore}%"
echo "Mutation Score (Killed/Reached) =: ${mscore}%" >> $BENCHMARK-report.txt 
echo "============Report-Finish===================="
echo "============Report-Finish====================" >> $BENCHMARK-report.txt
