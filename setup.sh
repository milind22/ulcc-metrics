cache_size=3072			#Last level cache size in KiB
cache_assoc=12			#Last level cache associativity
page_bits=12			#Number of bits for the size of a memory page: 4KiB should be pretty standard

sed -i 's/.*#define ULCC_CACHE_KB.*/#define ULCC_CACHE_KB '"$cache_size"'/g' src/arch.h
sed -i 's/.*#define ULCC_CACHE_ASSOC.*/#define ULCC_CACHE_ASSOC '"$cache_assoc"'/g' src/arch.h
sed -i 's/.*#define ULCC_PAGE_BITS.*/#define ULCC_PAGE_BITS '"$page_bits"'/g' src/arch.h
sed -i 's/.*#define CACHE_SIZE.*/#define CACHE_SIZE '"$cache_size"'/g' test/bench/pt1/infinite_version_ulcc.c
sed -i 's/.*#define CACHE_SIZE.*/#define CACHE_SIZE '"$cache_size"'/g' test/bench/pt2/infinite_version.c
sed -i 's/.*#define CACHE_SIZE.*/#define CACHE_SIZE '"$cache_size"'/g' test/bench/pt2/infinite_version_ulcc.c

cd src

make
