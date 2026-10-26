#define MAX(a, b) \
((a) > (b) ? (a) : (b))

int main(void) {
    int i = 1, j = 2;
    int m = MAX(++i, ++j);
}
