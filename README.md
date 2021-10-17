# Docker image for nlohmann/json

This repository contains the [Dockerfile](Dockerfile) of the image used in the CI of [JSON for Modern C++](https://github.com/nlohmann/json).

The image is pushed automatically to [DockerHub](https://hub.docker.com/r/nlohmann/json-ci) and can be used with

```
docker pull nlohmann/json-ci:latest
```

## Contents

The goal is to provide a fairly recent C++ build and analysis tool chain.

Versions (as of 2021-10-17):

- Clang 14.0.0-++20211015062452+81e9c90686f7-1~exp1~20211015063048.20
- GCC 11.1.0
- ICC 2021.3.0 20210609
- Intel(R) oneAPI DPC++ Compiler 2021.3.0 (2021.3.0.20210619)
- Cppcheck 2.7 dev
- Clang-Tidy 14.0.0
- include-what-you-use 0.12
- CMake 3.21.3
- Ninja 1.10.1
- Valgrind 3.15.0
- OCLint 21.05
- PVS Studio 7.15.53134.163
- LCOV 1.14
- Artistic Style 3.1
- Infer v1.1.0

Furthermore, some "historic" C++ compilers are available:

- g++ 4.8.5
- g++ 4.9.3
- g++ 5.4.0
- g++ 6.4.0
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
- clang 12.0.0
- clang 13.0.1-++20211015123032+cf15ccdeb6d5-1~exp1~20211015003613.5
- nvcc 10.1.243


### Scripts

Make Intel compilers available:

```sh
source /opt/intel/oneapi/setvars.sh
```

Collect all versions:

```sh
for TOOL in g++-11 clang++-14 icpc icpx cppcheck iwyu cmake ninja valgrind oclint pvs-studio lcov astyle infer nvcc; do echo $TOOL; $TOOL --version; echo ""; done
```
