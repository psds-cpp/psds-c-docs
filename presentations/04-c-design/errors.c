#include <stdio.h>
typedef enum {
    ERR_OK = 0,
    ERR_EMPTY,
} err_t;
int parse(int *out, const char *s) {
    if (!*s) return ERR_EMPTY;
    *out = *s - '0';
    return ERR_OK;
}
int main(void) {
    int v = 0;
    err_t e = parse(&v, "7");
    printf("%d: %d\n", e, v);
    return 0;
}
