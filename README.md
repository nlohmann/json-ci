# Docker image for nlohmann/json

This repository contains the [Dockerfile](Dockerfile) of the image used in the CI of [JSON for Modern C++](https://github.com/nlohmann/json).

The image is pushed automatically to [DockerHub](https://hub.docker.com/r/nlohmann/json-ci) and can be used with

```
docker pull nlohmann/json-ci:latest
```

## Contents

The goal is to provide a fairly recent C++ build and analysis tool chain.

Versions (as of 2022-04-04):

- Clang 15.0.0-++20220403052648+896770c9a92e-1~exp1~20220403172744.209
- GCC 12.0.0 20220116 (experimental)
- ICC 2021.5.0 20211109
- Intel(R) oneAPI DPC++ Compiler 2022.0.0 (2022.0.0.20211123)
- Cppcheck 2.7 dev
- Clang-Tidy 15.0.0
- include-what-you-use 0.12
- CMake 3.23.0
- Ninja 1.10.0
- Valgrind 3.15.0
- OCLint 22.02
- PVS Studio 7.17.56957.190
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
- g++ 11.1.0
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
- Clang 14.0.1-++20220402053234+23d08271a4b2-1~exp1~20220402053315.111
- nvcc 11.0.221


### Scripts

Make Intel compilers available:

```sh
source /opt/intel/oneapi/setvars.sh
```

Collect all versions:

```sh
for TOOL in g++-latest clang++-14 icpc icpx cppcheck iwyu cmake ninja valgrind oclint pvs-studio lcov astyle infer nvcc; do echo $TOOL; $TOOL --version; echo ""; done
```
