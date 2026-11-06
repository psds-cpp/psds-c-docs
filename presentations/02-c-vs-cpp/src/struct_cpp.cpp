#include <iostream>

struct Point {
    int x;
    int y;
};

int main() {
    Point p{3, 4};
    std::cout << p.x << ' '
        << p.y << '\n';
}
