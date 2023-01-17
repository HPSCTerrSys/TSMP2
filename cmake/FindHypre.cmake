find_path(HYPRE_LIB_DIR NAMES libHYPRE.a PATH_SUFFIXES lib lib64)

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(Hypre DEFAULT_MSG
  HYPRE_LIB_DIR
)

if(Hypre_FOUND)
   get_filename_component(HYPRE_ROOT ${HYPRE_LIB_DIR} DIRECTORY)
endif()