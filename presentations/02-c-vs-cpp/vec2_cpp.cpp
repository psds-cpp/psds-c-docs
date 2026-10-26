#include <iostream>

struct Vec2 {
    double x, y;

    Vec2 operator+(const Vec2 &o) const {
        return {x + o.x, y + o.y};
    }
};

int main() {
    Vec2 u{1.0, 2.0};
    Vec2 w{3.0, 4.0};
    Vec2 v = u + w;   /* так можно */
    std::cout << v.x << ' ' << v.y << '\n';
}
