#include <filesystem>
#include <windows.h>

int main() {
  return std::filesystem::current_path().empty() ? -1 : 0;
}

