cmake_minimum_required (VERSION 3.21.1)
project(eTSMP LANGUAGES C CXX Fortran)
include(ExternalProject)

list(APPEND CMAKE_MODULE_PATH "${CMAKE_SOURCE_DIR}/cmake")

if(NOT CMAKE_BUILD_TYPE AND NOT CMAKE_CONFIGURATION_TYPES)
  set(CMAKE_BUILD_TYPE "RELEASE" CACHE STRING "Choose the type of build." FORCE)
  set_property(CACHE CMAKE_BUILD_TYPE PROPERTY STRINGS "DEBUG" "RELEASE")
endif()

find_package(OASIS3MCT REQUIRED)
find_package(MPIFortran REQUIRED)

# TODO (for all Build*.cmake scripts):
# - Check validity of compile flags
# - Implement set of compile flags depending on compiler (e.g. GNU, Intel) and 
#   build configuration (e.g. Debug, Release, Profiling)

if(DEFINED eCLM_SRC)
  include(BuildeCLM)
endif()

if(DEFINED PARFLOW_SRC)
  include(BuildParFlow)
endif()

if(DEFINED ICON_SRC)
  include(BuildICON)
endif()

if(DEFINED CLM35_SRC)
  include(BuildCLM3.5)
endif()

if(DEFINED COSMO_SRC)
  include(BuildCOSMO)
endif()