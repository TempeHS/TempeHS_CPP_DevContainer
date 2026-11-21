#include <iostream>
#include <string_view>

namespace {

constexpr std::string_view platform_name() {
#if defined(_WIN32)
    return "Windows";
#elif defined(__APPLE__)
    return "macOS";
#elif defined(__linux__)
    return "Linux";
#else
    return "Unknown";
#endif
}

}  // namespace

int main() {
    std::cout << "Hello, World!\n";
    std::cout << "Built for: " << platform_name() << '\n';
    std::cout << "Compiler:  "
#if defined(__clang__)
              << "Clang " << __clang_major__ << '.' << __clang_minor__
#elif defined(__GNUC__)
              << "GCC " << __GNUC__ << '.' << __GNUC_MINOR__
#elif defined(_MSC_VER)
              << "MSVC " << _MSC_VER
#else
              << "unknown"
#endif
              << '\n';
    return 0;
}
