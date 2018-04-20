set(CALCULIX_CPPFLAGS)
function(check_calculix_compatibility mat source)
  behaviour_query(modelling_hypotheses
    ${mat} ${source} "--supported-modelling-hypotheses")
  # creating a cmake list
  separate_arguments(modelling_hypotheses)
  list(FIND modelling_hypotheses "Tridimensional" tridimensional_found)
  if(tridimensional_found EQUAL -1)
    set(file_OK OFF PARENT_SCOPE)
  else(tridimensional_found EQUAL -1)
    behaviour_query(external_state_variables
      ${mat} ${source}
      "--modelling-hypothesis=Tridimensional"
      "--external-state-variables")
    list(LENGTH external_state_variables nb_external_state_variables)
    if(NOT (nb_external_state_variables EQUAL 1))
      set(file_OK OFF PARENT_SCOPE)
    endif(NOT (nb_external_state_variables EQUAL 1))
  endif(tridimensional_found EQUAL -1)
endfunction(check_calculix_compatibility)

function(getCalculiXBehaviourName name)
  string(TOUPPER "${name}" uname)
  set(lib "${uname}CALCULIXBEHAVIOURS" PARENT_SCOPE)
endfunction(getCalculiXBehaviourName)
