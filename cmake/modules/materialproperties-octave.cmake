macro(mfront_properties_octave_library mat)
  set (octave_targets )
  foreach(source ${ARGN})
    set(source_dir "${CMAKE_CURRENT_SOURCE_DIR}")
    set(mfront_file   "${source_dir}/${source}.mfront")
    set(mfront_output "${CMAKE_CURRENT_BINARY_DIR}/octave/octave/${source}.cpp")
    set(oct_file "octave/${source}.oct")
    list(APPEND octave_targets ${source}-octave)
    add_custom_command(
      OUTPUT  "${mfront_output}"
      COMMAND "${MFRONT}"
      ARGS    "--search-path=${CMAKE_SOURCE_DIR}/materials/${mat}/properties"
      ARGS    "--interface=octave" "${mfront_file}"
      DEPENDS "${mfront_file}"
      WORKING_DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}/octave"
      COMMENT "mfront source ${mfront_file}")
    add_library(${source}-octave SHARED ${mfront_output}
      ${${mat}_mfront_properties_dependencies_octave_SOURCES})
    set_target_properties(${source}-octave PROPERTIES
      OUTPUT_NAME ${source}
      PREFIX "octave/" SUFFIX  ".oct"
      COMPILE_FLAGS "${OCTAVE_INCLUDE_DIRS} ${COMPILER_DEFAULT_VISIBILITY}")
    target_include_directories(${source}-octave
      PRIVATE "${CMAKE_CURRENT_BINARY_DIR}/octave/include"
      PRIVATE "${TFEL_INCLUDE_PATH}")
    target_link_libraries(${source}-octave
      ${OCTAVE_LIBRARIES})  
    if(WIN32)
      install(FILES ${CMAKE_CURRENT_BINARY_DIR}/${oct_file} DESTINATION
	bin/octave-${OCTAVE_VERSION_STRING})
    else(WIN32)
      install(FILES ${CMAKE_CURRENT_BINARY_DIR}/${oct_file} DESTINATION
	lib/octave-${OCTAVE_VERSION_STRING})
    endif(WIN32)
  endforeach(source ${ARGN})
  add_custom_target(${mat}MaterialProperties-octave ALL
    DEPENDS ${octave_targets})
  add_dependencies(check ${mat}MaterialProperties-octave)
endmacro(mfront_properties_octave_library mat)

macro(octave_property_test mat file)
  if(MFM_OCTAVE_INTERFACE)
    string(TOLOWER ${mat} lib)
    set(test_file "${CMAKE_CURRENT_SOURCE_DIR}/${file}.m")
    set(test_name "${file}-octave")
    add_test(NAME ${test_name}
      COMMAND ${OCTAVE_EXECUTABLE} ${test_file}
      WORKING_DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}/octave")
  endif(MFM_OCTAVE_INTERFACE)
endmacro(octave_property_test $(file))
