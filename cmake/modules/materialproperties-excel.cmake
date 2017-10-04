macro(mfront_properties_excel_internal_library mat)
  set(lib "Excel${mat}")
  set(mfront_sources)
  foreach(source ${ARGN})
    set(mfront_file   "${CMAKE_CURRENT_SOURCE_DIR}/${source}.mfront")
    list(APPEND mfront_sources ${mfront_file})
    set(mfront_output1 "excel/include/${source}-Excel.hxx")
    set(mfront_output2 "excel/src/${source}-Excel.cxx")
    add_custom_command(
      OUTPUT  "${mfront_output1}"
      OUTPUT  "${mfront_output2}"
      COMMAND "${MFRONT}"
      ARGS    "--search-path=${CMAKE_SOURCE_DIR}/materials/${mat}/properties"
      ARGS    "--interface=excel-internal" "${mfront_file}"
      DEPENDS "${mfront_file}"
      WORKING_DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}/excel"
      COMMENT "mfront source ${mfront_file}")
    set(${lib}_SOURCES ${mfront_output2} ${${lib}_SOURCES})
  endforeach(source)
  foreach(deps ${${mat}_mfront_properties_dependencies_excel_SOURCES})
    set(${lib}_SOURCES ${deps} ${${lib}_SOURCES})
  endforeach(deps ${${mat}_mfront_properties_dependencies_excel_SOURCES})
  message(STATUS "Adding library : ${lib} (${${lib}_SOURCES})")
  if(MSVC)
    set(mfront_def_file "${CMAKE_CURRENT_BINARY_DIR}/excel/src/lib${lib}.def")
    add_custom_command(
      OUTPUT  "${mfront_def_file}"
      COMMAND "${MFRONT}"
      ARGS    "--def-file=${lib}"
      ARGS    "--search-path=${CMAKE_SOURCE_DIR}/materials/${mat}/properties"
      ARGS    "--interface=excel-internal" ${mfront_sources}
      DEPENDS ${mfront_sources}
      WORKING_DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}/excel"
      COMMENT "mfront def file ${mfront_def_file}")
  endif(MSVC)
  add_library(${lib} SHARED ${${lib}_SOURCES})
  if(MSVC)
    add_custom_target(${lib}_def DEPENDS ${mfront_def_file})
    add_dependencies(${lib} ${lib}_def)
    add_link_flags(${lib} "/DEF:${mfront_def_file}")
  endif(MSVC)
  if((CMAKE_HOST_WIN32) AND (NOT MSYS))  
    set_target_properties(${lib} PROPERTIES PREFIX "lib")
  endif((CMAKE_HOST_WIN32) AND (NOT MSYS))  
  target_include_directories(${lib}
    PRIVATE "${CMAKE_CURRENT_BINARY_DIR}/excel/include"
    PRIVATE "${TFEL_INCLUDE_PATH}")
  if(WIN32)
    if(${CMAKE_CXX_COMPILER_ID} STREQUAL "GNU")
      set_target_properties(${lib}
	PROPERTIES LINK_FLAGS "-Wl,--kill-at -Wl,--no-undefined")
    endif(${CMAKE_CXX_COMPILER_ID} STREQUAL "GNU")
    install(TARGETS ${lib} DESTINATION bin)
  else(WIN32)
    install(TARGETS ${lib} DESTINATION lib${LIB_SUFFIX})
  endif(WIN32)
endmacro(mfront_properties_excel_internal_library mat)

macro(mfront_properties_excel_library mat)
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
endmacro(mfront_properties_excel_library mat)
