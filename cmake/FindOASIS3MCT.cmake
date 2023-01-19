find_library(PSMILE_LIB NAMES psmile.MPI1 PATH_SUFFIXES lib)
find_library(MCT_LIB NAMES mct PATH_SUFFIXES lib)
find_library(MPEU_LIB NAMES mpeu PATH_SUFFIXES lib)
find_library(SCRIP_LIB NAMES scrip PATH_SUFFIXES lib)
cmake_path(GET PSMILE_LIB PARENT_PATH OASIS_LIB_DIR)

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(OASIS3MCT DEFAULT_MSG
    PSMILE_LIB
    MCT_LIB
    MPEU_LIB
    SCRIP_LIB
)

if(OASIS3MCT_FOUND)
   cmake_path(GET PSMILE_LIB PARENT_PATH OASIS_LIB_DIR)
   cmake_path(GET OASIS_LIB_DIR PARENT_PATH OASIS_ROOT)
   set(OASIS_LIBRARIES "-L${OASIS_ROOT}/lib -lpsmile.MPI1 -lmct -lmpeu -lscrip")
   set(OASIS_INCLUDE_DIR "${OASIS_ROOT}/include")
endif()

unset(PSMILE_LIB)
unset(MCT_LIB)
unset(MPEU_LIB)
unset(SCRIP_LIB)