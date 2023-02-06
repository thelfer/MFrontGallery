set(CALCULIX_CPPFLAGS)
function(check_calculix_compatibility mat search_paths source)
  mfront_query(behaviour_type
    ${mat} "${search_paths}" ${source} "--type")
  if(behaviour_type STREQUAL "1")
    # strain based behaviour, do nothing
  elseif(behaviour_type STREQUAL "2")
    # finite strain behaviour, do nothing
  else(behaviour_type STREQUAL "1")
    # unsupported behaviour type
    set(compatibility_failure "unsupported behaviour type" PARENT_SCOPE)
    set(file_OK OFF PARENT_SCOPE)
  endif(behaviour_type STREQUAL "1")    
  if(file_OK)
    mfront_behaviour_check_temperature_is_first_external_state_variable(${mat} "${search_paths}" ${source})
    if(NOT file_OK)
      set(file_OK OFF PARENT_SCOPE)
      set(compatibility_failure "${compatibility_failure}" PARENT_SCOPE)
    endif(NOT file_OK)
  endif(file_OK)
  if(file_OK)
    mfront_query(modelling_hypotheses
      ${mat} "${search_paths}" ${source} "--supported-modelling-hypotheses")
    # creating a cmake list
    separate_arguments(modelling_hypotheses)
    list(FIND modelling_hypotheses "Tridimensional" tridimensional_found)
    if(tridimensional_found EQUAL -1)
      set(compatibility_failure
          "tridimensional modelling hypothesis not supported" PARENT_SCOPE)
      set(file_OK OFF PARENT_SCOPE)
    else(tridimensional_found EQUAL -1)
      mfront_query(external_state_variables
        ${mat} "${search_paths}" ${source}
        "--modelling-hypothesis=Tridimensional"
        "--external-state-variables")
      list(LENGTH external_state_variables nb_external_state_variables)
      if(NOT (nb_external_state_variables EQUAL 1))
        set(msg "behaviours with external state variable other ")
        set(msg "${msg} than the temperature are not supported")
        set(compatibility_failure ${msg} PARENT_SCOPE)
        set(file_OK OFF PARENT_SCOPE)
      endif(NOT (nb_external_state_variables EQUAL 1))
    endif(tridimensional_found EQUAL -1)
  endif(file_OK)
endfunction(check_calculix_compatibility)

function(getCalculiXBehaviourName name)
  string(TOUPPER "${name}" uname)
  set(lib "${uname}CALCULIXBEHAVIOURS" PARENT_SCOPE)
endfunction(getCalculiXBehaviourName)
