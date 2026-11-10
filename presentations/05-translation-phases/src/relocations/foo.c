void bar(void);

void foo(void) {
    volatile int a = -1;
}

int main(void) {
    bar();
}
