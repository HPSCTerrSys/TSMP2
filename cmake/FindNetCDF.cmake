find_package(PkgConfig QUIET)
include(FindPackageHandleStandardArgs)

find_package(NetCDF_C QUIET NAMES netCDF)
if(NetCDF_C_FOUND)
   set(NetCDF_C_LIB_DIR "${netCDF_LIB_DIR}")
endif()

pkg_check_modules(NetCDF_F90 REQUIRED netcdf-fortran)
if (NetCDF_F90_FOUND)
   pkg_get_variable(NetCDF_F90_LIB_DIR netcdf-fortran libdir)
   pkg_get_variable(NetCDF_F90_ROOT netcdf-fortran prefix)
endif()

find_package_handle_standard_args(NetCDF
   REQUIRED_VARS NetCDF_C_LIB_DIR NetCDF_F90_LIB_DIR
   VERSION_VAR NetCDF_F90_VERSION)

if(NetCDF_FOUND)
   set(NetCDF_LIBRARIES "-L${NetCDF_C_LIB_DIR} -L${NetCDF_F90_LIB_DIR} -lnetcdff -lnetcdf" CACHE STRING "NetCDF linker options")
   set(NetCDF_ROOT ${NetCDF_F90_ROOT} CACHE PATH "Full path to the root directory containing NetCDF include files and libraries.")
endif()