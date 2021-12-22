set(ANSYS_CPPFLAGS)
function(check_ansys_compatibility mat search_paths source)
  behaviour_query(behaviour_type
    ${mat} "${search_paths}" ${source} "--type")
  if(behaviour_type STREQUAL "1")
    # strain based behaviour, do nothing
  elseif(behaviour_type STREQUAL "2")
    # finite strain behaviour, do nothing
  else(behaviour_type STREQUAL "1")
    # unsupported behaviour type
    set(file_OK OFF PARENT_SCOPE)
  endif(behaviour_type STREQUAL "1")    
  if(file_OK)
    behaviour_query(modelling_hypotheses
      ${mat} "${search_paths}" ${source} "--supported-modelling-hypotheses")
    # creating a cmake list
    separate_arguments(modelling_hypotheses)
    list(LENGTH modelling_hypotheses nb_modelling_hypotheses)
    if(nb_modelling_hypotheses EQUAL 0)
      set(file_OK OFF PARENT_SCOPE)
    endif(nb_modelling_hypotheses EQUAL 0)
    set(_external_state_variable_test OFF)
    foreach(h ${modelling_hypotheses})
      behaviour_query(external_state_variables
        ${mat} "${search_paths}" ${source} 
        "--modelling-hypothesis=${h}"
        "--external-state-variables")
      list(LENGTH external_state_variables nb_external_state_variables)
      if(nb_external_state_variables EQUAL 1)
        set(_external_state_variable_test ON)
      endif(nb_external_state_variables EQUAL 1)
    endforeach(h ${modelling_hypotheses})
    if(NOT _external_state_variable_test)
      set(file_OK OFF PARENT_SCOPE)
    endif()
  endif(file_OK)
endfunction(check_ansys_compatibility)

function(getAnsysBehaviourName name)
  string(TOUPPER "${name}" uname)
  set(lib "${uname}ANSYSBEHAVIOURS" PARENT_SCOPE)
endfunction(getAnsysBehaviourName)
