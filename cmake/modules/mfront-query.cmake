function(behaviour_query res mat source )
  if(${ARGC} LESS 1)
    message(FATAL_ERROR "behaviour_query: no query specified")
  endif(${ARGC} LESS 1)
  execute_process(COMMAND ${MFRONT_QUERY}
    "--verbose=quiet"
    "--search-path=${CMAKE_SOURCE_DIR}/materials/${mat}/properties"
    "--search-path=${CMAKE_SOURCE_DIR}/materials/${mat}/behaviours"
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
