FROM ubuntu:focal

####################
# install packages #
####################

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && \
    apt-get install --no-install-recommends -y software-properties-common && \
    add-apt-repository -y ppa:ubuntu-toolchain-r/test && \
    apt-add-repository -y "deb http://archive.ubuntu.com/ubuntu/ xenial main" && \
    apt-add-repository -y "deb http://archive.ubuntu.com/ubuntu/ xenial universe" && \
    apt-get update && \
    apt-get install -y --no-install-recommends \
        ca-certificates gnupg \
        git astyle ninja-build make unzip iwyu xz-utils libidn11 valgrind cmake \
        lsb-release wget software-properties-common lcov gpg-agent \
        gcc-multilib g++-multilib \
        g++-4.8 clang && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

############################
# get a newer CUDA Toolkit #
############################

RUN apt-key adv --fetch-keys https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2004/x86_64/3bf863cc.pub && \
    echo "deb https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2004/x86_64 /" \
    | tee /etc/apt/sources.list.d/cuda.list && \
    apt-get update && \
    apt-get install -y             \
      cuda-command-line-tools-11-0 \
      cuda-compiler-11-0           \
      cuda-minimal-build-11-0   && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    ln -s cuda-11.0 /usr/local/cuda

ENV PATH=${PATH}:/usr/local/cuda/bin

##################
# get latest GCC #
##################

RUN wget http://kayari.org/gcc-latest/gcc-latest.deb && \
    dpkg -i gcc-latest.deb && \
    rm -rf gcc-latest.deb && \
    ln -s /opt/gcc-latest/bin/g++ /opt/gcc-latest/bin/g++-latest && \
    ln -s /opt/gcc-latest/bin/gcc /opt/gcc-latest/bin/gcc-latest

ENV PATH=${PATH}:/opt/gcc-latest/bin

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

RUN OCLINT_RELEASE=oclint-22.02-llvm-13.0.1-x86_64-linux-ubuntu-20.04.tar.gz && \
    cd ~ && \
    wget https://github.com/oclint/oclint/releases/download/v22.02/${OCLINT_RELEASE} && \
    tar xfz ${OCLINT_RELEASE} && \
    rm ${OCLINT_RELEASE}

ENV PATH=${PATH}:/root/oclint-22.02/bin

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
