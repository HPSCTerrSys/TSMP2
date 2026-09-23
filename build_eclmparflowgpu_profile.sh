#!/usr/bin/env bash
#
# Script for manually building OASIS3-MCT, eCLM, and Parflow.
#
set -eo pipefail

TSMP2_ROOT=`git rev-parse --show-toplevel`
MODEL_ID=${SYSTEMNAME^^}_eCLM-ParflowGPU_S${STAGE}_GNU-OPENMPI_SCALASCA
BUILD_DIR=${TSMP2_ROOT}/bld_manual/${MODEL_ID}
INSTALL_DIR=${TSMP2_ROOT}/bin/${MODEL_ID}

rm -rf ${INSTALL_DIR}
#
# Source env for eCLM and Parflow build
#
cd ${TSMP2_ROOT}
echo "Sourcing env file ..."
source env/jsc.2026.gnu.openmpi --parflowgpu --profile

#
# Build OASIS3-MCT
#
echo ""
echo "Building OASIS3-MCT with Score-P ..."
echo ""
cd ${TSMP2_ROOT}/models/oasis3-mct
CC=$(which mpicc) FC=$(which mpif90) INSTALL_PREFIX=${INSTALL_DIR} ./build
echo "Successfully built OASIS3-MCT!"

echo ""
echo "Building Parflow with Score-P ..."
echo ""
BLD_ParFlow=${BUILD_DIR}/ParFlow
rm -rf ${BLD_ParFlow}
if [[ ! -d ${BLD_ParFlow} ]]; then
  SCOREP_WRAPPER=off cmake -S ${TSMP2_ROOT}/models/parflow        \
                           -B ${BLD_ParFlow}                      \
                           -DCMAKE_BUILD_TYPE="RELEASE"           \
                           -DCMAKE_INSTALL_PREFIX=${INSTALL_DIR}  \
                           -DCMAKE_PREFIX_PATH=${INSTALL_DIR}     \
                           -DCMAKE_C_COMPILER=$CC                 \
                           -DCMAKE_Fortran_COMPILER=$FC           \
                           -DCMAKE_CXX_COMPILER=$CXX              \
                           -DPARFLOW_ENABLE_HYPRE=ON              \
                           -DPARFLOW_ENABLE_NETCDF=ON             \
                           -DPARFLOW_AMPS_SEQUENTIAL_IO=ON        \
                           -DPARFLOW_ENABLE_TIMING=TRUE           \
                           -DPARFLOW_ACCELERATOR_BACKEND="cuda"   \
                           -DMPIEXEC_EXECUTABLE=$(which srun)     \
                           -DMPIEXEC_NUMPROC_FLAG="--ntasks"      \
                           -DPARFLOW_ENABLE_SLURM=TRUE            \
                           -DUMPIRE_ROOT=${EBROOTUMPIRE}          \
                           -DSUNDIALS_ROOT=${EBROOTSUNDIALS}      \
			   -DPARFLOW_AMPS_LAYER=oas3              \
			   -DOAS3_ROOT=${INSTALL_DIR}             \
			   -DPARFLOW_HAVE_ECLM=ON
fi
cd ${BLD_ParFlow}
make SCOREP_WRAPPER_INSTRUMENTER_FLAGS="--thread=pthread --verbose" VERBOSE=1 -j8 install
echo "Successfully built ParFlowGPU!"

#
# Build eCLM
#
echo ""
echo "Building eCLM with Score-P ..."
echo ""
rm -rf ${BLD_eCLM}
BLD_eCLM=${BUILD_DIR}/eCLM
if [[ ! -d ${BLD_eCLM} ]]; then
  SCOREP_WRAPPER=off cmake -S ${TSMP2_ROOT}/models/eCLM/src       \
                           -B ${BLD_eCLM}                         \
                           -DCMAKE_BUILD_TYPE="PROFILE"           \
                           -DCMAKE_PREFIX_PATH=${INSTALL_DIR}     \
                           -DCMAKE_INSTALL_PREFIX=${INSTALL_DIR}  \
                           -DCMAKE_C_COMPILER=$CC                 \
                           -DCMAKE_Fortran_COMPILER=$FC           \
                           -DCOUP_OAS_PFL=True
fi
cd ${BLD_eCLM}
make SCOREP_WRAPPER_INSTRUMENTER_FLAGS="--thread=pthread --verbose" VERBOSE=1 -j8 install
echo "Successfully built eCLM!"

echo ""
echo "SUccessfully built eCLM-ParflowGPU to ${INSTALL_DIR}"
echo ""
