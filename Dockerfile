FROM ubuntu:latest

###############
# prepare apt #
###############

RUN apt-get update
RUN DEBIAN_FRONTEND=noninteractive apt-get -y install git cmake ninja-build make unzip iwyu libidn11 valgrind

####################
# get latest Clang #
####################

# prerequisties for llvm.sh
RUN apt-get -y install lsb-release wget software-properties-common

# see https://apt.llvm.org
RUN wget https://apt.llvm.org/llvm.sh
RUN chmod +x llvm.sh
RUN ./llvm.sh 11

RUN apt-get -y install clang-tools-11 clang-tidy-11

##################
# get latest GCC #
##################

# see https://jwakely.github.io/pkg-gcc-latest/
RUN wget http://kayari.org/gcc-latest/gcc-latest.deb
RUN dpkg -i gcc-latest.deb
RUN rm gcc-latest.deb
ENV PATH /opt/gcc-latest/bin:${PATH}
ENV LD_RUN_PATH=/opt/gcc-latest/lib64:${LD_RUN_PATH}

#####################################
# build and install latest cppcheck #
#####################################

RUN wget https://github.com/danmar/cppcheck/archive/2.3.zip
RUN unzip 2.3.zip
RUN cmake -S cppcheck-2.3 -B build -G Ninja -DCMAKE_BUILD_TYPE=Release
RUN cmake --build build --target install
RUN rm -fr 2.3.zip build cppcheck-2.3
