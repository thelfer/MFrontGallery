function(mfront_model_check_temperature_is_first_external_state_variable mat search_paths
         source)
  set(_external_state_variable_test OFF)
  mfront_query(external_state_variables ${mat} "${search_paths}" ${source}
               "--external-state-variables")
  list(LENGTH external_state_variables nb_external_state_variables)
  if(nb_external_state_variables GREATER 0)
    list(GET external_state_variables 0 first_external_state_variable)
    string(FIND "${first_external_state_variable}" "- Temperature" out)
    if(${out} EQUAL 0)
      set(_external_state_variable_test ON)
    endif()
  endif(nb_external_state_variables GREATER 0)
  if(NOT _external_state_variable_test)
    set(msg "temperature is not the first external state variable")
    set(compatibility_failure
        ${msg}
        PARENT_SCOPE)
    set(file_OK
        OFF
        PARENT_SCOPE)
  else()
    set(file_OK ON PARENT_SCOPE)
  endif()
endfunction(mfront_model_check_temperature_is_first_external_state_variable)

# ! get_mfront_model_library_name: this function returns the name of the
# library generated for the given material or phenomenon for the given interface
#
# \param: mat name of a material or the name of phenomenon
# \param: interface interface used
function(get_mfront_model_library_name mat interface)
  if(${interface} STREQUAL "castem")
    getcastemmodelname(${mat})
  elseif(${interface} STREQUAL "castem21")
    getcastem21modelname(${mat})
  else()
    set(lib "${mat}Models-${interface}")
  endif()
  set(mfront_model_library_name
      ${lib}
      PARENT_SCOPE)
endfunction(get_mfront_model_library_name)

function(add_mfront_model_source lib mat interface search_paths mfront_path)
  check_model_compatibility(${mat} ${interface} "${search_paths}"
                                ${mfront_path})
  if(file_OK)
    get_model_dsl_options(${interface})
    get_mfront_generated_sources(${mat} ${interface} "${search_paths}"
                                 "${mfront_dsl_options}" ${mfront_path})
    list(TRANSFORM mfront_generated_sources
         PREPEND "${CMAKE_CURRENT_BINARY_DIR}/${interface}/src/")
    list(APPEND ${lib}_SOURCES ${mfront_generated_sources})
    list(REMOVE_DUPLICATES ${lib}_SOURCES)
    set(${lib}_SOURCES
        ${${lib}_SOURCES}
        PARENT_SCOPE)
    string(FIND "${mfront_path}" "madnex:" test_madnex_path)
    if(NOT "${test_madnex_path}" EQUAL 0)
      install_mfront("${mfront_path}" ${mat} models)
    endif()
  else(file_OK)
    set(msg "${mfront_path} has been discarded for interface ${interface}")
    if(compatibility_failure)
      set(msg "${msg} (${compatibility_failure})")
    endif()
    message(STATUS "${msg}")
  endif(file_OK)
  set(file_OK
      ${file_OK}
      PARENT_SCOPE)
endfunction(add_mfront_model_source)

