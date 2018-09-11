project(MFrontGallery)
set(PACKAGE mfront-gallery)

cmake_minimum_required(VERSION 3.0.2)
cmake_policy(SET CMP0005 OLD)
cmake_policy(SET CMP0026 OLD)
cmake_policy(SET CMP0007 NEW)

include(cmake/modules/generalmacros.cmake)
# load the list of rounding modes defined by the IEEE754 standard
include(cmake/modules/ieee754.cmake)

# compatibility with autotools
include(cmake/modules/autotools.cmake)
set(PACKAGE_NAME    "mfm")
set(PACKAGE_VERSION "1.0")
execute_process(COMMAND svnversion
                WORKING_DIRECTORY "${PROJECT_SOURCE_DIR}"
                OUTPUT_VARIABLE PLEIADES_SVN_REVISION 
		OUTPUT_STRIP_TRAILING_WHITESPACE)

option(enable-developer-warnings "add warnings mostly useful for TFEL developers" OFF)

#find the tfel package
include(cmake/modules/tfel.cmake)
include(cmake/modules/mfront-query.cmake)

option(enable-c   "generate c-interface for material properties"      OFF)
if(enable-c)
  check_if_material_property_interface_is_supported("c")
  set(MFM_C_INTERFACE ON)
  set(mfront-properties-interfaces "c" ${mfront-properties-interfaces})
endif(enable-c)

option(enable-c++ "generate c++-interface for material properties"    OFF)
if(enable-c++)
  check_if_material_property_interface_is_supported("cxx")
  set(MFM_CXX_INTERFACE ON)
  set(mfront-properties-interfaces "c++" ${mfront-properties-interfaces})
endif(enable-c++)

option(enable-excel  "generate excel-interface for material properties"  OFF)
if(enable-excel)
  check_if_material_property_interface_is_supported("excel")
  set(MFM_EXCEL_INTERFACE ON)
  set(mfront-properties-interfaces "excel" ${mfront-properties-interfaces})
  set(mfront-properties-interfaces "excel-internal" ${mfront-properties-interfaces})
endif(enable-excel)

option(enable-fortran "generate fortran-interface for material properties" OFF)
if(enable-fortran)
  check_if_material_property_interface_is_supported("fortran")
  set(MFM_FORTRAN_INTERFACE ON)
  set(HAVE_FORTRAN ON)
  enable_language (Fortran)
  message(STATUS "fortran support enabled")
  set(mfront-properties-interfaces "fortran" ${mfront-properties-interfaces})
else(enable-fortran)
  set(HAVE_FORTRAN OFF)
  message(STATUS "fortran support disabled")
endif(enable-fortran)

#python
option(enable-python "enable python support" OFF)
if(enable-python)
  check_if_material_property_interface_is_supported("python")
  set(MFM_PYTHON_INTERFACE ON)
  set(mfront-properties-interfaces "python" ${mfront-properties-interfaces})
endif(enable-python)

if(TFEL_PYTHON_BINDINGS OR enable-python)
  if(TFEL_PYTHON_BINDINGS)
    if(Python_ADDITIONAL_VERSIONS)
      string(REPLACE "." ";" TFEL_PYTHON_VERSIONS ${TFEL_PYTHON_VERSION})
      list(GET TFEL_PYTHON_VERSIONS 0 TFEL_PYTHON_VERSION_MAJOR)
      list(GET TFEL_PYTHON_VERSIONS 1 TFEL_PYTHON_VERSION_MINOR)
      set(TFEL_PYTHON_VERSION2 "${TFEL_PYTHON_VERSION_MAJOR}.${TFEL_PYTHON_VERSION_MINOR}")
      if(NOT Python_ADDITIONAL_VERSIONS VERSION_EQUAL TFEL_PYTHON_VERSION2)
	message(FATAL_ERROR "python version mismatch: "
	  "(Python_ADDITIONAL_VERSIONS gives ${Python_ADDITIONAL_VERSIONS} and "
	  "TFEL_PYTHON_VERSION gives ${TFEL_PYTHON_VERSION}).")
      endif(NOT Python_ADDITIONAL_VERSIONS VERSION_EQUAL TFEL_PYTHON_VERSION2)
    else(Python_ADDITIONAL_VERSIONS)
      set(Python_ADDITIONAL_VERSIONS)
      list(APPEND Python_ADDITIONAL_VERSIONS ${TFEL_PYTHON_VERSION})
    endif(Python_ADDITIONAL_VERSIONS)
  endif(TFEL_PYTHON_BINDINGS)
  if(Python_ADDITIONAL_VERSIONS)
    find_package(PythonLibs ${Python_ADDITIONAL_VERSIONS} REQUIRED)
  else(Python_ADDITIONAL_VERSIONS)
    find_package(PythonLibs REQUIRED)
  endif(Python_ADDITIONAL_VERSIONS)
  find_package(PythonInterp ${PYTHONLIBS_VERSION_STRING} REQUIRED)
  get_filename_component(PYTHON_LIBRARY_PATH ${PYTHON_LIBRARIES} PATH)
  get_filename_component(PYTHON_LIBRARY_FULL ${PYTHON_LIBRARIES} NAME)
  string(REGEX REPLACE "lib(.+)\\.(.+)$" "\\1"
    PYTHON_LIBRARY ${PYTHON_LIBRARY_FULL})
  message(STATUS "found python")
  message(STATUS "python executable     ${PYTHON_EXECUTABLE}")
  message(STATUS "python include path   ${PYTHON_INCLUDE_DIRS}")
  message(STATUS "python libraries path ${PYTHON_LIBRARY_PATH}")
  message(STATUS "python library        ${PYTHON_LIBRARY}")
