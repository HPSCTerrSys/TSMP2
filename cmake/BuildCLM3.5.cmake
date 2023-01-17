find_package(NetCDF REQUIRED)
find_package(MPI COMPONENTS Fortran REQUIRED)

if (DEFINED MPI_HOME)
  set(CLM35_MPI_INC ${MPI_HOME}/include)
  set(CLM35_MPI_LIB ${MPI_HOME}/lib) 
else()
  if (DEFINED MPI_Fortran_INCLUDE_DIRS)
    set(CLM35_MPI_INC ${MPI_Fortran_INCLUDE_DIRS})
  endif()
endif()

string(JOIN " " CLM35_LDFLAGS ${NetCDF_LIBRARIES} ${OASIS_LIBRARIES})

ExternalProject_Add(CLM3_5
  PREFIX            CLM3_5
  SOURCE_DIR        ${CLM35_SRC}
  BUILD_IN_SOURCE   FALSE
  CONFIGURE_COMMAND ${CLM35_SRC}/bld/configure
                    -cc ${CMAKE_C_COMPILER}
                    -fc ${CMAKE_Fortran_COMPILER}
                    -clm_bld ${CMAKE_BINARY_DIR}/CLM3_5/bld
                    -clm_exedir ${CMAKE_INSTALL_PREFIX}/bin
                    -mpi_lib ${CLM35_MPI_LIB}
                    -mpi_inc ${CLM35_MPI_INC}
                    -spmd
                    -smp
                    -maxpft 1
                    -rtm off
                    -usr_src ${CLM35_SRC}/bld/usr.src
                    -oas3_pfl
                    -debug
                    -nc_inc ${NetCDF_F90_ROOT}/include
                    -nc_lib ${NetCDF_F90_ROOT}/lib
                    -nc_mod ${NetCDF_F90_ROOT}/include
                    -fflags -I${OASIS_ROOT}/include
                    -ldflags ${CLM35_LDFLAGS}
  BUILD_COMMAND     make -j16 -C ${CMAKE_BINARY_DIR}/CLM3_5/bld
  INSTALL_COMMAND   ""
)