if( CMAKE_SIZEOF_VOID_P EQUAL 8 )
  set(CYRANO_CPPFLAGS "-DCYRANO_ARCH=64")
else( CMAKE_SIZEOF_VOID_P EQUAL 8 )
  set(CYRANO_CPPFLAGS "-DCYRANO_ARCH=32")
endif( CMAKE_SIZEOF_VOID_P EQUAL 8 )

function(check_cyrano_compatibility mat source)
  behaviour_query(behaviour_type
    ${mat} ${source} "--type")
  if(NOT (behaviour_type STREQUAL "1"))
    set(file_OK OFF PARENT_SCOPE)
  else(NOT (behaviour_type STREQUAL "1"))
    behaviour_query(behaviour_has_strain_measure
      ${mat} ${source} "--is-strain-measure-defined")
    if(behaviour_has_strain_measure STREQUAL "true")
      behaviour_query(behaviour_strain_measure
	${mat} ${source} "--strain-measure")
      if(NOT (behaviour_type STREQUAL "Linearised"))
	set(file_OK OFF PARENT_SCOPE)
      endif(NOT (behaviour_type STREQUAL "Linearised"))
    endif(behaviour_has_strain_measure STREQUAL "true")
  endif(NOT (behaviour_type STREQUAL "1"))
endfunction(check_cyrano_compatibility)
