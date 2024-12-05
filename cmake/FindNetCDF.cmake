find_package(PkgConfig QUIET)
include(FindPackageHandleStandardArgs)

# ************************
# 1. Find NetCDF C library
# ************************

# Attempt 1: Prioritize finding a parallel-aware NetCDF. 
find_path(NetCDF_C_INCLUDEDIR NAMES netcdf_par.h PATH_SUFFIXES include)

if(NetCDF_C_INCLUDEDIR)
   # Attempt 1 succeeded!
   get_filename_component(NetCDF_C_ROOT ${NetCDF_C_INCLUDEDIR} DIRECTORY)
   set(NetCDF_C_LIB_DIR "${NetCDF_C_ROOT}/lib")
   set(NetCDF_HAS_PARALLEL TRUE)

   # Run `cmake ... --log-level=DEBUG` to see these debugging information.
   message(DEBUG "FindNETCDF_1: NetCDF_C_ROOT=${NetCDF_C_ROOT}")
   message(DEBUG "FindNETCDF_1: NetCDF_C_LIB_DIR=${NetCDF_C_LIB_DIR}")
   message(DEBUG "FindNETCDF_1: NetCDF_C_INCLUDEDIR=${NetCDF_C_INCLUDEDIR}")
else()
   # Attempt 2: Use find_package() to find NetCDF. The complicated logical
   #            structure below reflects the voodoo behavior of
   #            find_package() + buggy NetCDF CMake config file + platform-specific filesystem layout
   find_package(NetCDF_C NAMES netCDF)
   if(NetCDF_C_FOUND)
      set(NetCDF_C_ROOT ${netCDF_INSTALL_PREFIX})
      set(NetCDF_C_LIB_DIR ${netCDF_LIB_DIR})
      message(DEBUG "FindNETCDF_2: NetCDF_C_ROOT=${NetCDF_C_ROOT}")
      message(DEBUG "FindNETCDF_2: NetCDF_C_LIB_DIR=${NetCDF_C_LIB_DIR}")

      # Don't trust what netCDF_HAS_PARALLEL reports. The existence of netcdf_par.h header
      # is the surest way to know that netCDF was built with parallel support.
      find_path(NetCDF_C_INCLUDEDIR NAMES netcdf_par.h PATH_SUFFIXES ${NetCDF_C_ROOT}/include)

      if(NetCDF_C_INCLUDEDIR)
         # Result 2.1: find_package() gets lucky in finding parallel-aware NetCDF
         set(NetCDF_HAS_PARALLEL TRUE)
         message(DEBUG "FindNETCDF_21: NetCDF_C_INCLUDEDIR=${NetCDF_C_INCLUDEDIR}")
      else()
         # Result 2.2: find_package() only finds serial-aware NetCDF
         set(NetCDF_HAS_PARALLEL FALSE)
         set(NetCDF_C_INCLUDEDIR ${NetCDF_C_ROOT}/include)
         message(DEBUG "FindNETCDF_22: NetCDF_C_INCLUDEDIR=${NetCDF_C_INCLUDEDIR}")

         # TODO: It's possible to keep searching for a parallel-aware NetCDF, but
         #       I'm not yet aware of any method that isn't too platform-specific.
      endif()

      # ---------------------------------------------------------------------------
      # 31-Oct-2024 kvrigor: The snippet below works for Ubuntu. The package
      # `libnetcdf-mpi-dev` is a parallel-aware NetCDF library, but it takes
      # some trickery to extract the correct prefix path, which doesn't really
      # work 100% of the time (e.g. see [1]). Baking such fragile system-specific
      # manouevre here doesn't seem to be worth it; anyway I'm leaving this piece
      # of code here in case somebody would like to investigate this further.
      #
      # [1]: https://github.com/Unidata/netcdf-c/issues/2069
      # ---------------------------------------------------------------------------
      #
      # pkg_check_modules(NetCDF_C_MPI netcdf-mpi)
      # if (NetCDF_C_MPI_FOUND)
      #    pkg_get_variable(NetCDF_C_ROOT netcdf-mpi prefix)
      #    set(NetCDF_C_LIB_DIR "${NetCDF_C_ROOT}/lib")
      #    set(NetCDF_C_INCLUDEDIR "${NetCDF_C_ROOT}/lib")
      #    set(NetCDF_HAS_PARALLEL "ON")
      #    message(DEBUG "FindNETCDF_MPI: NetCDF_C_ROOT=${NetCDF_C_ROOT}")
      #    message(DEBUG "FindNETCDF_MPI: NetCDF_C_LIB_DIR=${NetCDF_C_LIB_DIR}")
      #    message(DEBUG "FindNETCDF_MPI: NetCDF_C_INCLUDEDIR=${NetCDF_C_ROOT}")
      # endif()
      #
      # --------------------------------------------------------------------
   endif()
endif()

# ************************
# 2. Find NetCDF Fortran
# ************************
pkg_check_modules(NetCDF_F90 REQUIRED netcdf-fortran)
if (NetCDF_F90_FOUND)
   pkg_get_variable(NetCDF_F90_ROOT netcdf-fortran prefix)
   pkg_get_variable(NetCDF_F90_LIB_DIR netcdf-fortran libdir)
   pkg_get_variable(NetCDF_F90_INCLUDEDIR netcdf-fortran fmoddir)
endif()


# *************************************
# 3. Set paths to NetCDF C and Fortran
# *************************************
find_package_handle_standard_args(NetCDF
   REQUIRED_VARS NetCDF_C_ROOT NetCDF_F90_ROOT NetCDF_C_LIB_DIR NetCDF_F90_LIB_DIR NetCDF_F90_INCLUDEDIR
   VERSION_VAR NetCDF_F90_VERSION)

if(NetCDF_FOUND)
   set(NetCDF_LIBRARIES "-L${NetCDF_C_LIB_DIR} -L${NetCDF_F90_LIB_DIR} -lnetcdff -lnetcdf" CACHE STRING "NetCDF linker options")
   set(NetCDF_F90_ROOT ${NetCDF_F90_ROOT} CACHE PATH "Path to NetCDF-Fortran directory which contains its include header files and libraries.")
   set(NetCDF_C_ROOT   ${NetCDF_C_ROOT} CACHE PATH "Path to NetCDF-C directory which contains its include header files and libraries.")
   if (${NetCDF_HAS_PARALLEL})
      message(STATUS "TSMP2 found NetCDF C built with parallel I/O support.")
   else()
      message(WARNING "TSMP2 is using NetCDF C without parallel I/O support.")
   endif()
endif()
