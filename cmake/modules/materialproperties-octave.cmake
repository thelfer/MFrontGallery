function(mfront_properties_octave_library mat)
  set (octave_targets )
  parse_mfront_library_sources(${ARGN})
  if(EXISTS ${CMAKE_SOURCE_DIR}/materials/${mat})
    list(APPEND mfront_search_paths 
      "--search-path=${CMAKE_SOURCE_DIR}/materials/${mat}/properties")
  endif(EXISTS ${CMAKE_SOURCE_DIR}/materials/${mat})
  list(APPEND mfront_search_paths 
      "--search-path=${CMAKE_CURRENT_SOURCE_DIR}")
  foreach(source ${mfront_sources})
    set(source_dir "${CMAKE_CURRENT_SOURCE_DIR}")
    get_mfront_source_location(${source})
    if(NOT mfront_path)
      continue()
    endif()
    if (madnex_file)
      continue()
    endif()
    execute_process(COMMAND ${MFRONT_QUERY}
      "--verbose=quiet"
      "--law-name" "${mfront_path}"
      ${mfront_search_paths}
      RESULT_VARIABLE _mfront_law_name_available
      OUTPUT_VARIABLE _mfront_law_name
      OUTPUT_STRIP_TRAILING_WHITESPACE)
    get_mfront_all_specific_targets_generated_sources("octave" ${mat} ${source} ${mfront_search_paths})
    if(mfront_generated_sources)
      list(TRANSFORM mfront_generated_sources PREPEND "${CMAKE_CURRENT_BINARY_DIR}/octave/src/")
      _get_mfront_command_line_arguments()
      set(mfront_args )
      list(APPEND mfront_args ${mfront_command_line_arguments})
      list(APPEND mfront_args ${mfront_search_paths})
      get_material_property_dsl_options("octave")
      if(mfront_dsl_options)
        list(APPEND mfront_args ${mfront_dsl_options})
      endif(mfront_dsl_options)
      list(APPEND mfront_args "--interface=octave")
      list(APPEND mfront_args "${mfront_path}")
      add_custom_command(
        OUTPUT  ${mfront_generated_sources}
        COMMAND "${MFRONT}"
        ARGS    ${mfront_args}
        DEPENDS "${mfront_file}"
        WORKING_DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}/${interface}"
        COMMENT "mfront source ${mfront_file} for interface ${interface}")
      set(oct_file "octave/${_mfront_law_name}.oct")
      set(_lib ${mat}_${_mfront_law_name}-octave)
      list(APPEND octave_targets ${_lib})
      add_library(${_lib} SHARED ${mfront_generated_sources})
      set_target_properties(${_lib} PROPERTIES
        OUTPUT_NAME ${mat}_${_mfront_law_name}
        PREFIX "octave/" SUFFIX  ".oct"
        COMPILE_FLAGS "${OCTAVE_INCLUDE_DIRS} ${COMPILER_DEFAULT_VISIBILITY}")
      target_include_directories(${_lib}
        PRIVATE "${CMAKE_CURRENT_BINARY_DIR}/octave/include"
        PRIVATE "${TFEL_INCLUDE_PATH}")
      target_link_libraries(${_lib} ${OCTAVE_LIBRARIES})  
      if(WIN32)
        install(FILES ${CMAKE_CURRENT_BINARY_DIR}/${oct_file} DESTINATION
          bin/octave-${OCTAVE_VERSION_STRING})
      else(WIN32)
        install(FILES ${CMAKE_CURRENT_BINARY_DIR}/${oct_file} DESTINATION
       	  lib/octave-${OCTAVE_VERSION_STRING})
      endif(WIN32)
    endif()
  endforeach(source)
  add_custom_target(${mat}MaterialProperties-octave ALL
    DEPENDS ${octave_targets})
  add_dependencies(check ${mat}MaterialProperties-octave)
endfunction(mfront_properties_octave_library mat)

function(octave_property_test mat file)
  if(MFM_OCTAVE_INTERFACE)
    string(TOLOWER ${mat} lib)
    set(test_file "${CMAKE_CURRENT_SOURCE_DIR}/${file}.m")
    set(test_name "${file}-octave")
    add_test(NAME ${test_name}
      COMMAND ${OCTAVE_EXECUTABLE} ${test_file}
      WORKING_DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}/octave")
  endif(MFM_OCTAVE_INTERFACE)
endfunction(octave_property_test $(file))
