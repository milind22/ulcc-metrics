input=perf-out
lines=8


misses=`tail -n $lines $input | grep cache-misses | cut -f 1 -d "c" | sed "s/,//g"`
accesses=`tail -n $lines $input | grep references | cut -f 1 -d "c" | sed "s/,//g"`
instr=`tail -n $lines $input | grep instructions | cut -f 1 -d "i" | sed "s/,//g"`
L1loads=`tail -n $lines $input | grep  L1-dcache-loads | cut -f 1 -d "L" | sed "s/,//g"`
L1loadsmiss=`tail -n $lines $input | grep  L1-dcache-load-misses | cut -f 1 -d "L" | sed "s/,//g"`
L1stores=`tail -n $lines $input | grep  L1-dcache-stores | cut -f 1 -d "L" | sed "s/,//g"`
L1storemisses=`tail -n $lines $input | grep  L1-dcache-store-misses | cut -f 1 -d "L" | sed "s/,//g"`
LLCprefetch=`tail -n $lines $input | grep  LLC-prefetches   | cut -f 1 -d "L" | sed "s/,//g"`
time_sec=`tail -n $lines $input | grep seconds | cut -f 1 -d "s" `
nodeprefetch=`tail -n $lines $input | grep  node-prefetches   | cut -f 1 -d "n" | sed "s/,//g"`
cmr=$((misses*100/accesses))

echo $misses $accesses $instr $time_sec $L1loads $L1loadsmiss $L1stores $L1storemisses $LLCprefetch $nodeprefetch $cmr
