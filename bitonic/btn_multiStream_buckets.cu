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

__global__ void bitonic_kernel(idata* d,int cd,int cbs)
{
    idata temp;
    int i = threadIdx.x + blockDim.x * blockIdx.x;
    int j = i^cd;
    if(j>i)
    {
        if((i&cbs)==0) //Sort in Increasing order
        {
            if(d[i]>d[j])
            {
                temp = d[i];
                d[i] = d[j];
                d[j] = temp;
                
            }
        }
        else //Sort in decreasing order
        {
            if(d[i]<d[j])
            {
                temp = d[i];
                d[i] = d[j];
                d[j] = temp;
                
            }
        }
    }
}


__global__ void null_kernel() {
	//do nothing
}

void btns(idata *cuda_inpoup,int N,int num_streams,int cbsi) 
{

	int num_of_blocks =int( ceil((double)N/1024));
	int num_of_threads = N/num_of_blocks;

	int cbs; //current bitonic sequence length
	int cd; //comparison distance
	
	cudaStream_t streams[num_streams];
	for (int i = 0; i < num_streams; i++) {
		cudaStreamCreate(&streams[i]);
    		for(cbs=cbsi; cbs<=N; cbs=cbs<<1) 
    		{
        		for(cd=cbs>>1; cd>0; cd=cd>>1)
        		{
           		 bitonic_kernel<<<num_of_blocks,num_of_threads,0,streams[i]>>>(cuda_inpoup,cd,cbs);
        		}
    		}

	}
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

void oets(idata *cuda_inpoup,int Ns, int num_streams) 
{

	int num_of_blocks =int( ceil((double)Ns/1024));
	int num_of_threads = (Ns<1024?Ns:1024);
	cudaStream_t streams[num_streams];
	for (int i = 0; i < num_streams; i++) {
		cudaStreamCreate(&streams[i]);
 
		for(int j=0;j<=Ns/2;j++){
			even_kernel<<<num_of_blocks,num_of_threads,0,streams[i] >>>(cuda_inpoup+i*Ns,Ns);
    			odd_kernel<<<num_of_blocks,num_of_threads,0,streams[i] >>>(cuda_inpoup+i*Ns,Ns);
			}
		
	}

}

__global__ void swap(idata* d,int N) {

	int j = blockDim.x * blockIdx.x + threadIdx.x ;
	idata temp;
	if(j <  N/2){
		temp = d[j];
		d[j] = d[N-1-j];
		d[N-1-j] = temp;
	}
}

void reverse(idata *d,int Ns) {
	int num_of_blocks =int( ceil((double)Ns/1024));
	int num_of_threads = (Ns<1024?Ns:1024);
	swap<<<num_of_blocks,num_of_threads>>>(d,Ns);
}

int main(int argc, char *argv[]) {
  
    int N;
    idata  *sptr,*aptr;
    sptr = NULL;
    aptr = NULL;
    char *filename = NULL;
	clock_t start, end;
	
    N   = atoi(argv[1]);
    filename = argv[2];
    int num_batches   = atoi(argv[3]);

    fprintf(stdout,"N=%d filename=%s\n",N,filename);
    sptr  = (idata *) malloc(N*sizeof(idata));
    
    readDataFromFile(sptr,N,filename);
    //printf("Input Data is:-\n");
    //printData(sptr,N);


    idata *cuda_inpoup;
    cudaMalloc(&cuda_inpoup, N * sizeof(idata));
    cudaMemcpy(cuda_inpoup,sptr,N*sizeof(idata), cudaMemcpyHostToDevice);

    start = clock();
    int num_streams = num_batches;
    int N_per_stream = N/num_streams;
    aptr = cuda_inpoup;
    int cbs=2;
    btns(aptr,N_per_stream,num_streams,cbs);


    cudaDeviceSynchronize(); 
    
    num_streams = 1; 
    N_per_stream = 2*N/num_batches; 
    int N_rev=N_per_stream/2; 
    cbs = N_per_stream;
    for(int i=0;i<num_batches/2;i++) { 
			              
       for(int j=0;j<num_batches/2;j++) {   //even round 
       		aptr = cuda_inpoup + (2*j*N)/num_batches; 
 	        reverse(aptr+N_rev,N_rev); 
 		btns(aptr,N_per_stream,num_streams,cbs); 
   	} 
        
	cudaDeviceSynchronize(); 
  	       
  	for(int j=0;j+1<num_batches/2;j++) { // odd round 
  		 aptr = cuda_inpoup + (((2*j)+1)*N)/num_batches; 
                 reverse(aptr+N_rev,N_rev); 
                 btns(aptr,N_per_stream,num_streams,cbs); 
   	} 
   			        
        cudaDeviceSynchronize(); 
    } 
    
    end = clock();
    cudaMemcpy(sptr,cuda_inpoup,N*sizeof(idata), cudaMemcpyDeviceToHost);
//    printf("Sorted Array is:\n");
//    printData(sptr,N);
    printElaspedTime(start,end);
	return 0;

}

