#!/usr/bin/env bash
### TSMP2 frontend
### Shell-based script to compile model components within the TSMP2 framework.
###
### For more information:
### ./build_tsmp2.sh --help

# Force script to exit when error occurs
set -eo pipefail

## functions

function help_tsmp2() {
  echo "Usage: $0 [-v ] [--component_name] [--optionals]"
  echo "  -q, --quiet      Write less output during shell execution"
  echo "  -v, --verbose    Enable verbose output from Makefile builds using CMAKE_VERBOSE_MAKEFILE"
  echo "  --version        Print $0 scipt version"
  echo "  --ICON           Compile with ICON"
  echo "  --eCLM           Compile with eCLM"
  echo "  --ParFlow        Compile with ParFlow (CPU mode)"
  echo "  --ParFlowGPU     Compile with ParFlow (GPU mode)"
  echo "  --PDAF           Compile with PDAF"
  echo "  --COSMO          Compile with COSMO"
  echo "  --CLM35          Compile with CLM3.5"
  echo "  --CLM3.5         Compile with CLM3.5"
  echo "  --ICON_SRC       Set ICON_SRC directory"
  echo "  --eCLM_SRC       Set eCLM_SRC directory"
  echo "  --ParFlow_SRC    Set ParFlow_SRC directory"
  echo "  --OASIS_SRC      Set OASIS3-MCT directory"
  echo "  --PDAF_SRC       Set PDAF_SRC directory"
  echo "  --no_update      Skip component model download"
  echo "  --build_type     Set build configuration: 'DEBUG' 'RELEASE'"
  echo "  --build_dir      Set build dir cmake, if not set bld/<SYSTEMNAME>_<model-id> is used. Build artifacts will be generated in this folder."
  echo "  --install_dir    Set install dir cmake, if not set bin/<SYSTEMNAME>_<model-id> is used. Model executables and libraries will be installed here"
  echo "  --clean_first    Delete build_dir if it already exists"
  echo "  --env            Set model environment."
  echo ""
  echo "Example: $0 --ICON --eCLM --ParFlow"
  exit 1
}

function set_component(){
local -n component=$1
cmake_name=$2
if [ "${component}" = "y" ];then
  if [ ! "${model_id}" ];then
      model_id="${cmake_name}"
  else
      model_id+="-${cmake_name}"
  fi # model_id
  cmake_comp_str+=" -D${cmake_name}=ON"
  if [[ $cmake_name = @(ICON|eCLM|ParFlow|ParFlowGPU|COSMO|CLM3.5) ]]; then
     model_count=$(( $model_count + 1 ))
  fi # cmake_name
fi # component
}

function set_compsrc(){
local -n compsrc_name=$1
cmake_srcname=$2
if [ -n "${compsrc_name}" ];then
  cmake_compsrc_str+=" -D${cmake_srcname}=${compsrc_name}"
fi # compsrc
}

function dwn_compsrc(){
comp_name=$1
local -n comp_name=$1
local -n comp_srcname=$2
sub_srcname=$3
if [ -n "${comp_name}" ] && [ -z "${comp_srcname}" ];then
  if [ "${sub_srcname}" = "parflow" ] && [ -n "${pdaf}" ];then
     submodule_name=$(echo "models/${sub_srcname}_pdaf")
  else
     submodule_name=$(echo "models/"${sub_srcname})
  fi
  if [ "$( ls -A ${cmake_tsmp2_dir}/${submodule_name} | wc -l)" -ne 0 ];then
     read -p "submodule ${submodule_name} already exists. Do you want to overwrite it? (y/N) " yn
     if [ "${yn,}" = "y" ];then
        message "Overwrite submodule ${submodule_name}"
        git submodule update --init --force -- ${submodule_name}
     else
        message "Do not overwrite submodule ${submodule_name}"
     fi
  else
     git submodule update --init -- ${submodule_name}
  fi
fi # compsrc
}

function message(){
if [ -z "${quiet}" ];then
  echo "$1"
fi # quiet
}

###
## PROGRAM START
###

