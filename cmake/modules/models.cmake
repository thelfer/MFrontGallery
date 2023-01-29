function(add_mfront_model_sources lib interface search_paths file)
  if(EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/${file}.mfront.in")
    set(mfront_file   "${CMAKE_CURRENT_BINARY_DIR}/${file}.mfront")
    configure_file(
      "${CMAKE_CURRENT_SOURCE_DIR}/${file}.mfront.in"
      "${CMAKE_CURRENT_BINARY_DIR}/${file}.mfront"
      @ONLY)
  else(EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/${file}.mfront.in")
    set(mfront_file   "${CMAKE_CURRENT_SOURCE_DIR}/${file}.mfront")
  endif(EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/${file}.mfront.in")
  get_model_dsl_options(${interface})
  get_mfront_generated_sources(${lib} ${interface} "${search_paths}"
                                 "${mfront_dsl_options}" ${mfront_file})
  list(TRANSFORM mfront_generated_sources
       PREPEND "${CMAKE_CURRENT_BINARY_DIR}/${interface}/src/")
  _get_mfront_command_line_arguments()
  set(mfront_args )
  list(APPEND mfront_args ${mfront_command_line_arguments})
  list(APPEND mfront_args ${search_paths})
  if(mfront_dsl_options)
    list(APPEND mfront_args ${mfront_dsl_options})
  endif(mfront_dsl_options)
  list(APPEND mfront_args "--interface=${interface}")
  list(APPEND mfront_args "${mfront_file}")
  add_custom_command(
    OUTPUT  ${mfront_generated_sources}
    COMMAND "${MFRONT}"
    ARGS    ${mfront_args}
    DEPENDS "${mfront_file}"
    WORKING_DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}/${interface}"
    COMMENT "mfront source ${mfront_file}")
  list(APPEND ${lib}_SOURCES ${mfront_generated_sources})
  list(REMOVE_DUPLICATES ${lib}_SOURCES)
  set(${lib}_SOURCES ${${lib}_SOURCES} PARENT_SCOPE)
  if(${${interface}_SPECIFIC_DEFINITIONS})
    set_source_files_properties(${mfront_output}
      PROPERTIES COMPILE_FLAGS
      ${${interface}_SPECIFIC_DEFINITIONS})
  endif(${${interface}_SPECIFIC_DEFINITIONS})
endfunction(add_mfront_model_sources)

function(check_model_compatibility mat interface search_paths mfront_file)
  set(file_OK ON)
  set(compatibility_failure)
  if(${interface} STREQUAL "castem")
    check_castem_model_compatibility(${mat} "${search_paths}" ${mfront_file})
  else()
    message(FATAL_ERROR "unsupported interface ${interface}")
  endif()
  set(file_OK ${file_OK} PARENT_SCOPE)
  set(compatibility_failure ${compatibility_failure} PARENT_SCOPE)
endfunction(check_model_compatibility)

function(mfront_models_library mat)
  parse_mfront_library_sources(${ARGN})
  if(EXISTS ${CMAKE_SOURCE_DIR}/materials/${mat})
    list(APPEND mfront_search_paths 
      "--search-path=${CMAKE_SOURCE_DIR}/materials/${mat}/properties")
  endif(EXISTS ${CMAKE_SOURCE_DIR}/materials/${mat})
  list(APPEND mfront_search_paths 
      "--search-path=${CMAKE_CURRENT_SOURCE_DIR}")
  if(${ARGC} LESS 1)
    message(FATAL_ERROR "mfront_models_library : no source specified")
  endif(${ARGC} LESS 1)
  foreach(interface ${mfront-models-interfaces})
    file(MAKE_DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}/${interface}")
    if(${interface} STREQUAL "castem")
      getCastemModelName("${mat}")
      set(mfront_model_library_name "${lib}")
    else()
      set(mfront_model_library_name "${mat}Models-${interface}")
    endif(${interface} STREQUAL "castem")
    foreach(source ${mfront_sources})
      add_mfront_model_sources(${mfront_model_library_name} ${interface} "${mfront_search_paths}" ${source})
    endforeach(source)
    add_library(${mfront_model_library_name} SHARED
      ${${mfront_model_library_name}_SOURCES})
    target_include_directories(${mfront_model_library_name}
        PRIVATE "${CMAKE_CURRENT_BINARY_DIR}/${interface}/include"
        PRIVATE "${TFEL_INCLUDE_PATH}")
    if(EXISTS "${CMAKE_SOURCE_DIR}/include")
      target_include_directories(${mfront_model_library_name}
          PRIVATE "${CMAKE_SOURCE_DIR}/include")
    endif(EXISTS "${CMAKE_SOURCE_DIR}/include")
    if(mfront_include_directories)
        target_include_directories(${mfront_model_library_name}
          PRIVATE ${mfront_include_directories})
    endif()
    if(EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/include")
        target_include_directories(${mfront_model_library_name}
          PRIVATE "${CMAKE_CURRENT_SOURCE_DIR}/include")
    endif(EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/include")
    if(${interface} STREQUAL "castem")
	  if(CASTEMHOME)
	    if(enable-castem-pleiades)
	      target_include_directories(${mfront_model_library_name}
	        PRIVATE "${CASTEMHOME}/include")
	    else(enable-castem-pleiades)
	      target_include_directories(${mfront_model_library_name}
	        PRIVATE "${CASTEMHOME}/include/c")
	    endif(enable-castem-pleiades)
	  endif(CASTEMHOME)
      if(CASTEM_CPPFLAGS)
	    set_target_properties(${mfront_model_library_name} PROPERTIES
	      COMPILE_FLAGS "${CASTEM_CPPFLAGS}")
      endif(CASTEM_CPPFLAGS)
    endif(${interface} STREQUAL "castem")
    mfm_install_library(${mfront_model_library_name})
    if(${interface} STREQUAL "castem")
      target_link_libraries(${mfront_model_library_name}
        PRIVATE ${TFEL_MFRONT_LIBRARIES}
	    ${CastemInterface})
    endif(${interface} STREQUAL "castem")    
  endforeach(interface ${mfront-models-interfaces})
  foreach(source ${ARGN})
    install_mfront(${CMAKE_CURRENT_SOURCE_DIR}/${source}.mfront ${mat} models)
  endforeach(source ${ARGN})
endfunction(mfront_models_library)
