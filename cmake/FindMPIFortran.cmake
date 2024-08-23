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

if (MPI_Fortran_MODULE_DIR)
  message(STATUS "MPI_Fortran_MODULE_DIR=${MPI_Fortran_MODULE_DIR}")
endif()

if (MPI_mpi_LIBRARY)
  message(STATUS "MPI_mpi_LIBRARY=${MPI_mpi_LIBRARY}")
  get_filename_component(MPI_Fortran_LIB_DIR ${MPI_mpi_LIBRARY} DIRECTORY)
  message(STATUS "MPI_Fortran_LIB_DIR=${MPI_Fortran_LIB_DIR}")
endif()

find_package_handle_standard_args(MPIFortran
   REQUIRED_VARS MPI_Fortran_FOUND
                 MPI_Fortran_COMPILER 
                 MPI_Fortran_MODULE_DIR
                 MPI_Fortran_LIB_DIR
                 MPIEXEC_EXECUTABLE
                 MPIEXEC_NUMPROC_FLAG
   VERSION_VAR MPI_Fortran_VERSION)