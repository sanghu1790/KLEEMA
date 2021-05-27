echo sanghu
export BENCHMARK=$1
export toolValue=$2
#This shell script is written by Sangharatna Godboley
#The below code is to identify the dead mutatns and avoid them to run 
cp $BENCHMARK-$toolValue/klee-out-0/LinesCovered.txt $BENCHMARK-Mutants
mkdir $BENCHMARK-ReachedMutants
cd $BENCHMARK-Mutants
ls -v *.c > files.txt 
let z=1;
while read q; do
echo $q > tmp1.txt
cut -d_ -f1-3 tmp1.txt > tmp2.txt
sed 's/.*_//' tmp2.txt > tmp3.txt
grep -F -x -v -f LinesCovered.txt tmp3.txt
if [ $? == 1 ]
then
echo $q >> ../$BENCHMARK-ReachedMutantsList.txt
var=($q)
cp  $var ../$BENCHMARK-ReachedMutants
else
echo $q >> ../$BENCHMARK-DeadMutantsList.txt
fi
rm tmp*.txt
  ((z=z+1))
done <files.txt
rm files.txt
cd ..

