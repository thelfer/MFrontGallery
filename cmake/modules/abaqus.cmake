set(ABAQUS_CPPFLAGS)

function(check_abaqus_compatibility mat search_paths source)
  behaviour_query(behaviour_type
    ${mat} "${search_paths}" ${source} "--type")
  if(behaviour_type STREQUAL "2")
    # finite strain behaviour, do nothing
  elseif(behaviour_type STREQUAL "1")
    # strain based behaviour, check if a strain measure is defined
    behaviour_query(behaviour_has_strain_measure
      ${mat} "${search_paths}" ${source} "--is-strain-measure-defined")
    if(behaviour_has_strain_measure STREQUAL "true")
      behaviour_query(behaviour_strain_measure
        ${mat} "${search_paths}" ${source} "--strain-measure")
      if(behaviour_strain_measure STREQUAL "Linearised")
	# small strain behaviours are not supported, skipping
      endif(behaviour_strain_measure STREQUAL "Linearised")
    else(behaviour_has_strain_measure STREQUAL "true")
      # no strain measure defined, skipping
    endif(behaviour_has_strain_measure STREQUAL "true")
  else(behaviour_type STREQUAL "2")
    # unsupported behaviour type
    set(file_OK OFF PARENT_SCOPE)
    set(compatibility_failure "unsupported behaviour type" PARENT_SCOPE)
  endif(behaviour_type STREQUAL "2")    
  if(file_OK)
    check_temperature_is_first_external_state_variable(${mat} "${search_paths}" ${source})
    if(NOT file_OK)
      set(file_OK OFF PARENT_SCOPE)
      set(compatibility_failure "${compatibility_failure}" PARENT_SCOPE)
    endif(NOT file_OK)
  endif(file_OK)
endfunction(check_abaqus_compatibility)

function(getAbaqusBehaviourName name)
  string(TOUPPER "${name}" uname)
  set(lib "${uname}ABAQUSBEHAVIOURS" PARENT_SCOPE)
endfunction(getAbaqusBehaviourName)

