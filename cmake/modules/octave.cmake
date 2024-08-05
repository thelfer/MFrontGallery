# - Find Octave
# GNU Octave is a high-level interpreted language, primarily intended for numerical computations.
# available at http://www.gnu.org/software/octave/
#
# This module defines: 
#  OCTAVE_EXECUTABLE           - octave interpreter
#  OCTAVE_VERSION_STRING       - octave version string
#  OCTAVE_MAJOR_VERSION        - major version
#  OCTAVE_MINOR_VERSION        - minor version
#  OCTAVE_PATCH_VERSION        - patch version

# find the tfel library
if(OCTAVE_INSTALL_PATH)
  set(OCTAVEHOME "${OCTAVE_INSTALL_PATH}")
else(OCTAVE_INSTALL_PATH)
  set(OCTAVEHOME $ENV{OCTAVEHOME})
endif(OCTAVE_INSTALL_PATH)

# octave
find_program(OCTAVE_EXECUTABLE
  NAMES octave
  HINTS "${OCTAVEHOME}/bin")
# octave-config
find_program(OCTAVE_CONFIG_EXECUTABLE
  NAMES octave-config
  HINTS "${OCTAVEHOME}/bin")
# mkoctfile
find_program(MKOCTFILE_EXECUTABLE
  NAMES mkoctfile)

if((NOT OCTAVE_CONFIG_EXECUTABLE) OR NOT MKOCTFILE_EXECUTABLE)
  message(FATAL_ERROR "octave-config or mkoctfile not found")
endif((NOT OCTAVE_CONFIG_EXECUTABLE) OR NOT MKOCTFILE_EXECUTABLE)

execute_process ( COMMAND ${OCTAVE_CONFIG_EXECUTABLE} -v
  OUTPUT_VARIABLE OCTAVE_VERSION_STRING
  OUTPUT_STRIP_TRAILING_WHITESPACE )    

if ( OCTAVE_VERSION_STRING )                 
  string ( REGEX REPLACE "([0-9]+)\\..*" "\\1" OCTAVE_MAJOR_VERSION ${OCTAVE_VERSION_STRING} )
  string ( REGEX REPLACE "[0-9]+\\.([0-9]+).*" "\\1" OCTAVE_MINOR_VERSION ${OCTAVE_VERSION_STRING} )
  string ( REGEX REPLACE "[0-9]+\\.[0-9]+\\.([0-9]+).*" "\\1" OCTAVE_PATCH_VERSION ${OCTAVE_VERSION_STRING} )               
endif ()                  

# location of the octave headers
execute_process ( COMMAND ${MKOCTFILE_EXECUTABLE} -p INCFLAGS
  OUTPUT_VARIABLE OCTAVE_INCLUDE_DIRS
  OUTPUT_STRIP_TRAILING_WHITESPACE )    
# location of the octave libraries
execute_process ( COMMAND ${MKOCTFILE_EXECUTABLE} -p LIBDIR
  OUTPUT_VARIABLE OCTAVE_LIBRARY_PATH
  OUTPUT_STRIP_TRAILING_WHITESPACE )    
execute_process ( COMMAND ${MKOCTFILE_EXECUTABLE} -p OCTAVE_VERSION
  OUTPUT_VARIABLE OCTAVE_VERSION
  OUTPUT_STRIP_TRAILING_WHITESPACE )    

# octave libraries
macro(find_octave_library name)
  find_library(${name}
    NAMES ${name}
    HINTS ${OCTAVE_LIBRARY_PATH}
    ${OCTAVE_LIBRARY_PATH}/octave/${OCTAVE_VERSION})
endmacro(find_octave_library name)

find_octave_library(octave)
find_octave_library(octinterp)
if(NOT octave)
   MESSAGE(FATAL_ERROR "octave library not found")
endif(NOT octave)
if(octinterp)
  set(OCTAVE_LIBRARIES ${octave} ${octinterp})
else(octinterp)
  set(OCTAVE_LIBRARIES ${octave})
endif(octinterp)

# summary
if((NOT OCTAVE_CONFIG_EXECUTABLE) OR
   (NOT MKOCTFILE_EXECUTABLE) OR
   (NOT OCTAVE_INCLUDE_DIRS) OR
   (NOT OCTAVE_LIBRARIES))
  message(FATAL_ERROR "failed to get proper information about octave")
endif()

message(STATUS "octave-config             : ${OCTAVE_CONFIG_EXECUTABLE}")
message(STATUS "mkoctfile                 : ${MKOCTFILE_EXECUTABLE}")
message(STATUS "octave_headers location   : ${OCTAVE_INCLUDE_DIRS}")
message(STATUS "octave libraries          : ${OCTAVE_LIBRARIES}")

mark_as_advanced (
  OCTAVE_CONFIG_EXECUTABLE
  MKOCTFILE_EXECUTABLE 
  OCTAVE_LIBRARIES
  OCTAVE_LIBRARIES_DIRS
  OCTAVE_INCLUDE_DIRS
  OCTAVE_VERSION_STRING
  OCTAVE_MAJOR_VERSION
  OCTAVE_MINOR_VERSION
  OCTAVE_PATCH_VERSION)
