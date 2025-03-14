if(${ICON} OR ${ParFlow})
    list(APPEND COUP_OAS_FLAGS -DUSE_OASIS=True)
    if(${ParFlow})
        list(APPEND COUP_OAS_FLAGS  -DCOUP_OAS_PFL=True)
    endif()
    if(${ICON})
        list(APPEND COUP_OAS_FLAGS  -DCOUP_OAS_ICON=True)
    endif()
else()
    list(APPEND COUP_OAS_FLAGS -DUSE_OASIS=False)
endif()

if(${PDAF})
  list(APPEND PDAF_FLAGS  -DUSE_PDAF=True)
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
		              ${PDAF_FLAGS}
    BUILD_ALWAYS      YES
    BUILD_COMMAND     ""   # This needs to be empty to avoid building eCLM twice.
                           # This happens because INSTALL_COMMAND triggers rebuild
                           # which is abnormal. This is a problem in eCLM and should be fixed.
    DEPENDS           ${MODEL_DEPENDENCIES}
)

if(${PDAF})
    ExternalProject_Add_Step(eCLM pdaf-workaround
        COMMAND       mv ${CMAKE_INSTALL_PREFIX}/lib/libmct.a ${CMAKE_INSTALL_PREFIX}/lib/libmct2.a
        COMMENT       "Workaround for PDAF: Renaming libmct.a to libmct2.a ..."
        DEPENDEES     install
        ALWAYS        TRUE
        USES_TERMINAL TRUE
    )
endif()

get_model_version(${eCLM_SRC} eCLM_VERSION)
list(APPEND TSMP2_MODEL_VERSIONS "eCLM: ${eCLM_VERSION}")
