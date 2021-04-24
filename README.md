# Docker image for nlohmann/json

This repository contains the [Dockerfile](Dockerfile) of the image used in the CI of [JSON for Modern C++](https://github.com/nlohmann/json).

The image is pushed automatically to [DockerHub](https://hub.docker.com/r/nlohmann/json-ci) and can be used with

```
docker pull nlohmann/json-ci:latest
```

## Contents

The goal is to provide a fairly recent C++ build and analysis tool chain.

Versions (as of 2021-04-24):

- Clang 12.0.1-++20210423082613+072c90a863aa-1~exp1~20210423063319.76
- GCC 11.0.1 20210321 (experimental)
- Cppcheck 2.4
- Clang-Tidy 11.1.0
- include-what-you-use 0.12
- CMake 3.20.1
- Ninja 1.10.1
- Valgrind 3.15.0
- OCLint 21.03
- PVS Studio 7.12.46137.116
- LCOV 1.14
- Artistic Style 3.1
- Infer v1.1.0

Furthermore, some "historic" C++ compilers are available:

- g++ 4.8.5
- g++ 4.9.3
- g++ 5.4.0
- g++ 7.5.0
- g++ 8.4.0
- g++ 9.3.0
- g++ 10.2.0
- clang 3.5.2
- clang 3.6.2
- clang 3.7.1
- clang 3.8.0
- clang 3.9.1
- clang 4.0.0
- clang 5.0.0
- clang 6.0.1
- clang 7.0.1
- clang 8.0.1
- clang 9.0.1
- clang 10.0.0
- clang 11.0.0
- nvcc 10.1

```
for TOOL in g++-latest clang++-12 cppcheck iwyu cmake ninja valgrind oclint pvs-studio lcov astyle infer; do echo $TOOL; $TOOL --version; echo ""; done
```
