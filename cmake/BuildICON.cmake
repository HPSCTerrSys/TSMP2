# ICON 2.6.4
if(CMAKE_Fortran_COMPILER_ID STREQUAL "GNU")
  # TODO: These flags were based from a DWD build script. There are too many warning supression flags and
  #       the flags seems to be inconsistent (e.g. both optimization and debug flags were enabled in the
  #       DWD build script!). These flags should be validated and pruned whenever possible.
  #
  # [1] https://github.com/HPSCTerrSys/icon-model_coup-oas/blob/ce5c8f8ba75d2e7db73e41cbb186d98ec34171c8/config/dwd/rcl.VH.gcc-12.3.0_mpi-3.5_oper#L82
  set(ICON_CFLAGS "")
  set(ICON_FCFLAGS "-std=gnu -fno-range-check -fallow-invalid-boz -fallow-argument-mismatch -fmodule-private -fbacktrace -fimplicit-none -fmax-identifier-length=63 -ffree-line-length-none -Wall -Wcharacter-truncation -Wconversion -Wunderflow -Wunused-parameter -Wno-surprising -fall-intrinsics")
if (${CMAKE_SYSTEM_PROCESSOR} MATCHES "x86_64|amd64")
    string(APPEND ICON_CFLAGS " -mavx2 -mno-fma")
    string(APPEND ICON_FCFLAGS " -mavx2 -mno-fma -mpc64")
endif() 
elseif(CMAKE_Fortran_COMPILER_ID STREQUAL "Intel" OR CMAKE_Fortran_COMPILER_ID STREQUAL "IntelLLVM")
  set(ICON_CFLAGS "-gdwarf-4 -qno-opt-dynamic-align -ftz -march=native")
  set(ICON_FCFLAGS "-gdwarf-4 -march=native -pc64 -fp-model source -traceback -qno-opt-dynamic-align -no-fma")
endif()
set(ICON_LDFLAGS "-Wl,--copy-dt-needed-entries,--as-needed ${OASIS_LIBRARIES}")
set(ICON_ECRAD_FCFLAGS "-D__ECRAD_LITTLE_ENDIAN")

# Control compiler optimization depending on CMAKE_BUILD_TYPE
if (CMAKE_BUILD_TYPE STREQUAL "DEBUG")
  string(PREPEND ICON_CFLAGS "-g ")
  string(PREPEND ICON_FCFLAGS "-g ")
elseif (CMAKE_BUILD_TYPE STREQUAL "RELEASE")
  string(PREPEND ICON_CFLAGS "-O2 ")
  string(PREPEND ICON_FCFLAGS "-O2 ")
else()
  # Assume CMAKE_BUILD_TYPE=RELEASE if CMAKE_BUILD_TYPE is unknown
  string(PREPEND ICON_CFLAGS "-O2 ")
  string(PREPEND ICON_FCFLAGS "-O2 ")
  message(WARNING "CMAKE_BUILD_TYPE='${CMAKE_BUILD_TYPE}' is not supported by ICON")
endif()

# -Wl specifies linker options. '--as-needed' means only libraries 
# required by the program are linked, i.e. libraries passed to the
# linker that are unused won't be recorded on the ELF header.
list(APPEND ICON_LIBS "-Wl,--as-needed")

# Link HDF5 Fortran libraries
if (CMAKE_MESSAGE_LOG_LEVEL STREQUAL "DEBUG")
  set(HDF5_FIND_DEBUG "TRUE")
endif()
set(HDF5_PREFER_PARALLEL "TRUE")
find_package(HDF5 REQUIRED COMPONENTS Fortran HL)
list(APPEND ICON_LIBS "${HDF5_Fortran_HL_LIBRARIES}")

# libXML2 - XML parsing library
find_package(LibXml2 REQUIRED)
list(APPEND ICON_LIBS "${LIBXML2_LIBRARIES}")

# libLZMA - XZ compression library 
find_package(LibLZMA REQUIRED)
list(APPEND ICON_LIBS "${LIBLZMA_LIBRARIES}")

# LAPACK
find_package(LAPACK REQUIRED)
list(APPEND ICON_LIBS "${LAPACK_LIBRARIES}")

# OASIS3-MCT
list(APPEND ICON_LIBS "${OASIS_LIBRARIES}")

# NetCDF
find_package(NetCDF REQUIRED)
list(APPEND ICON_LIBS "${NetCDF_LIBRARIES}")
string(PREPEND ICON_FCFLAGS "-I${NetCDF_F90_ROOT}/include ")

# Assemble linker options
list(JOIN ICON_LIBS " " ICON_LIBS)

# Enable/disable model-specific features
list(APPEND EXTRA_CONFIG_ARGS --enable-parallel-netcdf --disable-ocean --disable-jsbach --disable-coupling --enable-ecrad --disable-mpi-checks --disable-rte-rrtmgp)

# Coupling-specific options
if( ${eCLM} OR ${CLM3.5} OR ${ParFlow} )
  string(PREPEND ICON_FCFLAGS "-I${OASIS_ROOT}/include ")
  list(APPEND EXTRA_CONFIG_ARGS --enable-oascoupling)
endif()

ExternalProject_Add(ICON
    PREFIX            ICON
    SOURCE_DIR        ${ICON_SRC}
    BUILD_IN_SOURCE   FALSE
    CONFIGURE_COMMAND ${ICON_SRC}/configure
                      CC=${CMAKE_C_COMPILER}
                      FC=${CMAKE_Fortran_COMPILER}
                      CFLAGS=${ICON_CFLAGS}
                      FCFLAGS=${ICON_FCFLAGS}
                      ICON_ECRAD_FCFLAGS=${ICON_ECRAD_FCFLAGS}
                      LDFLAGS=${ICON_LDFLAGS}
                      LIBS=${ICON_LIBS}
                      MPI_LAUNCH=${MPIEXEC_EXECUTABLE}
                      --prefix=${CMAKE_INSTALL_PREFIX}
                      ${EXTRA_CONFIG_ARGS}
    BUILD_COMMAND     make -j8 install
    INSTALL_COMMAND   ""
    BUILD_ALWAYS      YES
    DEPENDS           ${MODEL_DEPENDENCIES}
)

get_model_version(${ICON_SRC} ICON_VERSION)
list(APPEND TSMP2_MODEL_VERSIONS "ICON: ${ICON_VERSION}")
