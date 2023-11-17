# PDAFMODEL variables
# -----------------------

# PDAF-Model: Set subdirectories of source code
set(TSMPPDAFPFLDIR "parflow")
if(DEFINED CLM35_SRC)
set(TSMPPDAFCLMDIR "clm3_5")
endif()
if(DEFINED eCLM_SRC)
set(TSMPPDAFCLMDIR "eclm")
endif()

# PDAF-Model: Directory for copying static library `libmodel.a`
set(TSMPPDAFLIBDIR "${CMAKE_INSTALL_PREFIX}/lib")

# Include directories
# -------------------
# DA include dirs
list(APPEND PDAF_INCLUDES "-I${PDAF_SRC}/interface/model/common")
list(APPEND PDAF_INCLUDES "-I${PDAF_SRC}/interface/model/parflow")

# OASIS include dirs
if(DEFINED OASIS_SRC)
  list(APPEND PDAF_INCLUDES "-I${CMAKE_INSTALL_PREFIX}/OASIS3-MCT/lib/psmile.MPI1")
  list(APPEND PDAF_INCLUDES "-I${CMAKE_INSTALL_PREFIX}/OASIS3-MCT/lib/scrip")
  list(APPEND PDAF_INCLUDES "-I${CMAKE_INSTALL_PREFIX}/OASIS3-MCT/include")
endif()

# CLM include dirs
if(DEFINED CLM35_SRC)
  list(APPEND PDAF_INCLUDES "-I${CMAKE_BINARY_DIR}/CLM3_5/bld")
endif()
if(DEFINED eCLM_SRC)
  list(APPEND PDAF_INCLUDES "-I${CMAKE_BINARY_DIR}/eCLM/src/eCLM-build/clm5")
  list(APPEND PDAF_INCLUDES "-I${CMAKE_BINARY_DIR}/eCLM/src/eCLM-build/csm_share")
  list(APPEND PDAF_INCLUDES "-I${CMAKE_BINARY_DIR}/eCLM/src/eCLM-build/datm")
  list(APPEND PDAF_INCLUDES "-I${CMAKE_BINARY_DIR}/eCLM/src/eCLM-build/eclm")
  list(APPEND PDAF_INCLUDES "-I${CMAKE_BINARY_DIR}/eCLM/src/eCLM-build/mosart")
  list(APPEND PDAF_INCLUDES "-I${CMAKE_BINARY_DIR}/eCLM/src/eCLM-build/stub_comps")
  list(APPEND PDAF_INCLUDES "-I${CMAKE_BINARY_DIR}/eCLM/src/eCLM-build/externals/gptl/include")
  list(APPEND PDAF_INCLUDES "-I${CMAKE_BINARY_DIR}/eCLM/src/eCLM-build/externals/mct/include")
  list(APPEND PDAF_INCLUDES "-I${CMAKE_BINARY_DIR}/eCLM/src/eCLM-build/pio1")
endif()

# ParFlow include dirs
if(DEFINED PARFLOW_SRC)
  # list(APPEND PDAF_INCLUDES "-I${CMAKE_INSTALL_PREFIX}/include/parflow")
  list(APPEND PDAF_INCLUDES "-I${PARFLOW_SRC}/pfsimulator/parflow_lib")
  list(APPEND PDAF_INCLUDES "-I${PARFLOW_SRC}/pfsimulator/amps/oas3")
  list(APPEND PDAF_INCLUDES "-I${PARFLOW_SRC}/pfsimulator/amps/common")
  list(APPEND PDAF_INCLUDES "-I${CMAKE_BINARY_DIR}/ParFlow/ParFlow-build/include")
  list(APPEND PDAF_INCLUDES "-I${PARFLOW_SRC}/build/include")
  list(APPEND PDAF_INCLUDES "-I/usr/include")
  # list(APPEND PDAF_INCLUDES "-I${PARFLOW_SRC}/rmm/include/rmm")
endif()

# Join list of include dirs
list(JOIN PDAF_INCLUDES " " PDAF_INCLUDES)


# Libraries
# ---------
list(APPEND PDAF_LIBS "-L${MPI_Fortran_LIB_DIR} -lmpich")
list(APPEND PDAF_LIBS "${NetCDF_LIBRARIES}")

# OASIS libraries
if(DEFINED OASIS_SRC)
  list(APPEND PDAF_LIBS "-L${CMAKE_INSTALL_PREFIX}/OASIS3-MCT/lib -lpsmile.MPI1 -lmct -lmpeu -lscrip")
endif()

# CLM libraries
if(DEFINED CLM35_SRC)
  list(APPEND PDAF_LIBS "-L${CMAKE_INSTALL_PREFIX}/lib -lclm")
