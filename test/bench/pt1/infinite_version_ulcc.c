#include <sys/time.h>
#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include "../../../src/ulcc.h"
static unsigned long x=123456789, y=362436069, z=521288629;
#define CACHE_SIZE 3072

unsigned long xorshf96(void) {          //period 2^96-1
unsigned long t;
    x ^= x << 16;
    x ^= x >> 5;
    x ^= x << 1;

   t = x;
   x = y;
   y = z;
   z = t ^ x ^ y;

  return z;
}

int *data_start, *data_end;
const long int size=2048000;
int linesize = 64 / sizeof(int);
int ways; // range 4 - 20
int stride,color_low,color_high;
void * buffer;
#define num_sets (CACHE_SIZE*1024)/(12*64)
int dump[100];

unsigned long long int val=0;
float val2=100, val1=100;
void init_buffer()
{
	int i;
	int j, flag;
	cc_cacheregn_t regn;
	int *p;

	buffer = malloc(sizeof(int)*num_sets*ways*linesize);
	printf(" allocating a total of %ldMB \n",sizeof(int)*num_sets*ways*linesize/(1024*1024));

// 	insert ulcc here
	
	data_start = (int *)ULCC_ALIGN_HIGHER((unsigned long)buffer);
	data_end = (int *)ULCC_ALIGN_LOWER((unsigned long)(buffer+(sizeof(int)*num_sets*ways*linesize)));
	
	cc_cacheregn_clr(&regn);
	cc_cacheregn_set(&regn, color_low, color_high, 1);

	if(cc_remap((unsigned long *)&data_start, (unsigned long *)&data_end, 1,
			&regn, CC_ALLOC_NOMOVE | CC_MAPORDER_SEQ) < 0) {
		fprintf(stderr, "failed to remap data region 1\n");
		return;
	}
	//printf("%d\n",*data_end);
	
	srand(time(NULL));
	p=(int *)buffer;
	for(p = (int *)data_start; p<(int *)data_end; p++) {
		*p = (rand()%128);
	}
}
#define NUMACCESS 100000000


void access_pattern(int stride)
{
  unsigned int i,j,jj,st;
  int flag;
  int cnt=1;
  int *p = (int *)buffer;
	
  while(1)
  //for(cnt=1;cnt<NUMACCESS;cnt+=ways*num_sets)
  {
      for(i=0;i<ways;i++)
      {
        for(st=0;st<=stride-1;st++)
        {
		  for(j=1;j<num_sets/stride;j++)
		  {
			jj = st + (j-1) * stride;		
            val += p[ (i*num_sets + jj)*linesize];
		  }
        }
      }
  }
}

int main(int argc, char ** argv)
{
	struct timeval t1, t2;
	srandom(time(NULL));
	printf("argc = %d\n",argc);
        if(argc == 5)
        {
        ways = atoi(argv[1]);
		stride=atoi(argv[2]);
		color_low =atoi(argv[3]);
		color_high=atoi(argv[4]);
        }
	else
	{
		printf("Usage: ways (4-20) \n");
		exit(0);
	}

	gettimeofday(&t1, NULL);
	init_buffer();
	gettimeofday(&t2,NULL);
	printf("%ld useconds \n",(t2.tv_usec - t1.tv_usec + (t2.tv_sec - t1.tv_sec)*1000000));

	access_pattern(stride);
       
	printf("done\n"); 
        //dummy(val);
}
//typcast *p=*buffer
