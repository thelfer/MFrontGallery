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

