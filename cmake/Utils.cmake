find_package(Git)
if(NOT Git_FOUND)
  message(WARNING "TSMP2: git executable not found. Model versions would not be detected.")
endif()

# Count how many component models shoul be build, and if >=2 compile with OASIS
function(check_build_oasis BUILD_OASIS)
   # Combine all options into a list
   list(APPEND COMPONENT_MODELS ICON COSMO eCLM CLM3.5 ParFlow)
   # Count enabled models
   set(MODELCOUNT 0)
   foreach(comp_model IN LISTS COMPONENT_MODELS)
      if (${comp_model})
         MATH(EXPR MODELCOUNT "${MODELCOUNT}+1")
      endif()
   endforeach()
   #
   if (${MODELCOUNT} GREATER_EQUAL 2)
      set(${BUILD_OASIS} TRUE PARENT_SCOPE)
   else()
      set(${BUILD_OASIS} FALSE PARENT_SCOPE)
   endif()
endfunction()

function(get_model_version MODEL_DIR MODEL_VERSION)
  if(Git_FOUND)
      EXECUTE_PROCESS(
          COMMAND ${GIT_EXECUTABLE} describe --tags --always
          WORKING_DIRECTORY ${MODEL_DIR}
          OUTPUT_VARIABLE GIT_REPO_VERSION
          RESULT_VARIABLE GIT_DESCRIBE_RESULT
          OUTPUT_STRIP_TRAILING_WHITESPACE
      )
      if (GIT_DESCRIBE_RESULT EQUAL 0)
        set(${MODEL_VERSION} ${GIT_REPO_VERSION} PARENT_SCOPE)
      else()
        message(WARNING "Failed to extract repo version from ${MODEL_DIR}. Error message: ${GIT_DESCRIBE_RESULT}")
        set(${MODEL_VERSION} "xxxxx" PARENT_SCOPE)
      endif()
  endif()
endfunction()

function(print_model_versions COMPONENT_MODELS MODEL_VERSIONS)
  string(JOIN "-" MODEL_COMBINATION ${COMPONENT_MODELS})
  string(REPEAT "═" 50 H_SEPARATOR)

  message(STATUS ${H_SEPARATOR})
  message(STATUS "Building »${MODEL_COMBINATION}« ${CMAKE_BUILD_TYPE} version")
  if(Git_FOUND)
    foreach(model IN LISTS MODEL_VERSIONS)
      message(STATUS "  ${model}")
    endforeach()
  endif()
  message(STATUS ${H_SEPARATOR})
endfunction()
