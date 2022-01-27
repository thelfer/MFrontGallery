function(behaviour_query res mat search_paths source )
  if(${ARGC} LESS 1)
    message(FATAL_ERROR "behaviour_query: no query specified")
  endif(${ARGC} LESS 1)
  set(mfront_query_args)
  list(APPEND mfront_query_args "--no-gui")
  list(APPEND mfront_query_args "--verbose=quiet")
  if(search_paths)
    list(APPEND mfront_query_args ${search_paths})
  endif(search_paths)
  list(APPEND mfront_query_args ${ARGN})
  list(APPEND mfront_query_args ${source})
  execute_process(COMMAND ${MFRONT_QUERY}
    ${mfront_query_args}
    RESULT_VARIABLE query_result
    OUTPUT_VARIABLE query_output
    OUTPUT_STRIP_TRAILING_WHITESPACE)
  if( query_result EQUAL 0 )
    string(REGEX REPLACE "\n" ";" query_output "${query_output}")
    set(${res} ${query_output} PARENT_SCOPE)
  else( query_result EQUAL 0 )
    message(WARNING "behaviour_query: call to mfront-query failed for ${source} (${MFRONT_QUERY} ${mfront_query_args})")
  endif( query_result EQUAL 0 )
endfunction(behaviour_query)
