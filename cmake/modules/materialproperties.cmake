function(add_mfront_property_source lib mat interface search_paths file)
  if(${ARGC} EQUAL 6)
    set(source_dir "${ARGN}")
  else(${ARGC} EQUAL 6)
    set(source_dir "${CMAKE_CURRENT_SOURCE_DIR}")
  endif(${ARGC} EQUAL 6)
  set(mfront_file   "${source_dir}/${file}.mfront")
  get_mfront_generated_sources(${mat} ${interface} "${search_paths}" ${mfront_file})
  list(TRANSFORM mfront_generated_sources PREPEND "${CMAKE_CURRENT_BINARY_DIR}/${interface}/src/")
  set(${lib}_MFRONT_SOURCES ${mfront_file} ${${lib}_MFRONT_SOURCES} PARENT_SCOPE)
  list(APPEND mfront_generated_sources ${${lib}_SOURCES})
  list(REMOVE_DUPLICATES mfront_generated_sources)
  set(${lib}_SOURCES ${mfront_generated_sources} PARENT_SCOPE)
endfunction(add_mfront_property_source)

function(mfront_properties_standard_library2 lib mat interface)
  parse_mfront_library_sources(${ARGN})
  list(APPEND mfront_search_paths 
      "--search-path=${CMAKE_SOURCE_DIR}/materials/${mat}/properties")
  foreach(source ${mfront_sources})
    add_mfront_property_source(${lib} ${mat} ${interface} "${mfront_search_paths}" ${source})
  endforeach(source)
  set(mfront_args)
  list(APPEND mfront_args "--interface=${interface}")
  if(EXISTS "${CMAKE_SOURCE_DIR}/materials/${mat}/properties")
    list(APPEND mfront_args "--search-path=${CMAKE_SOURCE_DIR}/materials/${mat}/properties")
  endif(EXISTS "${CMAKE_SOURCE_DIR}/materials/${mat}/properties")
  add_custom_command(
      OUTPUT  ${${lib}_SOURCES}
      COMMAND "${MFRONT}"
      ARGS    "--interface=${interface}"
      ARGS    "--search-path=${CMAKE_SOURCE_DIR}/materials/${mat}/properties"
      ARGS    ${${lib}_MFRONT_SOURCES}
      DEPENDS ${${lib}_MFRONT_SOURCES}
      WORKING_DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}/${interface}"
      COMMENT "mfront sources ${${lib}_MFRONT_SOURCES} for interface ${interface}")
  message(STATUS "Adding library : ${lib} (${${lib}_SOURCES})")
  add_library(${lib} SHARED ${${lib}_SOURCES})
  target_include_directories(${lib}
    PRIVATE "${CMAKE_CURRENT_BINARY_DIR}/${interface}/include"
    PRIVATE "${TFEL_INCLUDE_PATH}")
  mfm_install_library(${lib})
endfunction(mfront_properties_standard_library2)

function(mfront_properties_standard_library mat interface)
  if(${interface} STREQUAL "c")
    set(lib "${mat}MaterialProperties")
  else(${interface} STREQUAL "c")
    set(lib "${mat}MaterialProperties-${interface}")
  endif(${interface} STREQUAL "c")
  mfront_properties_standard_library2(${lib} ${mat} ${interface} ${ARGN})
endfunction(mfront_properties_standard_library)

include(cmake/modules/materialproperties-fortran.cmake)
include(cmake/modules/materialproperties-python.cmake)
include(cmake/modules/materialproperties-java.cmake)
include(cmake/modules/materialproperties-octave.cmake)
include(cmake/modules/materialproperties-excel.cmake)

macro(mfront_properties_library mat)
  set ( _CMD SOURCES )
  set ( _SOURCES )
  foreach ( _ARG ${ARGN})
    if ( ${_ARG} MATCHES SOURCES )
      set ( _CMD SOURCES )
    else ()
      if ( ${_CMD} MATCHES SOURCES )
        list ( APPEND _SOURCES "${_ARG}" )
      endif ()
    endif ()
  endforeach ()
  list(LENGTH _SOURCES _SOURCES_LENGTH )
  if(${_SOURCES_LENGTH} LESS 1)
    message(FATAL_ERROR "mfront_properties_library : no source specified")
  endif(${_SOURCES_LENGTH} LESS 1)
  # treating sources
  foreach(interface ${mfront-properties-interfaces})
    message(STATUS "Treating interface ${interface}")
    file(MAKE_DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}/${interface}")
    if(${interface} STREQUAL "python")
      mfront_properties_python_library(${mat} ${_SOURCES})
    elseif(${interface} STREQUAL "excel")
      mfront_properties_excel_library(${mat} ${_SOURCES})
    elseif(${interface} STREQUAL "excel-internal")
      mfront_properties_excel_internal_library(${mat} ${_SOURCES})
    elseif(${interface} STREQUAL "java")
      mfront_properties_java_library(${mat} ${_SOURCES})
    elseif(${interface} STREQUAL "octave")
      mfront_properties_octave_library(${mat} ${_SOURCES})
    else(${interface} STREQUAL "python")
      mfront_properties_standard_library(${mat} ${interface} ${_SOURCES})
    endif(${interface} STREQUAL "python")
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
