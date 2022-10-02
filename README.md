# Docker image for nlohmann/json

This repository contains the [Dockerfile](Dockerfile) of the image used in the CI of [JSON for Modern C++](https://github.com/nlohmann/json).

The image is pushed automatically to [DockerHub](https://hub.docker.com/r/nlohmann/json-ci) and can be used with

```
docker pull nlohmann/json-ci:latest
```

## Contents

The goal is to provide a fairly recent C++ build and analysis tool chain.

Versions (as of 2022-04-04):

- GCC 13.0.0 20220605 (experimental)
- ICC 2021.6.0 20220226
- Intel(R) oneAPI DPC++ Compiler 2022.1.0 (2022.1.0.20220316)
- Cppcheck 2.7
- include-what-you-use 0.12
- Ninja 1.10.0
- Valgrind 3.15.0
- OCLint 22.02
- PVS Studio 7.19.61166.216
- LCOV 1.14
- Artistic Style 3.1
- Infer v1.1.0

Furthermore, some "historic" C++ compilers are available:

- g++ 4.8.5
- nvcc 11.0.221


### Scripts

Make Intel compilers available:

```sh
source /opt/intel/oneapi/setvars.sh
```

Collect all versions:

```sh
for TOOL in g++-latest icpc icpx cppcheck iwyu cmake ninja valgrind oclint pvs-studio lcov astyle infer nvcc; do echo $TOOL; $TOOL --version; echo ""; done
```
