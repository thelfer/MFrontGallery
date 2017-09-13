macro(mfront_properties_fortran_library mat)
  set(lib "${mat}MaterialProperties-fortran")
  foreach(source ${ARGN})
    set(mfront_file   "${CMAKE_CURRENT_SOURCE_DIR}/${source}.mfront")
    set(mfront_output "fortran/src/${source}-fortran.cxx")
    add_custom_command(
      OUTPUT  "${mfront_output}"
      COMMAND "${MFRONT}"
      ARGS    "--search-path=${CMAKE_SOURCE_DIR}/materials/${mat}/properties"
      ARGS    "--interface=fortran" "${mfront_file}"
      DEPENDS "${mfront_file}"
      WORKING_DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}/fortran"
      COMMENT "mfront source ${mfront_file}")
    set(${lib}_SOURCES ${mfront_output} ${${lib}_SOURCES})
  endforeach(source)
  foreach(deps ${${mat}_mfront_properties_dependencies_fortran_SOURCES})
    set(${lib}_SOURCES ${deps} ${${lib}_SOURCES})
  endforeach(deps ${${mat}_mfront_properties_dependencies_fortran_SOURCES})
  message(STATUS "Adding library : ${lib} (${${lib}_SOURCES})")
  add_library(${lib} SHARED ${${lib}_SOURCES})
  target_include_directories(${lib}
    PRIVATE "${CMAKE_CURRENT_BINARY_DIR}/fortran/include"
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
endmacro(mfront_properties_fortran_library mat)

macro(fortran_property_test mat file)
  if(MFM_FORTRAN_INTERFACE)
    set(lib "${mat}MaterialProperties-fortran")
    set(test_file ${file}.f)
    set(test_name "${file}-fortran")
    add_executable(${test_name} EXCLUDE_FROM_ALL ${test_file})
    add_test(NAME ${test_name}
      COMMAND ${test_name}
      WORKING_DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}/fortran")
    add_dependencies(check ${test_name})
    add_dependencies(${test_name} ${lib})
    target_link_libraries(${test_name} ${lib})
  endif(MFM_FORTRAN_INTERFACE)
endmacro(fortran_property_test $(file))