## get params
while [[ "$#" -gt 0 ]]; do
  case "${1,,}" in
    -h|--help) help_tsmp2;;
    -q|--quiet) quiet=y;;
    -v|--verbose) verbose_makefile=y;;
    --version) echo "$0 version 0.1.0"; exit 0;;
    --icon) icon=y;;
    --eclm) eclm=y;;
    --parflow) parflow=y; parflowCPU=y; parflowCMakeModelID="ParFlow" ;;
    --parflowgpu) parflow=y; parflowGPU=y; parflowCMakeModelID="ParFlowGPU" ;;
    --pdaf) pdaf=y;;
    --cosmo) cosmo=y;;
    --clm35|--clm3.5) clm35=y;;
    --no_update) update_compsrc=n;;
    --clean_first) clean_first=y;;
    --icon_src) icon_src="$2"; shift ;;
    --eclm_src) eclm_src="$2"; shift ;;
    --parflow_src) parflow_src="$2"; shift ;;
    --cosmo_src) cosmo_src="$2"; shift ;;
    --clm35_src|--clm3.5_src) clm35_src="$2"; shift ;;
    --pdaf_src) pdaf_src="$2"; shift ;;
    --oasis_src) oasis_src="$2"; shift ;;
    --build_type) build_type="$2"; shift ;;
    --build_dir) build_dir="$2"; shift ;;
    --install_dir) install_dir="$2"; shift ;;
    --env) env="$2"; shift ;;
    *) echo "Unknown parameter passed: $1"; exit 1 ;;
  esac
  shift
done

# Get tsmp2_dir (full path) from location of $0
cmake_tsmp2_dir=$(dirname $(realpath ${BASH_SOURCE:-$0}))

## Create MODEL_ID + COMPONENT STRING
model_id=""
model_count=0
cmake_comp_str=""

message "Setting model-id and component string..."
# fun set_component shell_name cmake_name
set_component icon "ICON"
set_component eclm "eCLM"
set_component parflow $parflowCMakeModelID
set_component cosmo "COSMO"
set_component clm35 "CLM3.5"
set_component pdaf "PDAF"

if [ $model_count = 0 ];then
  echo "ABORT: No model component is chosen"
  exit 1
elif [ $model_count -ge 2 ];then
  oasis=y
fi

if [[ "${parflowCPU}" == "y" &&  "${parflowGPU}" == "y" ]];then
  echo "ABORT: Building --parflow and --parflowgpu at the same time is not supported."
  exit 1
fi

## CONCATENATE SOURCE CODE STRING
message "Setting component source dir..."
cmake_compsrc_str=""
set_compsrc icon_src "ICON_SRC"
set_compsrc eclm_src "eCLM_SRC"
set_compsrc parflow_src "PARFLOW_SRC"
set_compsrc oasis_src "OASIS_SRC"
set_compsrc pdaf_src "PDAF_SRC"
set_compsrc cosmo_src "COSMO_SRC"
set_compsrc clm35_src "CLM35_SRC"

#
# 1. Download model components
#
if [ "${update_compsrc}" != n ]; then
  dwn_compsrc icon icon_src "icon"
  dwn_compsrc eclm eclm_src "eCLM"
  dwn_compsrc parflow parflow_src "parflow"
  dwn_compsrc oasis oasis_src "oasis3-mct"
  dwn_compsrc pdaf pdaf_src "pdaf"
  dwn_compsrc cosmo cosmo_src "cosmo"
  dwn_compsrc clm35 clm35_src "CLM3.5"
fi

#
# 2. Source environment file
#

if [[ ! -z "${env}" ]]; then
  # Case 1: --env is supplied
  TSMP2_ENV_FILE=$(realpath ${env})
elif [[ ! -z "${TSMP2_ENV_FILE}" ]]; then
  # Case 2: Env var TSMP2_ENV_FILE is set
  message "Detected environment variable TSMP2_ENV_FILE=${TSMP2_ENV_FILE}"
  env=${TSMP2_ENV_FILE}
else
  # Case 3: Neither --env nor TSMP2_ENV_FILE were supplied; use the default env file.
  #         The default env file is expected to set TSMP2_ENV_FILE.
  env="${cmake_tsmp2_dir}/env/default.2025.env"
fi

# Check if the supplied environment file actually exists.
if [[ ! -f "${env}" ]]; then
  message "ERROR: Environment file \"${env}\" not found."
  exit 1
fi

if [[ -n "${env}" ]]; then
  message "Sourcing environment..."

  # TODO: Fix this GPU thing on another PR
  if [[ "$parflowGPU" == "y" ]];then
    source "${env}" --parflowgpu
  else
    source "${env}"
  fi
fi

# TSMP2_ENV_FILE should be set either (1) through --env, (2) as a shell variable,
# or (3) via the default environent file.
if [[ -z "${TSMP2_ENV_FILE}" ]]; then
  message "ERROR: TSMP2_ENV_FILE is not set."
  exit 1
fi

#
# 3. Set CMake build directory
#
BUILD_ID="${SYSTEMNAME^^}_${model_id}"
if [[ -z "${build_dir}" ]]; then
  cmake_build_dir="${cmake_tsmp2_dir}/bld/${BUILD_ID}"
else
  cmake_build_dir="${build_dir}"
fi

