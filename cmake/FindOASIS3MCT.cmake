find_library(PSMILE_LIB NAMES psmile.MPI1 PATHS ${OASIS_ROOT} PATH_SUFFIXES lib)
find_library(MCT_LIB NAMES mct PATHS ${OASIS_ROOT} PATH_SUFFIXES lib)
find_library(MPEU_LIB NAMES mpeu PATHS ${OASIS_ROOT} PATH_SUFFIXES lib)
find_library(SCRIP_LIB NAMES scrip PATHS ${OASIS_ROOT} PATH_SUFFIXES lib)

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(OASIS3MCT DEFAULT_MSG
    PSMILE_LIB
    MCT_LIB
    MPEU_LIB
    SCRIP_LIB
)

if(OASIS3MCT_FOUND)
   set(OASIS_LIBRARIES ${PSMILE_LIB} ${MCT_LIB} ${MPEU_LIB} ${SCRIP_LIB})
endif()

unset(PSMILE_LIB)
unset(MCT_LIB)
unset(MPEU_LIB)
unset(SCRIP_LIB)