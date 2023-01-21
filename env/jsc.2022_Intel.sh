#!/usr/bin/env bash

# Load modules
module --force purge
module load Stages/2022
module load StdEnv/2022
module load lxml/4.6.3
module load Intel/2021.4.0
module load ParaStationMPI/5.5.0-1
module load mpi-settings/UCX
module load Hypre/2.25.0-cpu
module load netCDF/4.8.1
module load netCDF-Fortran/4.5.3
module load PnetCDF/1.12.2
module load ecCodes/2.22.1
module load Silo/4.11
module load imkl/2021.4.0
module load Tcl/8.6.11
module load Python/3.9.6
module load Perl/5.34.0
module load CMake/3.21.1
module list

# Set default compilers
export CC=mpicc
export FC=mpif90
export CXX=mpicxx
export MPI_HOME=$EBROOTPSMPI

# Set OASIS root
export OASIS_ROOT="/p/project/cslts/software/$STAGE/${SYSTEMNAME}/OASIS3-MCT/5.0"
if [[ ":$CMAKE_PREFIX_PATH:" != *":${OASIS_ROOT}:"* ]]; then
  CMAKE_PREFIX_PATH="${CMAKE_PREFIX_PATH:+"$CMAKE_PREFIX_PATH:"}${OASIS_ROOT}"
fi