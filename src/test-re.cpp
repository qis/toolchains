#include <regex>
#include <string>

int main() {
  std::regex re("^[a-z]+[0-9]+$", std::regex_constants::extended | std::regex_constants::nosubs);
  return std::regex_search("test0159", re) ? 0 : -1;
}

