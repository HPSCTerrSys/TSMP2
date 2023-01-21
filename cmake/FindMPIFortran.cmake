# Wrapper to CMake's internal [FindMPI.cmake][1] module
#
# FindMPI.cmake is supposed to automatically set MPI_Fortran_INCLUDE_DIRS, but for some reason
# it doesn't despite knowing where the MPI compilers are. This module serves as a workaround
# for this issue.
#
# [1]: https://gitlab.kitware.com/cmake/cmake/blob/v3.21.1/Modules/FindMPI.cmake)

find_package(MPI REQUIRED)
find_package(PkgConfig QUIET)
include(FindPackageHandleStandardArgs)

if (NOT MPI_Fortran_INCLUDE_DIRS)
  pkg_check_modules(MPICH_Fortran REQUIRED mpich)
  if (MPICH_Fortran_FOUND)
    pkg_get_variable(MPI_Fortran_INCLUDE_DIRS mpich includedir)
    pkg_get_variable(MPI_Fortran_LIB_DIR mpich libdir)
  endif()
endif()

find_package_handle_standard_args(MPIFortran
   REQUIRED_VARS MPI_Fortran_FOUND
                 MPI_Fortran_COMPILER 
                 MPI_Fortran_INCLUDE_DIRS
                 MPI_Fortran_LIB_DIR
                 MPIEXEC_EXECUTABLE
                 MPIEXEC_NUMPROC_FLAG
   VERSION_VAR MPI_Fortran_VERSION)