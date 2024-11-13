# PDAF variables
# --------------

# Required packages
# -----------------

# NetCDF is required
# For eCLM-PDAF, NetCDF is not loaded by other component models
find_package(NetCDF REQUIRED)

# MKL is required (error: https://gitlab.jsc.fz-juelich.de/HPSCTerrSys/tsmp-internal-development-tracking/-/issues/87)
# `find_package`command for oneMKL from https://www.intel.com/content/www/us/en/docs/onemkl/developer-guide-windows/2024-0/cmake-config-for-onemkl.html
# set(MKL_LINK static) # Switching to static MKL libraries
# find_package(MKL CONFIG REQUIRED PATHS $ENV{MKLROOT})

# LAPACK is required
# For eCLM-PDAF, this setting has to be consistent with MKL/LAPACK
# loading in `eCLM/src/clm5/CMakelists.txt`
find_package(LAPACK REQUIRED)

# OpenMP is required
find_package(OpenMP REQUIRED)

# # TODO: Insert CMake-finding of "-lm"
# find_library(M_LIB NAMES m)
# if(M_LIB)
#   message(STATUS "M_LIB: ${M_LIB}")
# endif()

# Set PDAF_DEPENDENCIES: component models / OASIS
# -----------------------------------------------
if(DEFINED OASIS_SRC)
  list(APPEND PDAF_DEPENDENCIES OASIS3_MCT)
endif()
if(DEFINED eCLM_SRC)
  list(APPEND PDAF_DEPENDENCIES eCLM)
endif()
if(DEFINED CLM35_SRC)
  list(APPEND PDAF_DEPENDENCIES CLM3_5)
endif()
if(DEFINED PARFLOW_SRC)
  list(APPEND PDAF_DEPENDENCIES ParFlow)
endif()

# Set environment header/include file for PDAF-library compilation
# ----------------------------------------------------------------
set(PDAF_ARCH "cmake")

# Set PDAF source directory
# -------------------------
set(PDAF_DIR "${PDAF_SRC}")

# Set PDAF_LINK_LIBS for Makefile header
# --------------------------------------
# --start-group: libraries inside the group are recalled until, such
# --that order does not matter in the linking command
list(APPEND PDAF_LINK_LIBS "-Wl,--start-group")
list(APPEND PDAF_LINK_LIBS "${mkl_intel_ilp64_file}")
list(APPEND PDAF_LINK_LIBS "${mkl_intel_thread_file}")
list(APPEND PDAF_LINK_LIBS "${mkl_core_file}")
list(APPEND PDAF_LINK_LIBS "-qmkl")
list(APPEND PDAF_LINK_LIBS "-Wl,--end-group")

# Explicit libraries named in comments should be handed over by the
# variables. For checking this, search `$BUILD_DIR/CMakeCache.txt`.
list(APPEND PDAF_LINK_LIBS "${MPICH_Fortran_LDFLAGS}") # "-lpthread"
list(APPEND PDAF_LINK_LIBS "-lmpich")
list(APPEND PDAF_LINK_LIBS "${OpenMP_Fortran_FLAGS}") # "-qopenmp"
list(APPEND PDAF_LINK_LIBS "${NetCDF_F90_STATIC_LDFLAGS}") # "-lnetcdf", "-lnetcdff", "-lpnetcdf", "-lm"

# Join list
list(JOIN PDAF_LINK_LIBS " " PDAF_LINK_LIBS)

# Set PDAF_FOPT for Makefile header
# ----------------------------------
if (CMAKE_CXX_COMPILER_ID STREQUAL "Intel"
    OR CMAKE_CXX_COMPILER_ID STREQUAL "IntelLLVM")

  # using Intel Compiler
  if (CMAKE_BUILD_TYPE STREQUAL "RELEASE")
    # Release optimization flags
    list(APPEND PDAF_FOPT "-O2")
  elseif (CMAKE_BUILD_TYPE STREQUAL "DEBUG")
    # Debug optimization flags
    list(APPEND PDAF_FOPT "-O0")
    list(APPEND PDAF_FOPT "-g")
    list(APPEND PDAF_FOPT "-traceback")
  else()
    message(FATAL_ERROR "Unsupported CMAKE_BUILD_TYPE: ${CMAKE_BUILD_TYPE}")
  endif()

  list(APPEND PDAF_FOPT "-xHost")

elseif (CMAKE_CXX_COMPILER_ID STREQUAL "GNU")

  # using GCC (experimental)
  if (CMAKE_BUILD_TYPE STREQUAL "RELEASE")
    # Release optimization flags
    list(APPEND PDAF_FOPT "-O2")
  elseif (CMAKE_BUILD_TYPE STREQUAL "DEBUG")
    # Debug optimization flags
    list(APPEND PDAF_FOPT "-O0")
    list(APPEND PDAF_FOPT "-g")
    list(APPEND PDAF_FOPT "-fbacktrace")
  else()
    message(FATAL_ERROR "Unsupported CMAKE_BUILD_TYPE: ${CMAKE_BUILD_TYPE}")
  endif()

  list(APPEND PDAF_FOPT "-falign-commons")
  list(APPEND PDAF_FOPT "-fno-automatic")
  list(APPEND PDAF_FOPT "-finit-local-zero")
  list(APPEND PDAF_FOPT "-mcmodel=large")

else()
  message(FATAL_ERROR "Unsupported CMAKE_CXX_COMPILER_ID: ${CMAKE_CXX_COMPILER_ID}")
endif()

# Join list
list(JOIN PDAF_FOPT " " PDAF_FOPT)

