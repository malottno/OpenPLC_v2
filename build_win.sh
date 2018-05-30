#!/bin/bash
echo Building OpenPLC environment:

echo [MATIEC COMPILER]
cp ./matiec_src/bin_win32/iec2c.exe ./
cp ./matiec_src/bin_win32/*.dll ./

echo [LADDER]
./iec2c.exe ./st_files/blank_program.st
mv -f POUS.c POUS.h LOCATED_VARIABLES.h VARIABLES.csv Config0.c Config0.h Res0.c ./core/

echo [ST OPTIMIZER]
cd st_optimizer_src
g++ st_optimizer.cpp -o st_optimizer
cd ..
cp ./st_optimizer_src/st_optimizer.exe ./

echo [GLUE GENERATOR]
cd glue_generator_src
g++ glue_generator.cpp -o glue_generator
cd ..
cp ./glue_generator_src/glue_generator.exe ./core/glue_generator.exe

clear
echo Disabling DNP3 support \(opendnp3 is not compatible with Cygwin\)...
mv ./core/dnp3.cpp ./core/dnp3.disabled 2> /dev/null
mv ./core/dnp3_dummy.disabled ./core/dnp3_dummy.cpp 2> /dev/null
cp -f ./core/core_builders/dnp3_disabled/*.* ./core/core_builders/

cd core
rm -f ./hardware_layer.cpp
rm -f ../build_core.sh

echo The OpenPLC needs a driver to be able to control physical or virtual hardware.
cp ./hardware_layers/blank.cpp ./hardware_layer.cpp
cp ./core_builders/build_normal.sh ../build_core.sh
echo [OPENPLC]
cd ..
./build_core.sh
echo 'export PATH=$PATH:"/cygdrive/c/Program Files/nodejs/"' >> ~/.bashrc


done
