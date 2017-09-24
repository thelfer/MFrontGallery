set(ABAQUS_EXPLICIT_CPPFLAGS)
function(check_abaqus_explicit_compatibility mat source)
  behaviour_query(behaviour_type
    ${mat} ${source} "--type")
  if(NOT (behaviour_type STREQUAL "2"))
    set(file_OK OFF PARENT_SCOPE)
  endif(NOT (behaviour_type STREQUAL "2"))    
endfunction(check_abaqus_explicit_compatibility)

function(getAbaqusExplicitBehaviourName name)
  string(TOUPPER "${name}" uname)
  set(lib "${uname}ABAQUSEXPLICITBEHAVIOURS" PARENT_SCOPE)
endfunction(getAbaqusExplicitBehaviourName)
