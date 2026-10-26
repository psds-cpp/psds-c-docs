#include <errno.h>
#include <stdio.h>

int main(void) {
  FILE *f =
    fopen("data.txt", "r");
  if (!f) {
    printf("%d\n", errno);
    return 1;
  }
}
