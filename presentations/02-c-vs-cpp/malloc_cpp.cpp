#include <cstdlib>

int main() {
  // именованное приведение
  int *a = static_cast<int *>(
    std::malloc(10 * sizeof *a)
  );
  // обратно (в void*) можно
  // привести неявно
  std::free(a);
}
