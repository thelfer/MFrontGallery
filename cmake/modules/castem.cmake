function(check_castem_behaviour_compatibility mat search_paths source)
  set(file_OK ON)
  mfront_query(behaviour_type ${mat} "${search_paths}" ${source} "--type")
  if(behaviour_type STREQUAL "1")
    # strain based behaviour, do nothing
  elseif(behaviour_type STREQUAL "2")
    # finite strain behaviour, do nothing
  elseif(behaviour_type STREQUAL "3")
    # cohesive zone model, do nothing
  else(behaviour_type STREQUAL "0")
    mfront_query(gradients ${mat} "${search_paths}" ${source} "--gradients")
    mfront_query(thermodynamic_forces ${mat} "${search_paths}" ${source}
                 "--thermodynamic-forces")
    list(LENGTH gradients nb_gradients)
    list(LENGTH thermodynamic_forces nb_thermodynamic_forces)
    if((nb_gradients EQUAL 0) AND (nb_thermodynamic_forces EQUAL 0))
      # point wise models are supported
    else()
      # unsupported behaviour type
      set(file_OK
          OFF
          PARENT_SCOPE)
      set(compatibility_failure
          "unsupported behaviour type"
          PARENT_SCOPE)
    endif()
  endif(behaviour_type STREQUAL "1")
  if(file_OK)
    mfront_behaviour_check_temperature_is_first_external_state_variable(${mat} "${search_paths}"
                                                       ${source})
    if(NOT file_OK)
      set(file_OK
          OFF
          PARENT_SCOPE)
      set(compatibility_failure
          "${compatibility_failure}"
          PARENT_SCOPE)
    endif(NOT file_OK)
  endif(file_OK)
endfunction(check_castem_behaviour_compatibility)

function(check_castem_model_compatibility mat search_paths source)
  mfront_model_check_temperature_is_first_external_state_variable(${mat} "${search_paths}"
                                                                        ${source})
  if(NOT file_OK)
    set(file_OK OFF PARENT_SCOPE)
    set(compatibility_failure "${compatibility_failure}" PARENT_SCOPE)
  endif(NOT file_OK)
endfunction(check_castem_model_compatibility)

function(getCastemBehaviourName name)
  set(lib
      "${name}Behaviours"
      PARENT_SCOPE)
endfunction(getCastemBehaviourName)

function(getCastem21BehaviourName name)
  set(lib
      "${name}Behaviours-Cast3M21"
      PARENT_SCOPE)
endfunction(getCastem21BehaviourName)

function(getCastemModelName name)
  set(lib
      "${name}Models"
      PARENT_SCOPE)
endfunction(getCastemModelName)

if(CASTEM_INSTALL_PATH)
  set(CASTEMHOME "${CASTEM_INSTALL_PATH}")
else(CASTEM_INSTALL_PATH)
  set(CASTEMHOME $ENV{CASTEMHOME})
endif(CASTEM_INSTALL_PATH)

if(enable-castem-pleiades AND (NOT UNIX))
  message(FATAL "castem pleiades may only be used on linux")
endif(enable-castem-pleiades AND (NOT UNIX))

message(STATUS "looking for the castem.h header.")
option(enable-castem-pleiades "use a pleiades version of castem" OFF)

find_path(CASTEM_HEADER castem.h HINTS ${TFEL_INCLUDE_PATH})

if(CASTEM_HEADER STREQUAL "CASTEM_HEADER-NOTFOUND")
  if(CASTEMHOME)
    find_path(CASTEM_INCLUDE_DIR castem.h HINTS ${CASTEMHOME}/include
                                                ${CASTEMHOME}/include/c)
    if(CASTEM_INCLUDE_DIR STREQUAL "CASTEM_INCLUDE_DIR-NOTFOUND")
      message(FATAL_ERROR "castem.h not found")
    endif(CASTEM_INCLUDE_DIR STREQUAL "CASTEM_INCLUDE_DIR-NOTFOUND")
    message(
      STATUS "Cast3M include files path detected: [${CASTEM_INCLUDE_DIR}].")
  else(CASTEMHOME)
    message(FATAL_ERROR "no CASTEMHOME defined")
  endif(CASTEMHOME)
endif(CASTEM_HEADER STREQUAL "CASTEM_HEADER-NOTFOUND")

option(enable-castem-tests "enable tests based on the castem solver" OFF)
if(enable-castem-tests)
  message(STATUS "enabling Cast3M tests")
  if(CASTEM_VERSION)
    set(castem_supported_versions ${CASTEM_VERSION})
  else(CASTEM_VERSION)
    set(castem_supported_versions
        10 12 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30)
  endif(CASTEM_VERSION)
  message(STATUS "looking for the Cast3M executable.")
  if(enable-castem-pleiades)
    if(NOT CASTEMHOME)
      message(FATAL_ERROR "The CASTEHOME variable is not set. This is required when using the pleiades version of castem."
	          "Please set the CASTEM_INSTALL_PATH variable of define the CASTEMHOME environment variable")      
    endif(NOT CASTEMHOME)    
    foreach(cversion ${castem_supported_versions})
      file(GLOB castem20${cversion}s
           "${CASTEMHOME}/bin/castem*${cversion}*_PLEIADES")
      foreach(cexe ${castem20${cversion}s})
        if(castem_executable)
          if(NOT (${castem_executable} STREQUAL ${cexe}))
            message(FATAL "multiple castem executable found")
          endif(NOT (${castem_executable} STREQUAL ${cexe}))
        endif(castem_executable)
        set(castem_executable ${cexe})
        set(castem_version ${cversion})
      endforeach(cexe ${castem20${cversion}s})
    endforeach(cversion ${castem_supported_versions})
  else(enable-castem-pleiades)
    foreach(cversion ${castem_supported_versions})
      if(CASTEMHOME)
        file(GLOB castem${cversion}s "${CASTEMHOME}/bin/castem${cversion}*")
        foreach(cexe ${castem${cversion}s})
          if(castem_executable)
            if(NOT (${castem_executable} STREQUAL ${cexe}))
              message(FATAL "multiple castem executable found")
            endif(NOT (${castem_executable} STREQUAL ${cexe}))
          endif(castem_executable)
          set(castem_executable ${cexe})
          set(castem_version ${cversion})
        endforeach(cexe ${castem${cversion}s})
      else(CASTEMHOME)
        unset(cexe CACHE)
        find_program(cexe NAMES castem${cversion} NO_CACHE)
        if(NOT cexe STREQUAL "cexe-NOTFOUND")
          if(castem_executable)
            if(NOT (${castem_executable} STREQUAL ${cexe}))
              message(FATAL "multiple castem executable found")
            endif(NOT (${castem_executable} STREQUAL ${cexe}))
          endif(castem_executable)
          set(castem_executable ${cexe})
          set(castem_version ${cversion})
        endif(NOT cexe STREQUAL "cexe-NOTFOUND")
      endif(CASTEMHOME)
    endforeach(cversion ${castem_supported_versions})
  endif(enable-castem-pleiades)
  if(castem_executable)
    message(STATUS "found castem executable ${castem_executable}")
  else(castem_executable)
    message(FATAL_ERROR "no suitable version of the Cast3M executable found")
  endif(castem_executable)
endif(enable-castem-tests)
