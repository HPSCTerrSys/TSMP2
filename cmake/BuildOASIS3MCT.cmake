find_package(NetCDF REQUIRED)

if (CMAKE_BUILD_TYPE STREQUAL "DEBUG")
  set(OMPTIM_FLAG "-g")
  set(MCT_DEBUGFLAG "--enable-debugging")
elseif (CMAKE_BUILD_TYPE STREQUAL "RELEASE")
  set(OMPTIM_FLAG "-O2")
  set(MCT_DEBUGFLAG "")
else()
  # Assume CMAKE_BUILD_TYPE=RELEASE if CMAKE_BUILD_TYPE is unknown
  set(OMPTIM_FLAG "-O2")
  message(WARNING "CMAKE_BUILD_TYPE='${CMAKE_BUILD_TYPE}' is not supported by OASIS3-MCT")
endif()

set(OASIS_BLD_DIR ${CMAKE_CURRENT_BINARY_DIR}/OASIS3_MCT/bld)
set(OASIS_MAKE_INC ${OASIS_BLD_DIR}/make.inc)
file(WRITE   ${OASIS_MAKE_INC} "CHAN            = MPI1\n")
file(APPEND  ${OASIS_MAKE_INC} "COUPLE          = ${OASIS_SRC}\n")
file(APPEND  ${OASIS_MAKE_INC} "BUILD_DIR       = ${OASIS_BLD_DIR}\n")
file(APPEND  ${OASIS_MAKE_INC} "ARCHDIR         = ${CMAKE_INSTALL_PREFIX}\n")
file(APPEND  ${OASIS_MAKE_INC} "NETCDF_INCLUDE  = ${NetCDF_ROOT}/include\n")
file(APPEND  ${OASIS_MAKE_INC} "NETCDF_LIBRARY  = ${NetCDF_LIBRARIES}\n")
file(APPEND  ${OASIS_MAKE_INC} "MPI_INCLUDE     = ${MPI_Fortran_INCLUDE_DIRS}\n")
file(APPEND  ${OASIS_MAKE_INC} "MAKE            = make\n")
file(APPEND  ${OASIS_MAKE_INC} "F90             = ${CMAKE_Fortran_COMPILER}\n")
file(APPEND  ${OASIS_MAKE_INC} "F               = $(F90)\n")
file(APPEND  ${OASIS_MAKE_INC} "f90             = $(F90)\n")
file(APPEND  ${OASIS_MAKE_INC} "f               = $(F90)\n")
file(APPEND  ${OASIS_MAKE_INC} "CC              = ${CMAKE_C_COMPILER}\n")
file(APPEND  ${OASIS_MAKE_INC} "LD              = ${CMAKE_Fortran_COMPILER} -L${MPI_Fortran_LIB_DIR}\n")
file(APPEND  ${OASIS_MAKE_INC} "AR              = ar\n")
file(APPEND  ${OASIS_MAKE_INC} "ARFLAGS         = -ruv\n")
file(APPEND  ${OASIS_MAKE_INC} "DYNOPT          = -fPIC\n")
file(APPEND  ${OASIS_MAKE_INC} "LDDYNOPT        = -shared\n")
file(APPEND  ${OASIS_MAKE_INC} "CPPDEF          = -Duse_netCDF -Duse_comm_$(CHAN) -D__VERBOSE  -DTREAT_OVERLAY\n")
file(APPEND  ${OASIS_MAKE_INC} "FCBASEFLAGS     = ${OMPTIM_FLAG} -xCORE-AVX2 -I. -assume byterecl -mt_mpi -qopenmp\n")
file(APPEND  ${OASIS_MAKE_INC} "CCBASEFLAGS     = ${OMPTIM_FLAG} -qopenmp\n")
file(APPEND  ${OASIS_MAKE_INC} "MCT_DEBUGFLAG   = ${MCT_DEBUGFLAG}\n")
file(APPEND  ${OASIS_MAKE_INC} "FLIBS           = ${NetCDF_LIBRARIES}\n")
file(APPEND  ${OASIS_MAKE_INC} "INC_DIRS        = -I${CMAKE_INSTALL_PREFIX}/include -I$(NETCDF_INCLUDE)\n")
file(APPEND  ${OASIS_MAKE_INC} "F90FLAGS        = $(FCBASEFLAGS) $(INC_DIRS) $(CPPDEF) \n")
file(APPEND  ${OASIS_MAKE_INC} "f90FLAGS        = $(F90FLAGS)\n")
file(APPEND  ${OASIS_MAKE_INC} "FFLAGS          = $(F90FLAGS)\n")
file(APPEND  ${OASIS_MAKE_INC} "fFLAGS          = $(F90FLAGS)\n")
file(APPEND  ${OASIS_MAKE_INC} "CFLAGS          = $(CCBASEFLAGS) $(INC_DIRS) $(CPPDEF)\n")
file(APPEND  ${OASIS_MAKE_INC} "CCFLAGS         = $(CCBASEFLAGS) $(INC_DIRS) $(CPPDEF)\n")
file(APPEND  ${OASIS_MAKE_INC} "LDFLAGS         = $(FCBASEFLAGS)\n")

set(OASIS_MAKE_COMMON ${OASIS_BLD_DIR}/make.common)
file(WRITE   ${OASIS_MAKE_COMMON} "LIBBUILD        ?= $(ARCHDIR)/lib\n")
file(APPEND  ${OASIS_MAKE_COMMON} "LIBBUILDSHARED  ?= $(ARCHDIR)/build-shared/lib\n")

ExternalProject_Add(OASIS3_MCT
  PREFIX            OASIS3_MCT
  SOURCE_DIR        ${OASIS_SRC}
  BUILD_IN_SOURCE   FALSE
  CONFIGURE_COMMAND ""
  BUILD_COMMAND     make -f ${OASIS_SRC}/util/make_dir/TopMakefileOasis3 realclean static-libs -C ${OASIS_BLD_DIR}
  INSTALL_COMMAND   ""
)

set(OASIS_ROOT ${CMAKE_INSTALL_PREFIX} CACHE PATH "Full path to the root directory containing OASIS3-MCT include files and libraries.")
set(OASIS_LIBRARIES "-L${OASIS_ROOT}/lib -lpsmile.MPI1 -lmct -lmpeu -lscrip" CACHE STRING "OASIS3-MCT linker options")
get_model_version(${OASIS_SRC} OASIS_VERSION)
list(APPEND eTSMP_MODEL_VERSIONS "OASIS3-MCT: ${OASIS_VERSION}")