# Decide how to deal with an existing build directory
if [[ -d "${cmake_build_dir}" ]]; then
  if [[ "${clean_first}" == y ]]; then
    # Case 1: User wants to explicitly remove existing build directory
    message "Deleting previous build directory $(basename ${cmake_build_dir}) ..."
    rm -rf ${cmake_build_dir}
  elif [[ -f "${cmake_build_dir}/build.env" ]]; then
    build_env=$(realpath ${cmake_build_dir}/build.env)
    bd=$(basename ${cmake_build_dir})
    if [[ "${build_env}" == "${TSMP2_ENV_FILE}" ]]; then
      # Case 2: Resume an existing build using the same environment it previously used.
      message "Resuming build at ${bd} ... "
    else
      # Case 3: Existing build was configured with a different environment.
      message "WARNING: Existing build directory ${bd} uses '$(basename ${build_env})' which is different from the current environment '$(basename ${TSMP2_ENV_FILE})'."
      read -p "Do you want to overwrite ${bd}? (y/N) " yn
      if [ "${yn,}" = "y" ];then
        message "Deleting previous build directory ${bd} ..."
        rm -rf ${cmake_build_dir}
      else
        message "Halting build_tsmp2.sh. Either re-run build_tsmp2.sh with \"--env ${build_env}\", or backup/delete '${cmake_build_dir}' first before re-running build_tsmp2.sh."
        exit 1
      fi
    fi
  fi
fi

# Create build folder for fresh builds
if [[ ! -d "${cmake_build_dir}" ]]; then
  mkdir -p ${cmake_build_dir}
  ln -sf ${TSMP2_ENV_FILE} ${cmake_build_dir}/build.env
fi
build_log="$(dirname ${cmake_build_dir})/${BUILD_ID}_$(date +%Y-%m-%d_%H-%M).log"

#
# 4. Set the rest of the CMake options
#
message "Setting CMAKE options..."
if [[ -z "$build_type" ]];then
   build_type="RELEASE"
fi
if [[ ${build_type^^} == "DEBUG" || ${build_type^^} == "RELEASE" ]]; then
   cmake_build_type="${build_type^^}"
else
   echo "ABORT: Unsupported build_type=${build_type}"
   exit 1
fi

if [ -z "${verbose_makefile}" ]; then
  cmake_verbose_makefile="OFF"
else
  cmake_verbose_makefile="ON"
fi

if [ -z "${install_dir}" ]; then
  cmake_install_dir="${cmake_tsmp2_dir}/bin/${BUILD_ID}"
else
  cmake_install_dir="${install_dir}"
fi
mkdir -p "${cmake_install_dir}"

#
# 5. CMake configure
#
message ""
message "===================="
message "== TSMP2 settings =="
message "===================="
message "MODEL_ID: $model_id"
message "TSMP2_DIR: $cmake_tsmp2_dir"
message "TSMP2_ENV: ${TSMP2_ENV_FILE}"
message "BUILD_DIR: $cmake_build_dir"
message "INSTALL_DIR: ${cmake_install_dir}"
message "CMAKE command:"
cmake_conf="-S ${cmake_tsmp2_dir} -B ${cmake_build_dir}"
cmake_conf+=" -DCMAKE_BUILD_TYPE=${cmake_build_type}"
cmake_conf+=" -DCMAKE_INSTALL_PREFIX=${cmake_install_dir}"
cmake_conf+=" -DCMAKE_VERBOSE_MAKEFILE=${cmake_verbose_makefile}"
cmake_conf+=" ${cmake_comp_str}"
cmake_conf+=" ${cmake_compsrc_str}"
message "cmake ${cmake_conf}" |& tee "${build_log}"
message "== CMAKE GENERATE PROJECT start"
cmake ${cmake_conf} |& tee -a "${build_log}"
message "== CMAKE GENERATE PROJECT finished"

#
# 6. CMake build and install
#
message "CMAKE build:"
message "cmake --build ${cmake_build_dir} |& tee -a $build_log"
message "== CMAKE BUILD start"
cmake --build ${cmake_build_dir} |& tee -a $build_log
message "== CMAKE BUILD finished"

message "CMAKE install:"
message "cmake --install ${cmake_build_dir} |& tee -a $build_log"
message "== CMAKE INSTALL start"
cmake --install ${cmake_build_dir} |& tee -a $build_log
message "== CMAKE INSTALL finished"

#
# 7. Post-installation steps
#
message "Copying build log and environment file to ${cmake_install_dir}..."
if [[ -n "${env}" ]]; then
  cp ${TSMP2_ENV_FILE} ${cmake_install_dir}
fi
cp ${build_log} ${cmake_install_dir}

message ""
message "Log can be found in: ${build_log}"
message "Model environment used: ${TSMP2_ENV_FILE}"
message "Model binaries can be found in: ${cmake_install_dir}"
