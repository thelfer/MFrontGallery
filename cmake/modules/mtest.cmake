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
  set(_MATERIAL)
  set(_MDNX_TEST)
  set(_MDNX_MATERIAL)
  set(_MDNX_BEHAVIOUR)
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
    elseif(${_ARG} MATCHES MTEST_PATH)
      set(_CMD MTEST_FILE)
    elseif(${_ARG} MATCHES MDNX_TEST)
      set(_CMD _MDNX_TEST)
    elseif(${_ARG} MATCHES MDNX_BEHAVIOUR)
      set(_CMD _MDNX_BEHAVIOUR)
    elseif(${_ARG} MATCHES BEHAVIOUR)
      set(_CMD _BEHAVIOUR)
    elseif(${_ARG} MATCHES LIBRARY)
      set(_CMD _LIBRARY)
    elseif(${_ARG} MATCHES MATERIAL_PROPERTIES_LIBRARIES)
      set(_CMD MATERIAL_PROPERTIES_LIBRARIES)
    elseif(${_ARG} MATCHES MATERIAL)
      set(_CMD _MATERIAL)
    elseif(${_ARG} MATCHES INTERFACE)
      set(_CMD _INTERFACE)
    elseif(${_ARG} MATCHES REFERENCE_FILE)
      set(_CMD _REFERENCE_FILE)
    elseif(${_ARG} MATCHES ACCELERATION_ALGORITHM)
      set(_CMD _ACCELERATION_ALGORITHM)
    elseif(${_ARG} MATCHES STIFFNESS_MATRIX_TYPE)
      set(_CMD _STIFFNESS_MATRIX_TYPE)
    else()
      if(${_CMD} MATCHES TEST_NAME)
        list(APPEND _TESTS "${_ARG}")
      elseif(${_CMD} MATCHES MTEST_FILE)
        list(APPEND _MTEST_PATHS "${_ARG}")
        set(_CMD TEST_NAME)
      elseif(${_CMD} MATCHES MATERIAL_PROPERTIES_LIBRARIES)
        list(APPEND _MATERIAL_PROPERTIES_LIBRARIES "${_ARG}")
      elseif(${_CMD} MATCHES LIBRARY)
        set(_LIBRARY --@library@="${_ARG}")
        set(_CMD TEST_NAME)
      elseif(${_CMD} MATCHES MATERIAL)
        set(_MATERIAL "${_ARG}")
        set(_CMD TEST_NAME)
      elseif(${_CMD} MATCHES MDNX_MATERIAL)
        set(_MDNX_MATERIAL "${_ARG}")
        set(_CMD TEST_NAME)
      elseif(${_CMD} MATCHES MDNX_BEHAVIOUR)
        set(_MDNX_BEHAVIOUR "${_ARG}")
        set(_CMD TEST_NAME)
      elseif(${_CMD} MATCHES MDNX_TEST)
        set(_MDNX_TEST "${_ARG}")
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
  if(_MTEST_PATHS)
    list(LENGTH _MTEST_PATHS _NB_MTEST_PATHS)
    if(NOT _NB_TESTS EQUAL _NB_MTEST_PATHS)
      message(
        FATAL_ERROR
          "add_mtest : the number of tests do no match the number of mtest files"
      )
    endif()
  else()
    set(_MTEST_PATHS ${_TESTS})
  endif()
  if(NOT _INTERFACE)
    set(_INTERFACE "--@interface@=${interface}")
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
    list(GET _MTEST_PATHS ${_index} _MTEST_PATH)
    string(FIND "${_MTEST_PATH}" "mdnx:" _mdnx_prefix)
    set(_mdnx_file OFF)
    if("${_mdnx_prefix}" EQUAL 0)
      update_mdnx_path(${_MTEST_PATH})
      set(_MTEST_FULL_PATH "${mdnx_path}")
    else()
      if(EXISTS ${CMAKE_CURRENT_SOURCE_DIR}/${_MTEST_PATH}.mtest.in)
        # The case of .mtest.in file is treated later
        set(_MTEST_FULL_PATH "${_MTEST_PATH}")
      else()
        if(EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/${_MTEST_PATH}.mtest")
           set(_MTEST_FULL_PATH "${CMAKE_CURRENT_SOURCE_DIR}/${_MTEST_PATH}.mtest")
        elseif(EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/${_MTEST_PATH}.mdnx")
           set(_mdnx_file ON)
           set(_MTEST_FULL_PATH "${CMAKE_CURRENT_SOURCE_DIR}/${_MTEST_PATH}.mdnx")
        else()
           message(FATAL_ERROR "unsupported test path ${_MTEST_PATH}")
        endif()
      endif()
    endif()
    set(_mdnx_args)
    if(${_mdnx_file})
      if(NOT _MDNX_TEST)
        list(APPEND _mdnx_args "--all-tests")
      else()
        list(APPEND _mdnx_args "--test=${_MDNX_TEST}")
      endif()
      if(NOT _MDNX_MATERIAL)
        if(NOT _MATERIAL)
          message(FATAL_ERROR "the 'MDNX_MATERIAL' parameter has not been specified")
        endif(NOT _MATERIAL)
        list(APPEND _mdnx_args "--material=${_MATERIAL}")
      else(NOT _MDNX_MATERIAL)
        list(APPEND _mdnx_args "--material=${_MDNX_MATERIAL}")
      endif(NOT _MDNX_MATERIAL)
      if(NOT _MDNX_BEHAVIOUR)
        message(FATAL_ERROR "the 'MDNX_BEHAVIOUR' parameter has not been specified")
      endif(NOT _MDNX_BEHAVIOUR)
      list(APPEND _mdnx_args "--behaviour=${_MDNX_BEHAVIOUR}")
    endif(${_mdnx_file})
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
        if(EXISTS ${CMAKE_CURRENT_SOURCE_DIR}/${_MTEST_FULL_PATH}.mtest.in)
          configure_file(${_MTEST_FULL_PATH}.mtest.in ${_MTEST_FULL_PATH}-${conf}.mtest
                         @ONLY)
          set(test_file ${_MTEST_FULL_PATH}-${conf}.mtest)
        else(EXISTS ${CMAKE_CURRENT_SOURCE_DIR}/${_MTEST_FULL_PATH}.mtest.in)
          set(test_file ${_MTEST_FULL_PATH})
        endif(EXISTS ${CMAKE_CURRENT_SOURCE_DIR}/${_MTEST_FULL_PATH}.mtest.in)
        foreach(rm ${IEEE754_ROUNDING_MODES})
          add_test(
            NAME ${_TEST_NAME}_${conf}_${rm}_mtest
            COMMAND
              ${MTEST} --rounding-direction-mode=${rm} --verbose=level0
              --result-file-output=false --xml-output=true
              --@XMLOutputFile="${_TEST_NAME}_${conf}_${rm}_mtest.xml"
              ${_mdnx_args}
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
      if(EXISTS ${CMAKE_CURRENT_SOURCE_DIR}/${_MTEST_FULL_PATH}.mtest.in)
        configure_file(${_MTEST_FULL_PATH}.mtest.in ${_MTEST_FULL_PATH}.mtest @ONLY)
        set(test_file ${_MTEST_FULL_PATH}.mtest)
      else(EXISTS ${CMAKE_CURRENT_SOURCE_DIR}/${_MTEST_FULL_PATH}.mtest.in)
        set(test_file ${_MTEST_FULL_PATH})
      endif(EXISTS ${CMAKE_CURRENT_SOURCE_DIR}/${_MTEST_FULL_PATH}.mtest.in)
      foreach(rm ${IEEE754_ROUNDING_MODES})
        add_test(
          NAME ${_TEST_NAME}_${rm}_mtest
          COMMAND
            ${MTEST} --rounding-direction-mode=${rm} --verbose=level0
            --xml-output=true --@XMLOutputFile="${_TEST_NAME}_${rm}_mtest.xml"
            --result-file-output=false
            ${_mdnx_args}
            ${_LIBRARY} ${_BEHAVIOUR} ${_INTERFACE}
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
    add_mtest("castem" ${mfront_behaviour_library_name}
              MATERIAL ${mat} INTERFACE castem ${ARGN})
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
    add_mtest("aster" ${mfront_behaviour_library_name}
              MATERIAL ${mat} INTERFACE aster ${ARGN})
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
    add_mtest("europlexus" ${mfront_behaviour_library_name}
              MATERIAL ${mat} INTERFACE epx ${ARGN})
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
    add_mtest("abaqus" ${mfront_behaviour_library_name}
              MATERIAL ${mat} INTERFACE abaqus ${ARGN})
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
    add_mtest("abaqusexplicit" ${mfront_behaviour_library_name}
              MATERIAL ${mat} INTERFACE abaqusexplicit ${ARGN})
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
    add_mtest("ansys" ${mfront_behaviour_library_name}
              MATERIAL ${mat} INTERFACE ansys ${ARGN})
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
    add_mtest("calculix" ${mfront_behaviour_library_name}
              MATERIAL ${mat} INTERFACE calculix ${ARGN})
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
    add_mtest("dianafea" ${mfront_behaviour_library_name}
              MATERIAL ${mat} INTERFACE dianafea ${ARGN})
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
    add_mtest("cyrano" ${mfront_behaviour_library_name}
              MATERIAL ${mat} INTERFACE cyrano ${ARGN})
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
    add_mtest("generic" ${mfront_behaviour_library_name}
              MATERIAL ${mat} INTERFACE generic ${ARGN})
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
