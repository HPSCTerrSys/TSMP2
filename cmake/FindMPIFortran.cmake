# Wrapper to CMake's internal [FindMPI.cmake][1] module
#
# FindMPI.cmake is supposed to automatically set MPI_Fortran_INCLUDE_DIRS, but for some reason
# it doesn't despite knowing where the MPI compilers are. This module serves as a workaround
# for this issue.
#  
# Updates
# -------
# 2025-02-25: Built-in FindMPI still unreliable for various MPI Fortran implementations.
#
# [1]: https://gitlab.kitware.com/cmake/cmake/-/blob/master/Modules/FindMPI.cmake
#

find_package(MPI REQUIRED)
find_package(PkgConfig QUIET)
include(FindPackageHandleStandardArgs)

# Introspect MPI library via MPI_HOME setting
set(MPI_HOME $ENV{MPI_HOME} CACHE STRING "Path to MPI root folder" FORCE)
if(NOT MPI_HOME)
  message(FATAL_ERROR "Cannot find MPI library. MPI_HOME must be set to the path of the MPI root directory.")
else()
  message(DEBUG "MPI_HOME=${MPI_HOME}")
endif() 

# Deduce MPI Fortran include and library paths by
# checking existence of a unique executable associated
# with an MPI library. Crude approach but it works.
macro(find_mpi_lib mpi_lib some_mpi_exe pkg_id)
  if (NOT MPI_Fortran_INCLUDE_DIRS OR NOT MPI_Fortran_LIB_DIR)
    find_file(SOME_MPI_EXE ${some_mpi_exe} PATHS ${MPI_HOME}/bin)
    if (SOME_MPI_EXE)
      pkg_check_modules(${mpi_lib}_Fortran ${pkg_id})
      if (${mpi_lib}_Fortran_FOUND)
        pkg_get_variable(MPI_Fortran_INCLUDE_DIRS ${pkg_id} includedir)
        pkg_get_variable(MPI_Fortran_LIB_DIR ${pkg_id} libdir)
      else()
        # Rough guess - may not work
        find_path(MPI_Fortran_INCLUDE_DIRS NAMES mpi.h PATHS ${MPI_HOME}/include NO_DEFAULT_PATH)
        find_path(MPI_Fortran_LIB_DIR NAMES libmpifort.a libmpifort.so PATHS ${MPI_HOME}/lib NO_DEFAULT_PATH)
      endif()
    endif()

    # Verify if search is successful
    if (MPI_Fortran_INCLUDE_DIRS AND MPI_Fortran_LIB_DIR)
      message(STATUS "${mpi_lib} found.")
    else()
      # Run `cmake ... --log-level=DEBUG` to display debug logs.
      message(DEBUG "${mpi_lib} not found.")
      message(DEBUG "MPI_Fortran_INCLUDE_DIRS=${MPI_Fortran_INCLUDE_DIRS}")
      message(DEBUG "MPI_Fortran_LIB_DIR=${MPI_Fortran_LIB_DIR}")
    endif()
  endif()
endmacro()

# Try searching for these MPI lbraries
find_mpi_lib(OpenMPI ompi_info ompi-fort)
find_mpi_lib(PSMPI mpichversion mpich)
find_mpi_lib(IntelMPI impi_info impi)

# Finalize
find_package_handle_standard_args(MPIFortran
   REQUIRED_VARS MPI_Fortran_FOUND
                 MPI_Fortran_COMPILER 
                 MPI_Fortran_INCLUDE_DIRS
                 MPI_Fortran_LIB_DIR
                 MPIEXEC_EXECUTABLE
                 MPIEXEC_NUMPROC_FLAG
   VERSION_VAR MPI_Fortran_VERSION)
