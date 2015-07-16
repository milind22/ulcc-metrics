nops=10							#specify the no. of nops to be inserted
sdStrong=( 10 )					#specify the stack distances for strong locality by space separated values
sdWeak=( 50 )					#specify the stack distances for weak locality by space separated values

color_strong=( 30 )				#specify the no. of colors for strong locality by space separated values
color_weak=( 30 )				#specify the no. of colors for weak locality by space separated values

itr=2							#specify the no. of iterations to be made

cl=0

med=$((itr / 2))
echo med="$med"

make -f makefile.infinite
sleep 1
make -f makefile.infiniteULCC

gcc -S infinite_version.c
sleep 1
gcc -S infinite_version_ulcc.c

mkdir data
mkdir files

#solo
cp infinite_version.s accesses_20_nops.s
for i in "${sdStrong[@]}"
do
for (( rep=1;rep<=itr;rep++))
do
for (( x=1 ; x <= nops ; x++ ))
do
	sed -i '/.L9:/a\\t nop ' accesses_20_nops.s
done
echo "$rep"
gcc accesses_20_nops.s -o accesses
numactl --physcpubind=0 --membind=0 perf stat --output=perf-out --append -B -e cache-misses,cache-references,LLC-prefetches  ./accesses $i 64 &
sleep 10
pkill accesses
bash arrange.sh >> data_solo.$i
done
sort -n data_solo.$i --output=data_solo.$i
cmr_mean="$(awk '{ sum+=$5} END {print sum/"'"$itr"'"}' data_solo.$i)"
echo "data_solo.$i- $cmr_mean" >> cmr_mean
acc="$(awk '{ sum+=$2} END {print sum/"'"$itr"'"}' data_solo.$i)"
echo "data_solo.$i- $acc" >> acc_mean
time="$(awk '{ sum+=$3} END {print sum/"'"$itr"'"}' data_solo.$i)"
echo "data_solo.$i- $time" >> time_mean
cmr_med="$(sed -n ''"$med"'p' data_solo.$i)"
echo "data_solo.$i- $cmr_med" >> median
mv data_solo.$i files/data_solo.$i
done

#solo with ulcc
cp infinite_version_ulcc.s accesses_20_nops.s
for j in "${color_strong[@]}"
do
for i in "${sdStrong[@]}"
do
for (( rep=1;rep<=itr;rep++))
do
for (( x=1 ; x <= nops ; x++ ))
do
	sed -i '/.L16:/a\\t nop ' accesses_20_nops.s
done
echo "$rep"
gcc accesses_20_nops.s -L../../../src -Wl,-rpath,../../../src -lulcc -lpthread -o accesses
numactl --physcpubind=0 --membind=0 perf stat --output=perf-out --append -B -e cache-misses,cache-references,LLC-prefetches  ./accesses $i 64 $cl $j &
sleep 10
pkill accesses
bash arrange.sh >> data_solo.$i.ulcc.$j
done
sort -n data_solo.$i.ulcc.$j --output=data_solo.$i.ulcc.$j
cmr_mean="$(awk '{ sum+=$5} END {print sum/"'"$itr"'"}' data_solo.$i.ulcc.$j)"
echo "data_solo.$i.ulcc.$j- $cmr_mean" >> cmr_mean
acc="$(awk '{ sum+=$2} END {print sum/"'"$itr"'"}' data_solo.$i.ulcc.$j)"
echo "data_solo.$i.ulcc.$j- $acc" >> acc_mean
time="$(awk '{ sum+=$3} END {print sum/"'"$itr"'"}' data_solo.$i.ulcc.$j)"
echo "data_solo.$i.ulcc.$j- $time" >> time_mean
cmr_med="$(sed -n ''"$med"'p' data_solo.$i.ulcc.$j)"
echo "data_solo.$i.ulcc.$j- $cmr_med" >> median
mv data_solo.$i.ulcc.$j files/data_solo.$i.ulcc.$j
done
done


