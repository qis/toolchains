#include <algorithm>
#include <execution>
#include <random>
#include <vector>

int main() {
  std::random_device rd;
  std::uniform_int_distribution<int> dist(0, std::numeric_limits<int>::max());
  std::vector<int> v(10000);
  for (auto i = 0; i < 100; i++) {
    std::generate(std::execution::par, v.begin(), v.end(), [&] () {
      return dist(rd);
    });
  }
}
