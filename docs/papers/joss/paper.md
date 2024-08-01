---
title: The `MFrontGallery` project
tags:
  - MFront
  - Mechanical solvers
  - Mechanical behaviours
  - Material knowledge management
authors:
  - name: Thomas Helfer
    orcid: 0000-0003-2460-5816
    affiliation: 1
  - name: Maxence Wangermez 
    orcid: 0000-0002-3431-5081
    affiliation: 1
  - name: Eric Simo
    affiliation: 2, 3
  - name: Thomas Nagel
    orcid: 0000-0001-8459-4616
    affiliation: "3, 4"
  - name: Christian B. Silbermann
    affiliation: "3"
  - name: Lorenzo Riparbelli
    affiliation: "5"
affiliations:
  - name: CEA, DES, IRESNE, DEC, Cadarache F-13108 Saint-Paul-Lez-Durance, France
    index: 1
  - name: BGE TECHNOLOGY, Eschenstrasse 55, 31224 Peine, Germany
    index: 2
  - name: Geotechnical Institute, Technische Universität Bergakademie Freiberg, Gustav-Zeuner-Str. 1, 09599 Freiberg, Germany
    index: 3
  - name: Department of Environmental Informatics, Helmholtz Centre for Environmental Research -- UFZ, Permoserstr. 15, 04318 Leipzig, Germany
    index: 4
  - name: University of Florence, Dagri Dept., Florence, Italy.
    index: 5
date: March 2022
numbersections: true
bibliography: bibliography.bib
---

<!--
pandoc -f markdown  --bibliography=bibliography.bib --citeproc -V geometry:a4paper,margin=2cm --highlight-style=tango --citeproc paper.md -o paper.pdf
-->

# Introduction

`MFront` is an open-source code generator dedicated to material
knowledge [@Helfer2015;@cea_edf_mfront_2022] developed by the French
Alternative Energies and Atomic Energy Commission (CEA) and Électricité
de France (EDF). `MFront` is part of the `PLEIADES` numerical platform, which
is devoted to multi-physics nuclear fuel simulations and is developed
by CEA and its industrial partners EDF and Framatome. Since it was released
as an open-source project, `MFront` has been used in numerous
applications covering a wide range of materials (ceramics, metals,
concrete, woods, etc.) and physical phenomena (viscoplasticity,
plasticity, damage, etc.) [^mfront:publications].

[^mfront:publications]: See this page for a list of publications based
on `MFront`: <https://thelfer.github.io/tfel/web/publications.html>

