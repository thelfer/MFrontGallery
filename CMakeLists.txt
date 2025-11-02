cmake_minimum_required(VERSION 3.10.0)

cmake_policy(SET CMP0048 NEW)
string(CONCAT MFrontGalleryDescription
	"The MFrontGallery project provides "
	"a cmake infrastructure to build material knowledge "
    "management projects bases on MFront and illustrates "
    "its usage by a selected set of MFront implementations")
set(MFrontGalleryDevelopmentVersion ON)
project(MFrontGallery
        VERSION 3.0.0
        DESCRIPTION  "${MFrontGalleryDescription}"
        HOMEPAGE_URL "https://thelfer.github.io/MFrontGallery/web/index.html")
set(PACKAGE mfront-gallery)

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
add_subdirectory(unit-tests/behaviours-without-temperature)
if(TFEL_MADNEX_SUPPORT)
add_subdirectory(unit-tests/madnex/material-properties-1)
add_subdirectory(unit-tests/madnex/material-properties-2)
add_subdirectory(unit-tests/madnex/behaviours-1)
add_subdirectory(unit-tests/madnex/behaviours-2)
add_subdirectory(unit-tests/madnex/models-1)
add_subdirectory(unit-tests/madnex/models-2)
endif(TFEL_MADNEX_SUPPORT)
add_subdirectory(unit-tests/tfel-check)

if(enable-website)
  add_subdirectory(docs/web)
endif(enable-website)

# Packaging
if(MFrontGalleryDevelopmentVersion)
  set(CPACK_PACKAGE_VERSION_PATCH "${CMAKE_PROJECT_VERSION_PATCH}-dev")
endif()
set(CPACK_RESOURCE_FILE_LICENSE "${CMAKE_SOURCE_DIR}/LGPL-3.0.txt")
set(CPACK_VERBATIM_VARIABLES YES)
if(NOT CPACK_SOURCE_GENERATOR)
  set(CPACK_SOURCE_GENERATOR "TGZ")
endif(NOT CPACK_SOURCE_GENERATOR)
set(CPACK_SOURCE_IGNORE_FILES "build;/\\.git/;.*~")
include(CPack)
