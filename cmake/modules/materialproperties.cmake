macro(add_mfront_property_source lib mat interface ext file)
  if(${ARGC} EQUAL 6)
    set(source_dir "${ARGN}")
  else(${ARGC} EQUAL 6)
    set(source_dir "${CMAKE_CURRENT_SOURCE_DIR}")
  endif(${ARGC} EQUAL 6)
  set(mfront_file   "${source_dir}/${file}.mfront")
  if("${ext}" STREQUAL "")
    set(mfront_output1 "${CMAKE_CURRENT_BINARY_DIR}/${interface}/src/${file}.cxx")
    set(mfront_output2 "${CMAKE_CURRENT_BINARY_DIR}/${interface}/include/${file}.hxx")
  elseif("${ext}" STREQUAL "cxx_ext")
    set(mfront_output1 "${CMAKE_CURRENT_BINARY_DIR}/${interface}/src/${file}-cxx.cxx")
    set(mfront_output2 "${CMAKE_CURRENT_BINARY_DIR}/${interface}/include/${file}-cxx.hxx")
  else("${ext}" STREQUAL "")
    set(mfront_output1 "${CMAKE_CURRENT_BINARY_DIR}/${interface}/src/${file}-${ext}.cxx")
    set(mfront_output2 "${CMAKE_CURRENT_BINARY_DIR}/${interface}/include/${file}-${ext}.hxx")
  endif("${ext}" STREQUAL "")
  add_custom_command(
    OUTPUT  "${mfront_output1}"
    OUTPUT  "${mfront_output2}"
    COMMAND "${MFRONT}"
    ARGS    "--search-path=${CMAKE_SOURCE_DIR}/materials/${mat}/properties"
    ARGS    "--interface=${interface}" "${mfront_file}"
    DEPENDS "${mfront_file}"
    WORKING_DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}/${interface}"
    COMMENT "mfront source ${mfront_file}")
  install(FILES ${mfront_output2} DESTINATION "include")
  set(${lib}_SOURCES ${mfront_output1} ${${lib}_SOURCES})
endmacro(add_mfront_property_source)

function(mfront_properties_extension interface)
  if("${interface}" STREQUAL "c++")
    set(source_ext "cxx_ext" PARENT_SCOPE)
  elseif("${interface}" STREQUAL "c")
    set(source_ext "" PARENT_SCOPE)
  elseif("${interface}" STREQUAL "castem")
    set(source_ext "castem" PARENT_SCOPE)
  elseif("${interface}" STREQUAL "cyrano")
    set(source_ext "cyrano" PARENT_SCOPE)
  else("${interface}" STREQUAL "c++")
    message(FATAL_ERROR
      "mfront_properties_extension : unsupported interface ${interface}")
  endif("${interface}" STREQUAL "c++")
endfunction(mfront_properties_extension)

macro(mfront_properties_standard_library mat interface)
  if(${interface} STREQUAL "c")
    set(lib "${mat}MaterialProperties")
  else(${interface} STREQUAL "c")
    set(lib "${mat}MaterialProperties-${interface}")
  endif(${interface} STREQUAL "c")
  mfront_properties_extension("${interface}")
  foreach(source ${ARGN})
    add_mfront_property_source(${lib} ${mat} ${interface} "${source_ext}" ${source})
  endforeach(source)
  foreach(deps ${${mat}_mfront_properties_dependencies_${interface}_SOURCES})
    set(${lib}_SOURCES ${deps} ${${lib}_SOURCES})
  endforeach(deps ${${mat}_mfront_properties_dependencies_${interface}_SOURCES})
  message(STATUS "Adding library : ${lib} (${${lib}_SOURCES})")
  add_library(${lib} SHARED ${${lib}_SOURCES})
  target_include_directories(${lib}
    PRIVATE "${CMAKE_CURRENT_BINARY_DIR}/${interface}/include"
    PRIVATE "${TFEL_INCLUDE_PATH}")
  if(WIN32)
    if(${CMAKE_CXX_COMPILER_ID} STREQUAL "GNU")
      set_target_properties(${lib}
	PROPERTIES LINK_FLAGS "-Wl,--kill-at -Wl,--no-undefined")
    endif(${CMAKE_CXX_COMPILER_ID} STREQUAL "GNU")
    install(TARGETS ${lib} DESTINATION bin)
  else(WIN32)
    install(TARGETS ${lib} DESTINATION lib${LIB_SUFFIX})
  endif(WIN32)
