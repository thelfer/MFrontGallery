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
EXECUTE_PROCESS(COMMAND ${MFRONT} "--list-material-property-interfaces"
  OUTPUT_VARIABLE MFRONT_MATERIALPROPERTY_INTERFACES_TMP
  OUTPUT_STRIP_TRAILING_WHITESPACE)
string(REGEX MATCHALL "[a-zA-Z]+"
       MFRONT_MATERIALPROPERTY_INTERFACES ${MFRONT_MATERIALPROPERTY_INTERFACES_TMP})

# list of available behaviour interfaces
EXECUTE_PROCESS(COMMAND ${MFRONT} "--list-behaviour-interfaces"
  OUTPUT_VARIABLE MFRONT_BEHAVIOUR_INTERFACES_TMP
  OUTPUT_STRIP_TRAILING_WHITESPACE)
string(REGEX MATCHALL "[a-zA-Z]+"
       MFRONT_BEHAVIOUR_INTERFACES ${MFRONT_BEHAVIOUR_INTERFACES_TMP})

# list of available model interfaces
EXECUTE_PROCESS(COMMAND ${MFRONT} "--list-model-interfaces"
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
	message(FATAL_ERROR "interface ${interface} is not supported by this version of TFEL")
  endif()
endfunction(check_if_behaviour_interface_is_supported interface)

function(check_if_model_interface_is_supported interface)
  list (FIND MFRONT_model_INTERFACES ${interface} interface_index)
  if (NOT ${interface_index} GREATER -1)
	message(FATAL_ERROR "interface ${interface} is not supported by this version of TFEL")
  endif()
endfunction(check_if_model_interface_is_supported interface)

function(get_mfront_all_specific_targets_generated_sources interface mat file)
  execute_process(COMMAND ${MFRONT_QUERY}
    "--verbose=quiet"
    "--interface=${interface}" "${file}"
    "--all-specific-targets-generated-sources"
    "--search-path=${CMAKE_SOURCE_DIR}/materials/${mat}/properties"
    "--search-path=${CMAKE_SOURCE_DIR}/materials/${mat}/behaviours"
    "--search-path=${CMAKE_SOURCE_DIR}/materials/${mat}/models"
    RESULT_VARIABLE MFRONT_SOURCES_AVAILABLE
    OUTPUT_VARIABLE MFRONT_SOURCES
    OUTPUT_STRIP_TRAILING_WHITESPACE)
  string(REPLACE " " ";" MFRONT_GENERATED_SOURCES ${MFRONT_SOURCES})
  set(mfront_generated_sources ${MFRONT_GENERATED_SOURCES} PARENT_SCOPE)
endfunction(get_mfront_all_specific_targets_generated_sources)

function(get_mfront_generated_sources mat interface search_paths file)
  execute_process(COMMAND ${MFRONT_QUERY}
    "--verbose=quiet"
    "--interface=${interface}" "${file}"
    "--generated-sources=unsorted"
    ${search_paths}
    RESULT_VARIABLE MFRONT_SOURCES_AVAILABLE
    OUTPUT_VARIABLE MFRONT_SOURCES
    OUTPUT_STRIP_TRAILING_WHITESPACE)
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

# Parse sources and options used to generate MFront libraries:
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

