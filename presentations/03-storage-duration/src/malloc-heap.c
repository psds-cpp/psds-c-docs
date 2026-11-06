#include <stdlib.h>

int main(void)
{
  int *p = malloc(3 * sizeof *p);
  if (p == NULL)
    return 1;
  p[0] = 1; p[1] = 2; p[2] = 3;
  free(p);
  return 0;
}