endif()
if(DEFINED eCLM_SRC)
  list(APPEND PDAF_LIBS "-L${CMAKE_INSTALL_PREFIX}/lib -leclm")
  list(APPEND PDAF_LIBS "-leclm")
  list(APPEND PDAF_LIBS "-lclm")
  list(APPEND PDAF_LIBS "-ldatm")
  list(APPEND PDAF_LIBS "-lglc")
  list(APPEND PDAF_LIBS "-lgptl")
  list(APPEND PDAF_LIBS "-lice")
  list(APPEND PDAF_LIBS "-lmosart")
  list(APPEND PDAF_LIBS "-locn")
  list(APPEND PDAF_LIBS "-lpio")
  list(APPEND PDAF_LIBS "-lwav")
  # list(APPEND PDAF_LIBS "-latm")
  # list(APPEND PDAF_LIBS "-lrof")
  list(APPEND PDAF_LIBS "-lesp")

  # BIG WORKAROUND for duplicate "-lmct" (OASIS / eCLM both generate this library)
  # We rename the eCLM-library
  execute_process(
    COMMAND mv "${CMAKE_INSTALL_PREFIX}/lib/libmct.a" "${CMAKE_INSTALL_PREFIX}/lib/libmct_eclm.a"
    RESULT_VARIABLE result
  )

  if(result EQUAL 0)
    message(STATUS "File libmct.a renamed successfully to libmct_eclm.a")
  else()
    message(FATAL_ERROR "Failed to rename file libmct.a")
  endif()

  list(APPEND PDAF_LIBS "-lmct_eclm")
  list(APPEND PDAF_LIBS "-lmpeu")

  list(APPEND PDAF_LIBS "-lpnetcdf")
  list(APPEND PDAF_LIBS "-qmkl")
  # list(APPEND PDAF_LIBS "-lnetcdff")
  # list(APPEND PDAF_LIBS "-lnetcdf")

  # Important for linking that it is at the end
  list(APPEND PDAF_LIBS "-lcsm_share")
endif()

# ParFlow libraries
if(DEFINED PARFLOW_SRC)
  list(APPEND PDAF_LIBS "-L${CMAKE_INSTALL_PREFIX}/lib -lpfsimulator -lamps -lpfkinsol -lgfortran -lcjson")
  # GPU
  # list(APPEND PDAF_LIBS "-L${CMAKE_INSTALL_PREFIX}/rmm/lib -lstdc++ -lcudart -lrmm -lnvToolsExt")
  list(APPEND PDAF_LIBS "-L${EBROOTHYPRE}/lib -lHYPRE")
  list(APPEND PDAF_LIBS "-L${EBROOTSILO}/lib -lsilo")
  list(APPEND PDAF_LIBS "-L/lib64 -lslurm")
endif()

# Join list of libraries
list(JOIN PDAF_LIBS " " PDAF_LIBS)


# Precompiler definitions
# -----------------------
if(DEFINED OASIS_SRC)
  list(APPEND PDAF_DEFS "-Duse_comm_da")
  list(APPEND PDAF_DEFS "-DMAXPATCH_PFT=1")
  if(DEFINED PARFLOW_SRC)
    list(APPEND PDAF_DEFS "-DCOUP_OAS_PFL")
    list(APPEND PDAF_DEFS "-DOBS_ONLY_PARFLOW")
  endif()
  if(DEFINED eCLM_SRC)
    list(APPEND PDAF_DEFS "-DCLMFIVE")
  endif()
else()
  if(DEFINED CLM35_SRC)
    list(APPEND PDAF_DEFS "-DCLMSA")
  endif()
  if(DEFINED eCLM_SRC)
    list(APPEND PDAF_DEFS "-DCLMSA")
    list(APPEND PDAF_DEFS "-DCLMFIVE")
  endif()
endif()

# Join list of precompiler definitions
list(JOIN PDAF_DEFS " " PDAF_DEFS)


# Set env vars required by PDAF Makefiles
# ---------------------------------------
# Additionally system environment variables are used by the Makefiles
# f.e. `EBROOTHYPRE`, etc, or `MKLROOT`
list(APPEND PDAFMODEL_ENV_VARS PDAF_ARCH=${PDAF_ARCH})
list(APPEND PDAFMODEL_ENV_VARS PDAF_DIR=${PDAF_DIR})
list(APPEND PDAFMODEL_ENV_VARS TSMPPDAFIMPORTFLAGS=${PDAF_INCLUDES})
list(APPEND PDAFMODEL_ENV_VARS TSMPPDAFCPPDEFS=${PDAF_DEFS})
list(APPEND PDAFMODEL_ENV_VARS TSMPPDAFLIBS=${PDAF_LIBS})
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
