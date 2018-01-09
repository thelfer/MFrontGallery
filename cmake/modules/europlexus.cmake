set(EUROPLEXUS_CPPFLAGS)
function(check_europlexus_compatibility mat source)
  behaviour_query(behaviour_type
    ${mat} ${source} "--type")
  if(behaviour_type STREQUAL "2")
    # finite strain behaviour, do nothing
  elseif(behaviour_type STREQUAL "1")
    # strain based behaviour, check if a strain measure is defined
    behaviour_query(behaviour_has_strain_measure
      ${mat} ${source} "--is-strain-measure-defined")
    if(behaviour_has_strain_measure STREQUAL "true")
      behaviour_query(behaviour_strain_measure
	${mat} ${source} "--strain-measure")
      if(behaviour_strain_measure STREQUAL "Linearised")
	# small strain behaviours are not supported, skipping
	set(file_OK OFF PARENT_SCOPE)
      endif(behaviour_strain_measure STREQUAL "Linearised")
    else(behaviour_has_strain_measure STREQUAL "true")
      # no strain measure defined, skipping
      set(file_OK OFF PARENT_SCOPE)
    endif(behaviour_has_strain_measure STREQUAL "true")
  else(behaviour_type STREQUAL "2")
    # unsupported behaviour type
    set(file_OK OFF PARENT_SCOPE)
  endif(behaviour_type STREQUAL "2")    
endfunction(check_europlexus_compatibility)