endif(TFEL_PYTHON_BINDINGS OR enable-python)

#java
option(enable-java "enable java support" OFF)
if(enable-java)
  check_if_material_property_interface_is_supported("java")
  find_package(Java)
  if(NOT Java_JAVA_EXECUTABLE)
    message(FATAL_ERROR "java not found. java is mandatory for java suppot.")
  endif(NOT Java_JAVA_EXECUTABLE)
  if(NOT Java_JAVAC_EXECUTABLE)
    message(FATAL_ERROR "javac not found. javac is mandatory for java suppot.")
  endif(NOT Java_JAVAC_EXECUTABLE)
  find_package(JNI)
  if(NOT JNI_FOUND)
    message(FATAL_ERROR "Java native interface not found. Java native interface is mandatory for java suppot.")
  endif(NOT JNI_FOUND)
  message(STATUS "java  path       : ${Java_JAVA_EXECUTABLE}")
  message(STATUS "javac path       : ${Java_JAVAC_EXECUTABLE}")
  message(STATUS "jni include path : ${JNI_INCLUDE_DIRS}")
  foreach(jni_include ${JNI_INCLUDE_DIRS})
    set(JNI_INCLUDES_FLAGS "${JNI_INCLUDES_FLAGS} -I${jni_include}")
  endforeach(jni_include ${JNI_INCLUDE_DIRS})
  include(UseJava)
  set(MFM_JAVA_INTERFACE ON)
  set(mfront-properties-interfaces "java" ${mfront-properties-interfaces})
endif(enable-java)

option(enable-octave   "generate octave-interface for material properties"      OFF)
if(enable-octave)
  check_if_material_property_interface_is_supported("octave")
  set(MFM_OCTAVE_INTERFACE ON)
  include(cmake/modules/octave.cmake)
  link_directories(${OCTAVE_LIBRARIES_DIRS})
  set(mfront-properties-interfaces "octave" ${mfront-properties-interfaces})
endif(enable-octave)

# MFront generic interfaces
option(enable-generic-behaviours "generate generic interface for mechanical behaviours"  OFF)
if(enable-generic-behaviours)
  check_if_behaviour_interface_is_supported("generic")
  set(MFM_GENERIC_BEHAVIOUR_INTERFACE ON)
  set(mfront-behaviours-interfaces "generic"
  ${mfront-behaviours-interfaces})
  include(cmake/modules/generic-behaviours.cmake)
endif(enable-generic-behaviours)

# castem
option(enable-castem "generate castem interface for material properties" OFF)
option(enable-castem-behaviours "generate castem interface for mechanical behaviours"  OFF)
if(enable-castem OR enable-castem-behaviours)
  include(cmake/modules/castem-unix-type.cmake)
endif(enable-castem OR enable-castem-behaviours)
if(enable-castem)
  check_if_material_property_interface_is_supported("castem")
  set(MFM_CASTEM_INTERFACE ON)
  set(mfront-properties-interfaces "castem" ${mfront-properties-interfaces})
endif(enable-castem)
if(enable-castem-behaviours)
  check_if_behaviour_interface_is_supported("castem")
  set(MFM_CASTEM_BEHAVIOUR_INTERFACE ON)
  find_tfel_library(CastemInterface)
  set(mfront-behaviours-interfaces "castem"
  ${mfront-behaviours-interfaces})
  include(cmake/modules/castem.cmake)
endif(enable-castem-behaviours)

# aster
option(enable-aster   "generate aster-interface for mechanical behaviours"  OFF)
if(enable-aster)
  check_if_behaviour_interface_is_supported("aster")
  set(MFM_ASTER_INTERFACE ON)
  find_tfel_library(AsterInterface)
  set(mfront-behaviours-interfaces "aster" ${mfront-behaviours-interfaces})
  include(cmake/modules/aster.cmake)
