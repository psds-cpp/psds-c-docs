#include <fstream>

int main() {
  using namespace std;
  try {
    ifstream f("data.txt");
    if (!f) {
      throw 1;
    }
  }
  catch (...) {}
}
