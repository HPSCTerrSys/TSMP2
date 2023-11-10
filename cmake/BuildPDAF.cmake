#TODO-PDAF

# Adds cmake option -DPDAF_TARGET="all"
set(PDAF_TARGET "all" CACHE STRING "PDAF component to build.")
set_property(CACHE PDAF_TARGET PROPERTY STRINGS all pdaf model framework)

set(PDAF_BLD_DIR ${CMAKE_CURRENT_BINARY_DIR}/PDAF/bld)
set(PDAF_MAKE_INC ${PDAF_BLD_DIR}/include)
file(WRITE  ${PDAF_MAKE_INC} "key1      = value1\n")
file(WRITE  ${PDAF_MAKE_INC} "key2      = value2\n")

ExternalProject_Add(PDAF
  PREFIX            PDAF
  SOURCE_DIR        ${PDAF_SRC}
  BUILD_IN_SOURCE   FALSE
  CONFIGURE_COMMAND ""
  BUILD_COMMAND     make -f ${PDAF_SRC}/Makefile ${PDAF_TARGET} -C ${PDAF_BLD_DIR}
  INSTALL_COMMAND   ""
  DEPENDS           ${PDAF_DEPENDENCIES}
)