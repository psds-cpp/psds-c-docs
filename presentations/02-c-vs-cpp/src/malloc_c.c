#include <stdlib.h>

int main(void) {
  // неявное приведение, так
  // как malloc возвращает void*
  int *a = malloc(1 * sizeof *a);
  // обратное приведение, free
  // принимает void*, тоже
  // неявное
  free(a);
}
