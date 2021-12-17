#include<stdio.h>
#include<cuda.h>
#include <time.h>

typedef  unsigned int    idata;

void printData (idata *d,int N);
void readDataFromFile(idata *d,int N,char *);

void readDataFromFile(idata *d,int N,char *myfilename) 
{
    //printf("Reading Data From File\n");
    FILE* fp = fopen (myfilename, "r");
    unsigned int val = 0;
    int i;
    if (fp == NULL)
      {
         puts("Couldn't open file");
         exit(0);
      }
    else
    {   
        for (i=0;i<N;i++)
        {  
            fscanf (fp, "%d", &val);   
            d[i] = val;
            //printf ("%d\n", val);     
        }
       // printf("Reading Input Over\n");
        fclose (fp);    
    } 
}

void printData (idata *d,int N) 
{
    int i;
    for (i=0;i<N;i++) {
        printf("%d  ",d[i]);
    }
    printf("\n");

}

void printElaspedTime(clock_t start,clock_t end) 
{
    double cpu_time_used;
    cpu_time_used = ((double) (end - start)) / CLOCKS_PER_SEC;
    //printf("\n\nRunning Time=%f seconds\n\n",cpu_time_used);
    printf("\nsort,oets,cuda,%f\n",cpu_time_used);

}


__global__ void even_kernel(idata* d,int N)
{
	int index = blockDim.x * blockIdx.x + threadIdx.x ;
	index = index * 2 ;
    int temp;
    
	if(index <=  N-2){
		if(d[index]>d[index+1]){
			temp=d[index];
			d[index]=d[index+1];
			d[index+1]=temp;
		}
	}
	
}

__global__ void odd_kernel(idata* d,int N)
{
	int index = blockDim.x * blockIdx.x + threadIdx.x ;
	index = index * 2 + 1;
    int temp;
    
	if(index <=  N-2){
		if(d[index]>d[index+1]){
			temp=d[index];
			d[index]=d[index+1];
			d[index+1]=temp;
		}
	}
	
}

void oets(idata *d,int N) 
{
    clock_t start, end;
	idata *cuda_inpoup;
	int i;
	cudaMalloc((void**)&cuda_inpoup, N*sizeof(idata));
	cudaMemcpy(cuda_inpoup,d,N*sizeof(idata),cudaMemcpyHostToDevice);
    start = clock();

	int num_of_blocks =int( ceil((double)N/1024));
	int num_of_threads = (N<1024?N:1024);
	for(i=0;i<=N/2;i++){
		even_kernel<<<num_of_blocks,num_of_threads>>>(cuda_inpoup,N);
    	odd_kernel<<<num_of_blocks,num_of_threads>>>(cuda_inpoup,N);
	}
    cudaDeviceSynchronize();
    end = clock();
	cudaMemcpy(d,cuda_inpoup,N*sizeof(idata), cudaMemcpyDeviceToHost);
	cudaFree(d);
    printElaspedTime(start,end);

}

int main(int argc, char *argv[]) {
  
    int N;
    idata  *sptr;
    sptr = NULL;
    char *filename = NULL;
	
    N   = atoi(argv[1]);
    filename = argv[2];

    fprintf(stdout,"N=%d filename=%s\n",N,filename);
    sptr  = (idata *) malloc(N*sizeof(idata));
    
    readDataFromFile(sptr,N,filename);
    //printf("Input Data is:-\n");
    //printData(sptr,N);

    oets(sptr,N);
    //printf("Sorted Array is:\n");
    //printData(sptr,N);
	return 0;

}

