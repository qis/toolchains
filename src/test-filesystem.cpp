#include <filesystem>

int main() {
  return std::filesystem::current_path().empty() ? -1 : 0;
}

