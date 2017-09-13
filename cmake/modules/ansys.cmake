set(ANSYS_CPPFLAGS)
function(check_ansys_compatibility mat source)
  behaviour_query(external_state_variables
    ${mat} ${source} "--external-state-variables")
  list(LENGTH external_state_variables nb_external_state_variables)
  if(NOT (nb_external_state_variables EQUAL 1))
    set(file_OK OFF PARENT_SCOPE)
  endif(NOT (nb_external_state_variables EQUAL 1))
endfunction(check_ansys_compatibility)
