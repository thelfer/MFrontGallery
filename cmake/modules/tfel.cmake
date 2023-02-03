# find the tfel library
if(TFEL_INSTALL_PATH)
  set(TFELHOME "${TFEL_INSTALL_PATH}")
else(TFEL_INSTALL_PATH)
  set(TFELHOME $ENV{TFELHOME})
endif(TFEL_INSTALL_PATH)

if(LIB_SUFFIX)
  add_definitions("-DLIB_SUFFIX=\\\"\"${LIB_SUFFIX}\"\\\"")
endif(LIB_SUFFIX)

# type of architecture
if( CMAKE_SIZEOF_VOID_P EQUAL 8 )
  add_definitions("-DTFEL_ARCH64")
else( CMAKE_SIZEOF_VOID_P EQUAL 8 )
  add_definitions("-DTFEL_ARCH32")
endif( CMAKE_SIZEOF_VOID_P EQUAL 8 )

if(TFEL_FLAVOUR)
  find_program(MFRONT mfront-${TFEL_FLAVOUR}
    HINTS "${TFELHOME}/bin")
  find_program(TFEL_CHECK tfel-check-${TFEL_FLAVOUR}
    HINTS "${TFELHOMEo}/bin")
  find_program(TFEL_CONFIG  tfel-config-${TFEL_FLAVOUR}
    HINTS "${TFELHOME}/bin")
  find_program(MFRONT_QUERY  mfront-query-${TFEL_FLAVOUR}
    HINTS "${TFELHOME}/bin")
  find_program(MFRONT_DOC mfront-doc-${TFEL_FLAVOUR}
    HINTS "${TFELHOME}/bin")
  find_program(MTEST mtest-${TFEL_FLAVOUR}
    HINTS "${TFELHOME}/bin")
  find_program(MFMTG mfm-test-generator-${TFEL_FLAVOUR}
    HINTS "${TFELHOME}/bin")
else(TFEL_FLAVOUR)
  find_program(MFRONT mfront
    HINTS "${TFELHOME}/bin")
  find_program(TFEL_CHECK tfel-check
    HINTS "${TFELHOME}/bin")
  find_program(TFEL_CONFIG tfel-config
    HINTS "${TFELHOME}/bin")
  find_program(MFRONT_DOC mfront-doc
    HINTS "${TFELHOME}/bin")
  find_program(MFRONT_QUERY  mfront-query
    HINTS "${TFELHOME}/bin")
  find_program(MFMTG mfm-test-generator
    HINTS "${TFELHOME}/bin")
  find_program(MTEST mtest
    HINTS "${TFELHOME}/bin")
endif(TFEL_FLAVOUR)

IF(NOT (TFEL_CONFIG AND MFRONT AND MFRONT_QUERY))
  MESSAGE(FATAL_ERROR "tfel not found")
ENDIF(NOT (TFEL_CONFIG AND MFRONT AND MFRONT_QUERY))

IF(NOT MFMTG)
  MESSAGE(WARNING "mfm-test-generator not found")
ENDIF(NOT MFMTG)

EXECUTE_PROCESS(COMMAND ${TFEL_CONFIG} "--quiet-failure"
  RESULT_VARIABLE TFEL_QUIET_FAILURE_AVAILABLE
  OUTPUT_VARIABLE TFEL_QUIET_FAILURE
  OUTPUT_STRIP_TRAILING_WHITESPACE)

if(TFEL_QUIET_FAILURE_AVAILABLE EQUAL 0)
  set(TFEL_QUIET_FAILURE "--quiet-failure")
else(TFEL_QUIET_FAILURE_AVAILABLE EQUAL 0)
  set(TFEL_QUIET_FAILURE "")
endif(TFEL_QUIET_FAILURE_AVAILABLE EQUAL 0)

