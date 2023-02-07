# This file is part of the MFrontGallery project website:
# <https://thelfer.github.io/MFrontGallery/web/index.html> github repository:
# <https://github.com/thelfer/MFrontGallery>

function(mfront_behaviour_check_temperature_is_first_external_state_variable mat search_paths
         source)
  mfront_query(modelling_hypotheses ${mat} "${search_paths}" ${source}
               "--supported-modelling-hypotheses")
  # creating a cmake list
  separate_arguments(modelling_hypotheses)
  list(LENGTH modelling_hypotheses nb_modelling_hypotheses)
  if(nb_modelling_hypotheses EQUAL 0)
    set(compatibility_failure
        "no modelling hypothesis defined"
        PARENT_SCOPE)
    set(file_OK
        OFF
        PARENT_SCOPE)
  endif(nb_modelling_hypotheses EQUAL 0)
  foreach(h ${modelling_hypotheses})
    set(_external_state_variable_test OFF)
    mfront_query(external_state_variables ${mat} "${search_paths}" ${source}
                 "--modelling-hypothesis=${h}" "--external-state-variables")
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
    endif()
  endforeach(h ${modelling_hypotheses})
endfunction(mfront_behaviour_check_temperature_is_first_external_state_variable)

function(mfront_behaviour_check_compatibility mat interface search_paths mfront_file)
  set(file_OK ON)
  set(compatibility_failure)
  if((${interface} STREQUAL "castem") OR (${interface} STREQUAL "castem21"))
    check_castem_behaviour_compatibility(${mat} "${search_paths}"
                                         ${mfront_file})
  elseif(${interface} STREQUAL "aster")
    check_aster_compatibility(${mat} "${search_paths}" ${mfront_file})
  elseif(${interface} STREQUAL "ansys")
    check_ansys_compatibility(${mat} "${search_paths}" ${mfront_file})
  elseif(${interface} STREQUAL "epx")
    check_europlexus_compatibility(${mat} "${search_paths}" ${mfront_file})
  elseif(${interface} STREQUAL "abaqus")
    check_abaqus_compatibility(${mat} "${search_paths}" ${mfront_file})
  elseif(${interface} STREQUAL "abaqusexplicit")
    check_abaqus_explicit_compatibility(${mat} "${search_paths}" ${mfront_file})
  elseif(${interface} STREQUAL "calculix")
    check_calculix_compatibility(${mat} "${search_paths}" ${mfront_file})
  elseif(${interface} STREQUAL "cyrano")
    check_cyrano_compatibility(${mat} "${search_paths}" ${mfront_file})
  elseif(${interface} STREQUAL "zmat")
    check_zmat_compatibility(${mat} "${search_paths}" ${mfront_file})
  elseif(${interface} STREQUAL "dianafea")
    check_diana_fea_compatibility(${mat} "${search_paths}" ${mfront_file})
  elseif(${interface} STREQUAL "generic")
    check_generic_behaviour_compatibility(${mat} "${search_paths}"
                                          ${mfront_file})
  else()
    message(FATAL_ERROR "unsupported interface ${interface}")
  endif()
  set(file_OK
      ${file_OK}
      PARENT_SCOPE)
  set(compatibility_failure
      ${compatibility_failure}
      PARENT_SCOPE)
endfunction(mfront_behaviour_check_compatibility)

function(add_mfront_behaviour_source lib mat interface search_paths mfront_path)
  mfront_behaviour_check_compatibility(${mat} ${interface} "${search_paths}"
                                       ${mfront_path})
  if(file_OK)
    get_behaviour_dsl_options(${interface})
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
      install_mfront("${mfront_path}" ${mat} behaviours)
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
endfunction(add_mfront_behaviour_source)

