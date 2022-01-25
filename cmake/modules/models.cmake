macro(add_mfront_model_sources lib interface search_paths file)
  if(EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/${file}.mfront.in")
    set(mfront_file   "${CMAKE_CURRENT_BINARY_DIR}/${file}.mfront")
    configure_file(
      "${CMAKE_CURRENT_SOURCE_DIR}/${file}.mfront.in"
      "${CMAKE_CURRENT_BINARY_DIR}/${file}.mfront"
      @ONLY)
  else(EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/${file}.mfront.in")
    set(mfront_file   "${CMAKE_CURRENT_SOURCE_DIR}/${file}.mfront")
  endif(EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/${file}.mfront.in")
  set(mfront_output "${CMAKE_CURRENT_BINARY_DIR}/src/${file}-${interface}.cxx")
  set(mfront_args)
  list(APPEND mfront_args ${search_paths})
  if(mfm_global_dsl_options)
    list(APPEND mfront_args ${mfm_global_dsl_options})
  endif(mfm_global_dsl_options)
  list(APPEND mfront_args "--interface=${interface}")
  list(APPEND mfront_args "${mfront_file}")
  add_custom_command(
    OUTPUT  "${mfront_output}"
    COMMAND "${MFRONT}"
    ARGS    ${mfront_args}
    DEPENDS "${mfront_file}"
    COMMENT "mfront source ${mfront_file}")
  set(${lib}_SOURCES ${mfront_output} ${${lib}_SOURCES})
  set_source_files_properties(${mfront_output}
    PROPERTIES COMPILE_FLAGS
    ${${interface}_SPECIFIC_DEFINITIONS})
endmacro(add_mfront_model_sources)

function(mfront_models_library mat)
  parse_mfront_library_sources(${ARGN})
  list(APPEND mfront_search_paths 
      "--search-path=${CMAKE_SOURCE_DIR}/materials/${mat}/properties")
  if(${ARGC} LESS 1)
    message(FATAL_ERROR "mfront_models_library : no source specified")
  endif(${ARGC} LESS 1)
  foreach(interface ${mfront-models-interfaces})
    if(${interface} STREQUAL "licos")
      set(lib "${mat}MaterialModels")
    else(${interface} STREQUAL "licos")
      set(lib "${mat}MaterialModels-${interface}")
    endif(${interface} STREQUAL "licos")
    foreach(source ${mfront_sources})
      add_mfront_model_sources(${lib} ${interface} "${mfront_search_paths}" ${source})
    endforeach(source)
    add_library(${lib} SHARED ${${lib}_SOURCES})
    if(WIN32)
      if(${CMAKE_CXX_COMPILER_ID} STREQUAL "GNU")
	set_target_properties(${lib}
	  PROPERTIES LINK_FLAGS "-Wl,--kill-at -Wl,--no-undefined")
      endif(${CMAKE_CXX_COMPILER_ID} STREQUAL "GNU")
      install(TARGETS ${lib} DESTINATION bin)
    else(WIN32)
      install(TARGETS ${lib} DESTINATION lib${LIB_SUFFIX})
    endif(WIN32)
  endforeach(interface ${mfront-models-interfaces})
  foreach(source ${ARGN})
    install_mfront(${CMAKE_CURRENT_SOURCE_DIR}/${source}.mfront ${mat} models)
  endforeach(source ${ARGN})
endfunction(mfront_models_library)
