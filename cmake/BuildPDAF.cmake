# Adds cmake option -DPDAF_TARGET="all"
set(PDAF_TARGET "pdaf" CACHE STRING "PDAF component to build.")
set_property(CACHE PDAF_TARGET PROPERTY STRINGS pdaf model framework)

#TODO: Populate include file (see BuildOASIS3MCT.cmake)
set(PDAF_MAKE_INC ${PDAF_SRC}/make.arch/include.h)
file(WRITE  ${PDAF_MAKE_INC} "key1      = value1\n")
file(APPEND ${PDAF_MAKE_INC} "key2      = value2\n")
file(APPEND ${PDAF_MAKE_INC} "key3      = value3\n")

# Set additional build options
list(APPEND PDAF_INCLUDES "-I${PDAF_SRC}/interface/model/common")
list(APPEND PDAF_INCLUDES "-I${PDAF_SRC}/interface/model/parflow")
list(APPEND PDAF_LIBS "-L${MPI_Fortran_LIB_DIR} -lmpich")
list(APPEND PDAF_LIBS "${NetCDF_LIBRARIES}")
list(APPEND PDAF_DEFS "-Duse_comm_da")
list(APPEND PDAF_DEFS "-DMAXPATCH_PFT=1")
list(APPEND PDAF_DEFS "-DCOUP_OAS_PFL")
list(APPEND PDAF_DEFS "-DOBS_ONLY_PARFLOW")

# Set env vars required by PDAF Makefiles
list(JOIN PDAF_INCLUDES " " PDAF_INCLUDES)
list(JOIN PDAF_LIBS " " PDAF_LIBS)
list(JOIN PDAF_DEFS " " PDAF_DEFS)
list(APPEND PDAF_ENV_VARS TSMPPDAFIMPORTFLAGS="${PDAF_INCLUDES}")
list(APPEND PDAF_ENV_VARS TSMPPDAFCPPDEFS="${PDAF_DEFS}")
list(APPEND PDAF_ENV_VARS TSMPPDAFLIBS="${PDAF_LIBS}")

# TODO: Remove debug statements when everything works
message(STATUS " *** PDAF_INCLUDES=${PDAF_INCLUDES}")
message(STATUS " *** PDAF_DEFS=${PDAF_DEFS}")
message(STATUS " *** PDAF_LIBS=${PDAF_LIBS}")
message(STATUS " *** PDAF_ENV_VARS:")
list(JOIN PDAF_ENV_VARS " " PDAF_ENV_VARS_STR)
message(WARNING "${PDAF_ENV_VARS_STR}")
#message(FATAL_ERROR "${PDAF_ENV_VARS}")  # uncomment to force stop CMake @ Configure step

# make pdaf
ExternalProject_Add(PDAF
  PREFIX            PDAF
  SOURCE_DIR        ${PDAF_SRC}/src
  BUILD_IN_SOURCE   TRUE
  CONFIGURE_COMMAND ""
  BUILD_COMMAND     make ${PDAF_ENV_VARS} clean pdaf-var
  INSTALL_COMMAND   ""
  DEPENDS           ${PDAF_DEPENDENCIES}
)

# make pdaf model
if (${PDAF_TARGET} STREQUAL "model" OR ${PDAF_TARGET} STREQUAL "framework")
  ExternalProject_Add(PDAF-Model
    PREFIX            PDAF-Model
    SOURCE_DIR        ${PDAF_SRC}/interface/model
    BUILD_IN_SOURCE   TRUE
    CONFIGURE_COMMAND ""
    BUILD_COMMAND     make ${PDAF_ENV_VARS} clean all
    INSTALL_COMMAND   ""
    DEPENDS           ${PDAF_DEPENDENCIES} PDAF             #TODO: Check if PDAF-Model requires PDAF
  )
endif()

# make pdaf framework
if (${PDAF_TARGET} STREQUAL "framework")
  ExternalProject_Add(PDAF-Framework
    PREFIX            PDAF-Model
    SOURCE_DIR        ${PDAF_SRC}/interface/framework
    BUILD_IN_SOURCE   TRUE
    CONFIGURE_COMMAND ""
    BUILD_COMMAND     make ${PDAF_ENV_VARS} clean all
    INSTALL_COMMAND   ""
    DEPENDS           ${PDAF_DEPENDENCIES} PDAF PDAF-Model  #TODO: Check if PDAF-Framework requires both PDAF and PDAF-Model
  )
endif()