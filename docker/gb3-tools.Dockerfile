FROM ubuntu:focal-20230412

ARG DEBIAN_FRONTEND=noninteractive

WORKDIR /

RUN apt-get update
RUN apt-get upgrade -y

RUN apt-get install -y \
	aptitude \
	pkg-config \
	build-essential \
	cmake \
	git \
	vim \
	python3

RUN git clone --recursive https://github.com/f-of-e/f-of-e-tools.git
RUN rm -rf /f-of-e-tools/.git

# icestorm
RUN aptitude install -y libftdi-dev
RUN cd /f-of-e-tools/tools/icestorm && make install
RUN rm -rf /f-of-e-tools/tools/icestorm

# nextpnr
RUN apt-get install -y \
	libboost-all-dev

RUN cd /f-of-e-tools/tools/nextpnr && cmake -DARCH=ice40 -DBUILD_GUI=OFF -DBUILD_PYTHON=OFF -DBUILD_HEAP=OFF .
RUN cd /f-of-e-tools/tools/nextpnr && make
RUN cd /f-of-e-tools/tools/nextpnr && make install
RUN rm -rf /f-of-e-tools/tools/nextpnr

# arachnepnr
RUN cd /f-of-e-tools/tools/arachnepnr && make install
RUN rm -rf /f-of-e-tools/tools/arachnepnr

# srec2hex
RUN cd /f-of-e-tools/tools/srec2hex && make install
RUN rm -rf /f-of-e-tools/tools/srec2hex

# yosys
RUN apt-get install -y \
	clang \
	flex \
	bison \
	tclsh \
	tcl8.6-dev \
	libreadline-dev

RUN cd /f-of-e-tools/tools/yosys && make install
RUN rm -rf /f-of-e-tools/tools/yosys

# sunflower
RUN apt-get install -y \
	wget \
	gawk \
	libmpc-dev

ADD setup.conf /f-of-e-tools/tools/sunflower/conf/setup.conf
ADD downloads.sh /f-of-e-tools/tools/sunflower/tools/source/downloads.sh
ADD Makefile-sf /f-of-e-tools/tools/sunflower/sunflower-toolchain/Makefile

RUN cd /f-of-e-tools/tools/sunflower/tools/source && ./downloads.sh
RUN cd /f-of-e-tools/tools/sunflower && make cross-riscv
RUN cd /f-of-e-tools/tools/sunflower && make

# iverilog
RUN apt-get install -y iverilog

