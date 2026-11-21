cmake_minimum_required(VERSION 3.21)

project(HelloWorld
  VERSION 1.0.0
  DESCRIPTION "Minimal cross-platform C++ hello world"
  LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

add_executable(hello src/main.cpp)

target_compile_options(hello PRIVATE
  $<$<CXX_COMPILER_ID:GNU,Clang,AppleClang>:-Wall -Wextra -Wpedantic>
  $<$<CXX_COMPILER_ID:MSVC>:/W4>)

install(TARGETS hello RUNTIME DESTINATION bin)