#! add_mfront_model_sources : 
function(add_mfront_model_sources lib mat interface search_paths file)
  get_mfront_source_location(${file})
  if(NOT mfront_path)
    list(APPEND ${lib}_OTHER_SOURCES "${file}")
    set(${lib}_OTHER_SOURCES
        ${${lib}_OTHER_SOURCES}
        PARENT_SCOPE)
  else()
    if(madnex_file)
      if(TFEL_MADNEX_SUPPORT)
        mfront_query(_impls ${mat} "${search_paths}" ${mfront_path}
                     "--all-models" "--list-implementation-paths=unsorted")
        if(_impls)
          string(REPLACE " " ";" _mfront_impls ${_impls})
        else(_impls)
          set(_mfront_impls)
        endif(_impls)
        set(append_file OFF)
        foreach(_impl ${_mfront_impls})
          add_mfront_model_source(${lib} ${mat} ${interface}
                                      "${search_paths}" ${_impl})
          if(file_OK)
            set(append_file ON)
            list(APPEND ${lib}_MFRONT_IMPLEMENTATION_PATHS ${_impl})
            set(${lib}_MFRONT_IMPLEMENTATION_PATHS
                ${${lib}_MFRONT_IMPLEMENTATION_PATHS}
                PARENT_SCOPE)
          endif(file_OK)
        endforeach(_impl ${impls})
        if(append_file)
          list(APPEND ${lib}_MFRONT_SOURCES ${mfront_path})
          set(${lib}_MFRONT_SOURCES
              ${${lib}_MFRONT_SOURCES}
              PARENT_SCOPE)
        endif(append_file)
      else(TFEL_MADNEX_SUPPORT)
        message(STATUS "file '${file}' has been discarded since "
                       "madnex support has not been enabled")
      endif(TFEL_MADNEX_SUPPORT)
    else()
      add_mfront_model_source(${lib} ${mat} ${interface} "${search_paths}"
                                  ${mfront_path})
      if(file_OK)
        list(APPEND ${lib}_MFRONT_SOURCES ${mfront_path})
        set(${lib}_MFRONT_SOURCES
            ${${lib}_MFRONT_SOURCES}
            PARENT_SCOPE)
        list(APPEND ${lib}_MFRONT_IMPLEMENTATION_PATHS ${mfront_path})
        set(${lib}_MFRONT_IMPLEMENTATION_PATHS
            ${${lib}_MFRONT_IMPLEMENTATION_PATHS}
            PARENT_SCOPE)
      endif(file_OK)
    endif()
    set(${lib}_SOURCES
        ${${lib}_SOURCES}
        PARENT_SCOPE)
  endif()
endfunction(add_mfront_model_sources)

#function(add_mfront_model_sources lib interface search_paths mfront_file)
#  get_model_dsl_options(${interface})
#  get_mfront_generated_sources(${lib} ${interface} "${search_paths}"
#                                 "${mfront_dsl_options}" ${mfront_file})
#  list(TRANSFORM mfront_generated_sources
#       PREPEND "${CMAKE_CURRENT_BINARY_DIR}/${interface}/src/")
#  _get_mfront_command_line_arguments()
#  set(mfront_args )
#  list(APPEND mfront_args ${mfront_command_line_arguments})
#  list(APPEND mfront_args ${search_paths})
#  if(mfront_dsl_options)
#    list(APPEND mfront_args ${mfront_dsl_options})
#  endif(mfront_dsl_options)
#  list(APPEND mfront_args "--interface=${interface}")
#  list(APPEND mfront_args "${mfront_file}")
#  add_custom_command(
#    OUTPUT  ${mfront_generated_sources}
#    COMMAND "${MFRONT}"
#    ARGS    ${mfront_args}
#    DEPENDS "${mfront_file}"
#    WORKING_DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}/${interface}"
#    COMMENT "mfront source ${mfront_file}")
#  list(APPEND ${lib}_SOURCES ${mfront_generated_sources})
#  list(REMOVE_DUPLICATES ${lib}_SOURCES)
#  set(${lib}_SOURCES ${${lib}_SOURCES} PARENT_SCOPE)
#  if(${${interface}_SPECIFIC_DEFINITIONS})
#    set_source_files_properties(${mfront_output}
#      PROPERTIES COMPILE_FLAGS
#      ${${interface}_SPECIFIC_DEFINITIONS})
#  endif(${${interface}_SPECIFIC_DEFINITIONS})
#endfunction(add_mfront_model_sources)

function(check_model_compatibility mat interface search_paths mfront_file)
  set(file_OK ON)
  set(compatibility_failure)
  if(${interface} STREQUAL "castem")
    check_castem_model_compatibility(${mat} "${search_paths}" ${mfront_file})
  elseif(${interface} STREQUAL "generic")
  else()
    message(FATAL_ERROR "unsupported interface ${interface}")
  endif()
  set(file_OK ${file_OK} PARENT_SCOPE)
  set(compatibility_failure ${compatibility_failure} PARENT_SCOPE)
