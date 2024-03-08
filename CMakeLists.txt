cmake_minimum_required (VERSION 3.21.1)
project(eTSMP LANGUAGES C CXX Fortran)
include(ExternalProject)

list(APPEND CMAKE_MODULE_PATH "${CMAKE_SOURCE_DIR}/cmake")
include(Utils)

if(NOT CMAKE_BUILD_TYPE AND NOT CMAKE_CONFIGURATION_TYPES)
  set(CMAKE_BUILD_TYPE "RELEASE" CACHE STRING "Choose the type of build." FORCE)
  set_property(CACHE CMAKE_BUILD_TYPE PROPERTY STRINGS "DEBUG" "RELEASE")
endif()

find_package(MPIFortran REQUIRED)
if(DEFINED OASIS_SRC)
  include(BuildOASIS3MCT)
  list(APPEND MODEL_DEPENDENCIES OASIS3_MCT)
endif()

# TODO (for all Build*.cmake scripts):
# - Check validity of compile flags
# - Implement set of compile flags depending on compiler (e.g. GNU, Intel) and 
#   build configuration (e.g. Debug, Release, Profiling)

if(DEFINED eCLM_SRC)
  include(BuildeCLM)
  list(APPEND COMPONENT_MODELS "eCLM")
endif()

if(DEFINED CLM35_SRC)
  include(BuildCLM3.5)
  list(APPEND COMPONENT_MODELS "CLM3.5")
endif()

if(DEFINED ICON_SRC)
  include(BuildICON)
  list(APPEND COMPONENT_MODELS "ICON")
endif()

if(DEFINED COSMO_SRC)
  include(BuildCOSMO)
  list(APPEND COMPONENT_MODELS "COSMO5.1")
endif()

if(DEFINED PARFLOW_SRC)
  include(BuildParFlow)
  list(APPEND COMPONENT_MODELS "ParFlow")
endif()

if(DEFINED PDAF_SRC)
  include(BuildPDAF)
  include(BuildPDAFMODEL)
  include(BuildPDAFFRAMEWORK)
  list(APPEND COMPONENT_MODELS "PDAF")
endif()

print_model_versions("${COMPONENT_MODELS}" "${eTSMP_MODEL_VERSIONS}")
