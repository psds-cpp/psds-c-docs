#include <stdio.h>

int counter(void)
{
    static int n = 0;
    return ++n;
}

int main(void)
{
    for (int i = 0; i < 3; ++i)
        printf("%d\n", counter());
    return 0;
}
