cmake_policy(SET CMP0007 NEW)
cmake_policy(SET CMP0053 NEW)
cmake_policy(VERSION 3.31)
cmake_policy(SET CMP0177 NEW)

set(MFM_USE_FORTRAN OFF)

function(mfm_install_library lib)
  if(WIN32)
	if(${CMAKE_CXX_COMPILER_ID} STREQUAL "GNU")
	  set_target_properties(${lib}
	    PROPERTIES LINK_FLAGS "-Wl,--kill-at -Wl,--no-undefined")
    endif(${CMAKE_CXX_COMPILER_ID} STREQUAL "GNU")
    install(TARGETS ${lib} DESTINATION bin)
  else(WIN32)
	install(TARGETS ${lib} DESTINATION lib${LIB_SUFFIX})
  endif(WIN32)
endfunction(mfm_install_library)

# portable-build
option(enable-portable-build "produce binary that can be shared between various machine (same architecture, same gcc version, different processors" OFF)

include(cmake/modules/generalmacros.cmake)
# load the list of rounding modes defined by the IEEE754 standard
include(cmake/modules/ieee754.cmake)

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
  set(MFM_USE_FORTRAN ON)
  set(MFM_FORTRAN_INTERFACE ON)
  message(STATUS "fortran interface for material properties support enabled")
  set(mfront-properties-interfaces "fortran" ${mfront-properties-interfaces})
else(enable-fortran)
  message(STATUS "fortran support disabled")
endif(enable-fortran)

option(enable-fortran-behaviours-wrappers
  "generate examples of how to use MFront as wrappers for behaviours writtent in Fortran" OFF)
if(enable-fortran-behaviours-wrappers)
  set(MFM_USE_FORTRAN ON)
  message(STATUS "fortran behaviour wrappers enabled")
endif(enable-fortran-behaviours-wrappers) 

if(MFM_USE_FORTRAN)
  enable_language (Fortran)
endif(MFM_USE_FORTRAN)

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
  find_package(Python REQUIRED COMPONENTS Interpreter Development NumPy)
  get_filename_component(PYTHON_LIBRARY_PATH ${Python_LIBRARIES} PATH)
  get_filename_component(PYTHON_LIBRARY_FULL ${Python_LIBRARIES} NAME)
  string(REGEX REPLACE "lib(.+)\\.(.+)$" "\\1"
    PYTHON_LIBRARY ${PYTHON_LIBRARY_FULL})
  message(STATUS "found python          ${Python_VERSION}")
  message(STATUS "python executable     ${Python_EXECUTABLE}")
  message(STATUS "python include path   ${Python_INCLUDE_DIRS}")
  message(STATUS "python libraries path ${PYTHON_LIBRARY_PATH}")
  message(STATUS "python library        ${PYTHON_LIBRARY}")
endif(TFEL_PYTHON_BINDINGS OR enable-python)

##java
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
option(enable-generic "generate generic interfaces"  OFF)
option(enable-generic-material-properties "generate generic interface for material properties"  OFF)
option(enable-generic-behaviours "generate generic interface for behaviours"  OFF)
option(enable-generic-models "generate generic interface for models"  OFF)
if(enable-generic)
  set(enable-generic-material-properties ON)
  set(enable-generic-behaviours ON)
  set(enable-generic-models ON)
endif(enable-generic)
if(enable-generic-material-properties)
  check_if_material_property_interface_is_supported("generic")
  set(MFM_GENERIC_BEHAVIOUR_INTERFACE ON)
  set(mfront-properties-interfaces "generic"
  ${mfront-properties-interfaces})
#  include(cmake/modules/generic-material-properties.cmake)
endif(enable-generic-material-properties)
if(enable-generic-behaviours)
  check_if_behaviour_interface_is_supported("generic")
  set(MFM_GENERIC_BEHAVIOUR_INTERFACE ON)
  set(mfront-behaviours-interfaces "generic"
  ${mfront-behaviours-interfaces})
  include(cmake/modules/generic-behaviours.cmake)
endif(enable-generic-behaviours)
if(enable-generic-models)
  check_if_model_interface_is_supported("generic")
  set(MFM_GENERIC_MODEL_INTERFACE ON)
  set(mfront-models-interfaces "generic"
  ${mfront-models-interfaces})
#  include(cmake/modules/generic-models.cmake)
endif(enable-generic-models)

# castem
option(enable-castem "generate castem interface for material properties and mechanical behaviours" OFF)
option(enable-castem-material-properties "generate castem interface for material properties"  OFF)
option(enable-castem-behaviours          "generate castem interface for mechanical behaviours"  OFF)
option(enable-castem-models          "generate castem interface for mechanical models"  OFF)
if(enable-castem)
  set(enable-castem-material-properties ON)
  set(enable-castem-behaviours ON)
  set(enable-castem-models ON)
