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

find_program(MFRONT       mfront
  HINTS "${TFELHOME}/bin")
find_program(TFEL_CHECK   tfel-check
  HINTS "${TFELHOME}/bin")
find_program(TFEL_CONFIG  tfel-config
  HINTS "${TFELHOME}/bin")
find_program(MFRONT_QUERY  mfront-query
  HINTS "${TFELHOME}/bin")
find_program(MFMTG        mfm-test-generator
  HINTS "${TFELHOME}/bin")

IF(NOT (TFEL_CONFIG AND MFRONT AND MFRONT_QUERY))
  MESSAGE(FATAL_ERROR "tfel not found")
ENDIF(NOT (TFEL_CONFIG AND MFRONT AND MFRONT_QUERY))

IF(NOT MFMTG)
  MESSAGE(WARNING "mfm-test-generator not found")
ENDIF(NOT MFMTG)

EXECUTE_PROCESS(COMMAND ${TFEL_CONFIG} "--includes"
  OUTPUT_VARIABLE TFEL_INCLUDE_PATH
  OUTPUT_STRIP_TRAILING_WHITESPACE)
STRING(LENGTH ${TFEL_INCLUDE_PATH}  TFEL_INCLUDE_PATH_LENGTH)
MATH(EXPR TFEL_INCLUDE_PATH_LENGTH "${TFEL_INCLUDE_PATH_LENGTH} - 2")
STRING(SUBSTRING ${TFEL_INCLUDE_PATH} 2 ${TFEL_INCLUDE_PATH_LENGTH} TFEL_INCLUDE_PATH)
EXECUTE_PROCESS(COMMAND ${TFEL_CONFIG} "--libs"
  OUTPUT_VARIABLE TFEL_LIBRARY_PATH
  OUTPUT_STRIP_TRAILING_WHITESPACE)
STRING(LENGTH ${TFEL_LIBRARY_PATH}  TFEL_LIBRARY_PATH_LENGTH)
MATH(EXPR TFEL_LIBRARY_PATH_LENGTH "${TFEL_LIBRARY_PATH_LENGTH} - 2")
STRING(SUBSTRING ${TFEL_LIBRARY_PATH} 2 ${TFEL_LIBRARY_PATH_LENGTH} TFEL_LIBRARY_PATH)

EXECUTE_PROCESS(COMMAND ${TFEL_CONFIG} "--cxx-standard"
  RESULT_VARIABLE TFEL_CXX_STANDARD_AVAILABLE
  OUTPUT_VARIABLE TFEL_CXX_STANDARD
  OUTPUT_STRIP_TRAILING_WHITESPACE)

  EXECUTE_PROCESS(COMMAND ${TFEL_CONFIG} "--version"
    OUTPUT_VARIABLE TFEL_VERSION_FULL
    OUTPUT_STRIP_TRAILING_WHITESPACE)
  STRING(REPLACE " " ";" TFEL_VERSION_FULL ${TFEL_VERSION_FULL})
  LIST(GET TFEL_VERSION_FULL 1 TFEL_VERSION)

if(NOT TFEL_CXX_STANDARD_AVAILABLE EQUAL 0)
  set(TFEL_CXX_STANDARD 11)
endif(NOT TFEL_CXX_STANDARD_AVAILABLE EQUAL 0)

EXECUTE_PROCESS(COMMAND ${TFEL_CONFIG} "--python-version"
  RESULT_VARIABLE TFEL_PYTHON_BINDINGS
  OUTPUT_VARIABLE TFEL_PYTHON_VERSION
  OUTPUT_STRIP_TRAILING_WHITESPACE)

if(TFEL_PYTHON_BINDINGS EQUAL 0)
  set(TFEL_PYTHON_BINDINGS ON)
else(TFEL_PYTHON_BINDINGS EQUAL 0)
  set(TFEL_PYTHON_BINDINGS OFF)
endif(TFEL_PYTHON_BINDINGS EQUAL 0)

if(TFEL_PYTHON_BINDINGS)
  message(STATUS "tfel python bindings ${TFEL_PYTHON_VERSION}")
else(TFEL_PYTHON_BINDINGS)
  message(STATUS "no tfel python bindings")
endif(TFEL_PYTHON_BINDINGS)
  
macro(find_tfel_library name)
  find_library(${name}
    NAMES ${name}
    HINTS ${TFEL_LIBRARY_PATH})
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

macro(install_generic_behaviour dir file)
  install(FILES ${file}
    DESTINATION "share/${PACKAGE_NAME}/generic-behaviours/${dir}/${type}")
endmacro(install_generic_behaviour)

macro(install_mfront file mat type)
  install(FILES ${file} DESTINATION "share/${PACKAGE_NAME}/materials/${mat}/${type}")
endmacro(install_mfront)

macro(add_mfront_dependency deps mat interface file)
  set(source_dir     "${PROJECT_SOURCE_DIR}/materials/${mat}/properties")
  set(mfront_file    "${source_dir}/${file}.mfront")
  set(mfront_output1 "${CMAKE_CURRENT_BINARY_DIR}/${interface}/src/${file}-mfront.cxx")
  set(mfront_output2 "${CMAKE_CURRENT_BINARY_DIR}/${interface}/include/${file}-mfront.hxx")
  add_custom_command(
    OUTPUT  "${mfront_output1}"
    OUTPUT  "${mfront_output2}"
    COMMAND "${MFRONT}"
    ARGS    "--search-path=${CMAKE_SOURCE_DIR}/materials/${mat}/properties"
    ARGS    "--interface=mfront" "${mfront_file}"
    DEPENDS "${mfront_file}"
    WORKING_DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}/${interface}"
    COMMENT "mfront source ${mfront_file}")
  set(${deps}_${interface}_SOURCES ${mfront_output1} ${${deps}_${interface}_SOURCES})
endmacro(add_mfront_dependency)

# function(mfmtg_generate target input)
#  EXECUTE_PROCESS(COMMAND ${MFMTG} "--plugins=${}" "--target=${target}" "${input}")
# endfunction(mfmtg_generate)

include(cmake/modules/materialproperties.cmake)
include(cmake/modules/behaviours.cmake)
include(cmake/modules/models.cmake)