#strong with weak
cp infinite_version.s accesses_20_nops.s
for i in "${sdStrong[@]}"
do
for j in "${sdWeak[@]}"
do
for (( rep=1;rep<=itr;rep++))
do
for (( x=1 ; x <= nops ; x++ ))
do
	sed -i '/.L9:/a\\t nop ' accesses_20_nops.s
done
echo "$rep"
gcc accesses_20_nops.s -o accesses
numactl --physcpubind=2 --membind=0 ./infinite $j 64 &
sleep 1
numactl --physcpubind=0 --membind=0 perf stat --output=perf-out --append -B -e cache-misses,cache-references,LLC-prefetches  ./accesses $i 64 &
sleep 10
pkill infinite
pkill accesses
bash arrange.sh >> data.strong.$i.weak.$j
done
sort -n data.strong.$i.weak.$j --output=data.strong.$i.weak.$j
cmr_mean="$(awk '{ sum+=$5} END {print sum/"'"$itr"'"}' data.strong.$i.weak.$j)"
echo "data.strong.$i.weak.$j- $cmr_mean" >> cmr_mean
acc="$(awk '{ sum+=$2} END {print sum/"'"$itr"'"}' data.strong.$i.weak.$j)"
echo "data.strong.$i.weak.$j- $acc" >> acc_mean
time="$(awk '{ sum+=$3} END {print sum/"'"$itr"'"}' data.strong.$i.weak.$j)"
echo "data.strong.$i.weak.$j- $time" >> time_mean
cmr_med="$(sed -n ''"$med"'p' data.strong.$i.weak.$j)"
echo "data.strong.$i.weak.$j- $cmr_med" >> median
mv data.strong.$i.weak.$j files/data.strong.$i.weak.$j
done
done

#strong with weak and ulcc
cp infinite_version_ulcc.s accesses_20_nops.s
for k in "${color_strong[@]}"
do
for l in "${color_weak[@]}"
do
for i in "${sdStrong[@]}"
do
for j in "${sdWeak[@]}"
do
for (( rep=1;rep<=itr;rep++))
do
for (( x=1 ; x <= nops ; x++ ))
do
	sed -i '/.L16:/a\\t nop ' accesses_20_nops.s
done
echo "$rep"
gcc accesses_20_nops.s -L../../../src -Wl,-rpath,../../../src -lulcc -lpthread -o accesses
numactl --physcpubind=2 --membind=0 ./infiniteULCC $j 64 $k+1 $k+$l &
sleep 1
numactl --physcpubind=0 --membind=0 perf stat --output=perf-out --append -B -e cache-misses,cache-references,LLC-prefetches  ./accesses $i 64 $cl $k &
sleep 10
pkill infiniteULCC
pkill accesses
bash arrange.sh >> data.strong.$i.weak.$j.ulcc.$k.$l
done
sort -n data.strong.$i.weak.$j.ulcc.$k.$l --output=data.strong.$i.weak.$j.ulcc.$k.$l
cmr_mean="$(awk '{ sum+=$5} END {print sum/"'"$itr"'"}' data.strong.$i.weak.$j.ulcc.$k.$l)"
echo "data.strong.$i.weak.$j.ulcc.$k.$l- $cmr_mean" >> cmr_mean
acc="$(awk '{ sum+=$2} END {print sum/"'"$itr"'"}' data.strong.$i.weak.$j.ulcc.$k.$l)"
echo "data.strong.$i.weak.$j.ulcc.$k.$l- $acc" >> acc_mean
time="$(awk '{ sum+=$3} END {print sum/"'"$itr"'"}' data.strong.$i.weak.$j.ulcc.$k.$l)"
echo "data.strong.$i.weak.$j.ulcc.$k.$l- $time" >> time_mean
cmr_med="$(sed -n ''"$med"'p' data.strong.$i.weak.$j.ulcc.$k.$l)"
echo "data.strong.$i.weak.$j.ulcc.$k.$l- $cmr_med" >> median
mv data.strong.$i.weak.$j.ulcc.$k.$l files/data.strong.$i.weak.$j.ulcc.$k.$l
done
done
done
done

mv cmr_mean data/cmr_mean
mv acc_mean data/acc_mean
mv time_mean data/time_mean
mv median data/median
