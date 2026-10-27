#include <stdio.h>

struct dev {
    void (*open)(struct dev *d);
    void (*close)(struct dev *d);
    const char *name;
};

static void tty_open(struct dev *d) { puts("open"); }
static void tty_close(struct dev *d) { puts("close"); }

int main(void) {
    struct dev d = { &tty_open, &tty_close, "tty0" };
    d.open(&d);
    d.close(&d);
}
