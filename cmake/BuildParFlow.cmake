# Choose which CLM to enable
if(DEFINED eCLM_SRC)
    list(APPEND PF_CLM_FLAGS -DPARFLOW_AMPS_LAYER=oas3
                             -DOAS3_ROOT=${OASIS_ROOT}
                             -DPARFLOW_HAVE_ECLM=ON)
elseif(DEFINED CLM35_SRC)
    list(APPEND PF_CLM_FLAGS -DPARFLOW_AMPS_LAYER=oas3
                             -DOAS3_ROOT=${OASIS_ROOT}
                             -DPARFLOW_HAVE_CLM=OFF)
else()
    # use ParFlow's internal CLM
    list(APPEND PF_CLM_FLAGS -DPARFLOW_AMPS_LAYER=mpi1
                             -DPARFLOW_HAVE_CLM=ON)
endif()

# Set GPU-specific options
if (${ParFlowGPU})
  # TODO: Add option to specify CUDA or Kokkos
  include(FindCUDAToolkit)
  if (CUDAToolkit_FOUND)
    set(PF_ACC_BACKEND "cuda")
  else()
    # Search for Kokkos (untested)
    find_package(Kokkos)
    if (Kokkos_FOUND)
      set(PF_ACC_BACKEND "kokkos")
    else()
      message(FATAL_ERROR "BuildParFlow: ParFlow GPU is enabled, but neither CUDA nor Kokkos was found.")
    endif()
  endif()
else()
  find_package(OpenMP)
  if (OpenMP_FOUND)
    set(PF_ACC_BACKEND "omp") 
  else()
    set(PF_ACC_BACKEND "none") 
  endif()
endif()

# Set compiler flags
if(CMAKE_C_COMPILER_ID STREQUAL "GNU")
    # Flags were based from https://github.com/parflow/parflow/blob/c8aa8d7140db19153194728b8fa9136b95177b6d/.github/workflows/linux.yml#L486
    set(PF_CFLAGS "-Wall -Werror -Wno-unused-result -Wno-unused-function -Wno-stringop-overread")
    # Silence arch-specific compiler warnings
    if (${CMAKE_SYSTEM_PROCESSOR} MATCHES "arm64|aarch64")
      string(APPEND PF_CFLAGS " -Wno-maybe-uninitialized")
    endif()
    set(PF_FFLAGS "-ffree-line-length-none -ffixed-line-length-none")
elseif(CMAKE_C_COMPILER_ID STREQUAL "Intel" OR CMAKE_C_COMPILER_ID STREQUAL "IntelLLVM")
elseif(CMAKE_C_COMPILER_ID STREQUAL "NVHPC")
    if (NOT ${ParFlowGPU})
      # TODO: Perhaps there's a case for using NVHPC to target CPU. This would require
      #       fiddling with libraries+environment so we don't support it for now.
      message(FATAL_ERROR "NVHPC is only valid for ParflowGPU builds.")
    endif()
else()
  message(FATAL_ERROR "C compiler '${CMAKE_C_COMPILER_ID}' is not supported.")
endif()

# Enable/disable SLURM
find_program(SLURM_SRUN srun DOC "Path to the SLURM srun executable")
if(SLURM_SRUN)
  set(ENABLE_SLURM "ON")
else()
  set(ENABLE_SLURM "OFF")
endif()

# Pass options to ParFlow CMake
ExternalProject_Add(ParFlow
    PREFIX      ParFlow
    SOURCE_DIR  ${PARFLOW_SRC}
    CMAKE_ARGS  -DCMAKE_C_COMPILER=${CMAKE_C_COMPILER}
                -DCMAKE_C_FLAGS=${PF_CFLAGS}
                -DCMAKE_CXX_COMPILER=${CMAKE_CXX_COMPILER}
                -DCMAKE_Fortran_COMPILER=${CMAKE_Fortran_COMPILER}
                -DCMAKE_Fortran_FLAGS=${PF_FFLAGS}
                -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE}
                -DCMAKE_INSTALL_PREFIX=${CMAKE_INSTALL_PREFIX}
                -DPARFLOW_ENABLE_HYPRE=ON
                -DPARFLOW_ENABLE_NETCDF=ON
                -DPARFLOW_AMPS_SEQUENTIAL_IO=ON
                -DPARFLOW_ENABLE_TIMING=TRUE
                -DPARFLOW_ACCELERATOR_BACKEND=${PF_ACC_BACKEND}
                -DMPIEXEC_EXECUTABLE=${MPIEXEC_EXECUTABLE}
                -DMPIEXEC_NUMPROC_FLAG=${MPIEXEC_NUMPROC_FLAG}
                -DPARFLOW_ENABLE_SLURM=${ENABLE_SLURM}
                ${PF_CLM_FLAGS}
    DEPENDS     ${MODEL_DEPENDENCIES}
)

get_model_version(${PARFLOW_SRC} PARFLOW_VERSION)
list(APPEND TSMP2_MODEL_VERSIONS "${PARFLOW_ID}: ${PARFLOW_VERSION}")
