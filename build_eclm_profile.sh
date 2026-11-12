#!/usr/bin/env bash
#
# Script for manually building eCLM
#
set -eo pipefail

if [[ $1 == "nvhpc" ]]; then
  COMPILER="NVHPC"
  ENV_FILE=jsc.2026.nvhpc.openmpi
else
  COMPILER="GNU"
  ENV_FILE=jsc.2026.gnu.openmpi  
fi
MAKE_JOBS=32
TSMP2_ROOT=`git rev-parse --show-toplevel`

#
# Source env for eCLM and Parflow build
#
cd ${TSMP2_ROOT}
echo "Sourcing ${ENV_FILE} ..."
source env/${ENV_FILE} --profile

MODEL_ID=${SYSTEMNAME^^}_eCLM_S${STAGE}_${COMPILER}-OPENMPI_SCALASCA
BUILD_DIR=${TSMP2_ROOT}/bld_manual/${MODEL_ID}
if [[ -z ${INSTALL_DIR// } ]]; then
  INSTALL_DIR=${TSMP2_ROOT}/bin/${MODEL_ID}
else
  INSTALL_DIR=${INSTALL_DIR}/${MODEL_ID}
fi
echo "TSMP2 binaries will be installed to ${INSTALL_DIR}"

#
# Build eCLM
#
echo ""
echo "Building eCLM with Score-P ..."
echo ""
cd ${TSMP2_ROOT}
rm -rf ${BLD_eCLM}
BLD_eCLM=${BUILD_DIR}/eCLM
SCOREP_WRAPPER=off cmake -S ${TSMP2_ROOT}/models/eCLM/src       \
                         -B ${BLD_eCLM}                         \
                         -DCMAKE_BUILD_TYPE="PROFILE"           \
                         -DCMAKE_PREFIX_PATH=${INSTALL_DIR}     \
                         -DCMAKE_INSTALL_PREFIX=${INSTALL_DIR}  \
                         -DCMAKE_C_COMPILER=$CC                 \
                         -DCMAKE_Fortran_COMPILER=$FC           \
                         -DCOUP_OAS_PFL=False

cd ${BLD_eCLM}
make SCOREP_WRAPPER_INSTRUMENTER_FLAGS="--thread=pthread --verbose" VERBOSE=1 -j${MAKE_JOBS} install
echo "Successfully built eCLM!"

#
# Copy env file to INSTALL_DIR
#
cp ${TSMP2_ROOT}/env/${ENV_FILE} ${INSTALL_DIR}

echo ""
echo "Successfully built eCLM to ${INSTALL_DIR}"
echo ""
