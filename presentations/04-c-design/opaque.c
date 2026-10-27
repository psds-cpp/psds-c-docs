#include "opaque.h"
#include <stdio.h>
struct secret { int n; };
static struct secret obj;
sec_t *sec_new(int n) {
    obj.n = n;
    return &obj;
}
int sec_get(sec_t *s) {
    return s->n;
}
int main(void) {
    sec_t *s = sec_new(42);
    printf("%d\n",
           sec_get(s));
    return 0;
}
