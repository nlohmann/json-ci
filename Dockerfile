FROM ubuntu:latest

####################
# install packages #
####################

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && \
    apt-get install -y software-properties-common && \
    add-apt-repository -y ppa:ubuntu-toolchain-r/test && \
    apt-add-repository -y "deb http://archive.ubuntu.com/ubuntu/ bionic main" && \
    apt-add-repository -y "deb http://archive.ubuntu.com/ubuntu/ bionic universe" && \
    apt-add-repository -y "deb http://archive.ubuntu.com/ubuntu/ xenial main" && \
    apt-add-repository -y "deb http://archive.ubuntu.com/ubuntu/ xenial universe" && \
    apt-add-repository -y "deb http://archive.ubuntu.com/ubuntu/ xenial-updates main" && \
    apt-add-repository -y "deb http://archive.ubuntu.com/ubuntu/ xenial-updates universe" && \
    apt-get update && \
    apt-get install -y --no-install-recommends \
        git astyle ninja-build make unzip iwyu libidn11 valgrind \
        lsb-release wget software-properties-common lcov gpg-agent nvidia-cuda-toolkit \
        g++-4.8 g++-4.9 g++-5 g++-6 g++-7 g++-8 g++-9 g++-10 g++ \
        clang-3.5 clang-3.6 clang-3.7 clang-3.8 clang-3.9 clang-4.0 clang-5.0 clang-6.0 clang-7 clang-8 clang-9 clang-10 clang-11 clang-12 && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

####################
# get latest CMake #
####################

RUN CMAKE_VERSION=3.21.3 && \
    wget https://github.com/Kitware/CMake/releases/download/v$CMAKE_VERSION/cmake-$CMAKE_VERSION-Linux-x86_64.sh && \
    chmod a+x cmake-$CMAKE_VERSION-Linux-x86_64.sh && \
    ./cmake-$CMAKE_VERSION-Linux-x86_64.sh --skip-license --prefix=/usr/local && \
    rm cmake-$CMAKE_VERSION-Linux-x86_64.sh

####################
# get latest Clang #
####################

# see https://apt.llvm.org
RUN wget https://apt.llvm.org/llvm.sh && chmod +x llvm.sh && ./llvm.sh 13 && ./llvm.sh 14 && rm llvm.sh
RUN apt-get update && \
    apt-get install -y clang-tools-14 clang-tidy-14

##################
# get latest GCC #
##################

RUN add-apt-repository -y ppa:ubuntu-toolchain-r/test && \
    apt-get update && \
    apt-get install -y g++-11 && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

#######################
# get latest cppcheck #
#######################

RUN git clone --depth 1 https://github.com/danmar/cppcheck.git && \
    cmake -S cppcheck -B cppcheck/build -G Ninja -DCMAKE_BUILD_TYPE=Release && \
    cmake --build cppcheck/build --target install && \
    rm -fr cppcheck

######################
# get latest OCLint #
#####################

RUN OCLINT_RELEASE=oclint-21.05-llvm-12.0.0-x86_64-linux-ubuntu-20.04.tar.gz && \
    cd ~ && \
    wget https://github.com/oclint/oclint/releases/download/v21.05/${OCLINT_RELEASE} && \
    tar xfz ${OCLINT_RELEASE} && \
    rm ${OCLINT_RELEASE}

ENV PATH=${PATH}:/root/oclint-21.05/bin

##################
# get PVS Studio #
##################

# see https://www.viva64.com/en/m/0039/#IDA60A8D2301
RUN wget -q -O - https://files.viva64.com/etc/pubkey.txt | apt-key add - && \
    wget -O /etc/apt/sources.list.d/viva64.list https://files.viva64.com/etc/viva64.list && \
    apt-get update && \
    apt-get install -y --no-install-recommends pvs-studio && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

######################
# get Facebook Infer #
######################

RUN wget -q -O - "https://github.com/facebook/infer/releases/download/v1.1.0/infer-linux64-v1.1.0.tar.xz" | tar -C /opt -xJ && \
    ln -s "/opt/infer-linux64-v1.1.0/bin/infer" /usr/local/bin/infer

###################
# Intel compilers #
###################

RUN wget https://apt.repos.intel.com/intel-gpg-keys/GPG-PUB-KEY-INTEL-SW-PRODUCTS.PUB && \
    APT_KEY_DONT_WARN_ON_DANGEROUS_USAGE=1 apt-key add GPG-PUB-KEY-INTEL-SW-PRODUCTS.PUB && \
    rm GPG-PUB-KEY-INTEL-SW-PRODUCTS.PUB && \
    add-apt-repository -y "deb https://apt.repos.intel.com/oneapi all main" && \
    apt-get update && \
    apt-get install -y --no-install-recommends intel-oneapi-compiler-dpcpp-cpp-and-cpp-classic && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*
