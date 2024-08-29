#!/bin/bash
### TSMP2 frontend
### Shell-based script to compile model components within the TSMP2 framework.
###
### For more information:
### ./build_tsmp2.sh --help

## functions

function help_tsmp2() {
  echo "Usage: $0 [-v ] [--component_name] [--optionals]"
  echo "  -q, --quite      Write less output during shell execution"
  echo "  --ICON           Compile with ICON"
  echo "  --eCLM           Compile with eCLM"
  echo "  --ParFlow        Compile with ParFlow"
  echo "  --PDAF           Compile with PDAF"
  echo "  --COSMO          Compile with COSMO"
  echo "  --CLM35          Compile with CLM3.5"
  echo "  --ICON_SRC       Set ICON_SRC directory"
  echo "  --eCLM_SRC       Set eCLM_SRC directory"
  echo "  --ParFlow_SRC    Set ParFlow_SRC directory"
  echo "  --OASIS_SRC      Set OASIS3-MCT directory"
  echo "  --PDAF_SRC       Set PDAF_SRC directory"
  echo "  --build_config   Set build configuration: 'Debug' 'Release'"
  echo "  --compiler       Set compiler for building"
  echo "  --source_dir     Set source dir of cmake, if not set <tsmp2_dir> is used"
  echo "  --build_dir      Set build dir cmake, if not set bld/<SYSTEMNAME>_<model-id> is used. Build artifacts will be generated in this folder."
  echo "  --install_dir    Set install dir cmake, if not set bin/<SYSTEMNAME>_<model-id> is used. Model executables and libraries will be installed here"
  echo "  --tsmp2_dir      Set tsmp2_dir, if not set pwd is used"
  echo "  --tsmp2_env      Set model environment."
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
  if [[ $cmake_name = @(ICON|eCLM|PARFLOW|COSMO|CLM35) ]]; then
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

function message(){
#local -n messstr="$1"
if [ -z "${quite}" ];then
  echo "$1" #$messstr
fi # message
}

###
## PROGRAM START
###

## get params
while [[ "$#" -gt 0 ]]; do
    case "${1,,}" in
	-h|--help) help_tsmp2;;
	-q|--quite) quite=y;;
        --icon) icon=y;;
        --eclm) eclm=y;;
	--parflow) parflow=y;;
	--pdaf) pdaf=y;;
	--cosmo) cosmo=y;;
	--clm35) clm35=y;;
	--icon_src) icon_src="$2"; shift ;;
	--eclm_src) eclm_src="$2"; shift ;;
	--parflow_src) parflow_src="$2"; shift ;;
	--pdaf_src) pdaf_src="$2"; shift ;;
	--oasis_src) oasis_src="$2"; shift ;;
	--build_config) build_config="$2"; shift ;;
	--compiler) compiler="$2"; shift ;; 
	--build_dir) build_dir="$2"; shift ;;
        --source_dir) source_dir="$2"; shift ;;
	--install_dir) install_dir="$2"; shift ;;
	--tsmp2_dir) tsmp2_dir="$2"; shift ;;
	--tsmp2_env) tsmp2_env="$2"; shift ;;
        *) echo "Unknown parameter passed: $1"; exit 1 ;;
    esac
    shift
done

## Create MODEL-ID + COMPONENT STRING
model_id=""
model_count=0
cmake_comp_str=""

message "set model-id and component string"
# fun set_component shell_name cmake_name
set_component icon "ICON"
set_component eclm "eCLM"
set_component parflow "PARFLOW"
set_component pdaf "PDAF"
set_component cosmo "COSMO"
set_component clm35 "CLM35"

if [ $model_count = 0 ];then
  echo "No model component is chosen"
  exit 1
fi

## CONCADINATE SOURCE CODE STRING
message "set component source dir"
cmake_compsrc_str=""
set_compsrc icon_src "ICON_SRC"
set_compsrc eclm_src "eCLM_SRC"
set_compsrc parflow_src "PARFLOW_SRC"
set_compsrc oasis_src "OASIS_SRC"
set_compsrc pdaf_src "PDAF_SRC"
set_compsrc cosmo_src "COSMO_SRC"
set_compsrc clm35_src "CLM35_SRC"

