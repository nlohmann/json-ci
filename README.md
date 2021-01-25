# Docker image for nlohmann/json

This repository contains the [Dockerfile](Dockerfile) of the image used in the CI of [JSON for Modern C++](https://github.com/nlohmann/json).

The image is pushed automatically to [DockerHub](https://hub.docker.com/r/nlohmann/json-ci) and can be used with

```
docker pull nlohmann/json-ci:latest
```

## Contents

The goal is to provide a fairly recent C++ build and analysis tool chain.

- Clang version 11.1.0
- GCC 11.0.0 20210117 (experimental)
- Cppcheck 2.3
- Clang-Tidy 11.1.0
- include-what-you-use 0.12
- CMake 3.16.3
- Ninja 1.10.1
- Valgrind 3.15.0
