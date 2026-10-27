#include "handle.h"

struct item { int value; };
static struct item pool[8];

handle_t item_new(int v) {
    static int n;
    if (n == 8) return (handle_t)-1;
    pool[n].value = v;
    return (handle_t)n++;
}

int item_get(handle_t h) { return pool[h].value; }
