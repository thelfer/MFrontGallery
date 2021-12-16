if( CMAKE_SIZEOF_VOID_P EQUAL 8 )
  set(CYRANO_CPPFLAGS "-DCYRANO_ARCH=64")
else( CMAKE_SIZEOF_VOID_P EQUAL 8 )
  set(CYRANO_CPPFLAGS "-DCYRANO_ARCH=32")
endif( CMAKE_SIZEOF_VOID_P EQUAL 8 )

function(check_cyrano_compatibility mat search_paths source)
  behaviour_query(modelling_hypotheses
    ${mat} "${search_paths}" ${source} "--supported-modelling-hypotheses")
  separate_arguments(modelling_hypotheses)
  list(FIND modelling_hypotheses "AxisymmetricalGeneralisedPlaneStrain"
    agpstrain)
  list(FIND modelling_hypotheses "AxisymmetricalGeneralisedPlaneStress"
    agpstress)
  if((agpstress EQUAL -1) AND (agpstrain EQUAL -1))
    set(file_OK OFF PARENT_SCOPE)
  else((agpstress EQUAL -1) AND (agpstrain EQUAL -1))
    behaviour_query(behaviour_type
      ${mat} "${search_paths}" ${source} "--type")
    if(NOT (behaviour_type STREQUAL "1"))
      set(file_OK OFF PARENT_SCOPE)
    else(NOT (behaviour_type STREQUAL "1"))
      behaviour_query(behaviour_has_strain_measure
        ${mat} "${search_paths}" ${source} "--is-strain-measure-defined")
      if(behaviour_has_strain_measure STREQUAL "true")
	    behaviour_query(behaviour_strain_measure
	      ${mat} "${search_paths}" ${source} "--strain-measure")
	if(behaviour_strain_measure STREQUAL "Linearised")
    elseif(behaviour_strain_measure STREQUAL "Hencky")
	else(behaviour_strain_measure STREQUAL "Linearised")
	  set(file_OK OFF PARENT_SCOPE)
	endif(behaviour_strain_measure STREQUAL "Linearised")
      endif(behaviour_has_strain_measure STREQUAL "true")
    endif(NOT (behaviour_type STREQUAL "1"))
  endif((agpstress EQUAL -1) AND (agpstrain EQUAL -1))
endfunction(check_cyrano_compatibility)