## CMAKE options

message "set CMAKE options"
# build_config
if [[ -z $build_config ]];then
   cmake_build_config=""
else
   cmake_build_config=" -DCMAKE_BUILD_TYPE=${build_config}"
fi

# set compiler
if [[ -z $compiler ]];then
   cmake_compiler=""
else
   cmake_comiler=" -DCMAKE_CXX_COMPILER_ID=${compiler}"
fi

# set INSTALL and BUILD DIR (neccesary for building)
if [ -n ${tsmp2_dir} ]; then
  cmake_tsmp2_dir="${PWD}"
else
  cmake_tsmp2_dir="${tsmp2_dir}"
fi # tsmp2_dir

if [ -z ${SYSTEMNAME} ]; then SYSTEMNAME="UNKN"; fi

if [ -n ${build_dir} ]; then
  cmake_build_dir="${cmake_tsmp2_dir}/bld/${SYSTEMNAME^^}_${model_id}" 
else
  cmake_build_dir="${build_dir}"
fi # build_dir

if [ -n ${install_dir} ]; then
  cmake_install_dir="-DCMAKE_INSTALL_PREFIX=${cmake_tsmp2_dir}/bin/${SYSTEMNAME^^}_${model_id}"
else
  cmake_install_dir="-DCMAKE_INSTALL_PREFIX=${install_dir}"
fi # install_dir

build_log="$(dirname ${cmake_build_dir})/${model_id}_$(date +%Y-%m-%d_%H-%M).log"

## source environment
message "source environment"
if [ -n ${tsmp2_env} ]; then
  tsmp2_env="${cmake_tsmp2_dir}/env/jsc.2023_Intel.sh"
else
  tsmp2_env="${tsmp2_env}"
fi # tsmp2_env
source $tsmp2_env

## CMAKE config
# rm -rf ${cmake_build_dir}
mkdir -pv ${cmake_build_dir} $( echo "${cmake_install_dir}" |cut -d\= -f2)
message "===================="
message "== TSMP2 settings =="
message "===================="
message "MODEL-ID: $model_id"
message "TSMP2DIR: $cmake_tsmp2_dir"
message "BUILDDIR: $cmake_build_dir"
message "INSTALLDIR: $( echo "${cmake_install_dir}" |cut -d\= -f2)"
message "CMAKE command:"
message "cmake -S ${cmake_tsmp2_dir} -B ${cmake_build_dir}  ${cmake_build_config} ${cmake_comp_str}  ${cmake_compsrc_str}  ${cmake_build_config} ${cmake_compiler} ${cmake_install_dir} |& tee ${build_log} "

cmake -S ${cmake_tsmp2_dir} -B ${cmake_build_dir} \
      ${cmake_build_config} \
      ${cmake_comp_str} \
      ${cmake_compsrc_str} \
      ${cmake_build_config} ${cmake_compiler} ${cmake_install_dir} \
      |& tee ${build_log}

## Build and install

message "CMAKE build:"
message "cmake --build ${cmake_build_dir} |& tee -a $build_log"
cmake --build ${cmake_build_dir} |& tee -a $build_log

message "CMAKE install:"
message "cmake --install ${cmake_build_dir} |& tee -a $build_log"
cmake --install ${cmake_build_dir} |& tee -a $build_log

## Copy log and environment
message "Copy log and environment to install_dir"
cp ${tsmp2_env} $( echo "${cmake_install_dir}" |cut -d\= -f2)
cp ${build_log} $( echo "${cmake_install_dir}" |cut -d\= -f2)

## message
message "Log can be found in: ${build_log}"
message "Model environment used: ${tsmp_env}"
message "Model binaries can be found in: $( echo "${cmake_install_dir}" |cut -d\= -f2)"
