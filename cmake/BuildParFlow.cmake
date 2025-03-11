find_package(NetCDF REQUIRED)
find_package(Hypre REQUIRED)
find_package(OpenMP REQUIRED)

#
# Choose which CLM to enable
#
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

#
# TODO: Add compile switches for ParFlow GPU
#
if(CMAKE_C_COMPILER_ID STREQUAL "GNU")
    # Flags were based from https://github.com/parflow/parflow/blob/c8aa8d7140db19153194728b8fa9136b95177b6d/.github/workflows/linux.yml#L486
    set(PF_CFLAGS "${OpenMP_Fortran_FLAGS} -Wall -Werror -Wno-unused-result -Wno-unused-function -Wno-stringop-overread")
    # Silence arch-specific compiler warnings
    if (${CMAKE_SYSTEM_PROCESSOR} MATCHES "arm64|aarch64")
      string(APPEND PF_CFLAGS " -Wno-maybe-uninitialized")
    endif()     
    set(PF_FFLAGS "-ffree-line-length-none -ffixed-line-length-none")
    #TODO: These flags are specific to JSC system. This should be set in an env or build script!
    set(PF_LDFLAGS "")
    set(ENABLE_SLURM "OFF")
elseif(CMAKE_C_COMPILER_ID STREQUAL "Intel" OR CMAKE_C_COMPILER_ID STREQUAL "IntelLLVM")
    set(PF_CFLAGS "${OpenMP_Fortran_FLAGS} -Wall -Werror -Wno-unused-function -Wno-unused-variable")
    #TODO: These flags are specific to JSC system. This should be set in an env or build script!
    set(PF_LDFLAGS "-lcudart -lcusparse -lcurand")
    set(ENABLE_SLURM "ON")
else()
  message(FATAL_ERROR "C compiler '${CMAKE_C_COMPILER_ID}' is not supported.")
endif()

#
# Pass options to ParFlow CMake
#
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
                -DHYPRE_ROOT=${HYPRE_ROOT}
                -DNETCDF_DIR=${NetCDF_C_ROOT}
                -DPARFLOW_AMPS_SEQUENTIAL_IO=on
                -DPARFLOW_ENABLE_TIMING=TRUE
                -DMPIEXEC_EXECUTABLE=${MPIEXEC_EXECUTABLE}
                -DMPIEXEC_NUMPROC_FLAG=${MPIEXEC_NUMPROC_FLAG}
                -DPARFLOW_ENABLE_SLURM=${ENABLE_SLURM}
                -DCMAKE_EXE_LINKER_FLAGS=${PF_LDFLAGS}
                ${PF_CLM_FLAGS}
                ${JSC_FLAGS}
    DEPENDS     ${MODEL_DEPENDENCIES}
)

get_model_version(${PARFLOW_SRC} PARFLOW_VERSION)
list(APPEND TSMP2_MODEL_VERSIONS "ParFlow: ${PARFLOW_VERSION}")
