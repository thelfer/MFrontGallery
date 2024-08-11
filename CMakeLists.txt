project(MFrontGallery)
set(PACKAGE mfront-gallery)

cmake_minimum_required(VERSION 3.12.0)

include(cmake/modules/mfm.cmake)

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
add_subdirectory(mfront-book-examples)
add_subdirectory(unit-tests/mfront-wrappers)
# add_subdirectory(unit-tests/behaviours-without-temperature)
add_subdirectory(unit-tests/madnex/material-properties-1)
add_subdirectory(unit-tests/madnex/material-properties-2)
add_subdirectory(unit-tests/madnex/behaviours-1)
add_subdirectory(unit-tests/madnex/behaviours-2)
add_subdirectory(unit-tests/madnex/models-1)
add_subdirectory(unit-tests/madnex/models-2)
add_subdirectory(unit-tests/tfel-check)

if(enable-website)
  add_subdirectory(docs/web)
endif(enable-website)

set(CPACK_VERBATIM_VARIABLES YES)
set(CPACK_SOURCE_GENERATOR "TGZ")
set(CPACK_SOURCE_IGNORE_FILES "build;/\\.git/;.*~")
include(CPack)
