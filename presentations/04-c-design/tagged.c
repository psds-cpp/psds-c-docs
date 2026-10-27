#include <stdio.h>
enum kind { K_INT, K_STR };
struct val {
    enum kind k;
    union { int i; const char *s; } u;
};
int val_get_int(const struct val *v) {
    return v->k == K_INT ? v->u.i : -1;
}
int main(void) {
    struct val a = { .k = K_INT, .u.i = 42 };
    struct val b = { .k = K_STR, .u.s = "hi" };
    printf("%d %d\n", val_get_int(&a), val_get_int(&b));
    return 0;
}
