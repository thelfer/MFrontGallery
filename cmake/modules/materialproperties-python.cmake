macro(mfront_properties_python_library mat)
  string(TOLOWER ${mat} lib)
  set(mfront_files)
  parse_mfront_library_sources(${ARGN})
  list(APPEND mfront_search_paths 
      "--search-path=${CMAKE_SOURCE_DIR}/materials/${mat}/properties")
  set(wrapper_source "${CMAKE_CURRENT_BINARY_DIR}/python/src/${mat}lawwrapper.cxx")
  get_material_property_dsl_options("python")
  foreach(source ${mfront_sources})
    set(mfront_file   "${CMAKE_CURRENT_SOURCE_DIR}/${source}.mfront")
    list(APPEND mfront_files "${mfront_file}")
    get_mfront_generated_sources("material-property"
                                 ${mat} "python" "${mfront_search_paths}"
                                 "${mfront_dsl_options}" ${mfront_file})
    list(TRANSFORM mfront_generated_sources PREPEND "${CMAKE_CURRENT_BINARY_DIR}/python/src/")
    list(APPEND ${lib}_SOURCES ${mfront_generated_sources})
  endforeach(source)
  list(APPEND ${lib}_SOURCES ${wrapper_source})
  list(REMOVE_DUPLICATES ${lib}_SOURCES)
  set(mfront_args)
  list(APPEND mfront_args ${mfront_search_paths})
  if(mfront_dsl_options)
    list(APPEND mfront_args ${mfront_dsl_options})
  endif(mfront_dsl_options)
  list(APPEND mfront_args "--interface=python")
  list(APPEND mfront_args "${mfront_files}")
  add_custom_command(
      OUTPUT  ${${lib}_SOURCES}
      COMMAND "${MFRONT}"
      ARGS    ${mfront_args}
      DEPENDS ${mfront_files}
      WORKING_DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}/python"
      COMMENT "mfront sources ${mfront_files} for interface python")
  message(STATUS "Adding library : ${lib} (${${lib}_SOURCES})")
  add_library(${lib} SHARED ${${lib}_SOURCES})
  target_include_directories(${lib}
    PRIVATE "${CMAKE_CURRENT_BINARY_DIR}/python/include"
    PRIVATE "${TFEL_INCLUDE_PATH}"
    PRIVATE "${PYTHON_INCLUDE_DIRS}")
  if(WIN32)
    set_target_properties(${lib} PROPERTIES
      COMPILE_FLAGS "-DHAVE_ROUND")
  endif(WIN32)
  target_link_libraries(${lib} ${PYTHON_LIBRARIES})
  install(TARGETS ${lib} DESTINATION
    lib/python${PYTHON_VERSION_MAJOR}.${PYTHON_VERSION_MINOR}/site-packages/mfm)
  set_target_properties(${lib} PROPERTIES PREFIX "")
  if(WIN32)
    set_target_properties(${lib} PROPERTIES SUFFIX ".pyd")
  endif(WIN32)
  if(APPLE)
    set_target_properties(${lib} PROPERTIES SUFFIX ".so")
  endif(APPLE)
  set_target_properties(${lib} PROPERTIES OUTPUT_NAME ${lib})
  add_dependencies(check ${lib})
endmacro(mfront_properties_python_library mat)

macro(python_property_test mat file)
  if(MFM_PYTHON_INTERFACE)
    string(TOLOWER ${mat} lib)
    set(test_file "${CMAKE_CURRENT_SOURCE_DIR}/${file}.py")
    set(test_name "${file}-python")
    add_test(NAME ${test_name}
      COMMAND ${PYTHON_EXECUTABLE} ${test_file}
      WORKING_DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}/python")
    if((CMAKE_HOST_WIN32) AND (NOT MSYS))
      set_property(TEST ${test_name}
	PROPERTY ENVIRONMENT "PYTHONPATH=$<TARGET_FILE_DIR:${lib}>;$ENV{PYTHONPATH}")
    else((CMAKE_HOST_WIN32) AND (NOT MSYS))
      set_property(TEST ${test_name}
	PROPERTY ENVIRONMENT "PYTHONPATH=$<TARGET_FILE_DIR:${lib}>:$ENV{PYTHONPATH}")
    endif((CMAKE_HOST_WIN32) AND (NOT MSYS))
    # add_dependencies(${test_name} ${lib})
  endif(MFM_PYTHON_INTERFACE)
endmacro(python_property_test $(file))
