#include <stdio.h>

// print Value and Comma
#define VC(X) printf("%s, ", #X)

int main(void) {
    VC(1);
    VC(3.14);
    printf("text\n");
}