endmacro(mfront_properties_standard_library mat)

include(cmake/modules/materialproperties-fortran.cmake)
include(cmake/modules/materialproperties-python.cmake)
include(cmake/modules/materialproperties-java.cmake)
include(cmake/modules/materialproperties-octave.cmake)
include(cmake/modules/materialproperties-excel.cmake)

macro(mfront_properties_library mat)
  set ( _CMD SOURCES )
  set ( _SOURCES )
  set ( _DEPENDENCIES )
  foreach ( _ARG ${ARGN})
    if ( ${_ARG} MATCHES SOURCES )
      set ( _CMD SOURCES )
    elseif ( ${_ARG} MATCHES DEPENDENCIES )
      set ( _CMD DEPENDENCIES )
    else ()
      if ( ${_CMD} MATCHES SOURCES )
        list ( APPEND _SOURCES "${_ARG}" )
      elseif ( ${_CMD} MATCHES DEPENDENCIES )
        list ( APPEND _DEPENDENCIES "${_ARG}" )
      endif ()
    endif ()
  endforeach ()
  list(LENGTH _SOURCES _SOURCES_LENGTH )
  if(${_SOURCES_LENGTH} LESS 1)
    message(FATAL_ERROR "mfront_properties_library : no source specified")
  endif(${_SOURCES_LENGTH} LESS 1)
  # treating dependencies
  foreach(dep ${_DEPENDENCIES})
    foreach(interface ${mfront-properties-interfaces})
      add_mfront_dependency(${mat}_mfront_properties_dependencies ${mat} ${interface} ${dep})
    endforeach(interface ${mfront-properties-interfaces})
  endforeach(dep ${_DEPENDENCIES})
  # treating sources
  foreach(interface ${mfront-properties-interfaces})
    message(STATUS "Treating interface ${interface}")
    file(MAKE_DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}/${interface}")
    if(${interface} STREQUAL "excel")
      mfront_properties_excel_library(${mat} ${_SOURCES})
    elseif(${interface} STREQUAL "excel-internal")
      mfront_properties_excel_internal_library(${mat} ${_SOURCES})
    elseif(${interface} STREQUAL "fortran")
      mfront_properties_fortran_library(${mat} ${_SOURCES})
    elseif(${interface} STREQUAL "java")
      mfront_properties_java_library(${mat} ${_SOURCES})
    elseif(${interface} STREQUAL "python")
      mfront_properties_python_library(${mat} ${_SOURCES})
    elseif(${interface} STREQUAL "octave")
      mfront_properties_octave_library(${mat} ${_SOURCES})
    else(${interface} STREQUAL "excel")
      mfront_properties_standard_library(${mat} ${interface} ${_SOURCES})
    endif(${interface} STREQUAL "excel")
  endforeach(interface ${mfront-properties-interfaces})
  foreach(source ${_SOURCES})
    install_mfront(${CMAKE_CURRENT_SOURCE_DIR}/${source}.mfront ${mat} properties)
  endforeach(source)
endmacro(mfront_properties_library)

## tests

macro(cxx_property_test mat file)
  if(MFM_CXX_INTERFACE)
    set(lib "${mat}MaterialProperties-c++")
    set(test_file ${file}.cxx)
    set(test_name "${file}-cxx")
    add_executable(${test_name} EXCLUDE_FROM_ALL ${test_file})
    add_test(NAME ${test_name}
      COMMAND ${test_name}
      WORKING_DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}/c++")
    add_dependencies(check ${test_name})
    add_dependencies(${test_name} ${lib})
    target_include_directories(${test_name}
      PRIVATE "${CMAKE_CURRENT_BINARY_DIR}/c++/include"
      PRIVATE "${TFEL_INCLUDE_PATH}")
    target_link_libraries(${test_name} ${lib}
      ${TFELTests})
  endif(MFM_CXX_INTERFACE)
endmacro(cxx_property_test $(file))
