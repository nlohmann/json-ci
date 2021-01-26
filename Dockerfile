FROM ubuntu:latest

####################
# install packages #
####################

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    git cmake ninja-build make unzip iwyu libidn11 valgrind \
    lsb-release wget software-properties-common clang-tools-11 clang-tidy-11

####################
# get latest Clang #
####################

# see https://apt.llvm.org
RUN wget https://apt.llvm.org/llvm.sh && chmod +x llvm.sh && ./llvm.sh 11 && rm llvm.sh

##################
# get latest GCC #
##################

# see https://jwakely.github.io/pkg-gcc-latest/
RUN wget http://kayari.org/gcc-latest/gcc-latest.deb && dpkg -i gcc-latest.deb && rm gcc-latest.deb

ENV PATH=/opt/gcc-latest/bin:${PATH}
ENV LD_RUN_PATH=/opt/gcc-latest/lib64:${LD_RUN_PATH}

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

ENV OCLINT_RELEASE=oclint-20.11-llvm-11.0.0-x86_64-linux-ubuntu-20.04.tar.gz

RUN cd ~ && \
    wget https://github.com/oclint/oclint/releases/download/v20.11/${OCLINT_RELEASE} && \
    tar xfz ${OCLINT_RELEASE} && \
    rm ${OCLINT_RELEASE}

ENV PATH=${PATH}:/root/oclint-20.11/bin

##################
# get PVS Studio #
##################

# see https://www.viva64.com/en/m/0039/#IDA60A8D2301
RUN wget -q -O - https://files.viva64.com/etc/pubkey.txt | apt-key add - && \
    wget -O /etc/apt/sources.list.d/viva64.list https://files.viva64.com/etc/viva64.list && \
    apt-get update && \
    apt-get install -y pvs-studio
