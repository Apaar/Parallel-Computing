#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <unistd.h>
#include <fcntl.h>
#include <pthread.h>
#include <sys/mman.h>
#include <sys/stat.h>


int input_len;
static char *addr,*filename, *input;
static struct stat filedata;
static pthread_mutex_t pmutex;

//structure to pass to each thread containing the chunk to be checked
typedef struct blob 
{
   char *start;
   int len;
} blob_t;

//freeing the memory segment that was mmap'ed
void free_map(void)
{
   if (addr)
   {
      munmap(addr, filedata.st_size);
      addr = NULL;
   }
}


//handler function for each thread
void *run_blob(void *data)
{
   char *line ,*n;
   int linelen ,shift;
   blob_t *blob = (blob_t *)data;
   line = blob->start;
   shift = 0;

   while (shift < blob->len) {
      n = strchr(line, '\n');
      if(!n) {
         break;
      }

      linelen = n - line + 1;

      if (memmem(line, linelen - 1, input, input_len)) {
            printf("%.*s", (int)linelen, line);         
      }

      shift += linelen;
      line = n + 1;
   }

   return NULL;
}


#define MAX_BLOBS 16

int main(int argc, char *argv[])
{
   char *n, *last;
   pthread_t thread[MAX_BLOBS];
   blob_t blob[MAX_BLOBS];
   int num, i;

   if (argc != optind + 2) {
      puts("Error: wrong number of arguments");
      return 0;
   }

   input = argv[optind++];
   input_len = strlen(input);
   filename = argv[optind];
  
   int fd = open(filename, O_RDONLY);
   fstat(fd, &filedata) ;
   addr = mmap(NULL, filedata.st_size, PROT_READ, MAP_SHARED, fd, 0);
   atexit(free_map);
   close(fd);

   num = sysconf(_SC_NPROCESSORS_ONLN);
      if (num < 2) {
         num = 1;
      } else if (num > MAX_BLOBS) {
         num = MAX_BLOBS;
      }
   
   blob[0].start = addr;
   blob[0].len = (int)filedata.st_size / num;
   for (i = 1; i < num; i++) {
      last = blob[i - 1].start + blob[i - 1].len;
      if (last - addr >= filedata.st_size) {
         blob[0].len = (int)filedata.st_size;
         num = 1;
         break;
      }
      n = strchr(last, '\n');
      blob[i - 1].len += n - last;
      blob[i].start = n + 1;
      blob[i].len = (int)filedata.st_size / num;

      if (blob[i].start - addr >= filedata.st_size) {
         blob[0].len = (int)filedata.st_size;
         num = 1;
         break;
      }
   }

   if (num > 1) {
      int abs_start = blob[i].start - addr;
      blob[i].len = filedata.st_size - abs_start;
   }

   pthread_mutex_init(&pmutex, NULL);

   for (i = 0; i < num; i++) {
      pthread_create(&thread[i], NULL, &run_blob, (void *)&blob[i]);
   }

   for (i = 0; i < num; i++) {
      pthread_join(thread[i], NULL);
   }

   pthread_mutex_destroy(&pmutex);

   return 0;
}