# Set PDAF_COPT for Makefile header
# ----------------------------------
if (CMAKE_CXX_COMPILER_ID STREQUAL "Intel")

  # using Intel Compiler
  if (CMAKE_BUILD_TYPE STREQUAL "RELEASE")
    # Release optimization flags
    list(APPEND PDAF_COPT "-O2")
  elseif (CMAKE_BUILD_TYPE STREQUAL "DEBUG")
    # Debug optimization flags
    list(APPEND PDAF_COPT "-O0")
    list(APPEND PDAF_COPT "-g")
    list(APPEND PDAF_COPT "-traceback")
  else()
    message(FATAL_ERROR "Unsupported CMAKE_BUILD_TYPE: ${CMAKE_BUILD_TYPE}")
  endif()

  list(APPEND PDAF_COPT "-xHost")

elseif (CMAKE_CXX_COMPILER_ID STREQUAL "GNU")

  # using GCC (experimental)
  if (CMAKE_BUILD_TYPE STREQUAL "RELEASE")
    # Release optimization flags
    list(APPEND PDAF_COPT "-O2")
  elseif (CMAKE_BUILD_TYPE STREQUAL "DEBUG")
    # Debug optimization flags
    list(APPEND PDAF_COPT "-O0")
    list(APPEND PDAF_COPT "-g")
    list(APPEND PDAF_COPT "-fbacktrace")
  else()
    message(FATAL_ERROR "Unsupported CMAKE_BUILD_TYPE: ${CMAKE_BUILD_TYPE}")
  endif()

  list(APPEND PDAF_COPT "-falign-commons")
  list(APPEND PDAF_COPT "-fno-automatic")
  list(APPEND PDAF_COPT "-finit-local-zero")
  list(APPEND PDAF_COPT "-mcmodel=large")

else()
  message(FATAL_ERROR "Unsupported CMAKE_CXX_COMPILER_ID: ${CMAKE_CXX_COMPILER_ID}")
endif()

# Join list
list(JOIN PDAF_COPT " " PDAF_COPT)

# Set PDAF_DOUBLEPRECISION for Makefile header
# --------------------------------------------
if (CMAKE_CXX_COMPILER_ID STREQUAL "Intel"
    OR CMAKE_CXX_COMPILER_ID STREQUAL "IntelLLVM")

  list(APPEND PDAF_DOUBLEPRECISION "-r8")

elseif (CMAKE_CXX_COMPILER_ID STREQUAL "GNU")

  list(APPEND PDAF_DOUBLEPRECISION "-fdefault-real-8")

else()
  message(FATAL_ERROR "Unsupported CMAKE_CXX_COMPILER_ID: ${CMAKE_CXX_COMPILER_ID}")
endif()

# Join list
list(JOIN PDAF_DOUBLEPRECISION " " PDAF_DOUBLEPRECISION)

# Set PDAF_MPI_INC for Makefile header
# ----------------------------------
list(APPEND PDAF_MPI_INC "-I${MPICH_Fortran_INCLUDEDIR}")

# Join list
list(JOIN PDAF_MPI_INC " " PDAF_MPI_INC)

# Set PDAF_CPP_DEFS for Makefile header
# ----------------------------------
# `-DUSE_PDAF` is always needed in the PDAF header file
list(APPEND PDAF_CPP_DEFS "-DUSE_PDAF")
if (CMAKE_BUILD_TYPE STREQUAL "DEBUG")
  # For debugging runs, turn on `-DPDAF_DEBUG`
  list(APPEND PDAF_CPP_DEFS "-DPDAF_DEBUG")
endif()

# Join list
list(JOIN PDAF_CPP_DEFS " " PDAF_CPP_DEFS)

# Set env vars required by PDAF Makefiles
# ---------------------------------------
list(APPEND PDAF_ENV_VARS PDAF_ARCH=${PDAF_ARCH})
list(APPEND PDAF_ENV_VARS PDAF_DIR=${PDAF_DIR})
list(APPEND PDAF_ENV_VARS TSMPPDAFLINK_LIBS=${PDAF_LINK_LIBS})
list(APPEND PDAF_ENV_VARS TSMPPDAFOPTIM=${PDAF_FOPT}) #backward compatibility
list(APPEND PDAF_ENV_VARS TSMPPDAFFOPT=${PDAF_FOPT})
list(APPEND PDAF_ENV_VARS TSMPPDAFCOPT=${PDAF_COPT})
list(APPEND PDAF_ENV_VARS TSMPPDAFDOUBLEPRECISION=${PDAF_DOUBLEPRECISION})
list(APPEND PDAF_ENV_VARS TSMPPDAFMPI_INC=${PDAF_MPI_INC})
list(APPEND PDAF_ENV_VARS TSMPPDAFCPP_DEFS=${PDAF_CPP_DEFS})

list(JOIN PDAF_ENV_VARS " " PDAF_ENV_VARS_STR)
# message(STATUS "${PDAF_ENV_VARS_STR}")
# message(WARNING "${PDAF_ENV_VARS_STR}")
# message(FATAL_ERROR "${PDAF_ENV_VARS}")
# # uncomment to force stop CMake @ Configure step

# make pdaf
ExternalProject_Add(PDAF
  PREFIX            PDAF
  SOURCE_DIR        ${PDAF_SRC}/src
  BUILD_IN_SOURCE   TRUE
  CONFIGURE_COMMAND ""
  BUILD_COMMAND     make ${PDAF_ENV_VARS} clean ../lib/libpdaf-d.a
  INSTALL_COMMAND   ""
  DEPENDS           ${PDAF_DEPENDENCIES}
)

get_model_version(${PDAF_SRC} PDAF_VERSION)
list(APPEND TSMP2_MODEL_VERSIONS "PDAF: ${PDAF_VERSION}")

