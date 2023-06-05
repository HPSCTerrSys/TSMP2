# ICON 2.6.4

set(ICON_CFLAGS "-gdwarf-4 -O3 -qno-opt-dynamic-align -ftz -march=native")
set(ICON_FCFLAGS "-I${OASIS_ROOT}/include -gdwarf-4 -O3 -march=native -pc64 -fp-model source -traceback -qno-opt-dynamic-align -no-fma")
set(ICON_LDFLAGS "-Wl,--copy-dt-needed-entries,--as-needed")
set(ICON_ECRAD_FCFLAGS "-D__ECRAD_LITTLE_ENDIAN")

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

list(APPEND EXTRA_CONFIG_ARGS --disable-coupling --disable-ocean --disable-jsbach --enable-oascoupling --enable-ecrad --enable-parallel-netcdf)


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
)
