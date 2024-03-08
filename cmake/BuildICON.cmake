# ICON 2.6.4
set(ICON_CFLAGS "-gdwarf-4 -qno-opt-dynamic-align -ftz -march=native")
set(ICON_FCFLAGS "-I${OASIS_ROOT}/include -gdwarf-4 -march=native -pc64 -fp-model source -traceback -qno-opt-dynamic-align -no-fma")
set(ICON_LDFLAGS "-Wl,--copy-dt-needed-entries,--as-needed ${OASIS_LIBRARIES}")
set(ICON_ECRAD_FCFLAGS "-D__ECRAD_LITTLE_ENDIAN")

if (CMAKE_BUILD_TYPE STREQUAL "DEBUG")
  string(PREPEND ICON_CFLAGS "-g ")
  string(PREPEND ICON_FCFLAGS "-g ")
elseif (CMAKE_BUILD_TYPE STREQUAL "RELEASE")
  string(PREPEND ICON_CFLAGS "-O3 ")
  string(PREPEND ICON_FCFLAGS "-O3 ")
else()
  # Assume CMAKE_BUILD_TYPE=RELEASE if CMAKE_BUILD_TYPE is unknown
  string(PREPEND ICON_CFLAGS "-O3 ")
  string(PREPEND ICON_FCFLAGS "-O3 ")
  message(WARNING "CMAKE_BUILD_TYPE='${CMAKE_BUILD_TYPE}' is not supported by ICON")
endif()

list(APPEND ICON_LIBS "-Wl,--as-needed")

find_package(HDF5 REQUIRED)
list(APPEND ICON_LIBS "${HDF5_LIBRARIES}")

find_package(LibXml2 REQUIRED)
list(APPEND ICON_LIBS "${LIBXML2_LIBRARIES}")

find_package(LibLZMA REQUIRED)
list(APPEND ICON_LIBS "${LIBLZMA_LIBRARIES}")

set(BLA_VENDOR Intel10_64lp)
find_package(BLAS REQUIRED)
list(APPEND ICON_LIBS "${BLAS_LIBRARIES}")

list(APPEND ICON_LIBS "${OASIS_LIBRARIES}")
find_package(NetCDF REQUIRED)
list(APPEND ICON_LIBS "${NetCDF_LIBRARIES}")

list(JOIN ICON_LIBS " " ICON_LIBS)

list(APPEND EXTRA_CONFIG_ARGS --disable-coupling --disable-ocean --disable-jsbach --enable-ecrad --enable-parallel-netcdf)
if(DEFINED eCLM_SRC OR DEFINED CLM35_SRC)
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
list(APPEND eTSMP_MODEL_VERSIONS "ICON: ${ICON_VERSION}")