`MFront` provides so-called interfaces to ensure that a material
knowledge is portable, i.e. can be used in large number of contexts. For
example, mechanical behaviours can be compiled for the following
commercial or academic solvers: [`Cast3M`](http://www-cast3m.cea.fr/),
[`code_aster`](https://code-aster.org),
[`Europlexus`](https://europlexus.jrc.ec.europa.eu/), `Abaqus/Standard`,
`Abaqus/Explicit`, `Ansys`, `AMITEX_FFTP`,
[`CalculiX`](http://www.calculix.de/),
[`ZSet`](http://www.zset-software.com/), [`DIANA
FEA`](https://dianafea.com/). Furthermore, thanks to the `generic`
interface, those mechanical behaviours are also available in all solvers
using the [`MFrontGenericInterfaceSupport`
projet](https://thelfer.github.io/mgis/web/index.html) (MGIS)
[@helfer_mfrontgenericinterfacesupport_2020], including:
[`OpenGeoSys`](https://www.opengeosys.org/) [@Bilke2019],
[`MFEM-MGIS`](https://thelfer.github.io/mfem-mgis/web/index.html),
`MANTA`,
[`mgis.fenics`](https://thelfer.github.io/mgis/web/mgis_fenics.html),
[`MoFEM`](http://mofem.eng.gla.ac.uk/mofem/html), XPER, etc.

The `MFrontGallery` project addresses the question of the management of
`MFront` implementations including their compilation, unit testing and
deployment.

The [MFrontGallery project](https://github.com/thelfer/MFrontGallery)
has two main, almost orthogonal, goals:

1. The first one is to show how solver developers may provide their
  users a set of ready-to-use (mechanical) behaviours which can be
  parametrized by their users to match their needs.
2. The second one is to describe how to set up a high-quality material
  knowledge management project based on
  [`MFront`](https://thelfer.github.io/tfel/web/index.html), able to
  meet the requirements of safety-critical studies.

While the first goal is common to all (mechanical) solvers, one
originality of the `MFrontGallery` project is to address the second goal
which is discussed in depth in Section
\ref{sec:mfm:introduction:statement_of_need}.

In summary, the project provides:

- a [`CMake`](https://cmake.org) infrastructure that can be duplicated
  in (academic or industrial) derived projects. This infrastructure allows:
  - to compile `MFront` sources using all interfaces supported by
    `MFront`.
  - to execute unit tests based on `MTest`. Those unit tests generate
    `XML` result files conforming to the `JUnit` standard that can
    readily be used by continuous integration platforms such as
    [jenkins](https://www.jenkins.io/).
  - generate the documentation associated with the stored implementations.
- a documentation of best practices to handle material knowledge
  implemented using `MFront` implementations, such as use of consistent 
  unit systems, bound-aware physical quantities, consistent tangent
  operators, and others.
- a set of high-quality `MFront` implementations.

This paper aims to describe the project and is organized as follows:

Section \ref{sec:mfm:introduction:statement_of_need} discusses why a
new approach to material knowledge management is needed in the context
of safety-criticial studies.

Section \ref{sec:mfm:introduction:cmake_infrastructure} provides an
overview of the `CMake` infrastructure of the project, and describes how
to create a derived project based on the same `CMake` infrastructure as
the `MFrontGallery`.

# Statement of need : material knowledge management for safety - criticial studies
\label{sec:mfm:introduction:statement_of_need}

## Role of material knowledge in numerical simulations of solids

Numerical simulations of solids are based on the description of the
evolution of the thermodynamical state of the materials of interest. In
the context of the `MFrontGallery` project, this thermodynamical state
is described at each point in space by a set of internal state variables
which can evolve with time due to various physical phenomena.

The knowledge that one may have about a given material can be represented
in different forms. In `MFront`, the following categorization is employed:

- **Material properties** are defined here as functions of the current
  state of the material. A typical example is the Young modulus of a
  material.
- **Behaviours** describe how a material evolves and reacts locally due
  to gradients inside the material. Here, the material reaction is
  associated with fluxes (or forces) thermodynamically conjugated to
  gradients. For instance, Fourier's law relates the heat flux to the
  temperature gradient. Mechanical behaviour in infinitesimal strain
  theory relates the stress and the strain and may describe (visco)elasticity,
  (visco)plasticity, or damage.
- **Point-wise models** describe the evolution of some internal state
  variables with the evolution of other state variables. Point-wise
  models may be seen as behaviours without gradients. Phase transition,
  swelling under irradiation or shrinkage due to dessication are
  examples of point-wise models.

## Requirements related to safety-critical studies
\label{sec:mfm:introduction:safety_critical_studies}

The `MFrontGallery` project has been developed to address various
issues related to material knowledge management for safety-critical
studies:

- **Intellectual property**: Frequently, material knowledge reflects 
  the know-how of industrials and shall be kept private for various reasons. 
  For example, some mechanical behaviours result from years of experimental
  testing in dedicated facilities and are thus highly valuable. In some
  cases, material knowledge can be a competitive advantage. To solve
  this issue, the `MFrontGallery` allows to create private derived
  projects, as detailled in Section
  \ref{sec:mfm:creating_derived_project}.
- **Portability**: safety-critical studies may involve several partners
  which use different solvers for independent assessment and review.
  From the same `MFront` source file, the `MFrontGallery` can generate
  shared libraries for all the solvers of interest. Moreover, the
  project employs [best practices
  guidelines](https://thelfer.github.io/MFrontGallery/web/best-practices.html)[^mfm:best_practices]
  to ensure that a given `MFront` implementation can be shared among
  several teams while assuring quality.
- **Maintainability over decades**: Some safety-critical studies involve
  the design of buildings, plants, or technological systems for
  operation periods of decades or more. Over such periods of time, both
  the solvers and the material knowledge will evolve. The
  safety-critical studies, however, on which design choices or decisions
  were based, need to remain accessible and reproducible. In the authors'
  experience, maintainability is more easily achieved by having a
  dedicated material knowledge project based on *self-contained*
  implementations, as discussed in Section
  \ref{sec:mfm:introduction:implementations}.
- **Progression of the state of the art**: Safety-critical studies need
  to reflect the state of the art. As such, the material knowledge per se,
  numerical methods and software engineering need to evolve while at the same
  time ensuring the other principles listed here are not violated in order
  to maintain quality assurance of past, present and future analyses.
- **Continuous integration and unit testing**: Each implementation has
  associated unit tests which can check no-regression during the
  development of `MFront`.
- **Documentation**: the project can generate the documentation
  associated with the various implementations in an automated manner.
  Implementations of material knowledge can be associated to essential
  meta data.

[^mfm:best_practices]: <https://thelfer.github.io/MFrontGallery/web/best-practices.html>

## Implementations and classification
\label{sec:mfm:introduction:implementations}

`MFront` implementations can be classified in two main categories:

- **self-contained implementations** that contain all the
  physical information (e.g., model equations and parameters).
- **generic implementations** for which the solver is 
  required to provide additional physical information to the material 
  treated, e.g. the values of certain parameters. Those "generic"
  implementations are usually shipped with solvers as ready-to-use
  behaviours.

An alternative way of expressing the distinction between self-contained
and generic implementations is to consider that self-contained
implementations describes a set of constitutive equations
**and** the material coefficients[^mfm:about_material_coefficients]
  identified on a well-defined set of experiments for a particular
  material while generic implementations
only describe a set of constitutive equations.

[^mfm:about_material_coefficients]: In practice, the physical
information described by self-contained implementations may be more
complex than a set of material coefficients. For example, the Young
modulus of a material may be defined by an analytical formula and cannot
thus be reduced to a set of constants. This analytical formula shall be
part of a self-contained mechanical behaviour implementation. Of course,
this analytical formula could be included in the set of constitutive
equations and parametrized to retrieve a certain degree of generality. In our
experience, such a hybrid approach is fragile, less readable and
cumbersome. Moreover, it does not address the main issue of generic
behaviours which is the management of the physical information in a
reliable and robust manner.

In the authors' experience, self-contained behaviours allows to
**decouple the material knowledge management from the development
  (source code) of the solvers of interest** and thus allow a proper
  material knowledge management strategy suitable to meet the
  requirements depicted on Section
  \ref{sec:mfm:introduction:safety_critical_studies}.

# The `CMake` infrastructure
\label{sec:mfm:introduction:cmake_infrastructure}

This section provides an overview of the [`CMake`](https://cmake.org)
infrastructure of the `MFrontGallery` and `MFrontMaterials` projects.

This infrastructure is fully contained in the `cmake/modules` directory,
the file `cmake/modules/mfm.cmake` being the main entry point.

Section \ref{sec:mfm:cmake:main_functions} describes the main `CMake`
functions provided by the project.

Section \ref{sec:mfm:creating_derived_project} shows how to create a
derived project.

## Main functions
\label{sec:mfm:cmake:main_functions}

The [`CMake`](https://cmake.org) infrastructure provides:

- functions used to compile `MFront` files related to material
  properties, behaviours and models.
- functions related to unit testing. Those functions will not be
  described in this paper.
- functions related to documentation and website generation. Those
  functions will not be described in this paper.

## Creation of a derived project
\label{sec:mfm:creating_derived_project}

This section describes how to setup a new project based on the [`CMake`
infrastructure](cmake-infrastructure.html) of the `MFrontGallery` and
`MFrontMaterials` projects.

### Fetching `cmake/modules` directory

To create a material management project derived from `MFrontGallery`,
just copy the contents of the `cmake/modules` directory in your local
directory.

If you intend to use `git` for version control, one easy way is to add
the `MFrontGallery` as a remote ressource and check out the `CMake`
repository from it as follows:

~~~~{.bash}
$ git remote add MFrontGallery https://github.com/thelfer/MFrontGallery
$ git fetch MFrontGallery master
$ git checkout MFrontGallery/master --cmake 
~~~~

Of course, the user may also want to follow another branch rather than
the `master` branch.

### Top-level `CMakeLists.txt` file

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

# add subdirectories here
add_subdirectory(materials)
~~~~

Now you are ready to create the subdirectory `materials` containing your
`MFront` files.

# Conclusions

The `MFrontGallery` project is dedicated to material knowledge management
in safety-critical studies and is the result of long-standing experience gathered
in the `PLEIADES` project. Key concepts built upon are portability,
maintainability and reproducability over long time periods, continuous integration
and unit testing, documentation and the safeguarding of intellectual property as 
well as attribution. Based on the technical infrastructure
described in this article, it becomes possible to set up derived projects 
in similar contexts where these concepts are considered relevant.

# Acknowledgements

This research was conducted in the framework of the `PLEIADES` project,
which is supported financially by the French Alternative Energies and
Atomic Energy Commission (CEA), Électricité de France (EDF) and
Framatome.

# References