endif(enable-castem)
if(enable-castem-material-properties OR enable-castem-behaviours OR enable-castem-models)
  include(cmake/modules/castem-unix-type.cmake)
  include(cmake/modules/castem.cmake)
endif(enable-castem-material-properties OR enable-castem-behaviours OR enable-castem-models)
if(enable-castem-material-properties)
  check_if_material_property_interface_is_supported("castem")
  set(MFM_CASTEM_INTERFACE ON)
  set(mfront-properties-interfaces "castem" ${mfront-properties-interfaces})
endif(enable-castem-material-properties)
if(enable-castem-behaviours)
  check_if_behaviour_interface_is_supported("castem")
  check_if_behaviour_interface_is_supported("castem21")
  set(MFM_CASTEM_BEHAVIOUR_INTERFACE ON)
  find_tfel_library(CastemInterface)
  set(mfront-behaviours-interfaces "castem"
  ${mfront-behaviours-interfaces})
  set(mfront-behaviours-interfaces "castem21"
  ${mfront-behaviours-interfaces})
endif(enable-castem-behaviours)
if(enable-castem-models)
  check_if_behaviour_interface_is_supported("castem")
  check_if_model_interface_is_supported("castem")
  set(MFM_CASTEM_MODEL_INTERFACE ON)
  find_tfel_library(CastemInterface)
  set(mfront-models-interfaces "castem"
  ${mfront-models-interfaces})
endif(enable-castem-models)

# aster
option(enable-aster   "generate aster-interface for mechanical behaviours"  OFF)
if(enable-aster)
  check_if_behaviour_interface_is_supported("aster")
  set(MFM_ASTER_INTERFACE ON)
  find_tfel_library(AsterInterface)
  set(mfront-behaviours-interfaces "aster" ${mfront-behaviours-interfaces})
  include(cmake/modules/aster.cmake)
endif(enable-aster)

option(enable-diana-fea   "generate DIANA-FEA interface for mechanical behaviours"  OFF)
if(enable-diana-fea)
  check_if_behaviour_interface_is_supported("dianafea")
  set(MFM_DIANA_FEA_INTERFACE ON)
  find_tfel_library(DianaFEAInterface)
  set(mfront-behaviours-interfaces "dianafea" ${mfront-behaviours-interfaces})
  include(cmake/modules/diana-fea.cmake)
endif(enable-diana-fea)

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
option(enable-cyrano "generate cyrano interface for material properties and mechanical behaviours" OFF)
option(enable-cyrano-material-properties "generate cyrano interface for material properties"  OFF)
option(enable-cyrano-behaviours          "generate cyrano interface for mechanical behaviours"  OFF)
if(enable-cyrano)
  set(enable-cyrano-material-properties ON)
  set(enable-cyrano-behaviours ON)
endif(enable-cyrano)
if(enable-cyrano-material-properties)
  check_if_material_property_interface_is_supported("cyrano")
  set(mfront-properties-interfaces "cyrano" ${mfront-properties-interfaces})
endif(enable-cyrano-material-properties)
if(enable-cyrano-behaviours)
  check_if_behaviour_interface_is_supported("cyrano")
  find_tfel_library(CyranoInterface)
  set(mfront-behaviours-interfaces "cyrano" ${mfront-behaviours-interfaces})
  include(cmake/modules/cyrano.cmake)
endif(enable-cyrano-behaviours)

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
  message(STATUS "Behaviours interfaces : ${mfront-behaviours-interfaces}")
endif(mfront-behaviours-interfaces)
if(mfront-models-interfaces)
  message(STATUS "Models interfaces : ${mfront-models-interfaces}")
endif(mfront-models-interfaces)
#compiler options
include(cmake/modules/compiler.cmake)

include(cmake/modules/tfel-check.cmake)

add_custom_target(doc)

# Documentation
option(enable-website "enable generation of the website" ON)
if(enable-website)
  add_custom_target(website)
  add_dependencies(doc website)
  include(cmake/modules/pandoc.cmake)
endif(enable-website)

# Function for installing documentation
function(mfm_install_doc file directory component)
  if(MFM_APPEND_SUFFIX)
    install(FILES ${file}
      DESTINATION share/doc/mfm-${MFM_SUFFIX}/${directory}
      COMPONENT ${component}
      ${ARGN})
  else(MFM_APPEND_SUFFIX)
    install(FILES ${file}
      DESTINATION share/doc/mfm/${directory}
      COMPONENT ${component}
      ${ARGN})
  endif(MFM_APPEND_SUFFIX)
endfunction(mfm_install_doc)

# Looking for LaTeX
option(enable-reference-doc "enable generation of the reference documentation" OFF)
if(enable-reference-doc)
  add_custom_target(doc-pdf)
  add_dependencies(doc doc-pdf)
  include(cmake/modules/latex.cmake)
endif(enable-reference-doc)

# Looking for Gnuplot
include(cmake/modules/gnuplot.cmake)
