if( CMAKE_SIZEOF_VOID_P EQUAL 8 )
  set(ASTER_CPPFLAGS "-DASTER_ARCH=64")
else( CMAKE_SIZEOF_VOID_P EQUAL 8 )
  set(ASTER_CPPFLAGS "-DASTER_ARCH=32")
endif( CMAKE_SIZEOF_VOID_P EQUAL 8 )

function(check_aster_compatibility mat search_paths source)
  behaviour_query(behaviour_type
    ${mat} "${search_paths}" ${source} "--type")
  if(behaviour_type STREQUAL "1")
    # strain based behaviour, do nothing
  elseif(behaviour_type STREQUAL "2")
    # finite strain behaviour, do nothing
  elseif(behaviour_type STREQUAL "3")
    # cohesive zone model, do nothing
  else(behaviour_type STREQUAL "1")
    # unsupported behaviour type
    set(compatibility_failure "unsupported behaviour type" PARENT_SCOPE)
    set(file_OK OFF PARENT_SCOPE)
  endif(behaviour_type STREQUAL "1")    
endfunction(check_aster_compatibility)
