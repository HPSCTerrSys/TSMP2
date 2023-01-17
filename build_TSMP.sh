#!/usr/bin/env bash
set -eo pipefail

# Load modules
module --force purge
module load Stages/2022
module load GCCcore/.11.2.0
module load lxml/4.6.3
module load Intel/2021.4.0
module load ParaStationMPI/5.5.0-1
module load mpi-settings/UCX
module load Hypre/2.25.0-cpu
module load ecCodes/2.22.1
module load netCDF-Fortran/4.5.3
module load netCDF/4.8.1
module load Silo/4.11
module load imkl/2021.4.0
module load Tcl/8.6.11
module load Python/3.9.6
module load Perl/5.34.0
module load PnetCDF/1.12.2
module load CMake/3.21.1
module list

# Models to build
MODEL_ID="CLM3.5-ParFlow-COSMO"
CLM35_SRC="/p/scratch/cslts/shared_data/eTSMP_models/CLM3.5"
PARFLOW_SRC="/p/scratch/cslts/shared_data/eTSMP_models/parflow"
COSMO_SRC="/p/scratch/cslts/shared_data/eTSMP_models/cosmo5.01"
OASIS_ROOT="/p/project/cslts/software/$STAGE/${SYSTEMNAME}/OASIS3-MCT/5.0"

# Where build artifacts and binaries will be saved
BUILD_DIR="./bld/${SYSTEMNAME^^}_${MODEL_ID}"
INSTALL_DIR="./bin/${SYSTEMNAME^^}_${MODEL_ID}"
BUILD_LOG="$(dirname ${BUILD_DIR})/${MODEL_ID}_$(date +%Y.%m.%d_%H.%M).log"

rm -rf ${BUILD_DIR}
mkdir -p ${BUILD_DIR} ${INSTALL_DIR}
cmake -S . -B ${BUILD_DIR}                  \
      -DOASIS_ROOT=${OASIS_ROOT}            \
      -DCLM35_SRC=${CLM35_SRC}              \
      -DCOSMO_SRC=${COSMO_SRC}              \
      -DPARFLOW_SRC=${PARFLOW_SRC}          \
      -DCMAKE_C_COMPILER=mpicc              \
      -DCMAKE_CXX_COMPILER=mpicxx           \
      -DCMAKE_Fortran_COMPILER=mpif90       \
      -DMPI_HOME=$EBROOTPSMPI               \
      -DCMAKE_INSTALL_PREFIX="$INSTALL_DIR" \
      |& tee ${BUILD_LOG}

# Build and install
cmake --build ${BUILD_DIR} |& tee -a ${BUILD_LOG}
cmake --install ${BUILD_DIR} |& tee -a ${BUILD_LOG}

echo ""
echo "Successfully installed ${MODEL_ID} to ${INSTALL_DIR}"
echo ""