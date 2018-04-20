set(ANSYS_CPPFLAGS)
function(check_ansys_compatibility mat source)
  behaviour_query(modelling_hypotheses
    ${mat} ${source} "--supported-modelling-hypotheses")
  # creating a cmake list
  separate_arguments(modelling_hypotheses)
  list(LENGTH modelling_hypotheses nb_modelling_hypotheses)
  if(nb_modelling_hypotheses EQUAL 0)
    set(file_OK OFF PARENT_SCOPE)
  endif(nb_modelling_hypotheses EQUAL 0)
  foreach(h ${modelling_hypotheses})
    behaviour_query(external_state_variables
      ${mat} ${source} 
      "--modelling-hypothesis=${h}"
      "--external-state-variables")
    list(LENGTH external_state_variables nb_external_state_variables)
    if(NOT (nb_external_state_variables EQUAL 1))
      set(file_OK OFF PARENT_SCOPE)
    endif(NOT (nb_external_state_variables EQUAL 1))
  endforeach(h ${modelling_hypotheses})
endfunction(check_ansys_compatibility)

function(getAnsysBehaviourName name)
  string(TOUPPER "${name}" uname)
  set(lib "${uname}ANSYSBEHAVIOURS" PARENT_SCOPE)
endfunction(getAnsysBehaviourName)
