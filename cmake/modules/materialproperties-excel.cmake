function(mfront_properties_excel_internal_library mat)
  mfront_properties_standard_library2("Excel${mat}" ${mat} "excel-internal" ${ARGN})
endfunction(mfront_properties_excel_internal_library)

function(mfront_properties_excel_library mat)
  set(mfront_sources "")
  foreach(source ${ARGN})
    list(APPEND mfront_sources "${CMAKE_CURRENT_SOURCE_DIR}/${source}.mfront")
  endforeach(source ${ARGN})
  # install vba file
  set(vba_file "${CMAKE_CURRENT_BINARY_DIR}/excel/src/Excel${mat}.bas")
  add_custom_command(
    OUTPUT  "${vba_file}"
    COMMAND "${MFRONT}"
    ARGS    "--search-path=${CMAKE_SOURCE_DIR}/materials/${mat}/properties"
    ARGS    "--interface=excel" ${mfront_sources}
    DEPENDS ${mfront_sources}
    WORKING_DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}/excel"
    COMMENT "mfront source ${mfront_file}")
  add_custom_target(lib${mat}MaterialProperties.bas ALL
    DEPENDS "${vba_file}")
  install(FILES ${vba_file} DESTINATION "share/mfm/excel")
endfunction(mfront_properties_excel_library mat)
