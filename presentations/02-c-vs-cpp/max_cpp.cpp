template <typename T>
T my_max(T a, T b) {
    return a > b ? a : b;
}

int main() {
    int i = 1, j = 2;
    int m = my_max(i++, j++);
}
