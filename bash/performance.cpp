#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <unistd.h>
#include <sys/types.h>
#include <sys/wait.h>
  
int test( void )
{
    int count = 300000000;
    double testmun;
    
    double begintime = clock();
    while(count-- > 0)
    {
        testmun = rand()*rand()*rand()*rand();
        //int* p = (int*)malloc(1024*1024*1024);
        // printf("\rtest num is: %f", testmun);
    }
    double finishtime = clock();
    double duration = (double)(finishtime - begintime) / CLOCKS_PER_SEC;
    printf("Chind process Test time to do count is %f seconds, standard : 10s \n", duration);
}


int main() {

    pid_t pid;
    int num_process = 1;
    
    printf("Performance Test start, Parent, pid = %d\n",getpid());
    printf("Create %d child process to test...\n", num_process);
    
    for(int i = 0; i < num_process; i++) {
        pid = fork();
        if(pid == 0) {
            break;
        }
    }

    if(pid > 0) {
        while(1) {
            int ret = wait(NULL);
            if(ret == -1) {
                break;
            }
        }
    }
    
    if (pid == 0){
        test();
        exit(0);
    }

    return 0;
}