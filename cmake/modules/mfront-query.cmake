function(behaviour_query res mat search_paths source )
  if(${ARGC} LESS 1)
    message(FATAL_ERROR "behaviour_query: no query specified")
  endif(${ARGC} LESS 1)
  set(SEARCH_PATH_STR "${search_paths}")
  execute_process(COMMAND ${MFRONT_QUERY}
    "--no-gui" "--verbose=quiet"
    ${search_paths}
	${ARGN} ${source}
    RESULT_VARIABLE query_result
    OUTPUT_VARIABLE query_output
    OUTPUT_STRIP_TRAILING_WHITESPACE)
  if( query_result EQUAL 0 )
    string(REGEX REPLACE "\n" ";" query_output "${query_output}")
    set(${res} ${query_output} PARENT_SCOPE)
  else( query_result EQUAL 0 )
    message(WARNING "behaviour_query: call to mfront-query failed for ${source}")
  endif( query_result EQUAL 0 )
endfunction(behaviour_query)
