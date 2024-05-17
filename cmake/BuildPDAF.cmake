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

# Set PDAF_OPTIM for Makefile header
# ----------------------------------
list(APPEND PDAF_OPTIM "-O2")
list(APPEND PDAF_OPTIM "-xHost")
list(APPEND PDAF_OPTIM "-r8")

# For Gnu-compiler
# list(APPEND PDAF_OPTIM "-O2 -xHost -fbacktrace -fdefault-real-8 -falign-commons -fno-automatic -finit-local-zero -mcmodel=large")

# Join list
list(JOIN PDAF_OPTIM " " PDAF_OPTIM)

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
list(APPEND PDAF_ENV_VARS TSMPPDAFOPTIM=${PDAF_OPTIM})
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
list(APPEND eTSMP_MODEL_VERSIONS "PDAF: ${PDAF_VERSION}")

