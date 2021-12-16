function(mfront_properties_octave_library mat)
  set (octave_targets )
  parse_mfront_library_sources(${ARGN})
  list(APPEND mfront_search_paths 
      "--search-path=${CMAKE_SOURCE_DIR}/materials/${mat}/properties")
  foreach(source ${mfront_sources})
    set(source_dir "${CMAKE_CURRENT_SOURCE_DIR}")
    set(mfront_file   "${source_dir}/${source}.mfront")
    get_mfront_all_specific_targets_generated_sources("octave" ${mat} ${mfront_file})
    list(TRANSFORM mfront_generated_sources PREPEND "${CMAKE_CURRENT_BINARY_DIR}/octave/src/")
    add_custom_command(
      OUTPUT  ${mfront_generated_sources}
      COMMAND "${MFRONT}"
      ARGS    "--interface=octave"
      ARGS    ${mfront_search_paths}
      ARGS     "${mfront_file}"
      DEPENDS "${mfront_file}"
      WORKING_DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}/${interface}"
      COMMENT "mfront source ${mfront_file} for interface ${interface}")
    set(oct_file "octave/${source}.oct")
    list(APPEND octave_targets ${source}-octave)
    add_library(${source}-octave SHARED ${mfront_generated_sources})
    set_target_properties(${source}-octave PROPERTIES
      OUTPUT_NAME ${source}
      PREFIX "octave/" SUFFIX  ".oct"
      COMPILE_FLAGS "${OCTAVE_INCLUDE_DIRS} ${COMPILER_DEFAULT_VISIBILITY}")
    target_include_directories(${source}-octave
      PRIVATE "${CMAKE_CURRENT_BINARY_DIR}/octave/include"
      PRIVATE "${TFEL_INCLUDE_PATH}")
    target_link_libraries(${source}-octave ${OCTAVE_LIBRARIES})  
    if(WIN32)
      install(FILES ${CMAKE_CURRENT_BINARY_DIR}/${oct_file} DESTINATION
              bin/octave-${OCTAVE_VERSION_STRING})
    else(WIN32)
      install(FILES ${CMAKE_CURRENT_BINARY_DIR}/${oct_file} DESTINATION
	lib/octave-${OCTAVE_VERSION_STRING})
    endif(WIN32)
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
