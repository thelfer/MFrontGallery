function(behaviour_query res mat source query)
  execute_process(COMMAND ${MFRONT_QUERY}
    "--verbose=quiet"
    "--search-path=${CMAKE_SOURCE_DIR}/materials/${mat}/properties"
    "--search-path=${CMAKE_SOURCE_DIR}/materials/${mat}/behaviours"
    ${query} ${source}
    OUTPUT_VARIABLE query_output
    OUTPUT_STRIP_TRAILING_WHITESPACE)
  string(REGEX REPLACE "\n" ";" query_output "${query_output}")
  set(${res} ${query_output} PARENT_SCOPE)
endfunction(behaviour_query)