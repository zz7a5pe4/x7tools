#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <stdio.h>
#include <assert.h>
#include <time.h>
#include <inttypes.h>
#include <stdlib.h>
#include <unistd.h>

uint64_t randfile(char* name, int filelen, int recordlen);
char* allocrandomstring(int strlen);

uint64_t diff(struct timespec start, struct timespec end)
{
  struct timespec temp;
  if ((end.tv_nsec-start.tv_nsec)<0) {
    temp.tv_sec = end.tv_sec-start.tv_sec-1;
    temp.tv_nsec = 1000000000+end.tv_nsec-start.tv_nsec;
  } else {
    temp.tv_sec = end.tv_sec-start.tv_sec;
    temp.tv_nsec = end.tv_nsec-start.tv_nsec;
  }
  return temp.tv_sec * 1000000000 + temp.tv_nsec;
}



uint64_t randfile(char* name, int filelen, int recordlen)
{
  int randomData = open("/dev/urandom", O_RDONLY);
  assert(filelen > 0);
  assert(recordlen > 0);
  char randbuf[recordlen];
  int outfs = 0;
  int writelen = 0;
  struct timespec time1, time2;

  read(randomData, randbuf, recordlen);
  clock_gettime(CLOCK_MONOTONIC, &time1);
  outfs = open(name, O_CREAT | O_RDWR | O_TRUNC | O_SYNC, S_IRWXU);
  if(outfs < 0)
    {
      // error
      printf("create tmp file error\n");
      return -1;
    }

  while(filelen > 0)
    {
      writelen  = filelen > recordlen ? recordlen : filelen;
      writelen = write(outfs, randbuf, writelen);
      filelen -= writelen;
    }

  close(outfs);
  clock_gettime(CLOCK_MONOTONIC, &time2);
  close(randomData);
  return diff(time1, time2);
}

char allchar[]="abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ";

// remember to free ret later
char* allocrandomstring(int strlen)
{
  assert(strlen > 0);
  char* ret = (char*)malloc(strlen + 1);
  int i = 0;
  int randomData = open("/dev/urandom", O_RDONLY);
  read(randomData, ret, strlen);
  close(randomData);
  
  for(i = 0; i < strlen; i++)
    {
      ret[i] = allchar[(128+ret[i])%52];
    }
  ret[strlen] = 0;
  return ret;
}

int randomint()
{
  int ret;
  int randomData = open("/dev/urandom", O_RDONLY);
  read(randomData, &ret, 4);
  close(randomData);
  return ret;
}

int smallfiletest(int maxsize, int number)
{
  assert(maxsize > 0);
  assert(number > 0);

  int i;
  uint64_t totalsize = 0;
  uint64_t totaltime = 0;
  unsigned int filesize = 0;
  char filename[128] = {0};
  char *tmpprefix = allocrandomstring(4);

  for(i = 0; i < number; i++)
    {
      snprintf(filename, 128, "./tmp/%s_%08d", tmpprefix, i);
      filesize = ((unsigned int)randomint()) % maxsize + 1;
      totalsize += filesize;
      totaltime += randfile(filename, filesize, 4096);
    }
  free(tmpprefix);
  printf("total write size is %ju, total write time is %ju, speed is: %fKByte/s\n", totalsize, totaltime, (double)totalsize*1000000000/totaltime/1024);
  return 0;
}

int main(int argc, char* argv[])
{
  //char *x = allocrandomstring(123);
  //printf("%s\n", x);
  int filesize = 0;
  int filenumber  = 0;
  if(argc < 3)
    {
      printf("usage: %s FILESIZE FILENUMBER\n", argv[0]);
      return -1;
    }
  struct timespec time1, time2;
  filesize = atoi(argv[1]);
  filenumber = atoi(argv[2]);
  if(filesize == 0)
    filesize =  65536;
  if(filenumber == 0)
    filenumber = 100000;
  clock_gettime(CLOCK_MONOTONIC, &time1);
  smallfiletest(filesize, filenumber);
  clock_gettime(CLOCK_MONOTONIC, &time2);
  printf("total time is %jums\n", diff(time1, time2)/1000000);
  //free(x);
  return 0;
}