EXECUTE_PROCESS(COMMAND ${TFEL_CONFIG} ${TFEL_CONFIG_QUIET_FAILURE} "--includes"
  OUTPUT_VARIABLE TFEL_INCLUDE_PATH
  OUTPUT_STRIP_TRAILING_WHITESPACE)
STRING(LENGTH ${TFEL_INCLUDE_PATH}  TFEL_INCLUDE_PATH_LENGTH)
MATH(EXPR TFEL_INCLUDE_PATH_LENGTH "${TFEL_INCLUDE_PATH_LENGTH} - 2")
STRING(SUBSTRING ${TFEL_INCLUDE_PATH} 2 ${TFEL_INCLUDE_PATH_LENGTH} TFEL_INCLUDE_PATH)
EXECUTE_PROCESS(COMMAND ${TFEL_CONFIG} ${TFEL_CONFIG_QUIET_FAILURE} "--libs"
  OUTPUT_VARIABLE TFEL_LIBRARY_PATH
  OUTPUT_STRIP_TRAILING_WHITESPACE)
STRING(LENGTH ${TFEL_LIBRARY_PATH}  TFEL_LIBRARY_PATH_LENGTH)
MATH(EXPR TFEL_LIBRARY_PATH_LENGTH "${TFEL_LIBRARY_PATH_LENGTH} - 2")
STRING(SUBSTRING ${TFEL_LIBRARY_PATH} 2 ${TFEL_LIBRARY_PATH_LENGTH} TFEL_LIBRARY_PATH)

EXECUTE_PROCESS(COMMAND ${TFEL_CONFIG} ${TFEL_CONFIG_QUIET_FAILURE} "--version"
  OUTPUT_VARIABLE TFEL_VERSION_FULL
  OUTPUT_STRIP_TRAILING_WHITESPACE)
STRING(REPLACE " " ";" TFEL_VERSION_FULL ${TFEL_VERSION_FULL})
LIST(GET TFEL_VERSION_FULL 1 TFEL_VERSION)

EXECUTE_PROCESS(COMMAND ${TFEL_CONFIG} "--cxx-standard"
  RESULT_VARIABLE TFEL_CXX_STANDARD_AVAILABLE
  OUTPUT_VARIABLE TFEL_CXX_STANDARD
  OUTPUT_STRIP_TRAILING_WHITESPACE)

if(NOT TFEL_CXX_STANDARD_AVAILABLE EQUAL 0)
  set(TFEL_CXX_STANDARD 11)
endif(NOT TFEL_CXX_STANDARD_AVAILABLE EQUAL 0)

# madnex support

EXECUTE_PROCESS(COMMAND ${TFEL_CONFIG} ${TFEL_CONFIG_QUIET_FAILURE} "--madnex-support"
  RESULT_VARIABLE TFEL_MADNEX_SUPPORT_AVAILABLE
  OUTPUT_VARIABLE TFEL_MADNEX_SUPPORT
  OUTPUT_STRIP_TRAILING_WHITESPACE)

if(TFEL_MADNEX_SUPPORT_AVAILABLE EQUAL 0)
  if(TFEL_MADNEX_SUPPORT STREQUAL true)
    set(TFEL_MADNEX_SUPPORT TRUE)
  else(TFEL_MADNEX_SUPPORT STREQUAL true)
    set(TFEL_MADNEX_SUPPORT FALSE)
  endif(TFEL_MADNEX_SUPPORT STREQUAL true)
else(TFEL_MADNEX_SUPPORT_AVAILABLE EQUAL 0)
  set(TFEL_MADNEX_SUPPORT FALSE)
endif(TFEL_MADNEX_SUPPORT_AVAILABLE EQUAL 0)

EXECUTE_PROCESS(COMMAND ${TFEL_CONFIG} ${TFEL_CONFIG_QUIET_FAILURE} "--python-version"
  RESULT_VARIABLE TFEL_PYTHON_BINDINGS
  OUTPUT_VARIABLE TFEL_PYTHON_VERSION
  OUTPUT_STRIP_TRAILING_WHITESPACE)

