#include <stdio.h>

struct Vec2 {
    double x, y;
};

static struct Vec2 vec_add(struct Vec2 a, struct Vec2 b) {
    struct Vec2 r = {a.x + b.x, a.y + b.y};
    return r;
}

int main(void) {
    struct Vec2 u = {1.0, 2.0};
    struct Vec2 w = {3.0, 4.0};
    struct Vec2 v = vec_add(u, w);   /* v = u + w — так нельзя */
    printf("%g %g\n", v.x, v.y);
    return 0;
}
