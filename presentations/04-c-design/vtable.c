#include <stdio.h>
struct dev { const struct ops *ops; const char *name; };
struct ops {
    void (*open)(struct dev *d);
    void (*close)(struct dev *d);
};
static void tty_open(struct dev *d) { puts("open"); }
static void tty_close(struct dev *d) { puts("close"); }
static const struct ops tty_ops = { tty_open, tty_close };
int main(void) {
    struct dev d = { &tty_ops, "tty0" };
    d.ops->open(&d);
    d.ops->close(&d);
    return 0;
}
