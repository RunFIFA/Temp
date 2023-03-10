#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <unistd.h>
#include <sys/types.h>
#include <sys/wait.h>
  
void test( void )
{
    int count = 100000000;
    double testmun;
    
    double begintime = clock();
    while(count-- > 0)
    {
        testmun = rand()*rand();
    }
    double finishtime = clock();
    double duration = (double)(finishtime - begintime) / CLOCKS_PER_SEC;
    printf("Chind process: Test time is %f seconds, standard : 2s \n", duration);

}


int main() {
    pid_t pid;
    for ( int num_process = 1; num_process <= 8; num_process++)
    {
        
        printf(" ------------------------ Performance Test %d ------------------------ \n",num_process);
        printf("Create %d child process to test...\n", num_process);
        
        for(int i = 0; i < num_process; i++) {
            pid = fork();
            if(pid == 0) {
                test();
                exit(0);
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
    }
    return 0;
}
