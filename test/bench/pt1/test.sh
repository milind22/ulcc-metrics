nops=10					#specify the no. of nops to be inserted
color_upper=125			#specify the upper limit of number of colors to be assigned
stack_dist=100			#specify the upper limit of stack distance
itr=50					#specify the no. of iterations to be made

cl=0

med=$((itr / 2))

gcc -S infinite_version_ulcc.c
#solo with ulcc
mkdir data
cp infinite_version_ulcc.s accesses__nops.s
for (( i=10 ; i<= stack_dist ; i=i+10 ))
do
mkdir cmrVScolor_$i
for (( j=0 ; j<= color_upper ; j=j+5 ))
do
for (( rep=1 ; rep<=itr ; rep++))
do
for (( x=1 ; x <= nops ; x++ ))
do
	sed -i '/.L16:/a\\t nop ' accesses__nops.s
done
echo "$rep"
gcc accesses__nops.s -L../../../src -Wl,-rpath,../../../src -lulcc -lpthread -o accesses
numactl --physcpubind=0 --membind=0 perf stat --output=perf-out --append -B -e cache-misses,cache-references,LLC-prefetches  ./accesses $i 64 $cl $j &
sleep 10
pkill accesses
bash arrange.sh >> data_solo.$i.ulcc.$j
done
sort -n data_solo.$i.ulcc.$j --output=data_solo.$i.ulcc.$j
cmr_mean="$(awk '{ sum+=$5} END {print sum/"'"$itr"'"}' data_solo.$i.ulcc.$j)"
echo "$cmr_mean" >> cmr_mean$i
acc="$(awk '{ sum+=$2} END {print sum/"'"$itr"'"}' data_solo.$i.ulcc.$j)"
echo "$acc" >> acc_mean$i
time="$(awk '{ sum+=$3} END {print sum/"'"$itr"'"}' data_solo.$i.ulcc.$j)"
echo "$time" >> time_mean$i
cmr_med="$(sed -n ''"$med"'p' data_solo.$i.ulcc.$j)"
echo "$cmr_med" >> median$i
mv data_solo.$i.ulcc.$j cmrVScolor_$i/data_solo.$i.ulcc.$j
done
mv cmr_mean$i data/cmr_mean$i
mv acc_mean$i data/acc_mean$i
mv time_mean$i data/time_mean$i
mv median$i data/median$i
done
