#include <stdio.h>
#include <stdlib.h>
struct cfg { int cap; };
struct cfg *cfg_init(int cap) {
    if (cap <= 0) return NULL;
    struct cfg *c = malloc(sizeof *c);
    if (c) c->cap = cap;
    return c;
}
void cfg_deinit(struct cfg *c) { free(c); }
int main(void) {
    struct cfg *c = cfg_init(4);
    printf("%d\n", c ? c->cap : -1);
    cfg_deinit(c);
    return 0;
}
