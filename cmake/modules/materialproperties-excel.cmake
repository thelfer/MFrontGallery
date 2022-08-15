function(mfront_properties_excel_internal_library mat)
  mfront_properties_standard_library2("Excel${mat}" ${mat} "excel-internal" ${ARGN})
endfunction(mfront_properties_excel_internal_library)

function(mfront_properties_excel_library mat)
  parse_mfront_library_sources(${ARGN})
  if(EXISTS ${CMAKE_SOURCE_DIR}/materials/${mat})
    list(APPEND mfront_search_paths 
      "--search-path=${CMAKE_SOURCE_DIR}/materials/${mat}/properties")
  endif(EXISTS ${CMAKE_SOURCE_DIR}/materials/${mat})
  list(APPEND mfront_search_paths 
      "--search-path=${CMAKE_CURRENT_SOURCE_DIR}")
  list(TRANSFORM mfront_sources PREPEND "${CMAKE_CURRENT_SOURCE_DIR}/")
  list(TRANSFORM mfront_sources APPEND ".mfront")
  set(mfront_args)
  list(APPEND mfront_args ${mfront_search_paths})
  get_material_property_dsl_options("excel")
  if(mfront_dsl_options)
    list(APPEND mfront_args ${mfront_dsl_options})
  endif(mfront_dsl_options)
  list(APPEND mfront_args "--interface=excel")
  list(APPEND mfront_args ${mfront_sources})
  # install vba file
  set(vba_file "${CMAKE_CURRENT_BINARY_DIR}/excel/src/Excel${mat}.bas")
  add_custom_command(
    OUTPUT  "${vba_file}"
    COMMAND "${MFRONT}"
    ARGS    ${mfront_args}
    DEPENDS ${mfront_sources}
    WORKING_DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}/excel"
    COMMENT "mfront source ${mfront_file}")
  add_custom_target(lib${mat}MaterialProperties.bas ALL
    DEPENDS "${vba_file}")
  install(FILES ${vba_file} DESTINATION "share/mfm/excel")
endfunction(mfront_properties_excel_library mat)
