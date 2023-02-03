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
- **Compilation**, which builds the shared libraries associated with the
  selected interfaces.
- **Unit testing**, which allows to verify that no regression has occured.
- **Installation**, which can deploy the built shared libraries.

# Cloning the `master` branch of the `MFrontGallery` project

The `master` branch of the `MFrontGallery` project can be cloned as
follows:
 
~~~~{.bash}
$ git clone https://github.com/thelfer/MFrontGallery
~~~~

# Configuration

The sources are assumed to be in the `MFrontGallery` directory. While
not strictly required, it is convienient to create a `build` directory
(the example assumes it to be at the same level as the `MFrontGallery`
directory):

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

### Variables affecting the compilation of `MFront` files

#### Option passed to domain specific languages

The following variables can be used to define options passed to domain
specific languages:

- `MFM_BUILD_IDENTIFIER`: string variable specifying a build identifier.
  By default, the build identifier exported by `MFront` will be empty.
  Defining this variable is only supported when using a version of
  `TFEL` greater than `4.1`.
- `MFM_TREAT_PARAMETERS_AS_STATIC_VARIABLES`: boolean variable stating
  if the parameters shall be treated as static variables. By default,
  parameters are not defined as static variables by `MFront` allowing
  their modifications at runtime. The way of modifying parameters
  depends on the interface considered. Defining this variable is only
  supported when using a version of `TFEL` greater than `4.1`.
- `MFM_ALLOW_PARAMETERS_INITIALIZATION_FROM_FILE`: boolean variable
  stating if `MFront` shall generate code for reading parameters from an
  external text file located in the current directory at runtime, a
  feature supported by most interfaces. By default, `MFront` does
  generate this code. Defining this variable is only supported when
  using a version of `TFEL` greater than `4.1`.

`MFrontGallery` may use more refined variables to define the options
passed to `MFront`' domain specific languages. The name of those
variables depends on the name of the considered interface and the type
of the material knowledge considered.

Assuming that the `castem` interface as been enabled for behaviours, the
build identifier passed to the domain specific languages of `MFront`'
files compiled with this interface is defined by one of the following
variables:

- `MFM_CASTEM_BEHAVIOURS_BUILD_IDENTIFIER`
- `MFM_CASTEM_BUILD_IDENTIFIER`
- `MFM_BUILD_IDENTIFIER`

The definition of all those variables is optional.

### Interface selection

#### Interfaces to material properties

- `enable-c`: enable compilation of material properties using the `c`
  interface.
- `enable-c++`: enable compilation of material properties using the
  `C++` interface.
- `enable-excel`: enable compilation of material properties using the
  `excel` interface.
- `enable-fortran`: enable compilation of material properties using the
  `fortran` interface.
- `enable-python`: Enable the generation of `python` modules. Note that
  the `Python_ADDITIONAL_VERSIONS` selects the `python` version to use.
  Only the major and minor version of python shall be passed, not the
  revision version (otherwise the detection fails).
- `enable-java`: enable compilation of material properties using the
  `java` interface.
- `enable-octave`: enable compilation of material properties using the
  `octave` interface.
- `enable-generic-material-properties`: enable compilation of material
  properties using the `generic` interface.

See also the `enable-castem-material-properties` and
`enable-cyrano-material-properties` options below.

#### Interfaces to behaviours

- `enable-generic-behaviours`: enable compilation of behaviours using
  the `generic` interface.
- `enable-aster`: enable compilation of behaviours using the `aster`
  interface.
- `enable-diana-fea`: enable compilation of behaviours using the
  `diana-fea` interface.
- `enable-europlexus`: enable compilation of behaviours using the
  `europlexus` interface.
- `enable-abaqus`: enable compilation of behaviours using the
  `abaqus` interface.
- `enable-abaqus-explicit`: enable compilation of behaviours using the
  `abaqus-explicit` interface.
- `enable-ansys`: enable compilation of behaviours using the `ansys`
  interface.
