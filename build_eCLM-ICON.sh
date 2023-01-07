#!/usr/bin/env bash
set -eo pipefail

# Load modules
module --force purge
module load Stages/2022
module load GCCcore/.11.2.0
module load lxml/4.6.3
module load Intel/2021.4.0
module load ParaStationMPI/5.5.0-1
module load ecCodes/2.22.1
module load netCDF-Fortran/4.5.3
module load netCDF/4.8.1
module load imkl/2021.4.0
module load Python/3.9.6
module load Perl/5.34.0
module load PnetCDF/1.12.2
module load CMake/3.21.1
module list

# Models to build
MODEL_ID="eCLM-ICON"
eCLM_SRC="/p/scratch/cslts/shared_data/eTSMP_models/eCLM"
ICON_SRC="/p/scratch/cslts/shared_data/eTSMP_models/icon2.6.4_oascoup"
OASIS_ROOT="/p/project/cslts/software/$STAGE/${SYSTEMNAME}/OASIS3-MCT/5.0"

# Where build artifacts and binaries will be saved
BUILD_DIR="./bld/${SYSTEMNAME^^}_${MODEL_ID}"
INSTALL_DIR="./bin/${SYSTEMNAME^^}_${MODEL_ID}"
BUILD_LOG="$(dirname ${BUILD_DIR})/${MODEL_ID}_$(date +%Y.%m.%d_%H.%M).log"

# Configure
rm -rf ${BUILD_DIR}
mkdir -p ${BUILD_DIR} ${INSTALL_DIR}
cmake -S . -B ${BUILD_DIR}                  \
      -DOASIS_ROOT=${OASIS_ROOT}            \
      -DeCLM_SRC=${eCLM_SRC}                \
      -DICON_SRC=${ICON_SRC}                \
      -DCMAKE_C_COMPILER=mpicc              \
      -DCMAKE_Fortran_COMPILER=mpifort      \
      -DCMAKE_INSTALL_PREFIX="$INSTALL_DIR" \
      |& tee ${BUILD_LOG}

# Build and install
cmake --build ${BUILD_DIR} |& tee -a ${BUILD_LOG}
cmake --install ${BUILD_DIR} |& tee -a ${BUILD_LOG}

echo ""
echo "Successfully installed ${MODEL_ID} to ${INSTALL_DIR}"
echo ""