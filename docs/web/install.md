---
title: Installation guide
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

After downloading or cloning the sources of the `MFrontGallery` project,
a typical usage of the project is divided in four steps (common to most
`cmake` projects):

- **Configuration**, which allows to select the interfaces to be used.
- **Compilation**, which builds the shared libraries associated wit the
  selected interfaces.
- **Unit testing**, which allows to verify that no regression occured.
- **Installation**, which can deploy the build shared libraries.

# Cloning the `master` branch of the `MFrontGallery` project

The `master` branch of the `MFrontGallery` project can be cloned as
follows:
 
~~~~{.bash}
$ git clone https://github.com/thelfer/MFrontGallery
~~~~

# Configuration

The sources are assumed to be in the `MFrontGallery` directory. While
not strictly required, it is convienient to create a `build` directory:

~~~~{.bash}
$ mkdir build
$ cd build
~~~~

The configuration step is triggered by calling `cmake`:

~~~~{.bash}
$ cmake  ../MFrontGallery/ [options]
~~~~

The interfaces are selected by a set of `cmake` options prefixed by
`enable` as described in the next paragraph.

## Available options

### Standard `cmake` variables

- `CMAKE_BUILD_TYPE`: This variable specifies the kind of build
  selected. Typical values are 'Release' and 'Debug'.
- `CMAKE_INSTALL_PREFIX`: specify where the project shall be installed.
- `CMAKE_TOOLCHAIN_FILE`: specify a tool chain file (for
  cross-compilation).

### Compilers and compile flag selections

The `CC` and `CC` environment variables are used respectively to 

If the boolean variable `USE_EXTERNAL_COMPILER_FLAGS` is set to true
(i.e. to the `ON` value following `cmake` conventions), the `CFLAGS` and
`CXXFLAGS` environment variables are used to define the compile flags
used to compile `C` and `C++` sources respectively.

### Interface selection

#### Interface to material properties

- `enable-c`:
- `enable-c++`:
- `enable-excel`:
- `enable-fortran`:
- `enable-python`: Enable the generation of `python` modules. Note that
  the `Python_ADDITIONAL_VERSIONS` selects the `python` version to use.
  Only the major and minor version of python shall be passed, not the
  revision version (otherwise the detection fails).
- `enable-java`:
- `enable-octave`:

See also the `enable-castem-material-properties` and
`enable-cyrano-material-properties` options below.

#### Interface to behaviours

- `enable-generic-behaviours`:
- `enable-aster`:
- `enable-diana-fea`:
- `enable-europlexus`:
- `enable-abaqus`:
- `enable-abaqus-explicit`:
- `enable-ansys`:
- `enable-calculix`:
- `enable-zmat`:

See also the `enable-castem-behaviours` and `enable-cyrano-behaviours`
below.

#### Options related to the `Cast3M` solver

- `enable-castem`:
- `enable-castem-material-properties`:
- `enable-castem-behaviours`:
- `enable-castem-pleiades`:

#### Options related to the `Cyrano` solver

- `enable-cyrano`:
- `enable-cyrano-material-properties`:
- `enable-cyrano-behaviours`:

### Generation of the website

The `enable-website` option selects if the website of the project shall
be generated. This requires `pandoc` (mandatory) and `pandoc-crossref`
(optional) to be available.

### Additional behaviours

- `enable-fortran-behaviours-wrappers`:

### Options related to tests

- `enable-random-tests`:

### Options related to compilation

- `enable-portable-build`:
- `enable-fast-math:
- `enable-sanitize-options`:
- `enable-developer-warnings`:

#### Option specific to `gcc`

- `enable-glibcxx-debug`:

#### Option specific to `clang`

- `enable-libcxx`:

## `TFEL` executables

By default, the configuration step assumes that the various binaries
provided by the `TFEL` project (including `mfront`) can be found in
the current environment.

# Compilation

The selected libraries can be built as follows:

~~~~{.bash}
$ cmake --build . --target all
~~~~

# Unit tests

Unit tests can be executed as follows:

~~~~{.bash}
$ cmake --build . --target check
~~~~

# Installation

The built shared libraries can be installed as follows:

~~~~{.bash}
$ cmake --build . --target install
~~~~