- `enable-calculix`: enable compilation of behaviours using the
  `calculix` interface.
- `enable-zmat`: enable compilation of behaviours using the `zmat`
  interface.

See also the `enable-castem-behaviours` and `enable-cyrano-behaviours`
below.

#### Interfaces to models

- `enable-generic-models`: enable compilation of models
  using the `generic` interface.

#### Options related to the `Cast3M` solver

- `enable-castem`: enable the compilation of material properties and
  behaviours using the `castem` interface. This option is equivalent to
  using enabling both options `enable-castem-material-properties` and
  `enable-castem-behaviours`.
- `enable-castem-material-properties`: enable compilation of material
  properties using the `castem` interface.
- `enable-castem-behaviours`: enable compilation of behaviours using the
  `castem` interface.
- `enable-castem-pleiades`: option specifying if the `PLEIADES` version
  of the `Cast3M` finite element solver is used.

#### Options related to the `Cyrano` solver

- `enable-cyrano`: enable the compilation of material properties and
  behaviours using the `cyrano` interface. This option is equivalent to
  using enabling both options `enable-castem-material-properties` and
  `enable-castem-behaviours`.
- `enable-cyrano-material-properties`: enable compilation of material
  properties using the `cyrano` interface.
- `enable-cyrano-behaviours`: enable compilation of behaviours using the
  `cyrano` interface.

### Debug options

- `enable-mfront-debug-mode`: appends --debug to the options passed to
  `MFront`.
- `enable-mtest-file-generation-on-failure`: appends
  `--@GenerateMTestFileOnFailure=true` to the options passed to `MFront`
  when compiling behaviours.

### Generation of the website

The `enable-website` option selects if the website of the project shall
be generated. This requires `pandoc` (mandatory) and `pandoc-crossref`
(optional) to be available.

### Additional behaviours

- `enable-fortran-behaviours-wrappers`: This option enables the
  compilation of behaviours based at least partially on the `fortran`
  language.

### Automatic documentation generation using `mfront-doc`

- `enable-mfront-documentation-generation`: this option enable or
  disable the generation of a documentation using `mfront-doc`. This
  option is disabled by default.

### Options related to tests

- `enable-random-tests`: By defaut, tests made with `MTest` are runned
  five times, one for each rounding modes defined by the IEEE754
  standard and one where the rounding mode is changed randomly at
  various stages of the test. This option removes the latest one.

### Options related to compilation

- `enable-portable-build`: This option disables machine specific
  instructions (i.e. removes the `--march=native` flag when using
  `gcc`).
- `enable-fast-math`: This option enables flags that allow the compiler
  to discard IEEE754 rules. When using `gcc`, this option appends
  `--fast-math` to the compiler flag.
- `enable-sanitize-options`: This option adds some sanitizers.
- `enable-developer-warnings`: This option appends additional warnings,
  mostly meaningful for the developpers.

### Compilers and compile flag selections

The `CC` and `CC` environment variables are used respectively to 

If the boolean variable `USE_EXTERNAL_COMPILER_FLAGS` is set to true
(i.e. to the `ON` value following `cmake` conventions), the `CFLAGS` and
`CXXFLAGS` environment variables are used to define the compile flags
used to compile `C` and `C++` sources respectively.

#### Option specific to `gcc`

- `enable-glibcxx-debug`: This option appends compiler flags to enable
  debug feature.

#### Option specific to `clang`

- `enable-libcxx`: This option forces the use of `libcxx` on `linux`
  when using `clang`.

## `TFEL` executables

By default, the configuration step assumes that the various binaries
provided by the `TFEL` project (including `mfront`) can be found in
the current environment.

A `cmake` variable named `TFEL_FLAVOUR` can be use to specify a suffix
to programs and libraries associated with `TFEL`. For example, if
`TFEL_FLAVOUR` is set to `debug`, an executable named `mfront-debug` is
searched.

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
