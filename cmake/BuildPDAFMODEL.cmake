# PDAFMODEL variables
# -----------------------

# PDAF-Model: Set subdirectories of source code
set(TSMPPDAFPFLDIR "parflow")
set(TSMPPDAFCLMDIR "clm3_5")

# PDAF-Model: Directory for copying static library `libmodel.a`
set(TSMPPDAFLIBDIR "${CMAKE_INSTALL_PREFIX}/lib")

# Include directories
# -------------------
# DA include dirs
list(APPEND PDAF_INCLUDES "-I${PDAF_SRC}/interface/model/common")
list(APPEND PDAF_INCLUDES "-I${PDAF_SRC}/interface/model/parflow")

# OASIS include dirs
list(APPEND PDAF_INCLUDES "-I${CMAKE_INSTALL_PREFIX}/OASIS3-MCT/lib/psmile.MPI1")
list(APPEND PDAF_INCLUDES "-I${CMAKE_INSTALL_PREFIX}/OASIS3-MCT/lib/scrip")
list(APPEND PDAF_INCLUDES "-I${CMAKE_INSTALL_PREFIX}/OASIS3-MCT/include")

# CLM include dirs
list(APPEND PDAF_INCLUDES "-I${CMAKE_BINARY_DIR}/CLM3_5/bld")

# ParFlow include dirs
# list(APPEND PDAF_INCLUDES "-I${CMAKE_INSTALL_PREFIX}/include/parflow")
list(APPEND PDAF_INCLUDES "-I${PARFLOW_SRC}/pfsimulator/parflow_lib")
list(APPEND PDAF_INCLUDES "-I${PARFLOW_SRC}/pfsimulator/amps/oas3")
list(APPEND PDAF_INCLUDES "-I${PARFLOW_SRC}/pfsimulator/amps/common")
list(APPEND PDAF_INCLUDES "-I${CMAKE_BINARY_DIR}/ParFlow/ParFlow-build/include")
list(APPEND PDAF_INCLUDES "-I${PARFLOW_SRC}/build/include")
list(APPEND PDAF_INCLUDES "-I/usr/include")
# list(APPEND PDAF_INCLUDES "-I${PARFLOW_SRC}/rmm/include/rmm")

# Join list of include dirs
list(JOIN PDAF_INCLUDES " " PDAF_INCLUDES)


# Libraries
# ---------
list(APPEND PDAF_LIBS "-L${MPI_Fortran_LIB_DIR} -lmpich")
list(APPEND PDAF_LIBS "${NetCDF_LIBRARIES}")

# OASIS libraries
list(APPEND PDAF_LIBS "-L${CMAKE_INSTALL_PREFIX}/OASIS3-MCT/lib -lpsmile.MPI1 -lmct -lmpeu -lscrip")

# CLM libraries
list(APPEND PDAF_LIBS "-L${CMAKE_INSTALL_PREFIX}/lib -lclm")

# ParFlow libraries
list(APPEND PDAF_LIBS "-L${CMAKE_INSTALL_PREFIX}/lib -lpfsimulator -lamps -lpfkinsol -lgfortran -lcjson")
# GPU
# list(APPEND PDAF_LIBS "-L${CMAKE_INSTALL_PREFIX}/rmm/lib -lstdc++ -lcudart -lrmm -lnvToolsExt")
list(APPEND PDAF_LIBS "-L${EBROOTHYPRE}/lib -lHYPRE")
list(APPEND PDAF_LIBS "-L${EBROOTSILO}/lib -lsilo")
list(APPEND PDAF_LIBS "-L/lib64 -lslurm")

# Join list of libraries
list(JOIN PDAF_LIBS " " PDAF_LIBS)


# Precompiler definitions
# -----------------------
list(APPEND PDAF_DEFS "-Duse_comm_da")
list(APPEND PDAF_DEFS "-DMAXPATCH_PFT=1")
list(APPEND PDAF_DEFS "-DCOUP_OAS_PFL")
list(APPEND PDAF_DEFS "-DOBS_ONLY_PARFLOW")

# Join list of precompiler definitions
list(JOIN PDAF_DEFS " " PDAF_DEFS)


# Set env vars required by PDAF Makefiles
# ---------------------------------------
# Additionally system environment variables are used by the Makefiles
# f.e. `EBROOTHYPRE`, etc, or `MKLROOT`
list(APPEND PDAFMODEL_ENV_VARS TSMPPDAFIMPORTFLAGS=${PDAF_INCLUDES})
list(APPEND PDAFMODEL_ENV_VARS TSMPPDAFCPPDEFS=${PDAF_DEFS})
list(APPEND PDAFMODEL_ENV_VARS TSMPPDAFLIBS=${PDAF_LIBS})
list(APPEND PDAFMODEL_ENV_VARS PDAF_ARCH=${PDAF_ARCH})
list(APPEND PDAFMODEL_ENV_VARS PDAF_DIR=${PDAF_DIR})
list(APPEND PDAFMODEL_ENV_VARS TSMPPDAFLIBDIR=${TSMPPDAFLIBDIR})
list(APPEND PDAFMODEL_ENV_VARS TSMPPDAFPFLDIR=${TSMPPDAFPFLDIR})
list(APPEND PDAFMODEL_ENV_VARS TSMPPDAFCLMDIR=${TSMPPDAFCLMDIR})

# PDAF-Model: Append variables for checking existing component models
if(DEFINED eCLM_SRC)
  list(APPEND PDAFMODEL_ENV_VARS eCLM_SRC="${eCLM_SRC}")
endif()
if(DEFINED CLM35_SRC)
  list(APPEND PDAFMODEL_ENV_VARS CLM35_SRC="${CLM35_SRC}")
endif()
if(DEFINED ICON_SRC)
  list(APPEND PDAFMODEL_ENV_VARS ICON_SRC="${ICON_SRC}")
endif()
if(DEFINED COSMO_SRC)
  list(APPEND PDAFMODEL_ENV_VARS COSMO_SRC="${COSMO_SRC}")
endif()
if(DEFINED PARFLOW_SRC)
  list(APPEND PDAFMODEL_ENV_VARS PARFLOW_SRC="${PARFLOW_SRC}")
endif()

ExternalProject_Add(PDAF-Model
  PREFIX            PDAF-Model
  SOURCE_DIR        ${PDAF_SRC}/interface/model
  BUILD_IN_SOURCE   TRUE
  CONFIGURE_COMMAND ""
  BUILD_COMMAND     make ${PDAFMODEL_ENV_VARS} clean all
  INSTALL_COMMAND   ""
  DEPENDS           ${PDAF_DEPENDENCIES} PDAF
)
