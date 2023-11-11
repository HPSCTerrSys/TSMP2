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

if(DEFINED PDAF_SRC)
  #TODO: Make implementation more robust by automatically detecting linker flags. This requires
  #      modifying ParFlow CMake scripts such that it exports targets.
  #      https://cmake.org/cmake/help/v3.27/guide/tutorial/Adding%20Export%20Configuration.html#step-11-adding-export-configuration 
  list(APPEND PDAF_DEPENDENCIES ParFlow)
  list(APPEND PDAF_INCLUDES "-I${CMAKE_INSTALL_PREFIX}/include/parflow")
  list(APPEND PDAF_LIBS "-L${CMAKE_INSTALL_PREFIX}/lib -lpfsimulator -lamps -lpfkinsol -lgfortran -lcjson")
  list(APPEND PDAF_LIBS "-L${HYPRE_ROOT}/lib -lHYPRE")
  list(APPEND PDAF_LIBS "-L/lib64 -lslurm")   #TODO: Replace hardcoded path!
endif()

get_model_version(${PARFLOW_SRC} PARFLOW_VERSION)
list(APPEND eTSMP_MODEL_VERSIONS "ParFlow: ${PARFLOW_VERSION}")