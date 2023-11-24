# PDAF variables
# --------------

# Required packages
# -----------------

# NetCDF is required
# For eCLM-PDAF, it will not be loaded
find_package(NetCDF REQUIRED)

# MKL is required
# Find oneMKL from https://www.intel.com/content/www/us/en/docs/onemkl/developer-guide-windows/2024-0/cmake-config-for-onemkl.html
find_package(MKL CONFIG REQUIRED PATHS $ENV{MKLROOT})
message(STATUS "Imported oneMKL targets: ${MKL_IMPORTED_TARGETS}")

# Switching to static libraries
if(MKL_FOUND)
  unset(MKL_LINK CACHE)
  set(MKL_LINK static CACHE STRING "Choose MKL_LINK options: static;dynamic;sdl")
endif()

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
set(PDAF_ARCH "linux_ifort")

# Set PDAF source directory
# -------------------------
set(PDAF_DIR "${PDAF_SRC}")

# Set PDAF_LINK_LIBS for Makefile header
# --------------------------------------
list(APPEND PDAF_LINK_LIBS "-Wl,--start-group")
list(APPEND PDAF_LINK_LIBS "${mkl_intel_ilp64_file}")
list(APPEND PDAF_LINK_LIBS "${mkl_intel_thread_file}")
list(APPEND PDAF_LINK_LIBS "${mkl_core_file}")
list(APPEND PDAF_LINK_LIBS "-L${MPICH_Fortran_LIBDIR}")
list(APPEND PDAF_LINK_LIBS "-Wl,--end-group")

list(APPEND PDAF_LINK_LIBS "-qopenmp")
list(APPEND PDAF_LINK_LIBS "-lpthread")
list(APPEND PDAF_LINK_LIBS "-lm")

# Possible adaptions for JUWELS
# list(APPEND PDAF_LINK_LIBS "-lmkl_intel_lp64")
# list(APPEND PDAF_LINK_LIBS "-lmkl_sequential")
# list(APPEND PDAF_LINK_LIBS "-lmkl_core")

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

# Set env vars required by PDAF Makefiles
# ---------------------------------------
list(APPEND PDAF_ENV_VARS PDAF_ARCH=${PDAF_ARCH})
list(APPEND PDAF_ENV_VARS PDAF_DIR=${PDAF_DIR})
list(APPEND PDAF_ENV_VARS TSMPPDAFLINK_LIBS=${PDAF_LINK_LIBS})
list(APPEND PDAF_ENV_VARS TSMPPDAFOPTIM=${PDAF_OPTIM})
list(APPEND PDAF_ENV_VARS TSMPPDAFMPI_INC=${PDAF_MPI_INC})

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

