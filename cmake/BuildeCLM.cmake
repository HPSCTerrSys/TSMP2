ExternalProject_Add(eCLM
    PREFIX            eCLM
    SOURCE_DIR        ${eCLM_SRC}
    SOURCE_SUBDIR     src
    CMAKE_ARGS        -DCMAKE_C_COMPILER=${CMAKE_C_COMPILER}
                      -DCMAKE_Fortran_COMPILER=${CMAKE_Fortran_COMPILER}
                      -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE}
                      -DCMAKE_PREFIX_PATH=${OASIS_ROOT}
                      -DCMAKE_INSTALL_PREFIX=${CMAKE_INSTALL_PREFIX}
                      -DUSE_OASIS=True
    BUILD_COMMAND     ""
)