# TODO: Properly implement these flags!
set(PF_CFLAGS "-qopenmp -Wall -Werror")
set(PF_LDFLAGS "-lcudart -lcusparse -lcurand")

find_package(NetCDF REQUIRED)
find_package(Hypre REQUIRED)

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

#TODO-PDAF: Check include dirs & link flags
if(DEFINED PDAF_SRC)
  add_library(ParFlow-LIB INTERFACE IMPORTED GLOBAL)
  target_include_directories(ParFlow-LIB INTERFACE ${CMAKE_INSTALL_PREFIX}/include)
  target_link_directories(ParFlow-LIB INTERFACE ${CMAKE_INSTALL_PREFIX}/lib)
  target_link_libraries(ParFlow-LIB INTERFACE pfsimulator amps pfkinsol gfortran cjson)

  add_dependencies(ParFlow-LIB ParFlow)
  list(APPEND PDAF_DEPENDENCIES ParFlow-LIB)
endif()

get_model_version(${PARFLOW_SRC} PARFLOW_VERSION)
list(APPEND eTSMP_MODEL_VERSIONS "ParFlow: ${PARFLOW_VERSION}")