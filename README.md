# Docker image for nlohmann/json

This repository contains the [Dockerfile](Dockerfile) of the image used in the CI of [JSON for Modern C++](https://github.com/nlohmann/json).

The image is pushed automatically to [DockerHub](https://hub.docker.com/r/nlohmann/json-ci) and can be used with

```
docker pull nlohmann/json-ci:latest
```

## Contents

The goal is to provide a fairly recent C++ build and analysis tool chain.

Versions (as of 2021-02-08):

- Clang 11.1.0-++20210204121720+1fdec59bffc1-1~exp1~20210203232336.162
- GCC 11.0.0-20210207git3d912941f29c
- Cppcheck 2.3
- Clang-Tidy 11.1.0
- include-what-you-use 0.12
- CMake 3.19.4
- Ninja 1.10.1
- Valgrind 3.15.0
- OCLint 20.11
- PVS Studio 7.11.44204.104-1
- LCOV 1.14
- Artistic Style 3.1
