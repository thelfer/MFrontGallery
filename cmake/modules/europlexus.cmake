set(EUROPLEXUS_CPPFLAGS)
function(check_europlexus_compatibility mat source)
  behaviour_query(behaviour_type
    ${mat} ${source} "--type")
  if(NOT (behaviour_type STREQUAL "2"))
    set(file_OK OFF PARENT_SCOPE)
  endif(NOT (behaviour_type STREQUAL "2"))    
endfunction(check_europlexus_compatibility)