#! add_mfront_behaviour_sources : 
function(add_mfront_behaviour_sources lib mat interface search_paths file)
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
                     "--all-behaviours" "--list-implementation-paths=unsorted")
        if(_impls)
          string(REPLACE " " ";" _mfront_impls ${_impls})
        else(_impls)
          set(_mfront_impls)
        endif(_impls)
        set(append_file OFF)
        foreach(_impl ${_mfront_impls})
          add_mfront_behaviour_source(${lib} ${mat} ${interface}
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
      add_mfront_behaviour_source(${lib} ${mat} ${interface} "${search_paths}"
                                  ${mfront_path})
      if(file_OK)
        list(APPEND ${lib}_MFRONT_IMPLEMENTATION_PATHS ${mfront_path})
        set(${lib}_MFRONT_IMPLEMENTATION_PATHS
            ${${lib}_MFRONT_IMPLEMENTATION_PATHS}
            PARENT_SCOPE)
        string(FIND "${source}" "mdnx:" mdnx_prefix)
        if("${mdnx_prefix}" EQUAL 0)
          string(REPLACE ":" ";" _path_tokens ${source})
          list(LENGTH _path_tokens _n_path_tokens)
          if(NOT _n_path_tokens EQUAL 5)
            message(FATAL_ERROR "invalid mdnx path '${source}'")
          endif()
         list(GET _path_tokens 1 _madnex_source_file)
         if(NOT EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/${_madnex_source_file}")
           message(FATAL_ERROR "invalide madnex file: "
                   "no file named '${CMAKE_CURRENT_SOURCE_DIR}/${_madnex_source_file}'")
         endif()
          list(APPEND ${lib}_MFRONT_SOURCES
              "${CMAKE_CURRENT_SOURCE_DIR}/${_madnex_source_file}")
        else("${mdnx_prefix}" EQUAL 0)
          list(APPEND ${lib}_MFRONT_SOURCES ${mfront_path})
        endif("${mdnx_prefix}" EQUAL 0)
        set(${lib}_MFRONT_SOURCES
            ${${lib}_MFRONT_SOURCES}
            PARENT_SCOPE)
      endif(file_OK)
    endif()
    set(${lib}_SOURCES
        ${${lib}_SOURCES}
        PARENT_SCOPE)
  endif()
endfunction(add_mfront_behaviour_sources)

# ! get_mfront_behaviour_library_name: this function returns the name of the
# library generated for the given material or phenomenon for the given interface
#
# \param: mat name of a material or the name of phenomenon \param: interface
# interface used
function(get_mfront_behaviour_library_name mat interface)
  if(${interface} STREQUAL "castem")
    getcastembehaviourname(${mat})
  elseif(${interface} STREQUAL "castem21")
    getcastem21behaviourname(${mat})
  elseif(${interface} STREQUAL "ansys")
    getansysbehaviourname(${mat})
  elseif(${interface} STREQUAL "abaqus")
    getabaqusbehaviourname(${mat})
  elseif(${interface} STREQUAL "abaqusexplicit")
    getabaqusexplicitbehaviourname(${mat})
  elseif(${interface} STREQUAL "calculix")
    getcalculixbehaviourname(${mat})
  elseif(${interface} STREQUAL "dianafea")
    getdianafeabehaviourname(${mat})
  else()
    set(lib "${mat}Behaviours-${interface}")
  endif()
  set(mfront_behaviour_library_name
      ${lib}
      PARENT_SCOPE)
endfunction(get_mfront_behaviour_library_name)

function(generate_mfront_doc search_paths mfront_file)
  if(enable-mfront-documentation-generation)
    get_filename_component(directory ${mfront_file} DIRECTORY)
    get_filename_component(raw_file ${mfront_file} NAME_WE)
    set(markdown_file "${CMAKE_CURRENT_BINARY_DIR}/${raw_file}.md")
    set(html_file "${CMAKE_CURRENT_BINARY_DIR}/${raw_file}-description.html")
    set(mfront_doc_args "${search_paths}")
    if(MFRONT_DOC_HAS_STANDALONE_OPTION)
      list(APPEND mfront_doc_args "--standalone")
    endif(MFRONT_DOC_HAS_STANDALONE_OPTION)
    add_custom_command(
      OUTPUT ${markdown_file}
      DEPENDS ${mfront_file}
      COMMAND ${MFRONT_DOC} ARGS ${mfront_doc_args} ARGS ${mfront_file})
    add_custom_target(${raw_file}-md ALL DEPENDS ${markdown_file})
    add_dependencies(doc ${raw_file}-md)
    pandoc_html_base("${raw_file}-description" ${markdown_file} ${html_file}
                     "--toc")
  endif(enable-mfront-documentation-generation)
endfunction(generate_mfront_doc)

# ! mfront_behaviours_library : this adds shared libraries related to
# behaviours!
#
# The `mfront_behaviours_library` function adds shared libraries to the project
# related to `MFront`' behaviours. The number of added shared libraries depends
# on the number of (behaviour) interfaces selected when the project is
# configured .
#
# # Usage
#
# A typical usage of the `mfront_behaviours_library` is the following:
#
# ~~~
# {.cmake}
# mfront_behaviours_library(Concrete
#   ConcreteBurger_EDF_CIWAP_2021
#   ConcreteBurger_EDF_CIWAP_2021_v2)
# ~~~
#
# which declares a set of shared libraries associated with the `Concrete`
# material. Those shared libraries are generated using two `MFront` files named
# respectively `ConcreteBurger_EDF_CIWAP_2021.mfront` and
# `ConcreteBurger_EDF_CIWAP_2021_v2.mfront`.
#
# Note that the `.mfront` suffix has been omitted in this declaration.
#
# ~~~
# {.bash}
# -- ConcreteBurger_EDF_CIWAP_2021 has been discarded for interface calculix (behaviours with external state variable other  than the temperature are not supported)
# -- ConcreteBurger_EDF_CIWAP_2021_v2 has been discarded for interface calculix (behaviours with external state variable other  than the temperature are not supported)
# -- No sources selected for library CONCRETECALCULIXBEHAVIOURS for interface calculix
# -- ConcreteBurger_EDF_CIWAP_2021 has been discarded for interface ansys (behaviours with external state variable other  than the temperature are not supported)
# -- ConcreteBurger_EDF_CIWAP_2021_v2 has been discarded for interface ansys (behaviours with external state variable other  than the temperature are not supported)
# -- No sources selected for library CONCRETEANSYSBEHAVIOURS for interface ansys
# -- Adding library : CONCRETEABAQUSBEHAVIOURS (/home/th202608/codes/MFrontGallery/master/src/build/materials/Concrete/behaviours/abaqus/src/abaqusConcreteBurger_EDF_CIWAP_2021.cxx;/home/th202608/codes/MFrontGallery/master/src/build/materials/Concrete/behaviours/abaqus/src/ConcreteBurger_EDF_CIWAP_2021.cxx;/home/th202608/codes/MFrontGallery/master/src/build/materials/Concrete/behaviours/abaqus/src/abaqusConcreteBurger_EDF_CIWAP_2021_v2.cxx;/home/th202608/codes/MFrontGallery/master/src/build/materials/Concrete/behaviours/abaqus/src/ConcreteBurger_EDF_CIWAP_2021_v2.cxx)
# -- Adding library : ConcreteBehaviours-cyrano (/home/th202608/codes/MFrontGallery/master/src/build/materials/Concrete/behaviours/cyrano/src/cyranoConcreteBurger_EDF_CIWAP_2021.cxx;/home/th202608/codes/MFrontGallery/master/src/build/materials/Concrete/behaviours/cyrano/src/ConcreteBurger_EDF_CIWAP_2021.cxx;/home/th202608/codes/MFrontGallery/master/src/build/materials/Concrete/behaviours/cyrano/src/cyranoConcreteBurger_EDF_CIWAP_2021_v2.cxx;/home/th202608/codes/MFrontGallery/master/src/build/materials/Concrete/behaviours/cyrano/src/ConcreteBurger_EDF_CIWAP_2021_v2.cxx)
# -- ConcreteBurger_EDF_CIWAP_2021 has been discarded for interface epx (small strain behaviours are not supported)
# -- ConcreteBurger_EDF_CIWAP_2021_v2 has been discarded for interface epx (small strain behaviours are not supported)
# -- No sources selected for library ConcreteBehaviours-epx for interface epx
# -- ConcreteBurger_EDF_CIWAP_2021 has been discarded for interface dianafea (behaviours with external state variable other  than the temperature are not supported)
# -- ConcreteBurger_EDF_CIWAP_2021_v2 has been discarded for interface dianafea (behaviours with external state variable other  than the temperature are not supported)
# -- No sources selected for library ConcreteDianaFEABehaviours for interface dianafea
# -- Adding library : ConcreteBehaviours-aster (/home/th202608/codes/MFrontGallery/master/src/build/materials/Concrete/behaviours/aster/src/asterConcreteBurger_EDF_CIWAP_2021.cxx;/home/th202608/codes/MFrontGallery/master/src/build/materials/Concrete/behaviours/aster/src/ConcreteBurger_EDF_CIWAP_2021.cxx;/home/th202608/codes/MFrontGallery/master/src/build/materials/Concrete/behaviours/aster/src/asterConcreteBurger_EDF_CIWAP_2021_v2.cxx;/home/th202608/codes/MFrontGallery/master/src/build/materials/Concrete/behaviours/aster/src/ConcreteBurger_EDF_CIWAP_2021_v2.cxx)
# -- Adding library : ConcreteBehaviours (/home/th202608/codes/MFrontGallery/master/src/build/materials/Concrete/behaviours/castem/src/umatConcreteBurger_EDF_CIWAP_2021.cxx;/home/th202608/codes/MFrontGallery/master/src/build/materials/Concrete/behaviours/castem/src/ConcreteBurger_EDF_CIWAP_2021.cxx;/home/th202608/codes/MFrontGallery/master/src/build/materials/Concrete/behaviours/castem/src/umatConcreteBurger_EDF_CIWAP_2021_v2.cxx;/home/th202608/codes/MFrontGallery/master/src/build/materials/Concrete/behaviours/castem/src/ConcreteBurger_EDF_CIWAP_2021_v2.cxx)
# ....
# ~~~
#
# which lists the shared libraries that will be compiled and the sources that
# will be generated by `MFront`. One may notice that each shared library is
# compiled in its own directory.
#
# One may also notice that the behaviours considered are not compatible with
# some of the selected behaviour interfaces and are thus discarded:
#
# * Those behaviours are not compatible with the `dianafea`, `calculix` and
#   `ansys` interfaces because it declares an external state variable which is
#   not the temperature and this is not supported by those interfaces.
# * Those behaviours are not compatible with the `epx` (Europlexus) interface
#   because this solver only supports finite strain behaviours.
#
# In this example, no shared libraries for the `Concrete` material will be
# generated for the interfaces `dianafea`, `calculix`, `ansys` and `epx`
# interfaces since no `MFront` are compatible with them.
#
# Internally, the `mfront_behaviours_library` function forward is arguments to
# the `parse_mfront_library_sources` function and use its results to add the
# shared libraries properly.
#
# # Treatment of the sources
#
# For each shared library to be added, each source returned in the
# `mfront_sources` variable by the `parse_mfront_library_sources` is treated as
# follows:
#
# * If the file `@source@.mfront` (where `@source@` is the name of the
#   considered source) exists in the current source directory, then it is
#   treated as an `MFront` source file.
# * If the file `@source@.mfront.in` (where `@source@` is the name of the
#   considered source) exists in the current source directory, then it is
#   automatically configured using `̀CMake`' `configure_file` command and the
#   resulting file is treated as an `MFront` source file.
# * If neither the `@source@.mfront` nor `@source@.mfront.in` exist in the
#   current directory, the file `@source@` is added in the list of sources for
#   the treated shared library. This file can be given by its full path, and is
#   searched in the current source directory or the the current binary
#   directory.
#
# `MFront` source files are treated by the `generate_mfront_doc` function which
# will generate a web page for this source file using the `mfront-doc` utility
# if the `enable-website` option has been choosen at the `CMake` configuration
# stage.
function(mfront_behaviours_library mat)
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
         "--search-path=${CMAKE_SOURCE_DIR}/materials/${mat}/behaviours")
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
    if(mfront_file)
      generate_mfront_doc("${mfront_search_paths}" ${mfront_file})
    endif()
  endforeach()
  foreach(interface ${mfront-behaviours-interfaces})
    get_mfront_behaviour_library_name(${mat} ${interface})
    file(MAKE_DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}/${interface}")
    # list of sources generated from MFront files. Populated by calls to
    # add_mfront_behaviour_sources
    set(${mfront_behaviour_library_name}_SOURCES)
    # list of sources not generated by MFront
    set(${mfront_behaviour_library_name}_OTHER_SOURCES)
    foreach(source ${mfront_sources})
      add_mfront_behaviour_sources(
        ${mfront_behaviour_library_name} ${mat} ${interface}
        "${mfront_search_paths}" ${source})
    endforeach(source ${mfront_sources})
    set(generate_library ON)
    list(LENGTH ${mfront_behaviour_library_name}_SOURCES nb_sources)
    list(LENGTH ${mfront_behaviour_library_name}_OTHER_SOURCES nb_other_sources)
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
      _get_mfront_behaviour_command_line_arguments()
      set(mfront_args)
      list(APPEND mfront_args ${mfront_behaviour_command_line_arguments})
      list(APPEND mfront_args ${mfront_search_paths})
      list(APPEND mfront_args "--interface=${interface}")
      get_behaviour_dsl_options(${interface})
      if(mfront_dsl_options)
        list(APPEND mfront_args ${mfront_dsl_options})
      endif(mfront_dsl_options)
      list(APPEND mfront_args
           ${${mfront_behaviour_library_name}_MFRONT_IMPLEMENTATION_PATHS})
      add_custom_command(
        OUTPUT ${${mfront_behaviour_library_name}_SOURCES}
        COMMAND "${MFRONT}" ARGS ${mfront_args}
        DEPENDS ${${mfront_behaviour_library_name}_MFRONT_SOURCES}
        WORKING_DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}/${interface}"
        COMMENT
          "mfront sources ${${mfront_behaviour_library_name}_MFRONT_SOURCES} for interface ${interface}"
      )
      set(_all_sources)
      list(APPEND _all_sources ${${mfront_behaviour_library_name}_SOURCES})
      list(APPEND _all_sources
           ${${mfront_behaviour_library_name}_OTHER_SOURCES})
      message(
        STATUS
          "Adding library : ${mfront_behaviour_library_name} (${_all_sources})")
      add_library(${mfront_behaviour_library_name} SHARED ${_all_sources})
      target_include_directories(
        ${mfront_behaviour_library_name}
        PRIVATE "${CMAKE_CURRENT_BINARY_DIR}/${interface}/include"
        PRIVATE "${TFEL_INCLUDE_PATH}")
      if(EXISTS "${CMAKE_SOURCE_DIR}/include")
        target_include_directories(${mfront_behaviour_library_name}
                                   PRIVATE "${CMAKE_SOURCE_DIR}/include")
      endif(EXISTS "${CMAKE_SOURCE_DIR}/include")
      if(mfront_include_directories)
        target_include_directories(${mfront_behaviour_library_name}
                                   PRIVATE ${mfront_include_directories})
      endif()
      if(EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/include")
        target_include_directories(
          ${mfront_behaviour_library_name}
          PRIVATE "${CMAKE_CURRENT_SOURCE_DIR}/include")
      endif(EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/include")
      if((${interface} STREQUAL "castem") OR (${interface} STREQUAL "castem21"))
        if(CASTEMHOME)
          if(enable-castem-pleiades)
            target_include_directories(${mfront_behaviour_library_name}
                                       PRIVATE "${CASTEMHOME}/include")
          else(enable-castem-pleiades)
            target_include_directories(${mfront_behaviour_library_name}
                                       PRIVATE "${CASTEMHOME}/include/c")
          endif(enable-castem-pleiades)
        endif(CASTEMHOME)
      endif((${interface} STREQUAL "castem") OR (${interface} STREQUAL "castem21"))
      mfm_install_library(${mfront_behaviour_library_name})
      if((${interface} STREQUAL "castem") OR (${interface} STREQUAL "castem21"))
        if(CASTEMHOME)
          target_include_directories(${mfront_behaviour_library_name}
                                     PRIVATE "${CASTEMHOME}/include")
        endif(CASTEMHOME)
        if(CASTEM_CPPFLAGS)
          set_target_properties(${mfront_behaviour_library_name}
                                PROPERTIES COMPILE_FLAGS "${CASTEM_CPPFLAGS}")
        endif(CASTEM_CPPFLAGS)
        target_link_libraries(
          ${mfront_behaviour_library_name} PRIVATE ${TFEL_MFRONT_LIBRARIES}
                                                   ${CastemInterface})
      elseif(${interface} STREQUAL "aster")
        if(ASTER_CPPFLAGS)
          set_target_properties(${mfront_behaviour_library_name}
                                PROPERTIES COMPILE_FLAGS "${ASTER_CPPFLAGS}")
        endif(ASTER_CPPFLAGS)
        target_link_libraries(
          ${mfront_behaviour_library_name} PRIVATE ${TFEL_MFRONT_LIBRARIES}
                                                   ${AsterInterface})
      elseif(${interface} STREQUAL "epx")
        if(EUROPLEXUS_CPPFLAGS)
          set_target_properties(
            ${mfront_behaviour_library_name}
            PROPERTIES COMPILE_FLAGS "${EUROPLEXUS_CPPFLAGS}")
        endif(EUROPLEXUS_CPPFLAGS)
        target_link_libraries(
          ${mfront_behaviour_library_name} PRIVATE ${TFEL_MFRONT_LIBRARIES}
                                                   ${EuroplexusInterface})
      elseif(${interface} STREQUAL "abaqus")
        if(ABAQUS_CPPFLAGS)
          set_target_properties(${mfront_behaviour_library_name}
                                PROPERTIES COMPILE_FLAGS "${ABAQUS_CPPFLAGS}")
        endif(ABAQUS_CPPFLAGS)
        target_link_libraries(
          ${mfront_behaviour_library_name} PRIVATE ${TFEL_MFRONT_LIBRARIES}
                                                   ${AbaqusInterface})
      elseif(${interface} STREQUAL "abaqusexplicit")
        if(ABAQUS_EXPLICIT_CPPFLAGS)
          set_target_properties(
            ${mfront_behaviour_library_name}
            PROPERTIES COMPILE_FLAGS "${ABAQUS_EXPLICIT_CPPFLAGS}")
        endif(ABAQUS_EXPLICIT_CPPFLAGS)
        target_link_libraries(
          ${mfront_behaviour_library_name} PRIVATE ${TFEL_MFRONT_LIBRARIES}
                                                   ${AbaqusInterface})
      elseif(${interface} STREQUAL "ansys")
        if(ANSYS_CPPFLAGS)
          set_target_properties(${mfront_behaviour_library_name}
                                PROPERTIES COMPILE_FLAGS "${ANSYS_CPPFLAGS}")
        endif(ANSYS_CPPFLAGS)
        target_link_libraries(
          ${mfront_behaviour_library_name} PRIVATE ${TFEL_MFRONT_LIBRARIES}
                                                   ${AnsysInterface})
      elseif(${interface} STREQUAL "calculix")
        if(CALCULIX_CPPFLAGS)
          set_target_properties(${mfront_behaviour_library_name}
                                PROPERTIES COMPILE_FLAGS "${CALCULIX_CPPFLAGS}")
        endif(CALCULIX_CPPFLAGS)
        target_link_libraries(
          ${mfront_behaviour_library_name} PRIVATE ${TFEL_MFRONT_LIBRARIES}
                                                   ${CalculiXInterface})
        #
      elseif(${interface} STREQUAL "dianafea")
        if(DIANA_FEA_CPPFLAGS)
          set_target_properties(
            ${mfront_behaviour_library_name} PROPERTIES COMPILE_FLAGS
                                                        "${DIANA_FEA_CPPFLAGS}")
        endif(DIANA_FEA_CPPFLAGS)
        target_link_libraries(
          ${mfront_behaviour_library_name} PRIVATE ${TFEL_MFRONT_LIBRARIES}
                                                   ${DianaFEAInterface})
        #
      elseif(${interface} STREQUAL "cyrano")
        if(CYRANO_CPPFLAGS)
          set_target_properties(${mfront_behaviour_library_name}
                                PROPERTIES COMPILE_FLAGS "${CYRANO_CPPFLAGS}")
        endif(CYRANO_CPPFLAGS)
        target_link_libraries(
          ${mfront_behaviour_library_name} PRIVATE ${TFEL_MFRONT_LIBRARIES}
                                                   ${CyranoInterface})
      elseif(${interface} STREQUAL "zmat")
        set_target_properties(${mfront_behaviour_library_name}
                              PROPERTIES COMPILE_FLAGS "${ZSET_CPPFLAGS}")
        target_include_directories(${mfront_behaviour_library_name} SYSTEM
                                   PRIVATE "${ZSET_INCLUDE_DIR}")
        target_link_libraries(${mfront_behaviour_library_name}
                              PRIVATE ${TFEL_MFRONT_LIBRARIES})
      elseif(${interface} STREQUAL "generic")
        target_link_libraries(${mfront_behaviour_library_name}
                              PRIVATE ${TFEL_MFRONT_LIBRARIES})
      else(${interface} STREQUAL "generic")
        message(FATAL_ERROR "mfront_behaviours_library : "
                            "unsupported interface ${interface}")
      endif((${interface} STREQUAL "castem") OR (${interface} STREQUAL "castem21"))
      foreach(_link_library ${mfront_link_libraries})
        target_link_libraries(${mfront_behaviour_library_name}
                              PRIVATE ${_link_library})
      endforeach(_link_library ${mfront_link_libraries})
    else(generate_library)
      if(nb_other_sources GREATER 0)
        message(
          STATUS
            "Only external sources provided for "
            "library ${mfront_behaviour_library_name} for interface ${interface}. "
            "The generation of this library is disabled by default. It can be enabled "
            "by passing the GENERATE_WITHOUT_MFRONT_SOURCES")
      else(nb_other_sources GREATER 0)
        message(
          STATUS
            "No sources selected for "
            "library ${mfront_behaviour_library_name} for interface ${interface}"
        )
      endif(nb_other_sources GREATER 0)
    endif(generate_library)
  endforeach(interface)
endfunction(mfront_behaviours_library)

# ! add_mtest : add a test using the `MTest` solver!
#
# The `add_mtest` function allows to declare a test on behaviours based on the
# `MTest` solver. The `add_mtest` function is used by wrappers such as
# `genericmtest` (for tests associated with the `generic` interface) or
# `castemmest` (for tests associated with the `Cast3M` interface) and not used
# directly (see below).
#
# This function takes two mandatory arguments:
#
# * the name of the interface.
# * the name of the library containing the behaviour to be tested.
#
# This function may take optional arguments introduced by the following
# keywords:
#
# * `TEST_NAME` (default): this keyword introduces the base name of one or
#   several tests. The full test name is created by adding: - the configuration
#   (`Release`, `Debug`, etc.) for build systems that support multiple
#   configurations in the same build - the rounding mode (see below for
#   details).
# * `MTEST_FILE`: this keyword introduces one or several base names to declare
#   `MTest` scripts (i.e. the name of a file without extension). For each base
#   name, the `add_mtest` function proceeds as follows: - If a file, with this
#   base name and the extension `.mtest.in` exists, the `configure_file`
#   function is called to generate a script file in the current directory. This
#   file will be called by `MTest`. - Otherwise, a file, with this base name and
#   the extension `.mtest` is expected to exist in the current source directory.
# * `BEHAVIOUR`: this keyword introduces the name of the behaviour. This name
#   used to replace all occurences of `@behaviour@` in the `MTest` scripts.
# * `LIBRARY`: this keyword introduces the path to the library containing the
#   behaviour to be tested. This name used to replace all occurences of
#   `@library@` in the `MTest` scripts. By default, this location is deduced
#   from the name of the second argument of the function.
# * `INTERFACE`: this keyword introduces the name of the interface used to
#   generate the library. This name used to replace all occurences of
#   `@interface@` in the `MTest` scripts.
# * `REFERENCE_FILE`: this keyword introduces the name of the file containing
#   the reference results. This name used to replace all occurences of
#   `@reference_file@` in the `MTest` scripts.
# * `ACCELERATION_ALGORITHM`: this keyword introduces the name of an
#   acceleration algorithm (see the `MTest` documentation for a list of
#   acceleration algorithms).
# * `STIFFNESS_MATRIX_TYPE`: this keyword introduces the type of stiffness
#   matrix type to be used for the test (see the `MTest` documentation for a
#   list of available stiffness matrix types).
# * `MATERIAL_PROPERTIES_LIBRARIES`: this keyword introduces a list of libraries
#   whose locations are requested. This keyword is only meaningful if an
#   `mtest.in` file is to be used.
#
# Several test names and several `MTest` scripts can be declared through the
# `TEST_NAME` and `MTEST_FILE` keywords respectively. The number of test names
# must match the number of scripts.
#
# A script is generally run several times with different rounding modes (see the
# `MTest` documentation for details).
#
# \arg:interface interface used to generate the library \arg:lib library name
#
function(add_mtest interface lib)
  set(_CMD TEST_NAME)
  set(_TESTS)
  set(_BEHAVIOUR)
  set(_MTEST_FILES)
  set(_LIBRARY)
  set(_REFERENCE_FILE)
  set(_ACCELERATION_ALGORITHM)
  set(_TEST_ACCELERATION_ALGORITHM)
  set(_STIFFNESS_MATRIX_TYPE)
  set(_TEST_STIFFNESS_MATRIX_TYPE)
  set(_TEST_INTERFACE)
  set(_INTERFACE)
  set(_MATERIAL_PROPERTIES_LIBRARIES)
  foreach(_ARG ${ARGN})
    if(${_ARG} MATCHES TEST_NAME)
      set(_CMD TEST_NAME)
    elseif(${_ARG} MATCHES MTEST_FILE)
      set(_CMD MTEST_FILE)
    elseif(${_ARG} MATCHES BEHAVIOUR)
      set(_CMD _BEHAVIOUR)
    elseif(${_ARG} MATCHES LIBRARY)
      set(_CMD _LIBRARY)
    elseif(${_ARG} MATCHES INTERFACE)
      set(_CMD _INTERFACE)
    elseif(${_ARG} MATCHES REFERENCE_FILE)
      set(_CMD _REFERENCE_FILE)
    elseif(${_ARG} MATCHES ACCELERATION_ALGORITHM)
      set(_CMD _ACCELERATION_ALGORITHM)
    elseif(${_ARG} MATCHES STIFFNESS_MATRIX_TYPE)
      set(_CMD _STIFFNESS_MATRIX_TYPE)
    elseif(${_ARG} MATCHES MATERIAL_PROPERTIES_LIBRARIES)
      set(_CMD MATERIAL_PROPERTIES_LIBRARIES)
    else()
      if(${_CMD} MATCHES TEST_NAME)
        list(APPEND _TESTS "${_ARG}")
      elseif(${_CMD} MATCHES MTEST_FILE)
        list(APPEND _MTEST_FILES "${_ARG}")
        set(_CMD TEST_NAME)
      elseif(${_CMD} MATCHES MATERIAL_PROPERTIES_LIBRARIES)
        list(APPEND _MATERIAL_PROPERTIES_LIBRARIES "${_ARG}")
      elseif(${_CMD} MATCHES LIBRARY)
        set(_LIBRARY --@library@="${_ARG}")
        set(_CMD TEST_NAME)
      elseif(${_CMD} MATCHES BEHAVIOUR)
        set(_BEHAVIOUR --@behaviour@="${_ARG}")
        set(_CMD TEST_NAME)
      elseif(${_CMD} MATCHES INTERFACE)
        set(_TEST_INTERFACE "${_ARG}")
        set(_INTERFACE --@interface@=${_TEST_INTERFACE})
        set(_CMD TEST_NAME)
      elseif(${_CMD} MATCHES REFERENCE_FILE)
        set(_REFERENCE_FILE --@reference_file@="${_ARG}")
        set(_CMD TEST_NAME)
      elseif(${_CMD} MATCHES ACCELERATION_ALGORITHM)
        set(_TEST_ACCELERATION_ALGORITHM "${_ARG}")
        set(_ACCELERATION_ALGORITHM --@AccelerationAlgorithm="${_ARG}")
        set(_CMD TEST_NAME)
      elseif(${_CMD} MATCHES STIFFNESS_MATRIX_TYPE)
        set(_TEST_STIFFNESS_MATRIX_TYPE "${_ARG}")
        set(_STIFFNESS_MATRIX_TYPE --@StiffnessMatrixType="${_ARG}")
        set(_CMD TEST_NAME)
      endif()
    endif()
  endforeach()
  if(NOT _TESTS)
    message(FATAL_ERROR "add_mtest : no test specified")
  endif(NOT _TESTS)
  list(LENGTH _TESTS _NB_TESTS)
  if(_MTEST_FILES)
    list(LENGTH _MTEST_FILES _NB_MTEST_FILES)
    if(NOT _NB_TESTS EQUAL _NB_MTEST_FILES)
      message(
        FATAL_ERROR
          "add_mtest : the number of tests do no match the number of mtest files"
      )
    endif()
  else()
    set(_MTEST_FILES ${_TESTS})
  endif()
  if(NOT _INTERFACE)
    set(_INTERFACE "--@interface@=${inteface}")
  endif(NOT _INTERFACE)
  math(EXPR _for_each_upper_bound "${_NB_TESTS} - 1")
  foreach(_index RANGE 0 ${_for_each_upper_bound})
    list(GET _TESTS ${_index} _TEST_NAME)
    if(_TEST_INTERFACE)
      set(_TEST_NAME "${_TEST_NAME}_${_TEST_INTERFACE}")
    endif(_TEST_INTERFACE)
    if(_TEST_ACCELERATION_ALGORITHM)
      set(_TEST_NAME "${_TEST_NAME}_${_TEST_ACCELERATION_ALGORITHM}")
    endif(_TEST_ACCELERATION_ALGORITHM)
    if(_TEST_STIFFNESS_MATRIX_TYPE)
      set(_TEST_NAME "${_TEST_NAME}_${_TEST_STIFFNESS_MATRIX_TYPE}")
    endif(_TEST_STIFFNESS_MATRIX_TYPE)
    list(GET _MTEST_FILES ${_index} _MTEST_FILE)
    if(CMAKE_CONFIGURATION_TYPES)
      foreach(conf ${CMAKE_CONFIGURATION_TYPES})
        set(file "${_TEST_NAME}-${conf}.mtest")
        if(NOT _LIBRARY)
          get_property(
            ${lib}BuildPath
            TARGET ${lib}
            PROPERTY LOCATION_${conf})
          set(_LIBRARY "--@library@='${${lib}BuildPath}'")
        endif(NOT _LIBRARY)
        foreach(mplib ${_MATERIAL_PROPERTIES_LIBRARIES})
          get_property(
            ${mplib}BuildPath
            TARGET ${mplib}
            PROPERTY LOCATION_${conf})
        endforeach(mplib ${_MATERIAL_PROPERTIES_LIBRARIES})
        if(EXISTS ${CMAKE_CURRENT_SOURCE_DIR}/${_MTEST_FILE}.mtest.in)
          configure_file(${_MTEST_FILE}.mtest.in ${_MTEST_FILE}-${conf}.mtest
                         @ONLY)
          set(test_file ${_MTEST_FILE}-${conf}.mtest)
        else(EXISTS ${CMAKE_CURRENT_SOURCE_DIR}/${_MTEST_FILE}.mtest.in)
          set(test_file ${CMAKE_CURRENT_SOURCE_DIR}/${_MTEST_FILE}.mtest)
        endif(EXISTS ${CMAKE_CURRENT_SOURCE_DIR}/${_MTEST_FILE}.mtest.in)
        foreach(rm ${IEEE754_ROUNDING_MODES})
          add_test(
            NAME ${_TEST_NAME}_${conf}_${rm}_mtest
            COMMAND
              ${MTEST} --rounding-direction-mode=${rm} --verbose=level0
              --result-file-output=false --xml-output=true
              --@XMLOutputFile="${_TEST_NAME}_${conf}_${rm}_mtest.xml"
              ${_LIBRARY} ${_BEHAVIOUR} ${_INTERFACE} ${_REFERENCE_FILE}
              ${_ACCELERATION_ALGORITHM} ${_STIFFNESS_MATRIX_TYPE} ${test_file}
            CONFIGURATIONS ${conf})
          set_property(
            TEST ${_TEST_NAME}_${conf}_${rm}_mtest
            PROPERTY DEPENDS ${lib} ${_MATERIAL_PROPERTIES_LIBRARIES})
        endforeach(rm ${IEEE754_ROUNDING_MODES})
      endforeach(conf ${CMAKE_CONFIGURATION_TYPES})
    else(CMAKE_CONFIGURATION_TYPES)
      get_property(
        ${lib}BuildPath
        TARGET ${lib}
        PROPERTY LOCATION)
      if(NOT _LIBRARY)
        set(_LIBRARY --@library@="${${lib}BuildPath}")
      endif(NOT _LIBRARY)
      foreach(mplib ${_MATERIAL_PROPERTIES_LIBRARIES})
        get_property(
          ${mplib}BuildPath
          TARGET ${mplib}
          PROPERTY LOCATION)
      endforeach(mplib ${_MATERIAL_PROPERTIES_LIBRARIES})
      if(EXISTS ${CMAKE_CURRENT_SOURCE_DIR}/${_MTEST_FILE}.mtest.in)
        configure_file(${_MTEST_FILE}.mtest.in ${_MTEST_FILE}.mtest @ONLY)
        set(test_file ${_MTEST_FILE}.mtest)
      else(EXISTS ${CMAKE_CURRENT_SOURCE_DIR}/${_MTEST_FILE}.mtest.in)
        set(test_file ${CMAKE_CURRENT_SOURCE_DIR}/${_MTEST_FILE}.mtest)
      endif(EXISTS ${CMAKE_CURRENT_SOURCE_DIR}/${_MTEST_FILE}.mtest.in)
      foreach(rm ${IEEE754_ROUNDING_MODES})
        add_test(
          NAME ${_TEST_NAME}_${rm}_mtest
          COMMAND
            ${MTEST} --rounding-direction-mode=${rm} --verbose=level0
            --xml-output=true --@XMLOutputFile="${_TEST_NAME}_${rm}_mtest.xml"
            --result-file-output=false ${_LIBRARY} ${_BEHAVIOUR} ${_INTERFACE}
            ${_REFERENCE_FILE} ${_ACCELERATION_ALGORITHM}
            ${_STIFFNESS_MATRIX_TYPE} ${test_file})
        set_property(TEST ${_TEST_NAME}_${rm}_mtest
                     PROPERTY DEPENDS ${lib} ${_MATERIAL_PROPERTIES_LIBRARIES})
      endforeach(rm ${IEEE754_ROUNDING_MODES})
    endif(CMAKE_CONFIGURATION_TYPES)
  endforeach()
endfunction(add_mtest)

# ! castemmtest : this function adds an `MTest` test for a behaviour generated
# thanks to the `Cast3M` interface!
#
# This function does nothing if the `Cast3M` behaviour interface has not been
# selected.
#
# \arg:mat this parameter is used to determine the name of the library generated
# for the `Cast3M` interface. In pratice this parameter may designate the name
# of a material (Concrete for example) or the name of a phenomenon (plasticity,
# damage, etc..).
#
# The other optional arguments are automatically forwarded to the `add_mtest`
# function. The name of the interface is forwarded to the `add_mtest` function
# using the `INTERFACE` keyword.
function(castemmtest mat)
  if(MFM_CASTEM_BEHAVIOUR_INTERFACE)
    get_mfront_behaviour_library_name(${mat} "castem")
    add_mtest("castem" ${mfront_behaviour_library_name} INTERFACE castem
              ${ARGN})
  endif(MFM_CASTEM_BEHAVIOUR_INTERFACE)
endfunction(castemmtest)

# ! astermtest : this function adds an `MTest` test for a behaviour generated
# thanks to the `aster` interface!
#
# This function does nothing if the `aster` behaviour interface has not been
# selected.
#
# \arg:mat this parameter is used to determine the name of the library generated
# for the `aster` interface. In pratice this parameter may designate the name of
# a material (Concrete for example) or the name of a phenomenon (plasticity,
# damage, etc..).
#
# The other optional arguments are automatically forwarded to the `add_mtest`
# function. The name of the interface is forwarded to the `add_mtest` function
# using the `INTERFACE` keyword.
function(astermtest mat)
  if(MFM_ASTER_INTERFACE)
    get_mfront_behaviour_library_name(${mat} "aster")
    add_mtest("aster" ${mfront_behaviour_library_name} INTERFACE aster ${ARGN})
  endif(MFM_ASTER_INTERFACE)
endfunction(astermtest)

# ! europlexusmtest : this function adds an `MTest` test for a behaviour
# generated thanks to the `epx` interface!
#
# This function does nothing if the `epx` behaviour interface has not been
# selected.
#
# \arg:mat this parameter is used to determine the name of the library generated
# for the `epx` interface. In pratice this parameter may designate the name of a
# material (Concrete for example) or the name of a phenomenon (plasticity,
# damage, etc..).
#
# The other optional arguments are automatically forwarded to the `add_mtest`
# function. The name of the interface is forwarded to the `add_mtest` function
# using the `INTERFACE` keyword.
function(europlexusmtest mat)
  if(MFM_EUROPLEXUS_INTERFACE)
    get_mfront_behaviour_library_name(${mat} "europlexus")
    add_mtest("europlexus" ${mfront_behaviour_library_name} INTERFACE epx
              ${ARGN})
  endif(MFM_EUROPLEXUS_INTERFACE)
endfunction(europlexusmtest)

# ! abaqusmtest : this function adds an `MTest` test for a behaviour generated
# thanks to the `abaqus` interface!
#
# This function does nothing if the `abaqus` behaviour interface has not been
# selected.
#
# \arg:mat this parameter is used to determine the name of the library generated
# for the `abaqus` interface. In pratice this parameter may designate the name
# of a material (Concrete for example) or the name of a phenomenon (plasticity,
# damage, etc..).
#
# The other optional arguments are automatically forwarded to the `add_mtest`
# function. The name of the interface is forwarded to the `add_mtest` function
# using the `INTERFACE` keyword.
function(abaqusmtest mat)
  if(MFM_ABAQUS_INTERFACE)
    get_mfront_behaviour_library_name(${mat} "abaqus")
    add_mtest("abaqus" ${mfront_behaviour_library_name} INTERFACE abaqus
              ${ARGN})
  endif(MFM_ABAQUS_INTERFACE)
endfunction(abaqusmtest)

# ! abaqusexplicitmtest : this function adds an `MTest` test for a behaviour
# generated thanks to the `abaqusexplicit` interface!
#
# This function does nothing if the `abaqusexplicit` behaviour interface has not
# been selected.
#
# \arg:mat this parameter is used to determine the name of the library generated
# for the `abaqusexplicit` interface. In pratice this parameter may designate
# the name of a material (Concrete for example) or the name of a phenomenon
# (plasticity, damage, etc..).
#
# The other optional arguments are automatically forwarded to the `add_mtest`
# function. The name of the interface is forwarded to the `add_mtest` function
# using the `INTERFACE` keyword.
function(abaqusexplicitmtest mat)
  if(MFM_ABAQUS_EXPLICIT_INTERFACE)
    get_mfront_behaviour_library_name(${mat} "abaqusexplicit")
    add_mtest("abaqusexplicit" ${mfront_behaviour_library_name} INTERFACE
              abaqusexplicit ${ARGN})
  endif(MFM_ABAQUS_EXPLICIT_INTERFACE)
endfunction(abaqusexplicitmtest)

# ! ansysmtest : this function adds an `MTest` test for a behaviour generated
# thanks to the `ansys` interface!
#
# This function does nothing if the `ansys` behaviour interface has not been
# selected.
#
# \arg:mat this parameter is used to determine the name of the library generated
# for the `ansys` interface. In pratice this parameter may designate the name of
# a material (Concrete for example) or the name of a phenomenon (plasticity,
# damage, etc..).
#
# The other optional arguments are automatically forwarded to the `add_mtest`
# function. The name of the interface is forwarded to the `add_mtest` function
# using the `INTERFACE` keyword.
function(ansysmtest mat)
  if(MFM_ANSYS_INTERFACE)
    get_mfront_behaviour_library_name(${mat} "ansys")
    add_mtest("ansys" ${mfront_behaviour_library_name} INTERFACE ansys ${ARGN})
  endif(MFM_ANSYS_INTERFACE)
endfunction(ansysmtest)

# ! calculixmtest : this function adds an `MTest` test for a behaviour generated
# thanks to the `calculix` interface!
#
# This function does nothing if the `calculix` behaviour interface has not been
# selected.
#
# \arg:mat this parameter is used to determine the name of the library generated
# for the `calculix` interface. In pratice this parameter may designate the name
# of a material (Concrete for example) or the name of a phenomenon (plasticity,
# damage, etc..).
#
# The other optional arguments are automatically forwarded to the `add_mtest`
# function. The name of the interface is forwarded to the `add_mtest` function
# using the `INTERFACE` keyword.
function(calculixmtest mat)
  if(MFM_CALCULIX_INTERFACE)
    get_mfront_behaviour_library_name(${mat} "calculix")
    add_mtest("calculix" ${mfront_behaviour_library_name} INTERFACE calculix
              ${ARGN})
  endif(MFM_CALCULIX_INTERFACE)
endfunction(calculixmtest)

# ! dianafeamtest : this function adds an `MTest` test for a behaviour generated
# thanks to the `dianafea` interface!
#
# This function does nothing if the `dianafea` behaviour interface has not been
# selected.
#
# \arg:mat this parameter is used to determine the name of the library generated
# for the `dianafea` interface. In pratice this parameter may designate the name
# of a material (Concrete for example) or the name of a phenomenon (plasticity,
# damage, etc..).
#
# The other optional arguments are automatically forwarded to the `add_mtest`
# function. The name of the interface is forwarded to the `add_mtest` function
# using the `INTERFACE` keyword.
function(dianafeamtest mat)
  if(MFM_DIANA_FEA_INTERFACE)
    get_mfront_behaviour_library_name(${mat} "dianafea")
    add_mtest("dianafea" ${mfront_behaviour_library_name} INTERFACE dianafea
              ${ARGN})
  endif(MFM_DIANA_FEA_INTERFACE)
endfunction(dianafeamtest)

# ! cyranomtest : this function adds an `MTest` test for a behaviour generated
# thanks to the `cyrano` interface!
#
# This function does nothing if the `cyrano` behaviour interface has not been
# selected.
#
# \arg:mat this parameter is used to determine the name of the library generated
# for the `cyrano` interface. In pratice this parameter may designate the name
# of a material (Concrete for example) or the name of a phenomenon (plasticity,
# damage, etc..).
#
# The other optional arguments are automatically forwarded to the `add_mtest`
# function. The name of the interface is forwarded to the `add_mtest` function
# using the `INTERFACE` keyword.
function(cyranomtest mat)
  if(MFM_CYRANO_INTERFACE)
    get_mfront_behaviour_library_name(${mat} "cyrano")
    add_mtest("cyrano" ${mfront_behaviour_library_name} INTERFACE cyrano
              ${ARGN})
  endif(MFM_CYRANO_INTERFACE)
endfunction(cyranomtest)

# ! genericmtest : this function adds an `MTest` test for a behaviour generated
# thanks to the `generic` interface!
#
# This function does nothing if the `generic` behaviour interface has not been
# selected.
#
# \arg:mat this parameter is used to determine the name of the library generated
# for the `generic` interface. In pratice this parameter may designate the name
# of a material (Concrete for example) or the name of a phenomenon (plasticity,
# damage, etc..).
#
# The other optional arguments are automatically forwarded to the `add_mtest`
# function. The name of the interface is forwarded to the `add_mtest` function
# using the `INTERFACE` keyword.
function(genericmtest mat)
  if(MFM_GENERIC_BEHAVIOUR_INTERFACE)
    get_mfront_behaviour_library_name(${mat} "generic")
    add_mtest("generic" ${mfront_behaviour_library_name} INTERFACE generic
              ${ARGN})
  endif(MFM_GENERIC_BEHAVIOUR_INTERFACE)
endfunction(genericmtest)

# ! mtest : this function adds a test based on an `MTest` script!
#
# This function expects that a list of interfaces are defined using either the
# `INTERFACES` keyword or the `INTERFACE` keyword. The following interfaces are
# supported:  `castem`, `aster`, `ansys`, `dianafea`, `epx`, `abaqus`,
# `abaqusexplicit`, `calculix`, `cyrano` and `generic`.
#
# The other optional arguments are automatically forwarded to the functions
# associated with the interfaces selected. For example, if the `ansys` interface
# is selected, the `ansysmtest` function is called.
function(mtest mat)
  set(_ARGS)
  set(_INTERFACES)
  set(_CMD)
  foreach(_ARG ${ARGN})
    if(${_ARG} MATCHES INTERFACES)
      set(_CMD _INTERFACES)
    elseif(${_ARG} MATCHES INTERFACE)
      set(_CMD _INTERFACE)
    elseif(${_CMD} MATCHES _INTERFACE)
      list(APPEND _INTERFACES "${_ARG}")
      set(_CMD _INTERFACE)
    elseif(${_CMD} MATCHES _INTERFACES)
      list(APPEND _INTERFACES "${_ARG}")
    else()
      list(APPEND _ARGS "${_ARG}")
    endif()
  endforeach()
  if(${_CMD} MATCHES _INTERFACE)
    message(FATAL_ERROR "no interface defined after INTERFACE option")
  endif()
  if(NOT INTERFACES)
    message(FATAL_ERROR "no interface defined")
  endif()
  foreach(interface ${_INTERFACES})
    if(${interface} STREQUAL "castem")
      castemmtest(${mat} ${_ARGS})
    elseif(${interface} STREQUAL "aster")
      astermtest(${mat} ${_ARGS})
    elseif(${interface} STREQUAL "ansys")
      ansysmtest(${mat} ${_ARGS})
    elseif(${interface} STREQUAL "dianafea")
      dianafeamtest(${mat} ${_ARGS})
    elseif(${interface} STREQUAL "epx")
      europlexusmtest(${mat} ${_ARGS})
    elseif(${interface} STREQUAL "abaqus")
      abaqusmtest(${mat} ${_ARGS})
    elseif(${interface} STREQUAL "abaqusexplicit")
      abaqus_explicitmtest(${mat} ${_ARGS})
    elseif(${interface} STREQUAL "calculix")
      calculixmtest(${mat} ${_ARGS})
    elseif(${interface} STREQUAL "cyrano")
      cyranomtest(${mat} ${_ARGS})
    elseif(${interface} STREQUAL "generic")
      genericmtest(${mat} ${_ARGS})
    else()
      message(FATAL_ERROR "unsupported interface ${interface}")
    endif()
  endforeach()
endfunction(mtest)

function(add_python_test interface lib)
  if(TFEL_PYTHON_BINDINGS)
    set(_CMD TESTS)
    set(_TESTS)
    set(_MATERIAL_PROPERTIES_LIBRARIES)
    foreach(_ARG ${ARGN})
      if(${_ARG} MATCHES TESTS)
        set(_CMD TESTS)
      elseif(${_ARG} MATCHES MATERIAL_PROPERTIES_LIBRARIES)
        set(_CMD MATERIAL_PROPERTIES_LIBRARIES)
      else()
        if(${_CMD} MATCHES TESTS)
          list(APPEND _TESTS "${_ARG}")
        elseif(${_CMD} MATCHES MATERIAL_PROPERTIES_LIBRARIES)
          list(APPEND _MATERIAL_PROPERTIES_LIBRARIES "${_ARG}")
        endif()
      endif()
    endforeach()
    list(LENGTH _TESTS _TESTS_LENGTH)
    if(${_TESTS_LENGTH} LESS 1)
      message(FATAL_ERROR "add_python_test : no test specified")
    endif(${_TESTS_LENGTH} LESS 1)
    foreach(test ${_TESTS})
      get_property(
        ${lib}BuildPath
        TARGET ${lib}
        PROPERTY LOCATION)
      foreach(mplib ${_MATERIAL_PROPERTIES_LIBRARIES})
        get_property(
          ${mplib}BuildPath
          TARGET ${mplib}
          PROPERTY LOCATION)
      endforeach(mplib ${_MATERIAL_PROPERTIES_LIBRARIES})
      configure_file(${test}.py.in ${test}.py @ONLY)
      add_test(NAME ${test}_py COMMAND ${PYTHON_EXECUTABLE} ${test}.py)
      set_tests_properties(${test}_py PROPERTIES DEPENDS ${lib})
    endforeach(test ${_TESTS})
  endif(TFEL_PYTHON_BINDINGS)
endfunction(
  add_python_test
  interface
  lib)

function(castempythontest mat)
  if(MFM_CASTEM_BEHAVIOUR_INTERFACE)
    get_mfront_behaviour_library_name(${mat} "castem")
    add_python_test("castem" ${mfront_behaviour_library_name} ${ARGN})
  endif(MFM_CASTEM_BEHAVIOUR_INTERFACE)
endfunction(castempythontest mat)

function(asterpythontest mat)
  if(MFM_ASTER_INTERFACE)
    get_mfront_behaviour_library_name(${mat} "aster")
    add_python_test("aster" ${mfront_behaviour_library_name} ${ARGN})
  endif(MFM_ASTER_INTERFACE)
endfunction(asterpythontest mat)
