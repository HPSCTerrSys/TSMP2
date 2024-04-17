#!/usr/bin/env bash
# Script to build TSMP2 framework
# Need to set MODEL-ID and TSMP2_PATHS in advance

set -eo pipefail

# Check if Model-ID is set
if [ -z ${MODEL_ID} ]; then
echo "MODEL_ID is not set"
exit 1
fi

# Source path to TSMP2 DIR, ENV and components
source ${TSMP2_PATHS} 

# change to $TSMP2_DIR
if [ -n ${TSMP2_DIR} ]; then
cd ${TSMP2_DIR}
else
exit 2
fi 

# Source environment 
source ${TSMP2_ENV}

# Set build parameters
BUILD_CONFIG="Debug" # "Release"
BUILD_DIR="./bld/${SYSTEMNAME^^}_${MODEL_ID}" # Build artifacts will be generated in this folder.
INSTALL_DIR="./run/${SYSTEMNAME^^}_${MODEL_ID}" # Model executables and libraries will be installed here

BUILD_LOG="$(dirname ${BUILD_DIR})/${MODEL_ID}_$(date +%Y.%m.%d_%H.%M).log"

echo "Building ${MODEL_ID}"

# Source code string
CMAKE_COMPSRC=""
if [[ "${MODEL_ID}" == *-* ]]; then
  CMAKE_COMPSRC+="-DOASIS_SRC=${OASIS_SRC} "
fi
if [[ "${MODEL_ID}" == *ICON* ]]; then
  CMAKE_COMPSRC+="-DICON_SRC=${ICON_SRC} "
fi
if [[ "${MODEL_ID}" == *eCLM* ]]; then
  CMAKE_COMPSRC+="-DeCLM_SRC=${eCLM_SRC} "
fi
if [[ "${MODEL_ID}" == *ParFlow* ]]; then
  CMAKE_COMPSRC+="-DPARFLOW_SRC=${PARFLOW_SRC} "
fi

# Configure
rm -rf ${BUILD_DIR}
mkdir -p ${BUILD_DIR} ${INSTALL_DIR}
cmake -S ${TSMP2_DIR} -B ${BUILD_DIR}         \
      -DCMAKE_BUILD_TYPE=${BUILD_CONFIG}      \
      ${CMAKE_COMPSRC}                            \
      -DCMAKE_INSTALL_PREFIX="${INSTALL_DIR}" \
      |& tee ${BUILD_LOG}

# Build and install
cmake --build ${BUILD_DIR} |& tee -a $BUILD_LOG
cmake --install ${BUILD_DIR} |& tee -a $BUILD_LOG

# Copy log and environment
cp ${TSMP2_ENV} ${INSTALL_DIR}
cp ${BUILD_LOG} ${INSTALL_DIR}
cp ${TSMP2_PATHS} ${INSTALL_DIR}

echo "Compiled successfully!"
