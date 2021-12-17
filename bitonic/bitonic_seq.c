#include<stdio.h>
#include <time.h>
#include <stdlib.h>


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
   // printf("\n\nRunning Time=%f seconds\n\n",cpu_time_used);
    printf("\nsort,btns,seq,%f\n",cpu_time_used);

}

void btns(idata *d,int N)
{
    
    int i;
    idata temp;
    int cbs; //current bitonic sequence length
    int cd; //comparison distance
    
    for(cbs=2; cbs<=N; cbs=cbs<<1) 
    {
        for(cd=cbs>>1; cd>0; cd=cd>>1)
        {
            for(i=0;i<N;i++)
            {
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
        }
    }

}


int main(int argc, char *argv[]) {
  
    int N;
    idata  *sptr;
    sptr = NULL;
    char *filename = NULL;
	clock_t start, end;
	
    N   = atoi(argv[1]);
    filename = argv[2];

    fprintf(stdout,"N=%d filename=%s\n",N,filename);
    sptr  = (idata *) malloc(N*sizeof(idata));
    
    readDataFromFile(sptr,N,filename);
    //printf("Input Data is:-\n");
    //printData(sptr,N);

	start = clock();
    btns(sptr,N);
    end = clock();
   // printf("Sorted Array is:\n");
   // printData(sptr,N);
    printElaspedTime(start,end);

}
