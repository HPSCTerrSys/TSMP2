cmake_minimum_required (VERSION 3.21.1)
project(TSMP2 LANGUAGES C CXX Fortran)
#project(TSMP2 LANGUAGES)
include(ExternalProject)

# set default of components to off
option(ICON "Compile ICON within TSMP2 framework" OFF)
option(eCLM "Compile eCLM within TSMP2 framework" OFF)
option(ParFlow "Compile ParFlow within TSMP2 framework" OFF)
option(PDAF "Compile PDAF within TSMP2 framework" OFF)

list(APPEND CMAKE_MODULE_PATH "${CMAKE_SOURCE_DIR}/cmake")
include(Utils)

#set(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/bld)
#set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/bin)

#message("eCLM bool value: $<BOOL:eCLM>")
message("eCLM value: ${eCLM}")
#message("ICON value: ${ICON}")

#MATH(EXPR MODELCOUNT "${ICON}+${eCLM}")
#message(${MODELCOUNT})
#if (MODELCOUNT GREATER_EQUAL 1)
#	message("WRITE MODELCOUNT > 1")
#  set(OASIS On)	
#endif()
##unset(MODELCOUNT CACHE)

string(TOUPPER $ENV{SYSTEMNAME} SYSTEMNAME)
set(MODELCOUNT 0)
set(MODEL_ID "")

#if(CMAKE_INSTALL_PREFIX_INITIALIZED_TO_DEFAULT)
#  set (CMAKE_INSTALL_PREFIX "${CMAKE_BINARY_DIR}/bin/${SYSTEMNAME}_${MODEL_ID}" CACHE PATH "default install path" FORCE)
#endif()
#message("CMAKE_INSTALL_PREFIX ${CMAKE_INSTALL_PREFIX}")

if(NOT CMAKE_BUILD_TYPE AND NOT CMAKE_CONFIGURATION_TYPES)
  set(CMAKE_BUILD_TYPE "RELEASE" CACHE STRING "Choose the type of build." FORCE)
  set_property(CACHE CMAKE_BUILD_TYPE PROPERTY STRINGS "DEBUG" "RELEASE")
endif()

# TODO (for all Build*.cmake scripts):
# - Check validity of compile flags
# - Implement set of compile flags depending on compiler (e.g. GNU, Intel) and 
#   build configuration (e.g. Debug, Release, Profiling)

if (${ICON})
  if(NOT DEFINED ICON_SRC)
    set(ICON_SRC "${CMAKE_BINARY_DIR}/models/icon")
  endif()
  include(BuildICON)
  list(APPEND COMPONENT_MODELS "ICON")
  set(MODEL_ID "${MODEL_ID}ICON")
  MATH(EXPR MODELCOUNT "${MODELCOUNT}+1")
endif()

if(DEFINED COSMO_SRC)
  include(BuildCOSMO)
  list(APPEND COMPONENT_MODELS "COSMO5.1")
endif()

if (${eCLM})
  if(NOT DEFINED eCLM_SRC)
    set(eCLM_SRC "${CMAKE_BINARY_DIR}/models/eCLM")
  endif()
  include(BuildeCLM)
  list(APPEND COMPONENT_MODELS "eCLM")
  set(MODEL_ID "${MODEL_ID}eCLM")
  MATH(EXPR MODELCOUNT "${MODELCOUNT}+1")
endif()
message("eCLMSRC: ${eCLM_SRC}")
message("MODEL_ID: ${MODEL_ID}")
message("MODELCOUNT: ${MODELCOUNT}")

if(DEFINED CLM35_SRC)
  include(BuildCLM3.5)
  list(APPEND COMPONENT_MODELS "CLM3.5")
endif()

if (${ParFlow})
  if(NOT DEFINED PARFLOW_SRC AND NOT ${PDAF})
    set(PARFLOW_SRC "${CMAKE_BINARY_DIR}/models/parflow")
  elseif (NOT DEFINED PARFLOW_SRC AND ${PDAF})
    set(PARFLOW_SRC "${CMAKE_BINARY_DIR}/models/parflow_pdaf")
  endif()
  include(BuildParFlow)
  list(APPEND COMPONENT_MODELS "ParFlow")
  set(MODEL_ID "${MODEL_ID}ParFlow")
  MATH(EXPR MODELCOUNT "${MODELCOUNT}+1")
endif()

if(DEFINED PDAF_SRC)
  include(BuildPDAF)
  include(BuildPDAFMODEL)
  include(BuildPDAFFRAMEWORK)
  list(APPEND COMPONENT_MODELS "PDAF")
endif()

#find_package(MPIFortran REQUIRED)
if (${MODELCOUNT} GREATER 1)
  if(NOT DEFINED OASIS_SRC)
    set(OASIS_SRC "${CMAKE_BINARY_DIR}/models/oasis3-mct")
  endif()
  include(BuildOASIS3MCT)
  list(APPEND MODEL_DEPENDENCIES OASIS3_MCT)
endif()


if(CMAKE_INSTALL_PREFIX_INITIALIZED_TO_DEFAULT)
  set (CMAKE_INSTALL_PREFIX "${CMAKE_BINARY_DIR}/bin/${SYSTEMNAME}_${MODEL_ID}" CACHE PATH "default install path" FORCE)
endif()
message("CMAKE_INSTALL_PREFIX ${CMAKE_INSTALL_PREFIX}")

message("CMAKE CUR BIN DIR ${CMAKE_CURRENT_BINARY_DIR}")
message("CMAKE BIN DIR ${CMAKE_BINARY_DIR}")

#if(NOT DEFINED BUILD_DIR)
#        set(BUILD_DIR "./bld/$ENV{SYSTEMNAME^^}_${MODEL_ID}")
#endif()

print_model_versions("${COMPONENT_MODELS}" "${eTSMP_MODEL_VERSIONS}")

message(FATAL_ERROR "at the end of script")
