find_package(NetCDF REQUIRED)
find_package(Hypre REQUIRED)
find_package(OpenMP REQUIRED)

if(CMAKE_C_COMPILER_ID STREQUAL "GNU")
    # Flags were based from https://github.com/parflow/parflow/blob/77316043227b95215744e58fe9005d35145432ab/.github/workflows/linux.yml#L305
    set(PF_CFLAGS "${OpenMP_Fortran_FLAGS} -Wall -Werror -Wno-unused-result -Wno-unused-function")
elseif(CMAKE_C_COMPILER_ID STREQUAL "Intel" OR CMAKE_C_COMPILER_ID STREQUAL "IntelLLVM")
    set(PF_CFLAGS "${OpenMP_Fortran_FLAGS} -Wall -Werror")
    set(PF_LDFLAGS "-lcudart -lcusparse -lcurand") #TODO: These linker flags are specific to JSC system!
else()
  message(FATAL_ERROR "C compiler '${CMAKE_C_COMPILER_ID}' is not supported.")
endif()


set(PF_CFLAGS "${OpenMP_Fortran_FLAGS} ${OpenMP_Fortran_FLAGS}")
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

# TODO: Add compile switches for ParFlow GPU
ExternalProject_Add(ParFlow
    PREFIX      ParFlow
    SOURCE_DIR  ${PARFLOW_SRC}
    CMAKE_ARGS  -DCMAKE_C_COMPILER=${CMAKE_C_COMPILER}
                -DCMAKE_CXX_COMPILER=${CMAKE_CXX_COMPILER}
                -DCMAKE_Fortran_COMPILER=${CMAKE_Fortran_COMPILER}
                -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE}
                -DCMAKE_INSTALL_PREFIX=${CMAKE_INSTALL_PREFIX}
                ${PF_CLM_FLAGS}
                -DNETCDF_DIR=${NetCDF_ROOT}
                -DPARFLOW_AMPS_SEQUENTIAL_IO=on
                -DHYPRE_ROOT=${HYPRE_ROOT}
                -DPARFLOW_ENABLE_TIMING=TRUE
                -DPARFLOW_ENABLE_SLURM=TRUE
                -DMPIEXEC_EXECUTABLE=${MPIEXEC_EXECUTABLE}
                -DMPIEXEC_NUMPROC_FLAG=${MPIEXEC_NUMPROC_FLAG}
                -DCMAKE_C_FLAGS=${PF_CFLAGS}
                -DCMAKE_EXE_LINKER_FLAGS=${PF_LDFLAGS}
    DEPENDS     ${MODEL_DEPENDENCIES}
)

get_model_version(${PARFLOW_SRC} PARFLOW_VERSION)
list(APPEND TSMP2_MODEL_VERSIONS "ParFlow: ${PARFLOW_VERSION}")