if(TFEL_PYTHON_BINDINGS EQUAL 0)
  set(TFEL_PYTHON_BINDINGS ON)
else(TFEL_PYTHON_BINDINGS EQUAL 0)
  set(TFEL_PYTHON_BINDINGS OFF)
endif(TFEL_PYTHON_BINDINGS EQUAL 0)

EXECUTE_PROCESS(COMMAND ${TFEL_CONFIG} ${TFEL_CONFIG_QUIET_FAILURE} "--mfront-doc-has-standalone-option"
  RESULT_VARIABLE MFRONT_DOC_HAS_STANDALONE_OPTION_AVAILABLE
  OUTPUT_VARIABLE MFRONT_DOC_HAS_STANDALONE_OPTION
  OUTPUT_STRIP_TRAILING_WHITESPACE)

if(MFRONT_DOC_HAS_STANDALONE_OPTION_AVAILABLE EQUAL 0)
  if(MFRONT_DOC_HAS_STANDALONE_OPTION STREQUAL true)
    set(MFRONT_DOC_HAS_STANDALONE_OPTION TRUE)
  else(MFRONT_DOC_HAS_STANDALONE_OPTION STREQUAL true)
    set(MFRONT_DOC_HAS_STANDALONE_OPTION FALSE)
  endif(MFRONT_DOC_HAS_STANDALONE_OPTION STREQUAL true)
else(MFRONT_DOC_HAS_STANDALONE_OPTION_AVAILABLE EQUAL 0)
  set(MFRONT_DOC_HAS_STANDALONE_OPTION FALSE)
endif(MFRONT_DOC_HAS_STANDALONE_OPTION_AVAILABLE EQUAL 0)

if(TFEL_PYTHON_BINDINGS)
  message(STATUS "tfel python bindings ${TFEL_PYTHON_VERSION}")
else(TFEL_PYTHON_BINDINGS)
  message(STATUS "no tfel python bindings")
endif(TFEL_PYTHON_BINDINGS)
  
macro(find_tfel_library name)
  if(TFEL_FLAVOUR)
    find_library(${name}
      NAMES ${name}-${TFEL_FLAVOUR}
      HINTS ${TFEL_LIBRARY_PATH})
  else(TFEL_FLAVOUR)
    find_library(${name}
      NAMES ${name}
      HINTS ${TFEL_LIBRARY_PATH})
  endif(TFEL_FLAVOUR)
  if(NOT ${name})
    MESSAGE(FATAL_ERROR "${name} library not found")
  endif(NOT ${name})
endmacro(find_tfel_library name)

find_tfel_library(TFELTests)
find_tfel_library(TFELException)
find_tfel_library(TFELUtilities)
find_tfel_library(TFELMath)
find_tfel_library(TFELMaterial)

if((TFEL_CXX_STANDARD GREATER 17) OR (TFEL_CXX_STANDARD EQUAL 17))
else((TFEL_CXX_STANDARD GREATER 17) OR (TFEL_CXX_STANDARD EQUAL 17))
  find_tfel_library(TFELPhysicalConstants)
endif((TFEL_CXX_STANDARD GREATER 17) OR (TFEL_CXX_STANDARD EQUAL 17))

MESSAGE(STATUS "tfel version          : ${TFEL_VERSION}")
MESSAGE(STATUS "tfel C++ standard     : ${TFEL_CXX_STANDARD}")
MESSAGE(STATUS "mfront                : ${MFRONT}")
MESSAGE(STATUS "mfront-doc            : ${MFRONT_DOC}")
MESSAGE(STATUS "mfront-query          : ${MFRONT_QUERY}")
MESSAGE(STATUS "tfel-config           : ${TFEL_CONFIG}")
if(TFEL_CHECK)
  MESSAGE(STATUS "tfel-check            : ${TFEL_CHECK}")
