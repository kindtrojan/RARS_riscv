#include <stdio.h>

void recurse(int iteration) {
  int dummy[10];

  if(iteration == 0) {
    return;
  }
  recurse(iteration - 1);
}

int main(void) {
  int i;

  printf("The size of an int is %lu bytes\n", sizeof(int));
  printf("Please enter a number of iterations: ");
  scanf("%d", &i);
  recurse(i);
  return 0;
}

