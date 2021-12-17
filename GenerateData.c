#include <math.h>
#include <stdio.h>
#include <stdlib.h>
#include <limits.h>

typedef  unsigned int    idata;
#define MODULO_UINT ((unsigned int) 0x7FFFFFFF)
#define myfilename "SortingInputFile.txt"

void generateData   (idata *d, int N, int type);
void writeDataToFile (idata *d,int N);
void printData (idata *d,int N);
void readDataFromFile(idata *d,int N); 

void readDataFromFile(idata *d,int N) 
{
    printf("Reading Data From File\n");
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
            printf ("%d\n", val);     
        }
        printf("Reading Input Over\n");
        fclose (fp);    
    } 
}

void printData (idata *d,int N) 
{
    int i;
    printf("Generated Input Data is:-\n");
    for (i=0;i<N;i++) {
        printf("i=%d,d[i]=%d\n",i,d[i]);
    }
}

void writeDataToFile (idata *d,int N) 
{

    FILE *fp = fopen(myfilename, "w");
    if (fp == NULL)
    {
        puts("Couldn't open file");
        exit(0);
    }
    else
    {   
        int i;
        for (i=0;i<N;i++) {
           fprintf(fp, "%d", d[i]);
           fputs("\n",fp);
        }
        fclose(fp);
    }
}

void generateData  (idata *d, int N, int type)
{
int i;


srandom(21+1001*11);
if (type == 1) {
    for (i=0;i<N;i++) {
        d[i]= (idata ) (random() & MODULO_UINT);
        }
    } 
    else 
    if (type == 2) {
        for (i=0;i<N;i++) {
        d[i]= (idata )  ((N)*(random()/((double)INT_MAX)));
        }
    }
    else
    if (type == 3) {
        for (i=0;i<N;i++) {
        d[i]= (idata )  (i+1);
        }
    }
    else
    if (type == 4) {
        for (i=0;i<N;i++) {
        d[i]= (idata )  (17);
        }
    }
    else {
    for (i=0;i<N;i++) {
        d[i]= (idata )  (N-i);
        }
    }
}

int main(int argc, char *argv[]) {
  
    int N,type,runs,debug,np;
    idata  *sptr,*optr;
    sptr = NULL;
    optr = NULL;
  
    if(argc<3)
        {
            printf("Script usage:- ./a.out <TotalNumOfKeys> <TypeNumber> "); 
            return 0;
        }
   
    N   = atoi(argv[1]);
    type = atoi(argv[2]);
  
    fprintf(stdout,"N=%d type=%d\n",N,type);
    sptr  = (idata *) malloc(N*sizeof(idata));
    optr  = (idata *) malloc(N*sizeof(idata));
    generateData(sptr,N,type);
    writeDataToFile(sptr,N);
    readDataFromFile(optr,N);
    printData(optr,N);

    return 0;

}