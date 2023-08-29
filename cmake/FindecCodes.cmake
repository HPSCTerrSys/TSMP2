find_path(ecCodes_LIB_DIR NAMES libeccodes.so PATH_SUFFIXES lib lib64)
find_library(ecCodes_LIB NAMES eccodes)
find_library(ecCodes_F90_LIB NAMES eccodes_f90)

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(ecCodes DEFAULT_MSG
  ecCodes_LIB_DIR
  ecCodes_LIB
  ecCodes_F90_LIB
)
if(ecCodes_FOUND)
   get_filename_component(ecCodes_ROOT ${ecCodes_LIB_DIR} DIRECTORY)
   set(ecCodes_LIBRARIES "-L${ecCodes_LIB_DIR} -leccodes_f90 -leccodes" CACHE STRING "ecCodes linker options")
endif()