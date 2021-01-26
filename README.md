# Docker image for nlohmann/json

This repository contains the [Dockerfile](Dockerfile) of the image used in the CI of [JSON for Modern C++](https://github.com/nlohmann/json).

The image is pushed automatically to [DockerHub](https://hub.docker.com/r/nlohmann/json-ci) and can be used with

```
docker pull nlohmann/json-ci:latest
```

## Contents

The goal is to provide a fairly recent C++ build and analysis tool chain.

Versions (as of 2021-01-26):

- Clang 11.1.0-++20210112083037+9bbcb554cdbf-1~exp1~20210112193657.159
- GCC 11.0.0-20210124git6b1633378b74
- Cppcheck 2.3
- Clang-Tidy 11.1.0
- include-what-you-use 0.12
- CMake 3.16.3
- Ninja 1.10.1
- Valgrind 3.15.0
- OCLint 20.11
- PVS Studio 7.11.44204.104-1