endif(TFEL_CHECK)  
MESSAGE(STATUS "tfel include          : ${TFEL_INCLUDE_PATH}")
MESSAGE(STATUS "tfel libs             : ${TFEL_LIBRARY_PATH}")
MESSAGE(STATUS "TFELTests             : ${TFELTests}")
MESSAGE(STATUS "TFELTests             : ${TFELTests}")
MESSAGE(STATUS "TFELException         : ${TFELException}")
MESSAGE(STATUS "TFELUtilities         : ${TFELUtilities}")
MESSAGE(STATUS "TFELMath              : ${TFELMath}")	
MESSAGE(STATUS "TFELMaterial          : ${TFELMaterial}")
MESSAGE(STATUS "TFELPhysicalConstants : ${TFELPhysicalConstants}") 
if(TFEL_MADNEX_SUPPORT)
  message(STATUS "madnex support enabled")
else(TFEL_MADNEX_SUPPORT)
  message(STATUS "madnex support disabled")
endif(TFEL_MADNEX_SUPPORT)
SET(HAVE_TFEL ON)

# list of available material property interfaces
execute_process(COMMAND ${MFRONT} "--list-material-property-interfaces"
  OUTPUT_VARIABLE MFRONT_MATERIALPROPERTY_INTERFACES_TMP
  OUTPUT_STRIP_TRAILING_WHITESPACE)
string(REGEX MATCHALL "[a-zA-Z]+"
       MFRONT_MATERIALPROPERTY_INTERFACES ${MFRONT_MATERIALPROPERTY_INTERFACES_TMP})

# list of available behaviour interfaces
execute_process(COMMAND ${MFRONT} "--list-behaviour-interfaces"
  OUTPUT_VARIABLE MFRONT_BEHAVIOUR_INTERFACES_TMP
  OUTPUT_STRIP_TRAILING_WHITESPACE)
string(REGEX MATCHALL "[a-zA-Z0-9]+"
       MFRONT_BEHAVIOUR_INTERFACES ${MFRONT_BEHAVIOUR_INTERFACES_TMP})

# list of available model interfaces
execute_process(COMMAND ${MFRONT} "--list-model-interfaces"
  OUTPUT_VARIABLE MFRONT_MODEL_INTERFACES_TMP
  OUTPUT_STRIP_TRAILING_WHITESPACE)
string(REGEX MATCHALL "[a-zA-Z]+"
       MFRONT_MODEL_INTERFACES ${MFRONT_MODEL_INTERFACES_TMP})

function(check_if_material_property_interface_is_supported interface)
  list (FIND MFRONT_MATERIALPROPERTY_INTERFACES ${interface} interface_index)
  if (NOT ${interface_index} GREATER -1)
	message(FATAL_ERROR "interface ${interface} is not supported by this version of TFEL")
  endif()
endfunction(check_if_material_property_interface_is_supported interface)

function(check_if_behaviour_interface_is_supported interface)
  list (FIND MFRONT_BEHAVIOUR_INTERFACES ${interface} interface_index)
  if (NOT ${interface_index} GREATER -1)
	message(FATAL_ERROR "interface ${interface} is not supported by this version of TFEL"
            "(supported interfaces are: ${MFRONT_BEHAVIOUR_INTERFACES})")
  endif()
endfunction(check_if_behaviour_interface_is_supported interface)

function(check_if_model_interface_is_supported interface)
  list (FIND MFRONT_MODEL_INTERFACES ${interface} interface_index)
  if (NOT ${interface_index} GREATER -1)
	message(FATAL_ERROR "interface ${interface} is not supported by this version of TFEL")
  endif()
endfunction(check_if_model_interface_is_supported interface)

option(enable-mfront-debug-mode "appends --debug to the options passed to MFront" OFF)
option(enable-mtest-file-generation-on-failure "appends --@GenerateMTestFileOnFailure=true to the options passed to MFront when compiling behaviours" OFF)