endif(enable-aster)

# europlexus
option(enable-europlexus   "generate europlexus-interface for mechanical behaviours"  OFF)
if(enable-europlexus)
  check_if_behaviour_interface_is_supported("epx")
  set(MFM_EUROPLEXUS_INTERFACE ON)
  find_tfel_library(EuroplexusInterface)
  set(mfront-behaviours-interfaces "epx" ${mfront-behaviours-interfaces})
  include(cmake/modules/europlexus.cmake)
endif(enable-europlexus)

# cyrano
option(enable-cyrano   "generate cyrano-interface for mechanical behaviours"  OFF)
if(enable-cyrano)
  check_if_behaviour_interface_is_supported("cyrano")
  set(MFM_CYRANO_INTERFACE ON)
  find_tfel_library(CyranoInterface)
  set(mfront-behaviours-interfaces "cyrano" ${mfront-behaviours-interfaces})
  include(cmake/modules/cyrano.cmake)
endif(enable-cyrano)

# abaqus
option(enable-abaqus   "generate abaqus-interface for mechanical behaviours"  OFF)
if(enable-abaqus)
  check_if_behaviour_interface_is_supported("abaqus")
  set(MFM_ABAQUS_INTERFACE ON)
  find_tfel_library(AbaqusInterface)
  set(mfront-behaviours-interfaces "abaqus" ${mfront-behaviours-interfaces})
  include(cmake/modules/abaqus.cmake)
endif(enable-abaqus)

# abaqus-explicit
option(enable-abaqus-explicit   "generate abaqus-explicit-interface for mechanical behaviours"  OFF)
if(enable-abaqus-explicit)
  check_if_behaviour_interface_is_supported("abaqusexplicit")
  set(MFM_ABAQUS_EXPLICIT_INTERFACE ON)
  find_tfel_library(AbaqusInterface)
  set(mfront-behaviours-interfaces "abaqusexplicit"
    ${mfront-behaviours-interfaces})
  include(cmake/modules/abaqus-explicit.cmake)
endif(enable-abaqus-explicit)

# ansys
option(enable-ansys "generate ansys-interface for mechanical behaviours"  OFF)
if(enable-ansys)
  check_if_behaviour_interface_is_supported("ansys")
  set(MFM_ANSYS_INTERFACE ON)
  find_tfel_library(AnsysInterface)
  set(mfront-behaviours-interfaces "ansys" ${mfront-behaviours-interfaces})
  include(cmake/modules/ansys.cmake)
endif(enable-ansys)

# calculix
option(enable-calculix "generate calculix-interface for mechanical behaviours"  OFF)
if(enable-calculix)
  check_if_behaviour_interface_is_supported("calculix")
  set(MFM_CALCULIX_INTERFACE ON)
  find_tfel_library(CalculiXInterface)
  set(mfront-behaviours-interfaces "calculix"
    ${mfront-behaviours-interfaces})
  include(cmake/modules/calculix.cmake)
endif(enable-calculix)

# zmat
option(enable-zmat   "generate zmat-interface for mechanical behaviours"  OFF)
if(enable-zmat)
  check_if_behaviour_interface_is_supported("zmat")
  include(cmake/modules/zset.cmake)
  set(MFM_ZMAT_INTERFACE ON)
  set(mfront-behaviours-interfaces "zmat" ${mfront-behaviours-interfaces})
endif(enable-zmat)

# summary
if(mfront-properties-interfaces)
  message(STATUS "Material properties interfaces : ${mfront-properties-interfaces}")
endif(mfront-properties-interfaces)
if(mfront-behaviours-interfaces)
  message(STATUS "Material behaviours interfaces : ${mfront-behaviours-interfaces}")
endif(mfront-behaviours-interfaces)

#compiler options
include(cmake/modules/compiler.cmake)

# testing
set(CTEST_CONFIGURATION_TYPE "${JOB_BUILD_CONFIGURATION}")
# (must be placed *before* any add_subdirectory, cmake bug ?)
enable_testing()
if(CMAKE_CONFIGURATION_TYPES)
  add_custom_target(check COMMAND 
    ${CMAKE_CTEST_COMMAND} -T test -C $<CONFIGURATION>)
else(CMAKE_CONFIGURATION_TYPES)
  add_custom_target(check COMMAND 
    ${CMAKE_CTEST_COMMAND} -T test )
endif(CMAKE_CONFIGURATION_TYPES)

add_subdirectory(generic-behaviours)
add_subdirectory(materials)

# if(TFEL_CHECK)
#   add_test(NAME tfel_check COMMAND ${TFEL_CHECK})
# endif(TFEL_CHECK)
