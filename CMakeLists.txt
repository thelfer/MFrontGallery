project(MFrontGallery)
set(PACKAGE mfront-gallery)

cmake_minimum_required(VERSION 3.0.2)

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
add_subdirectory(unit-tests/mfront-wrappers)
add_subdirectory(unit-tests/behaviours-without-temperature)
add_subdirectory(unit-tests/madnex/behaviours)

if(enable-website)
  add_subdirectory(docs/web)
endif(enable-website)

# if(TFEL_CHECK)
#   add_test(NAME tfel_check COMMAND ${TFEL_CHECK})
# endif(TFEL_CHECK)
