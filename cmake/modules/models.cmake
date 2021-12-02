macro(add_mfront_model_sources lib interface file)
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
  add_custom_command(
    OUTPUT  "${mfront_output}"
    COMMAND "${MFRONT}"
    ARGS    "--search-path=${CMAKE_SOURCE_DIR}/materials/${mat}/properties"
    ARGS    "--interface=${interface}" "${mfront_file}"
    DEPENDS "${mfront_file}"
    COMMENT "mfront source ${mfront_file}")
  set(${lib}_SOURCES ${mfront_output} ${${lib}_SOURCES})
  set_source_files_properties(${mfront_output}
    PROPERTIES COMPILE_FLAGS
    ${${interface}_SPECIFIC_DEFINITIONS})
endmacro(add_mfront_model_sources)

macro(mfront_models_library mat)
  if(${ARGC} LESS 1)
    message(FATAL_ERROR "mfront_models_library : no source specified")
  endif(${ARGC} LESS 1)
  foreach(interface ${mfront-models-interfaces})
    if(${interface} STREQUAL "licos")
      set(lib "${mat}MaterialModels")
    else(${interface} STREQUAL "licos")
      set(lib "${mat}MaterialModels-${interface}")
    endif(${interface} STREQUAL "licos")
    foreach(source ${ARGN})
      add_mfront_model_sources(${lib} ${interface} ${source})
#      foreach(deps ${${mat}_mfront_models_dependencies_SOURCES})
	set(${lib}_SOURCES ${deps} ${${lib}_SOURCES})
      endforeach(deps ${${mat}_mfront_models_dependencies_SOURCES})
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
  endforeach(interface)
  foreach(source ${ARGN})
    install_mfront(${CMAKE_CURRENT_SOURCE_DIR}/${source}.mfront ${mat} models)
  endforeach(source)
endmacro(mfront_models_library)
