macro(mfront_properties_python_library mat)
  string(TOLOWER ${mat} lib)
  set(mfront_files)
  foreach(source ${ARGN})
    set(mfront_file   "${CMAKE_CURRENT_SOURCE_DIR}/${source}.mfront")
    list(APPEND mfront_files "${mfront_file}")
    set(mfront_output "python/src/${source}-python.cxx")
    add_custom_command(
      OUTPUT  "${mfront_output}"
      OUTPUT  "python/include/${source}-python.hxx"
      COMMAND "${MFRONT}"
      ARGS    "--search-path=${CMAKE_SOURCE_DIR}/materials/${mat}/properties"
      ARGS    "--interface=python" "${mfront_file}"
      DEPENDS "${mfront_file}"
      WORKING_DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}/python"
      COMMENT "mfront source ${mfront_file}")
    set(${lib}_SOURCES ${mfront_output} ${${lib}_SOURCES})
  endforeach(source)
  foreach(deps ${${mat}_mfront_properties_dependencies_python_SOURCES})
    set(${lib}_SOURCES ${deps} ${${lib}_SOURCES})
  endforeach(deps ${${mat}_mfront_properties_dependencies_python_SOURCES})
  add_custom_command(
    OUTPUT  "python/src/${mat}lawwrapper.cxx"
    COMMAND "${MFRONT}"
    ARGS    "--search-path=${CMAKE_SOURCE_DIR}/materials/${mat}/properties"
    ARGS    "--interface=python" ${mfront_files}
    DEPENDS ${mfront_files}
    WORKING_DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}/python"
    COMMENT "mfront source ${mfront_file}")
  set(${lib}_SOURCES "python/src/${mat}lawwrapper.cxx" ${${lib}_SOURCES})
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
    lib/${PYTHON_LIBRARY}/site-packages/mfm)
  set_target_properties(${lib} PROPERTIES PREFIX "")
  if(WIN32)
    set_target_properties(${lib} PROPERTIES SUFFIX ".pyd")
  endif(WIN32)
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
