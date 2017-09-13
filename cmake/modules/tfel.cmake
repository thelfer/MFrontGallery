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

IF(NOT (TFEL_CONFIG AND MFRONT AND MFRONT_QUERY))
  MESSAGE(FATAL_ERROR "tfel not found")
ENDIF(NOT (TFEL_CONFIG AND MFRONT AND MFRONT_QUERY))

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

MESSAGE(STATUS "mfront        : ${MFRONT}")
MESSAGE(STATUS "tfel-config   : ${TFEL_CONFIG}")
if(TFEL_CHECK)
  MESSAGE(STATUS "tfel-check    : ${TFEL_CHECK}")
endif(TFEL_CHECK)  
MESSAGE(STATUS "tfel include  : ${TFEL_INCLUDE_PATH}")
MESSAGE(STATUS "tfel libs     : ${TFEL_LIBRARY_PATH}")
MESSAGE(STATUS "TFELTests     : ${TFELTests}")
MESSAGE(STATUS "TFELTests     : ${TFELTests}")
MESSAGE(STATUS "TFELException : ${TFELException}")
MESSAGE(STATUS "TFELUtilities : ${TFELUtilities}")
MESSAGE(STATUS "TFELMath      : ${TFELMath}")	
MESSAGE(STATUS "TFELMaterial  : ${TFELMaterial}") 
SET(HAVE_TFEL ON)

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

include(cmake/modules/materialproperties.cmake)
include(cmake/modules/behaviours.cmake)
include(cmake/modules/models.cmake)
