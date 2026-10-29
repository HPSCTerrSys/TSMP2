#!/usr/bin/env bash
#
# Script for manually building OASIS3-MCT, eCLM, and Parflow.
#
set -eo pipefail

if [[ $1 == "gnu" ]]; then
  COMPILER="GNU"
  ENV_FILE=jsc.2026.gnu.openmpi  
elif [[ $1 == "nvhpc" ]]; then
  COMPILER="NVHPC"
  ENV_FILE=jsc.2026.nvhpc.openmpi
else
  COMPILER="NVHPC"
  ENV_FILE=jsc.2026.nvhpc.openmpi
fi

MAKE_JOBS=32
TSMP2_ROOT=`git rev-parse --show-toplevel`
BUILD_DIR=${TSMP2_ROOT}/bld_manual/${MODEL_ID}

#
# Source env for eCLM and Parflow build
#
cd ${TSMP2_ROOT}
echo "Sourcing ${ENV_FILE} ..."
source env/${ENV_FILE} --parflowgpu --profile

MODEL_ID=${SYSTEMNAME^^}_eCLM-ParflowGPU_S${STAGE}_${COMPILER}-OPENMPI_SCALASCA
if [[ -z ${INSTALL_DIR// } ]]; then
  INSTALL_DIR=${TSMP2_ROOT}/bin/${MODEL_ID}
else
  INSTALL_DIR=${INSTALL_DIR}/${MODEL_ID}
fi
echo "TSMP2 binaries will be installed to ${INSTALL_DIR}"

#
# Build OASIS3-MCT
#
echo ""
echo "Building OASIS3-MCT with Score-P ..."
echo ""
cd ${TSMP2_ROOT}/models/oasis3-mct
export OASIS_ROOT=$(pwd) INSTALL_PREFIX=${INSTALL_DIR}
cd util/make_dir
make realclean -f TopMakefileOasis3
INSTALL_PREFIX=${INSTALL_DIR} make -f TopMakefileOasis3 -j${MAKE_JOBS} static-libs
echo "Successfully built OASIS3-MCT!"

echo ""
echo "Building Parflow with Score-P ..."
echo ""
cd ${TSMP2_ROOT}
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
make SCOREP_WRAPPER_INSTRUMENTER_FLAGS="--thread=pthread --verbose" VERBOSE=1 -j${MAKE_JOBS} install
echo "Successfully built ParFlowGPU!"

#
# Build eCLM
#
echo ""
echo "Building eCLM with Score-P ..."
echo ""
cd ${TSMP2_ROOT}
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
make SCOREP_WRAPPER_INSTRUMENTER_FLAGS="--thread=pthread --verbose" VERBOSE=1 -j${MAKE_JOBS} install
echo "Successfully built eCLM!"

#
# Copy env file to INSTALL_DIR
#
cp ${TSMP2_ROOT}/env/${ENV_FILE} ${INSTALL_DIR}

echo ""
echo "Successfully built eCLM-ParflowGPU to ${INSTALL_DIR}"
echo ""
