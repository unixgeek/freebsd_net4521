cmake_minimum_required(VERSION 2.8)
project(compare)

# For FreeBSD 8.4
set(CMAKE_CXX_STANDARD 98)

add_executable(compare main.cpp Config.cpp Config.h)
