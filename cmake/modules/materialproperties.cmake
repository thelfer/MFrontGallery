function(add_mfront_material_property_source lib mat interface search_paths mfront_path)
  get_material_property_dsl_options(${interface})
  get_mfront_generated_sources(${mat} ${interface} "${search_paths}"
                               "${mfront_dsl_options}" ${mfront_path})
  list(TRANSFORM mfront_generated_sources PREPEND
      "${CMAKE_CURRENT_BINARY_DIR}/${interface}/src/")
  set(${lib}_MFRONT_SOURCES ${mfront_file} ${${lib}_MFRONT_SOURCES} PARENT_SCOPE)
  list(APPEND mfront_generated_sources ${${lib}_SOURCES})
  list(REMOVE_DUPLICATES mfront_generated_sources)
  set(${lib}_SOURCES ${mfront_generated_sources} PARENT_SCOPE)
endfunction(add_mfront_material_property_source)

function(add_mfront_property_sources lib mat interface search_paths file)
  get_mfront_source_location(${file})
  if(NOT mfront_path)
    list(APPEND ${lib}_OTHER_SOURCES "${source}")
    set(${lib}_OTHER_SOURCES
        ${${lib}_OTHER_SOURCES} PARENT_SCOPE)
  else()
    if (madnex_file)
	  if(TFEL_MADNEX_SUPPORT)
        mfront_query(_impls ${mat} "${search_paths}" ${mfront_path}
                     "--all-material-properties" "--list-implementation-paths=unsorted")
        if(_impls)
          string(REPLACE " " ";" _mfront_impls ${_impls})
        else(_impls)
          set(_mfront_impls )
        endif(_impls)
        foreach(_impl ${_mfront_impls})
          add_mfront_material_property_source(${lib} ${mat} ${interface}
                                              "${search_paths}" ${_impl})
	      list(APPEND ${lib}_MFRONT_IMPLEMENTATION_PATHS ${_impl})
          set(${lib}_MFRONT_IMPLEMENTATION_PATHS
              ${${lib}_MFRONT_IMPLEMENTATION_PATHS} PARENT_SCOPE)
        endforeach(_impl ${impls})
        list(APPEND ${lib}_MFRONT_SOURCES ${mfront_path})
        set(${lib}_MFRONT_SOURCES ${${lib}_MFRONT_SOURCES} PARENT_SCOPE)
      else(TFEL_MADNEX_SUPPORT)
        message(STATUS "file '${file}' has been discarded since "
	                   "madnex support has not been enabled")
      endif(TFEL_MADNEX_SUPPORT)
    else()
      add_mfront_material_property_source(${lib} ${mat} ${interface}
                                          "${search_paths}" ${mfront_path})
	  list(APPEND ${lib}_MFRONT_SOURCES ${mfront_path})
      set(${lib}_MFRONT_SOURCES ${${lib}_MFRONT_SOURCES} PARENT_SCOPE)
	  list(APPEND ${lib}_MFRONT_IMPLEMENTATION_PATHS ${mfront_path})
      set(${lib}_MFRONT_IMPLEMENTATION_PATHS
          ${${lib}_MFRONT_IMPLEMENTATION_PATHS} PARENT_SCOPE)
    endif()
    set(${lib}_SOURCES ${${lib}_SOURCES} PARENT_SCOPE)
  endif()
endfunction(add_mfront_property_sources)

function(mfront_properties_standard_library2 lib mat interface)
  parse_mfront_library_sources(${ARGN})
  if(EXISTS ${CMAKE_SOURCE_DIR}/materials/${mat})
    list(APPEND mfront_search_paths 
      "--search-path=${CMAKE_SOURCE_DIR}/materials/${mat}/properties")
  endif(EXISTS ${CMAKE_SOURCE_DIR}/materials/${mat})
  list(APPEND mfront_search_paths 
      "--search-path=${CMAKE_CURRENT_SOURCE_DIR}")
  foreach(source ${mfront_sources})
    add_mfront_property_sources(${lib} ${mat} ${interface} "${mfront_search_paths}" ${source})
  endforeach(source)
  set(generate_library ON)
  list(LENGTH ${lib}_SOURCES nb_sources)
  list(LENGTH ${lib}_OTHER_SOURCES nb_other_sources)
  if(nb_sources EQUAL 0)
    if(nb_other_sources GREATER 0)
      if(NOT generate_without_mfront_sources)
        set(generate_library OFF)
      endif(NOT generate_without_mfront_sources)
    else(nb_other_sources GREATER 0)
      set(generate_library OFF)
    endif(nb_other_sources GREATER 0)
  endif(nb_sources EQUAL 0)
  if(generate_library)
	_get_mfront_command_line_arguments()
    set(mfront_args )
    list(APPEND mfront_args ${mfront_command_line_arguments})
    list(APPEND mfront_args "--interface=${interface}")
    list(APPEND mfront_args ${mfront_search_paths})
    get_material_property_dsl_options(${interface})
    if(mfront_dsl_options)
      list(APPEND mfront_args ${mfront_dsl_options})
    endif(mfront_dsl_options)
    list(APPEND mfront_args ${${lib}_MFRONT_IMPLEMENTATION_PATHS})
    add_custom_command(
        OUTPUT  ${${lib}_SOURCES}
        COMMAND "${MFRONT}"
        ARGS    ${mfront_args}
        DEPENDS ${${lib}_MFRONT_SOURCES}
        WORKING_DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}/${interface}"
        COMMENT "mfront sources ${${lib}_MFRONT_SOURCES} for interface ${interface}")
    message(STATUS "Adding library : ${lib} (${${lib}_SOURCES})")
    add_library(${lib} SHARED ${${lib}_SOURCES})
    target_include_directories(${lib}
      PRIVATE "${CMAKE_CURRENT_BINARY_DIR}/${interface}/include"
      PRIVATE "${TFEL_INCLUDE_PATH}")
    mfm_install_library(${lib})
  else(generate_library)
    if(nb_other_sources GREATER 0)
      message(STATUS "Only external sources provided for "
	    "library ${lib} for interface ${interface}. "
        "The generation of this library is disabled by default. It can be enabled "
        "by passing the GENERATE_WITHOUT_MFRONT_SOURCES")
    else(nb_other_sources GREATER 0)
      message(STATUS "No sources selected for "
	    "library ${lib} for interface ${interface}")
    endif(nb_other_sources GREATER 0)
  endif(generate_library)
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
