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
  # TODO: MPICH is specific to ParaStationMPI; another approach is necessary for IntelMPI
  pkg_check_modules(MPICH_Fortran REQUIRED mpich)
  if (MPICH_Fortran_FOUND)
    pkg_get_variable(MPI_Fortran_INCLUDE_DIRS mpich includedir)
    pkg_get_variable(MPI_Fortran_LIB_DIR mpich libdir)
  endif()
endif()

if (NOT MPI_Fortran_MODULE_DIR)
  find_path(MPI_Fortran_MODULE_DIR NAMES "mpi.mod" "mpi_f08.mod" HINTS MPI_Fortran_INCLUDE_DIRS)
endif()

find_package_handle_standard_args(MPIFortran
   REQUIRED_VARS MPI_Fortran_FOUND
                 MPI_Fortran_COMPILER 
                 MPI_Fortran_MODULE_DIR
                 MPI_Fortran_LIB_DIR
                 MPIEXEC_EXECUTABLE
                 MPIEXEC_NUMPROC_FLAG
   VERSION_VAR MPI_Fortran_VERSION)