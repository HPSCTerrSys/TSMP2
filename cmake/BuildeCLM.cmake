#TODO: Setting both COUP_OAS_ICON and COUP_OAS_PFL should be possible
if(DEFINED ICON_SRC)
    list(APPEND COUP_OAS_FLAGS -DUSE_OASIS=True -DCOUP_OAS_ICON=True)
elseif(DEFINED PARFLOW_SRC)
    list(APPEND COUP_OAS_FLAGS -DUSE_OASIS=True -DCOUP_OAS_PFL=True)
else()
    list(APPEND COUP_OAS_FLAGS -DUSE_OASIS=False)
endif()

ExternalProject_Add(eCLM
    PREFIX            eCLM
    SOURCE_DIR        ${eCLM_SRC}
    SOURCE_SUBDIR     src
    CMAKE_ARGS        -DCMAKE_C_COMPILER=${CMAKE_C_COMPILER}
                      -DCMAKE_Fortran_COMPILER=${CMAKE_Fortran_COMPILER}
                      -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE}
                      -DCMAKE_PREFIX_PATH=${OASIS_ROOT}
                      -DCMAKE_INSTALL_PREFIX=${CMAKE_INSTALL_PREFIX}
                      ${COUP_OAS_FLAGS}
    BUILD_COMMAND     ""
)