endfunction(check_model_compatibility)

function(mfront_models_library mat)
  if((TFEL_CXX_STANDARD GREATER 17) OR (TFEL_CXX_STANDARD EQUAL 17))
    set(TFEL_MFRONT_LIBRARIES
        "${TFELException};${TFELMath};${TFELMaterial};${TFELUtilities}")
  else((TFEL_CXX_STANDARD GREATER 17) OR (TFEL_CXX_STANDARD EQUAL 17))
    set(TFEL_MFRONT_LIBRARIES
        "${TFELException};${TFELMath};${TFELMaterial};${TFELUtilities};${TFELPhysicalConstants}"
    )
  endif((TFEL_CXX_STANDARD GREATER 17) OR (TFEL_CXX_STANDARD EQUAL 17))
  parse_mfront_library_sources(${ARGN})
  if(EXISTS ${CMAKE_SOURCE_DIR}/materials/${mat})
    list(APPEND mfront_search_paths
         "--search-path=${CMAKE_SOURCE_DIR}/materials/${mat}/properties")
    list(APPEND mfront_search_paths
         "--search-path=${CMAKE_SOURCE_DIR}/materials/${mat}/models")
    list(APPEND mfront_search_paths
         "--search-path=${CMAKE_SOURCE_DIR}/materials/${mat}/models")
  endif(EXISTS ${CMAKE_SOURCE_DIR}/materials/${mat})
  list(APPEND mfront_search_paths "--search-path=${CMAKE_CURRENT_SOURCE_DIR}")
  foreach(source ${mfront_sources})
    set(mfront_file)
    if(EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/${source}.mfront.in")
      set(mfront_file "${CMAKE_CURRENT_BINARY_DIR}/${source}.mfront")
    elseif(EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/${source}.mfront")
      set(mfront_file "${CMAKE_CURRENT_SOURCE_DIR}/${source}.mfront")
    endif(EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/${source}.mfront.in")
#    if(mfront_file)
#      generate_mfront_doc("${mfront_search_paths}" ${mfront_file})
#    endif()
  endforeach()
  foreach(interface ${mfront-models-interfaces})
    get_mfront_model_library_name(${mat} ${interface})
    file(MAKE_DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}/${interface}")
    # list of sources generated from MFront files. Populated by calls to
    # add_mfront_model_sources
    set(${mfront_model_library_name}_SOURCES)
    # list of sources not generated by MFront
    set(${mfront_model_library_name}_OTHER_SOURCES)
    foreach(source ${mfront_sources})
      add_mfront_model_sources(
        ${mfront_model_library_name} ${mat} ${interface}
        "${mfront_search_paths}" ${source})
    endforeach(source ${mfront_sources})
    set(generate_library ON)
    list(LENGTH ${mfront_model_library_name}_SOURCES nb_sources)
    list(LENGTH ${mfront_model_library_name}_OTHER_SOURCES nb_other_sources)
    if(nb_sources EQUAL 0)
      if(nb_other_sources GREATER 0)
        if(NOT generate_without_mfront_sources)
          set(generate_library OFF)
        endif(NOT generate_without_mfront_sources)
      else(nb_other_sources GREATER 0)
        set(generate_library OFF)
      endif(nb_other_sources GREATER 0)
    endif(nb_sources EQUAL 0)
    if(generate_library)
      _get_mfront_model_command_line_arguments()
      set(mfront_args)
      list(APPEND mfront_args ${mfront_model_command_line_arguments})
      list(APPEND mfront_args ${mfront_search_paths})
      list(APPEND mfront_args "--interface=${interface}")
      get_model_dsl_options(${interface})
      if(mfront_dsl_options)
        list(APPEND mfront_args ${mfront_dsl_options})
      endif(mfront_dsl_options)
      list(APPEND mfront_args
           ${${mfront_model_library_name}_MFRONT_IMPLEMENTATION_PATHS})
      add_custom_command(
        OUTPUT ${${mfront_model_library_name}_SOURCES}
        COMMAND "${MFRONT}" ARGS ${mfront_args}
        DEPENDS ${${mfront_model_library_name}_MFRONT_SOURCES}
        WORKING_DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}/${interface}"
        COMMENT
          "mfront sources ${${mfront_model_library_name}_MFRONT_SOURCES} for interface ${interface}"
      )
      set(_all_sources)
      list(APPEND _all_sources ${${mfront_model_library_name}_SOURCES})
      list(APPEND _all_sources
           ${${mfront_model_library_name}_OTHER_SOURCES})
      message(
        STATUS
          "Adding library : ${mfront_model_library_name} (${_all_sources})")
      add_library(${mfront_model_library_name} SHARED ${_all_sources})
      target_include_directories(
        ${mfront_model_library_name}
        PRIVATE "${CMAKE_CURRENT_BINARY_DIR}/${interface}/include"
        PRIVATE "${TFEL_INCLUDE_PATH}")
      if(EXISTS "${CMAKE_SOURCE_DIR}/include")
        target_include_directories(${mfront_model_library_name}
                                   PRIVATE "${CMAKE_SOURCE_DIR}/include")
      endif(EXISTS "${CMAKE_SOURCE_DIR}/include")
      if(mfront_include_directories)
        target_include_directories(${mfront_model_library_name}
                                   PRIVATE ${mfront_include_directories})
      endif()
      if(EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/include")
        target_include_directories(
          ${mfront_model_library_name}
          PRIVATE "${CMAKE_CURRENT_SOURCE_DIR}/include")
      endif(EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/include")
      if((${interface} STREQUAL "castem") OR (${interface} STREQUAL "castem21"))
        if(CASTEMHOME)
          if(enable-castem-pleiades)
            target_include_directories(${mfront_model_library_name}
                                       PRIVATE "${CASTEMHOME}/include")
          else(enable-castem-pleiades)
            target_include_directories(${mfront_model_library_name}
                                       PRIVATE "${CASTEMHOME}/include/c")
          endif(enable-castem-pleiades)
        endif(CASTEMHOME)
      endif((${interface} STREQUAL "castem") OR (${interface} STREQUAL "castem21"))
      mfm_install_library(${mfront_model_library_name})
      if((${interface} STREQUAL "castem") OR (${interface} STREQUAL "castem21"))
        if(CASTEMHOME)
          target_include_directories(${mfront_model_library_name}
                                     PRIVATE "${CASTEMHOME}/include")
        endif(CASTEMHOME)
        if(CASTEM_CPPFLAGS)
          set_target_properties(${mfront_model_library_name}
                                PROPERTIES COMPILE_FLAGS "${CASTEM_CPPFLAGS}")
        endif(CASTEM_CPPFLAGS)
        target_link_libraries(
          ${mfront_model_library_name} PRIVATE ${TFEL_MFRONT_LIBRARIES}
                                                   ${CastemInterface})
      elseif(${interface} STREQUAL "generic")
        target_link_libraries(${mfront_model_library_name}
                              PRIVATE ${TFEL_MFRONT_LIBRARIES})
      else(${interface} STREQUAL "generic")
        message(FATAL_ERROR "mfront_models_library : "
                            "unsupported interface ${interface}")
      endif((${interface} STREQUAL "castem") OR (${interface} STREQUAL "castem21"))
      foreach(_link_library ${mfront_link_libraries})
        target_link_libraries(${mfront_model_library_name}
                              PRIVATE ${_link_library})
      endforeach(_link_library ${mfront_link_libraries})
    else(generate_library)
      if(nb_other_sources GREATER 0)
        message(
          STATUS
            "Only external sources provided for "
            "library ${mfront_model_library_name} for interface ${interface}. "
            "The generation of this library is disabled by default. It can be enabled "
            "by passing the GENERATE_WITHOUT_MFRONT_SOURCES")
      else(nb_other_sources GREATER 0)
        message(
          STATUS
            "No sources selected for "
            "library ${mfront_model_library_name} for interface ${interface}"
        )
      endif(nb_other_sources GREATER 0)
    endif(generate_library)
  endforeach(interface)
endfunction(mfront_models_library)

#function(mfront_models_library mat)
#  parse_mfront_library_sources(${ARGN})
#  if(EXISTS ${CMAKE_SOURCE_DIR}/materials/${mat})
#    list(APPEND mfront_search_paths 
#      "--search-path=${CMAKE_SOURCE_DIR}/materials/${mat}/properties")
#  endif(EXISTS ${CMAKE_SOURCE_DIR}/materials/${mat})
#  list(APPEND mfront_search_paths 
#      "--search-path=${CMAKE_CURRENT_SOURCE_DIR}")
#  if(${ARGC} LESS 1)
#    message(FATAL_ERROR "mfront_models_library : no source specified")
#  endif(${ARGC} LESS 1)
#  foreach(interface ${mfront-models-interfaces})
#    file(MAKE_DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}/${interface}")
#    if(${interface} STREQUAL "castem")
#      getCastemModelName("${mat}")
#      set(mfront_model_library_name "${lib}")
#    else()
#      set(mfront_model_library_name "${mat}Models-${interface}")
#    endif(${interface} STREQUAL "castem")
#    foreach(source ${mfront_sources})
#      add_mfront_model_sources(${mfront_model_library_name} ${mat} ${interface} "${mfront_search_paths}" ${source})
#    endforeach(source)
#    add_library(${mfront_model_library_name} SHARED
#      ${${mfront_model_library_name}_SOURCES})
#    target_include_directories(${mfront_model_library_name}
#        PRIVATE "${CMAKE_CURRENT_BINARY_DIR}/${interface}/include"
#        PRIVATE "${TFEL_INCLUDE_PATH}")
#    if(EXISTS "${CMAKE_SOURCE_DIR}/include")
#      target_include_directories(${mfront_model_library_name}
#          PRIVATE "${CMAKE_SOURCE_DIR}/include")
#    endif(EXISTS "${CMAKE_SOURCE_DIR}/include")
#    if(mfront_include_directories)
#        target_include_directories(${mfront_model_library_name}
#          PRIVATE ${mfront_include_directories})
#    endif()
#    if(EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/include")
#        target_include_directories(${mfront_model_library_name}
#          PRIVATE "${CMAKE_CURRENT_SOURCE_DIR}/include")
#    endif(EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/include")
#    if(${interface} STREQUAL "castem")
#	  if(CASTEMHOME)
#	    if(enable-castem-pleiades)
#	      target_include_directories(${mfront_model_library_name}
#	        PRIVATE "${CASTEMHOME}/include")
#	    else(enable-castem-pleiades)
#	      target_include_directories(${mfront_model_library_name}
#	        PRIVATE "${CASTEMHOME}/include/c")
#	    endif(enable-castem-pleiades)
#	  endif(CASTEMHOME)
#      if(CASTEM_CPPFLAGS)
#	    set_target_properties(${mfront_model_library_name} PROPERTIES
#	      COMPILE_FLAGS "${CASTEM_CPPFLAGS}")
#      endif(CASTEM_CPPFLAGS)
#    endif(${interface} STREQUAL "castem")
#    mfm_install_library(${mfront_model_library_name})
#    if(${interface} STREQUAL "castem")
#      target_link_libraries(${mfront_model_library_name}
#        PRIVATE ${TFEL_MFRONT_LIBRARIES}
#	    ${CastemInterface})
#    endif(${interface} STREQUAL "castem")    
#  endforeach(interface ${mfront-models-interfaces})
#  foreach(source ${ARGN})
#    install_mfront(${CMAKE_CURRENT_SOURCE_DIR}/${source}.mfront ${mat} models)
#  endforeach(source ${ARGN})
#endfunction(mfront_models_library)