function(_get_mfront_command_line_arguments)
  set(_mfront_command_line_arguments "")
  if(enable-mfront-debug-mode)
    list(APPEND _mfront_command_line_arguments "--debug")
  endif(enable-mfront-debug-mode)
  set(mfront_command_line_arguments "${_mfront_command_line_arguments}" PARENT_SCOPE)
endfunction(_get_mfront_command_line_arguments)

function(_get_mfront_behaviour_command_line_arguments)
  _get_mfront_command_line_arguments()
  set(_mfront_behaviour_command_line_arguments "${mfront_command_line_arguments}")
  if(enable-mtest-file-generation-on-failure)
    list(APPEND _mfront_behaviour_command_line_arguments "--@GenerateMTestFileOnFailure=true")
  endif(enable-mtest-file-generation-on-failure)
  set(mfront_behaviour_command_line_arguments "${_mfront_behaviour_command_line_arguments}" PARENT_SCOPE)
endfunction(_get_mfront_behaviour_command_line_arguments)

# mkt: material knowledge type
# interface: interface considered 
# option: dsl option to be treated
# cmake_option_name: variable used to build the cmake option name
function(_get_boolean_dsl_options mkt interface option cmake_option_name)
  string(TOUPPER ${interface} uppercase_interface)
  if(MFM_${uppercase_interface}_${mkt}_${cmake_option_name})
    list(APPEND mfront_dsl_options
         "--dsl-option=${option}:true")
  else(MFM_${uppercase_interface}_${mkt}_${cmake_option_name})
    if(MFM_${uppercase_interface}_${cmake_option_name})
      list(APPEND mfront_dsl_options
           "--dsl-option=${option}:true")
    else(MFM_${uppercase_interface}_${cmake_option_name})
      if(MFM_${cmake_option_name})
        list(APPEND mfront_dsl_options
             "--dsl-option=${option}:true")
      endif(MFM_${cmake_option_name})
    endif(MFM_${uppercase_interface}_${cmake_option_name})
  endif(MFM_${uppercase_interface}_${mkt}_${cmake_option_name})
  set(mfront_dsl_options "${mfront_dsl_options}" PARENT_SCOPE)
endfunction(_get_boolean_dsl_options mkt interface option cmake_option_name)

# mkt: material knowledge type
# interface: interface considered 
# option: dsl option to be treated
# cmake_option_name: variable used to build the cmake option name
function(_get_string_dsl_options mkt interface option cmake_option_name)
  string(TOUPPER ${interface} uppercase_interface)
  if(MFM_${uppercase_interface}_${mkt}_${cmake_option_name})
    list(APPEND mfront_dsl_options
         "--dsl-option=${option}:${MFM_${uppercase_interface}_${mkt}_${cmake_option_name}}")
  else(MFM_${uppercase_interface}_${mkt}_${cmake_option_name})
    if(MFM_${uppercase_interface}_${cmake_option_name})
      list(APPEND mfront_dsl_options
           "--dsl-option=${option}:${MFM_${uppercase_interface}_${cmake_option_name}}")
    else(MFM_${uppercase_interface}_${cmake_option_name})
      if(MFM_${cmake_option_name})
        list(APPEND mfront_dsl_options
             "--dsl-option=${option}:${MFM_${cmake_option_name}}")
      endif(MFM_${cmake_option_name})
    endif(MFM_${uppercase_interface}_${cmake_option_name})
  endif(MFM_${uppercase_interface}_${mkt}_${cmake_option_name})
  set(mfront_dsl_options "${mfront_dsl_options}" PARENT_SCOPE)
endfunction(_get_string_dsl_options mkt interface option cmake_option_name)

