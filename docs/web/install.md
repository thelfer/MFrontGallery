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

The interfaces are selected by a set of `cmake` flags prefixed by
`enable`. In the previous command, we only selected the `generic` and
`ansys` interfaces.

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
