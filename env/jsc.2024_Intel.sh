#!/usr/bin/env bash

# Load modules
module --force purge
module use $OTHERSTAGES
module load Stages/2024
module load Intel/2023.2.1
module load ParaStationMPI/5.9.2-1
#module load IntelMPI/2021.10.0

#
module load Hypre/2.31.0-cpu
module load Silo/4.11.1
module load Tcl/8.6.13
#
module load ecCodes/2.31.0
module load HDF5/1.14.2
module load netCDF/4.9.2
module load netCDF-Fortran/4.6.1
module load PnetCDF/1.12.3
module load cURL/8.0.1
module load Szip/.2.1.1
module load Python/3.11.3
module load NCO/5.1.8
module load CMake/3.26.3
module load git/2.41.0-nodocs

module li

# Set default compilers
export CC=mpicc
export FC=mpif90
export CXX=mpicxx
export MPI_HOME=$EBROOTPSMPI
