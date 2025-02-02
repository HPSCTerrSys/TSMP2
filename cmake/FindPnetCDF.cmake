# Finds the PnetCDF library. If found, the CMake target PnetCDF::PnetCDF
# will be created and the following variables will be defined:
#
#  - PnetCDF_FOUND
#  - PnetCDF_INCLUDEDIR
#  - PnetCDF_LIBRARIES
#  - PnetCDF_VERSION
#
# Basic usage:
#
#  find_package(PnetCDF)
#  if(PnetCDF_FOUND)
#     target_link_libraries(mylibrary PUBLIC PnetCDF::PnetCDF)
#  endif()
#

# Find PnetCDF using pkg-tools.
find_package(PkgConfig QUIET)
if(PkgConfig_FOUND)
    pkg_check_modules(PnetCDF QUIET pnetcdf IMPORTED_TARGET)
endif()

# If not found, manually search for Pnetcdf include and library files.
if (NOT PnetCDF_FOUND)
    find_path(PnetCDF_INCLUDEDIR NAMES pnetcdf.mod)
    find_library(PnetCDF_LIBRARIES NAMES pnetcdf)
endif()

find_package_handle_standard_args(PnetCDF
   REQUIRED_VARS PnetCDF_INCLUDEDIR PnetCDF_LIBRARIES
   VERSION_VAR PnetCDF_VERSION)

if (PnetCDF_FOUND)
   if(DEFINED PnetCDF_LIBDIR)
     set(PnetCDF_PDAF_LIBRARIES "-L${PnetCDF_LIBDIR} -lpnetcdf" CACHE STRING "PnetCDF linker options")
   else()
     set(PnetCDF_PDAF_LIBRARIES "-lpnetcdf" CACHE STRING "PnetCDF linker options")
   endif()
endif()
