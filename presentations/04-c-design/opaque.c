#include "opaque.h"

struct secret { int n; };
static struct secret obj;

// library implementation
sec_t *sec_new(int n) {
    obj.n = n;
    return &obj;
}

int sec_get(sec_t *s) {
    return s->n;
}
