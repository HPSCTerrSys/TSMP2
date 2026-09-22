#!/usr/bin/env bash
#
# Script for manually building OASIS3-MCT, eCLM, and Parflow.
#
set -eo pipefail

TSMP2_ROOT=`git rev-parse --show-toplevel`
MODEL_ID=${SYSTEMNAME^^}_eCLM-ParflowGPU_S${STAGE}_GNU-OPENMPI_SCALASCA
BUILD_DIR=${TSMP2_ROOT}/bld_manual/${MODEL_ID}
INSTALL_DIR=${TSMP2_ROOT}/bin/${MODEL_ID}

#
# Build OASIS3-MCT
#
echo ""
echo "Building OASIS3-MCT (without Score-P) ..."
echo ""
cd ${TSMP2_ROOT}/models/oasis3-mct
#INSTALL_PREFIX=${INSTALL_DIR} ./build

#
# Source env for eCLM and Parflow build
#
cd ${TSMP2_ROOT}
source env/jsc.2026.gnu.openmpi --profile

#
# Build eCLM
#
echo ""
echo "Building eCLM with Score-P..."
echo ""
BLD_eCLM=${BUILD_DIR}/eCLM
rm -rf ${BLD_eCLM}
if [[ ! -d ${BLD_eCLM} ]]; then
  SCOREP_WRAPPER=off cmake -S ${TSMP2_ROOT}/models/eCLM/src       \
                           -B ${BLD_eCLM}                         \
                           -DCMAKE_PREFIX_PATH=${INSTALL_DIR}     \
                           -DCMAKE_INSTALL_PREFIX=${INSTALL_DIR}  \
                           -DCMAKE_C_COMPILER=$CC                 \
                           -DCMAKE_Fortran_COMPILER=$FC           \
	                   -DCOUP_OAS_PFL=True
fi
cd ${BLD_eCLM}
make SCOREP_WRAPPER_INSTRUMENTER_FLAGS="--thread=pthread --verbose" VERBOSE=1 install
# TODO: Check MCT error at /p/project1/cslts/rigor1/TSMP2_dev/TSMP2/models/eCLM/src/externals/mct/config.log

echo ""
echo "Building Parflow with Score-P..."
echo ""
# TODO
