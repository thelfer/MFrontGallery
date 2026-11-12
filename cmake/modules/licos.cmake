if(LICOS_DIR)
  find_program(LICOS_CONFIG  licos-config REQUIRED
      HINTS "${LICOS_DIR}/bin" "${Licos_DIR}/bin")
else(LICOS_DIR)
  find_program(LICOS_CONFIG  licos-config REQUIRED)
endif(LICOS_DIR)      

execute_process(COMMAND ${LICOS_CONFIG} "--includes"
  OUTPUT_VARIABLE LICOS_MODEL_CPPFLAGS
  OUTPUT_STRIP_TRAILING_WHITESPACE)

execute_process(COMMAND ${LICOS_CONFIG} "--libdir"
  OUTPUT_VARIABLE LICOS_MODEL_LIBRARIES
  OUTPUT_STRIP_TRAILING_WHITESPACE)

function(check_licos_model_compatibility mat search_paths source)
  if(NOT file_OK)
    set(file_OK OFF PARENT_SCOPE)
    set(compatibility_failure "${compatibility_failure}" PARENT_SCOPE)
  endif(NOT file_OK)
endfunction(check_licos_model_compatibility)

function(getLicosModelName name)
  set(lib "${name}LicosModels" PARENT_SCOPE)
endfunction(getLicosModelName)

option(enable-licos-tests "enable tests based on the licos solver" OFF)
if(enable-licos-tests)
  message(STATUS "enabling Licos tests")
  find_program(licos_executable NAMES licos REQUIRED)
endif(enable-licos-tests)
