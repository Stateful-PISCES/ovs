#!/bin/bash

# TODO: this should probably be a makefile
# TODO: install target
(
cd deps/dpdk
if [[ ! -e Makefile ]]
then
	echo "ERROR: dpdk submodule not initialized"
	echo "Please run git submodule update --init"
	exit 1
fi
patch -p1 -N < ../../setup-scripts/patches/dpdk.patch
make -j 8 install T=x86_64-native-linuxapp-gcc
cd ../../

cd setup-scripts
source ./helpers/setup-vars-ovs-dpdk.sh

cd ../
./boot.sh
if [[ -e ~/my-change/p4c-behavioral/fr_argfile_sample/l2_switch.json ]]
then
  ./configure --with-dpdk=$DPDK_BUILD CFLAGS="-g -O2 -Wno-cast-align" \
              p4inputfile=~/my-change/p4c-behavioral/fr_argfile_sample/l2_switch.p4 \
              p4outputdir=./include/p4/src \
              p4frargfile=~/my-change/p4c-behavioral/fr_argfile_sample/l2_switch.json
else
  ./configure --with-dpdk=$DPDK_BUILD CFLAGS="-g -O2 -Wno-cast-align" \
              p4inputfile=./include/p4/examples/l2_switch/l2_switch.p4 \
              p4outputdir=./include/p4/src
fi

make clean
make -j 8
)
