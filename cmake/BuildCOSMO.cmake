find_package(ecCodes REQUIRED)
find_package(NetCDF REQUIRED)
find_package(OpenMP REQUIRED)

set(COSMO_BLD_DIR ${CMAKE_BINARY_DIR}/COSMO5_1/bld)
set(COSMO_Fopts ${COSMO_BLD_DIR}/Fopts)
file(WRITE  ${COSMO_Fopts} "STDROOT      = ${COSMO_SRC}\n")
file(APPEND ${COSMO_Fopts} "OBJDIR       = ${COSMO_BLD_DIR}\n")
file(APPEND ${COSMO_Fopts} "F90          = ${CMAKE_Fortran_COMPILER}\n")
file(APPEND ${COSMO_Fopts} "INC_DIRS     = -I${NetCDF_F90_ROOT}/include -I${ecCodes_ROOT}/include -I${OASIS_ROOT}/include\n")
file(APPEND ${COSMO_Fopts} "COMPILE_DEFS = -DGRIBAPI -DNETCDF -D__COSMO__ -DCOUP_OAS_COS -DCPL_SCHEME_F -DHYMACS -DCPL_SCHEME_F\n")
file(APPEND ${COSMO_Fopts} "COMFLG1      = -c -O2 -fpp -fp-model source -qopenmp $(INC_DIRS) $(COMPILE_DEFS)\n")
file(APPEND ${COSMO_Fopts} "COMFLG2      = $(COMFLG1)\n")
file(APPEND ${COSMO_Fopts} "COMFLG3      = $(COMFLG1)\n")
file(APPEND ${COSMO_Fopts} "COMFLG4      = $(COMFLG1)\n")
file(APPEND ${COSMO_Fopts} "COMFLG       = $(COMFLG1)\n")
file(APPEND ${COSMO_Fopts} "COMFLG5      = $(COMFLG1)\n")
file(APPEND ${COSMO_Fopts} "LDPAR        = ${CMAKE_Fortran_COMPILER}\n")
file(APPEND ${COSMO_Fopts} "LDFLG        = ${OpenMP_Fortran_FLAGS}\n")
file(APPEND ${COSMO_Fopts} "PROGRAM      = lmparbin\n")
file(APPEND ${COSMO_Fopts} "LIBPATH      = ${ecCodes_LIBRARIES} ${NetCDF_LIBRARIES} ${OASIS_LIBRARIES}\n")

ExternalProject_Add(COSMO5_1
  PREFIX            COSMO5_1
  SOURCE_DIR        ${COSMO_SRC}
  CONFIGURE_COMMAND ""
  BUILD_COMMAND     FOPTS=${COSMO_Fopts} make -f ${COSMO_SRC}/Makefile -C ${COSMO_BLD_DIR}
  BUILD_ALWAYS      YES
  INSTALL_COMMAND   ""
  BUILD_BYPRODUCTS  ${COSMO_BLD_DIR}/lmparbin_pur
  DEPENDS           ${MODEL_DEPENDENCIES}
)

install (FILES ${COSMO_BLD_DIR}/lmparbin_pur
         TYPE BIN
         PERMISSIONS OWNER_EXECUTE OWNER_WRITE OWNER_READ
                     GROUP_EXECUTE GROUP_READ)

get_model_version(${COSMO_SRC} COSMO_VERSION)
list(APPEND TSMP2_MODEL_VERSIONS "COSMO5.1: ${COSMO_VERSION}")
