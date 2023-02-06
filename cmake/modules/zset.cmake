if(ZSET_INSTALL_PATH)
  set(ZSETHOME "${ZSET_INSTALL_PATH}")
else(ZSET_INSTALL_PATH)
  set(ZSETHOME $ENV{ZSETHOME})
endif(ZSET_INSTALL_PATH)

if(ZSETHOME)
  if(CMAKE_SYSTEM_NAME STREQUAL "Linux")
    set(ZSET_CPPFLAGS "-DLinux")
  else(CMAKE_SYSTEM_NAME STREQUAL "Linux")
    message(FATAL_ERROR "The zmat interface is only supported under linux")
  endif(CMAKE_SYSTEM_NAME STREQUAL "Linux")
  find_path(ZSET_INCLUDE_DIR Behavior.h
    HINTS ${ZSETHOME}/include)
  if(ZSET_INCLUDE_DIR STREQUAL "ZSET_INCLUDE_DIR-NOTFOUND")
    message(FATAL_ERROR "Behavior.h not found")
  endif(ZSET_INCLUDE_DIR STREQUAL "ZSET_INCLUDE_DIR-NOTFOUND")
  message(STATUS "ZSET include files path detected: [${ZSET_INCLUDE_DIR}].")
else(ZSETHOME)
  message(FATAL_ERROR "no ZSETHOME defined")
endif(ZSETHOME)

function(check_zmat_compatibility mat search_paths source)
  mfront_query(behaviour_type
    ${mat} "${search_paths}" ${source} "--type")
  if(behaviour_type STREQUAL "1")
    # strain based behaviour, do nothing
  elseif(behaviour_type STREQUAL "2")
    # finite strain behaviour, do nothing
  else(behaviour_type STREQUAL "1")
    # unsupported behaviour type
    set(compatibility_failure
        "unsupported behaviour type" PARENT_SCOPE)
    set(file_OK OFF PARENT_SCOPE)
  endif(behaviour_type STREQUAL "1")    
  if(file_OK)
    mfront_behaviour_check_temperature_is_first_external_state_variable(${mat} "${search_paths}" ${source})
    if(NOT file_OK)
      set(file_OK OFF PARENT_SCOPE)
      set(compatibility_failure "${compatibility_failure}" PARENT_SCOPE)
    endif(NOT file_OK)
  endif(file_OK)
endfunction(check_zmat_compatibility)