# mkt: material knowledge type
# interface: interface considered 
function(_get_dsl_options mkt interface)
  set(mfront_dsl_options)
  _get_string_dsl_options(${mkt} ${interface}
    "build_identifier" "BUILD_IDENTIFIER")
  _get_boolean_dsl_options(${mkt} ${interface}
    "parameters_as_static_variables" "TREAT_PARAMETERS_AS_STATIC_VARIABLES")
  _get_boolean_dsl_options(${mkt} ${interface}
    "parameters_initialization_from_file" "ALLOW_PARAMETERS_INITIALIZATION_FROM_FILE")
  set(mfront_dsl_options "${mfront_dsl_options}" PARENT_SCOPE)
endfunction(_get_dsl_options mkt interface)

function(get_material_property_dsl_options interface)
  _get_dsl_options("MATERIAL_PROPERTIES" ${interface})
  set(mfront_dsl_options "${mfront_dsl_options}" PARENT_SCOPE)
endfunction(get_material_property_dsl_options interface)

function(get_behaviour_dsl_options interface)
  _get_dsl_options("BEHAVIOURS" ${interface})
  set(mfront_dsl_options "${mfront_dsl_options}" PARENT_SCOPE)
endfunction(get_behaviour_dsl_options interface)

function(get_model_dsl_options interface)
  _get_dsl_options("MODELS" ${interface})
  set(mfront_dsl_options "${mfront_dsl_options}" PARENT_SCOPE)
endfunction(get_model_dsl_options interface)

