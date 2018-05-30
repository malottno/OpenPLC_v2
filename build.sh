#!/bin/bash
echo Building OpenPLC environment:

echo [MATIEC COMPILER]
cd matiec_src
autoreconf -i
./configure
make

echo [LADDER]
cd ..
cp ./matiec_src/iec2c ./
./iec2c ./st_files/blank_program.st
mv -f POUS.c POUS.h LOCATED_VARIABLES.h VARIABLES.csv Config0.c Config0.h Res0.c ./core/

echo [ST OPTIMIZER]
cd st_optimizer_src
g++ st_optimizer.cpp -o st_optimizer
cd ..
cp ./st_optimizer_src/st_optimizer ./

echo [GLUE GENERATOR]
cd glue_generator_src
g++ glue_generator.cpp -o glue_generator
cd ..
cp ./glue_generator_src/glue_generator ./core/glue_generator

clear
echo Installing DNP3 on the system...

#moving files to the right place
mv ./core/dnp3.disabled ./core/dnp3.cpp 2> /dev/null
mv ./core/dnp3_dummy.cpp ./core/dnp3_dummy.disabled 2> /dev/null
cp -f ./core/core_builders/dnp3_enabled/*.* ./core/core_builders/

#make sure cmake is installed
apt-get install cmake

#download opendnp3
#git clone --recursive https://github.com/automatak/dnp3.git
#cd dnp3

#create swapfile to prevent out of memory errors
#echo creating swapfile...
#dd if=/dev/zero of=swapfile bs=1M count=1000
#mkswap swapfile
#swapon swapfile

#build opendnp3
#cmake ../dnp3
#make
#make install
#ldconfig

#remove swapfile
#swapoff swapfile
#rm -f ./swapfile
#cd ..

#-----------------------
echo Skipping DNP3 installation
mv ./core/dnp3.cpp ./core/dnp3.disabled 2> /dev/null
mv ./core/dnp3_dummy.disabled ./core/dnp3_dummy.cpp 2> /dev/null
cp -f ./core/core_builders/dnp3_disabled/*.* ./core/core_builders/
#-----------------------

cd core
rm -f ./hardware_layer.cpp
rm -f ../build_core.sh
echo The OpenPLC needs a driver to be able to control physical or virtual hardware.

cp ./hardware_layers/blank.cpp ./hardware_layer.cpp
cp ./core_builders/build_normal.sh ../build_core.sh
echo [OPENPLC]
cd ..
./build_core.sh
		
