#include "lifecycle.h"
#include <stdlib.h>

struct cfg { int cap; };

struct cfg *cfg_init(int cap) {
    if (cap <= 0) return NULL;
    struct cfg *c = malloc(sizeof *c);
    if (c) c->cap = cap;
    return c;
}

void cfg_deinit(struct cfg *c) { free(c); }
