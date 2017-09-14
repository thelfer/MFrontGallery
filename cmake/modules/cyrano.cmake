if( CMAKE_SIZEOF_VOID_P EQUAL 8 )
  set(CYRANO_CPPFLAGS "-DCYRANO_ARCH=64")
else( CMAKE_SIZEOF_VOID_P EQUAL 8 )
  set(CYRANO_CPPFLAGS "-DCYRANO_ARCH=32")
endif( CMAKE_SIZEOF_VOID_P EQUAL 8 )

function(check_cyrano_compatibility mat source)
  behaviour_query(behaviour_type
    ${mat} ${source} "--type")
  if(NOT (behaviour_type EQUAL 1))
    set(file_OK OFF PARENT_SCOPE)
  endif(NOT (behaviour_type EQUAL 1))
endfunction(check_cyrano_compatibility)