# try to find the location of an MFront source
#
# This function sets the following variables on output:
# - mfront_path: path to the MFront or madnex file if found
# - madnex_file: boolean stating if the source designates an madnex file 
function(get_mfront_source_location source)
  set(_madnex_file OFF)
  set(_mfront_path)
  if(EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/${source}.mdnx")
    set(_madnex_file ON)
    set(_mfront_path "${CMAKE_CURRENT_SOURCE_DIR}/${source}.mdnx")
  endif()
  if(EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/${source}.madnex")
    if(_mfront_path)
      message(FATAL_ERROR "source specification '${source}' is ambiguous")
    endif(_mfront_path)
    set(_madnex_file ON)
    set(_mfront_path "${CMAKE_CURRENT_SOURCE_DIR}/${source}.madnex")
  endif()
  if(EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/${source}.mfront")
    if(_mfront_path)
      message(FATAL_ERROR "source specification '${source}' is ambiguous")
    endif(_mfront_path)
    set(_mfront_path "${CMAKE_CURRENT_SOURCE_DIR}/${source}.mfront")
  endif()
  if(EXISTS "${CMAKE_CURRENT_BINARY_DIR}/${source}.mfront")
    if(_mfront_path)
      message(FATAL_ERROR "source specification '${source}' is ambiguous")
    endif(_mfront_path)
    set(_mfront_path "${CMAKE_CURRENT_BINARY_DIR}/${source}.mfront")
  endif()
  set(madnex_file ${_madnex_file} PARENT_SCOPE)
  set(mfront_path ${_mfront_path} PARENT_SCOPE)
endfunction(get_mfront_source_location file)

function(get_mfront_all_specific_targets_generated_sources interface mat file search_paths)
  execute_process(COMMAND ${MFRONT_QUERY}
    "--verbose=quiet"
    "--interface=${interface}" "${file}"
    "--all-specific-targets-generated-sources"
    ${search_paths}
    RESULT_VARIABLE MFRONT_SOURCES_AVAILABLE
    OUTPUT_VARIABLE MFRONT_SOURCES
    OUTPUT_STRIP_TRAILING_WHITESPACE)
  string(REPLACE " " ";" MFRONT_GENERATED_SOURCES ${MFRONT_SOURCES})
  set(mfront_generated_sources ${MFRONT_GENERATED_SOURCES} PARENT_SCOPE)
endfunction(get_mfront_all_specific_targets_generated_sources)

function(get_mfront_generated_sources mat interface search_paths dsl_options mfront_path)
  set(mfront_query_args )
  list(APPEND mfront_query_args "--verbose=quiet")
  list(APPEND mfront_query_args ${dsl_options})
  list(APPEND mfront_query_args ${search_paths})
  list(APPEND mfront_query_args "--interface=${interface}")
  list(APPEND mfront_query_args "--generated-sources=unsorted")
  list(APPEND mfront_query_args "${mfront_path}")
  execute_process(COMMAND ${MFRONT_QUERY}
    ${mfront_query_args}
    RESULT_VARIABLE MFRONT_SOURCES_AVAILABLE
    OUTPUT_VARIABLE MFRONT_SOURCES
    OUTPUT_STRIP_TRAILING_WHITESPACE)
  if(MFRONT_SOURCES_AVAILABLE)
    message(FATAL_ERROR "get_mfront_generated_sources: call to mfront-query failed (executed: '${MFRONT_QUERY} ${mfront_query_args}')")
  endif(MFRONT_SOURCES_AVAILABLE)
  if(MFRONT_SOURCES)
    string(REPLACE " " ";" MFRONT_GENERATED_SOURCES ${MFRONT_SOURCES})
  else(MFRONT_SOURCES)
    set(MFRONT_GENERATED_SOURCES )
  endif(MFRONT_SOURCES)
  set(mfront_generated_sources ${MFRONT_GENERATED_SOURCES} PARENT_SCOPE)
endfunction(get_mfront_generated_sources)

if(NOT TFEL_CXX_STANDARD_AVAILABLE EQUAL 0)
  set(TFEL_CXX_STANDARD 11)
endif(NOT TFEL_CXX_STANDARD_AVAILABLE EQUAL 0)

macro(install_generic_behaviour dir file)
  install(FILES ${file}
    DESTINATION "share/${PACKAGE_NAME}/generic-behaviours/${dir}/${type}")
endmacro(install_generic_behaviour)

macro(install_mfront file mat type)
  install(FILES ${file} DESTINATION "share/${PACKAGE_NAME}/materials/${mat}/${type}")
endmacro(install_mfront)

# function(mfmtg_generate target input)
#  EXECUTE_PROCESS(COMMAND ${MFMTG} "--plugins=${}" "--target=${target}" "${input}")
# endfunction(mfmtg_generate)

#! parse_mfront_library_sources: parse sources and options used to generate MFront libraries!
#
# The following options can be specificed by the user:
#
# - SOURCES
# - SEARCH_PATH
# - SEARCH_PATHS
# - INCLUDE_DIRECTORY
# - INCLUDE_DIRECTORIES
# - LINK_LIBARARY
# - LINK_LIBARARIES
#
# The following values are set in the parent scopes
#
# - generate_without_mfront_sources: boolean stating if the library must
#   be generated even if no MFront implementation is selected for the
#   given interface
# - mfront_sources: list of sources
# - mfront_include_directories: include directories
# - mfront_link_libraries: list of link libraries
# - mfront_search_paths: search paths
function(parse_mfront_library_sources )
  set ( _CMD SOURCES )
  set ( _SOURCES )
  set ( _INCLUDE_DIRECTORIES )
  set ( _LINK_LIBRARIES )
  set ( _SEARCH_PATHS )
  set(_GENERATE_WITHOUT_MFRONT_SOURCES OFF)
  foreach ( _ARG ${ARGN})
    if ( ${_ARG} STREQUAL "SOURCES" )
      set ( _CMD SOURCES )
    elseif ( ${_ARG} STREQUAL "LINK_LIBRARY" )
      set ( _CMD LINK_LIBRARY )
    elseif ( ${_ARG} STREQUAL "LINK_LIBRARIES" )
      set ( _CMD LINK_LIBRARIES )
    elseif ( ${_ARG} STREQUAL "SEARCH_PATH" )
      set ( _CMD SEARCH_PATH )
    elseif ( ${_ARG} STREQUAL "SEARCH_PATHS" )
      set ( _CMD SEARCH_PATHS )
    elseif ( ${_ARG} STREQUAL "INCLUDE_DIRECTORY" )
      set ( _CMD INCLUDE_DIRECTORY )
    elseif ( ${_ARG} STREQUAL "INCLUDE_DIRECTORIES" )
      set ( _CMD INCLUDE_DIRECTORIES )
    elseif ( ${_ARG} STREQUAL "GENERATE_WITHOUT_MFRONT_SOURCES" )
      set ( _GENERATE_WITHOUT_MFRONT_SOURCES ON)
      set ( _CMD SOURCES )
    else ()
      if ( ${_CMD} STREQUAL "SOURCES" )
        list ( APPEND _SOURCES "${_ARG}" )
      elseif ( ${_CMD} STREQUAL "LINK_LIBRARY" )
        list ( APPEND _LINK_LIBRARIES "${_ARG}" )
        set ( _CMD SOURCES )
      elseif ( ${_CMD} STREQUAL "LINK_LIBRARIES" )
        list ( APPEND _LINK_LIBRARIES "${_ARG}" )
      elseif ( ${_CMD} STREQUAL "SEARCH_PATH")
        list ( APPEND _SEARCH_PATHS "${CMAKE_SOURCE_DIR}/${_ARG}" )
        set ( _CMD SOURCES )
      elseif ( ${_CMD} STREQUAL "SEARCH_PATHS" )
        list ( APPEND _SEARCH_PATHS "${CMAKE_SOURCE_DIR}/${_ARG}" )
      elseif ( ${_CMD} STREQUAL "INCLUDE_DIRECTORY")
        list ( APPEND _INCLUDE_DIRECTORYS "${CMAKE_SOURCE_DIR}/${_ARG}" )
        set ( _CMD SOURCES )
      elseif ( ${_CMD} STREQUAL "INCLUDE_DIRECTORIES" )
        list ( APPEND _INCLUDE_DIRECTORIES "${CMAKE_SOURCE_DIR}/${_ARG}" )
      endif ()
    endif ()
  endforeach ()
  if(${_CMD} STREQUAL "SEARCH_PATH")
   message(FATAL_ERROR "no argument given to SEARCH_PATH")
  endif(${_CMD} STREQUAL "SEARCH_PATH")
  if(${_CMD} STREQUAL "INCLUDE_DIRECTORY")
   message(FATAL_ERROR "no argument given to INCLUDE_DIRECTORY")
  endif(${_CMD} STREQUAL "INCLUDE_DIRECTORY")
  if(${_CMD} STREQUAL "LINK_LIBRARY")
   message(FATAL_ERROR "no argument given to LINK_LIBRARY")
  endif(${_CMD} STREQUAL "LINK_LIBRARY")
  list(TRANSFORM _SEARCH_PATHS PREPEND "--search-path=")
  list(LENGTH _SOURCES _SOURCES_LENGTH )
  if(${_SOURCES_LENGTH} LESS 1)
    message(FATAL_ERROR "parse_mfront_library_sources: no source specified")
  endif(${_SOURCES_LENGTH} LESS 1)
  set(generate_without_mfront_sources ${_GENERATE_WITHOUT_MFRONT_SOURCES} PARENT_SCOPE)
  set(mfront_sources             ${_SOURCES}        PARENT_SCOPE)
  set(mfront_search_paths        ${_SEARCH_PATHS}   PARENT_SCOPE)
  set(mfront_include_directories ${_INCLUDE_DIRECTORIES}   PARENT_SCOPE)
  set(mfront_link_libraries      ${_LINK_LIBRARIES} PARENT_SCOPE)
endfunction(parse_mfront_library_sources)

option(enable-mfront-documentation-generation "automatically generate documentation using mfront-doc" OFF)

include(cmake/modules/materialproperties.cmake)
include(cmake/modules/behaviours.cmake)
include(cmake/modules/models.cmake)

