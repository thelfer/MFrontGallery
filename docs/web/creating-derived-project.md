---
title: Building an new material management project derived from `MFrontGallery`
author: Thomas Helfer
date: 18/12/2021
lang: en-EN
link-citations: true
colorlinks: true
figPrefixTemplate: "$$i$$"
tblPrefixTemplate: "$$i$$"
secPrefixTemplate: "$$i$$"
eqnPrefixTemplate: "($$i$$)"
---

This document describes how to setup a new project based on the [cmake
infrastructure](cmake-infrastructure.html) of the `MFrontGallery` and
`MFrontMaterials` projects.

# Fetching `cmake/modules` directory

To create a material management project derived from `MFrontGallery`,
just copy the contents of the `cmake/modules` directory in your local
directory.

If you intent to use `git` for version control, one easy way it to add
the `MFrontGallery` as a remote ressource and check out the `cmake`
repository from it as follows:

~~~~{.bash}
$ git remote add MFrontGallery https://github.com/thelfer/MFrontGallery
$ git fetch MFrontGallery master
$ git checkout MFrontGallery/master -- cmake 
~~~~

# Top-level `CMakeLists.txt` file

The next step consist of creating a top level `CMakeLists.txt` file.
Here is a minimal example:

~~~~{.cmake}
project(NewMaterialManagementProject)
set(PACKAGE new-material-management-project)
cmake_minimum_required(VERSION 3.0.2)

include(cmake/modules/mfm.cmake)

# testing
set(CTEST_CONFIGURATION_TYPE "${JOB_BUILD_CONFIGURATION}")
enable_testing()
if(CMAKE_CONFIGURATION_TYPES)
  add_custom_target(check COMMAND 
    ${CMAKE_CTEST_COMMAND} -T test -C $<CONFIGURATION>)
else(CMAKE_CONFIGURATION_TYPES)
  add_custom_target(check COMMAND 
    ${CMAKE_CTEST_COMMAND} -T test )
endif(CMAKE_CONFIGURATION_TYPES)

# add subdirectories here

add_subdirectory(materials)
~~~~

Now you are ready to create the subdirectory `materials` containing your
`MFront` files.

# Sources organization

The following organization of the `MFront` sources is highly
recommended:

~~~~{.bash}
materials/
├── material1
│   ├── behaviours
│   ├── models
│   └── properties
├── material2
│   ├── behaviours
│   ├── models
│   └── properties
└── ...
~~~~

This structure is used to automatically declare `MFront` search paths by
the `mfront_properties_library` and `mfront_behaviours_library`.

# Synchronizing the `cmake/modules` directory

The lastest version of `cmake/modules` directory can be retrieved as
follows:

~~~~{.bash}
$ git fetch MFrontGallery master
$ git checkout MFrontGallery/master cmake
~~~~
