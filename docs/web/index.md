---
title: The MFrontGallery project
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

This page introduces the `MFrontGallery` project whose latest version is
available at: <https://github.com/thelfer/MFrontGallery>

This project has two main almost orthogonal goals:

1. The first one is to show how solver developers may provide to their
  user a set of ready-to-use (mechanical) behaviours which can be
  parametrized by their user to match their needs.
2. The second one is to show how to set up a high quality material
  knowledge management project based on
  [`MFront`](https://thelfer.github.io/tfel/web/index.html), able to
  meet the requirements of critical safety studies as discussed in
  Section @sec:mfm:introduction:safety_critical_studies.

This distinction between those two approaches is profound and discussed
in depth in Section @sec:mfm:introduction:statement_of_need.

While the first goal is common to all (mechanical) solvers, one
originality of the `MFrontGallery` project is to address the second
goal.

The `MFrontGallery` project also contains various high-quality `MFront`
implementations. Those implementations may originate from the `MFront`
tutorials, i.e. the [`MFront gallery`
page](https://thelfer.github.io/tfel/web/gallery.html) (hence the name
of the project). This project is also meant to store various
contributions of academic or industrial users of `MFront` willing to
share their material knowledge and also benefit from the continuous
integration process to garantee that no regression would happen as
`MFront` evolves.

> **The `MFrontGallery` and `MFrontMaterials` projects**
>
> The `MFrontGallery` project is the open-source counterpart of the
> `MFrontMaterials` project (called internally `mfm`). `MFrontMaterials`
> is used for material knowledge management by the fuel performance
> codes developped on top of the `PLEAIDES`
> platform [@plancq_pleiades_2004;@marelle_new_2016] and results from
> a common effort of CEA and its industrial partners EDF and Framatome.
> See the [faq](faq.html) for details about the relation between those
> two projects.
>
> As both projects shares the same [`cmake`
> infrastructure](cmake-infrastructure.html), the name `mfm` or references
> to the `MFrontMaterials` project may appear in function names,
> documentation, examples, etc..

In particular, the project provides:

- a [`cmake`](https://cmake.org) infrastructure that can be duplicated
  in child (academic or industrial) projects. This infrastructure allows:
  - to compile `MFront` sources using all supported interfaces supported
    by `MFront`. For example, concerning behaviours, the behaviours can
    be compiled for the following solvers:
    [`Cast3M`](http://www-cast3m.cea.fr/),
    [`code_aster`](https://code-aster.org),
    [`Europlexus`](https://europlexus.jrc.ec.europa.eu/),
    `Abaqus/Standard`, `Abaqus/Explicit`, `Ansys`, `AMITEX_FFTP`,
    [`CalculiX`](http://www.calculix.de/),
    [`ZSet`](http://www.zset-software.com/), [`DIANA
    FEA`](https://dianafea.com/). Thanks to the `generic` interface,
    those behaviours are also available in all solvers using the
    [`MFrontGenericInterfaceSupport`
    projet](https://thelfer.github.io/mgis/web/index.html) (MGIS),
    including: [`OpenGeoSys`](https://www.opengeosys.org/),
    [`MFEM-MGIS`](https://thelfer.github.io/mfem-mgis/web/index.html),
    `MANTA`,
    [`mgis.fenics`](https://thelfer.github.io/mgis/web/mgis_fenics.html),
    [`MoFEM`](http://mofem.eng.gla.ac.uk/mofem/html), XPER, etc.
  - to execute unit tests based on `MTest`. Those unit tests generate
    `XML` results files conforming to the `JUnit` standard that can
    readibily be used by continuous integration plateforms such as
    [jenkins](https://www.jenkins.io/).
  - generate the documentation associated with the stored implementations.

  [This page](creating-derived-project.html) describes how to create a
  derived project based on the same infrastructure.
- a documentation of best practices to handle material knowledge
  implemented using `MFront` implementations
- a set of high-quality `MFront` implementations.

Section @sec:mfm:introduction:statement_of_need discusses why a new
approach to material knowledge management is needed in the context of
safety criticial studies.

Section @sec:mfm:introduction:files discusses how `MFront`
implementations are stored in the project.

Section @sec:mfm:introduction:usage provides a short overview of the
usage of the project.

# Statemement of need: material knowledge management for safety criticial studies {#sec:mfm:introduction:statement_of_need}

## Role of material knowledge in numerical simulations of solids

Numerical simulations of solids are based on the description of the
evolution of the thermodynamical state of the materials of interest. In
the context of the `MFrontGallery` project, this thermodynamical state
is described at each point of space by a set of internal state variables
which can evolve with time du to various physical phenomena (plasticity,
viscoplaticity, damage, phase change, swelling due to dessication,
etc.).

The knowledge that one may have about a given material can be
categorized as follows:

- **Material properties** are defined here as functions of the current
  state of the material.
- **Behaviours** describes how a material evolves and reacts locally due
  to gradients inside the material. Here, the material reaction is
  associated with fluxes (or forces) thermodynamically conjugated with
  the gradients.
- **Point-wise models** describes the evolution of some internal state
  variables with the evolution of other state variables. Point-wise
  models may be seen as behaviours without gradients.

## Requirements related to safety critical studies {#sec:mfm:introduction:safety_critical_studies}

The `MFrontGallery` project has been developped to address various
issues related to material knowledge management for safety criticial
studies:

- **Portability**: Safety critical studies may involve several partners
  which use different solvers. From the same `MFront` source file, the
  `MFrontGallery` can generate shared libraries for all the solvers of
  interest.
- **Maintainability over decades**: Some safety critical studies can be
  used to desing buildings, plants, systems for decades. Over such
  periods of time, both the solvers and the material knowledge may
  evolve.
- **Continuous integration and unit testing**: Each implementation has
  associated unit tests with can check no-regression during the
  development of `MFront`.
- **Documentation**: the project can generate the documentation
  associated with the various implementations.

## Implementations and classification {#sec:mfm:introduction:implementations}

`MFront` implementations can be classified in two main categories:

- **self-contained**, which denotes implementations that contain all the
  physical information.
- **generic**, which denotes implementations that the solver provides
  physical information to the material treated. Those "generic"
  implementations are usually shipped with solvers as ready-to-use
  behaviours.

An alternative way of expression the disctinction between self-contained
and generic implementations is to consider that generic implementations
only describes a set of constitutive equations while self-contained
implementations describes a set of constitutive equations
**and** the material coefficients identified on a well defined set of
  experiments for a particular material.

In practice, the physical information contained in self-contained
implementations may be more complex than a set of material coefficients.
For example, the Young modulus of a material may be defined by an
analytical formula and can't thus be reduced to a set of constants. This
analytical formula shall be port of a self-contained mechanical
behaviour implementation. Of course, this analytical formula could be
included in the set of constitutive equations and parametrized to
retrieve a bit of genericity. In our experience, such hybrid approach is
fragile and and cumbersome. Moreover it does not adress the main issue
of generic behaviours which is the management of the physical
information.

## Discussion

Introducing generic implementations in solvers can be very useful for
rapid prototyping by the end-users. However, such generic
implementations raises the issues of how to manage the physical
information used in engineering studies.

For the sake of simplicity, we will first consider that the solver
provide all the generic implementations required by the users and
discuss in a second case the case of external implementations (such as
`UMAT` behaviours in `Abaqus`).

### A basic standard solution: using input files of the solver to define materials

Most of the time, this physical information will be in the input file of
the considered solver, generally in a section dedicated to the
definition of the materials.

But the input files not only contains those physical information but
also the boundary conditions, the loadings, numerical parameters, etc..
for the simulation it is meant to describe.

When a new simulation is considered, physical information, i.e. the
material definition section, is barely copy/pasted to a new input file.

Such input files are also generally shared by engineers which will
modify them to their own needs.

Things are even getting worse if this physical information must be
shared with another team which uses a different solver. In general, the
physical information are adapted to input file format of the new solver,
an operation which is error-prone.

In the end, our experience shows that is merely impossible to track
physical information this way, particularly if the knowledge of the
materials evolves over time.

### A more elaborate solution

A more elaborate solution consists in splitting the input file in
multiple ones and separating the material declarations from the rest.
One can thus maintain a database of ready-to-use material definitions.

A variant of this approach is to have specific keywords allowing to
request specific material definitions.

In each case, the physical information is associated to a label. If this
information evolves, one may just have to create a new label.

The solution is elegant and the physical information is no more
duplicated. 

However, this approach may have drawbacks:

- When the database is maintened by the developper of the code, new
  material definition can only be available when a new release of the
  solver is made.
- It may be limited to the solver' built-in generic implementation and
  is thus not extensible.
- It does not solve the issue regarding the portability of the physical
  information to another solver.

### Solution based on user defined subroutines

### Conclusions

According to the experience of the authors, a rigorous material
knowledge management suitable for safety critical studies is only
possible if self-contained implementations are considered.

## Solutions provided by the `MFrontGallery` project

The `MFrontGallery` is based on the assumption that the solvers of
interest (note the plural) can be use shared libraries generated by the
`MFront` code generator [@Helfer2015;@cea_edf_mfront_2021].

This assumption allows to **decouple the material knowledge management
from the development (source code) of the solvers of interest**.

### Code re-use and "self-contained" implementations

However, a important argument in favor of generic implementation is
**code-reuse**. `MFront` provides several techniques to facilitate code
  factorisation between implementations as described in the ["Best
  practices" page](best-practices.html)

# Files organization {#sec:mfm:introduction:files}

## Storage of self-contained implementations

Self-contained implementations are stored in the `materials` directory.
Under this directory, implementations are stored by material and by kind
(material property, behaviour or model), as follows:

~~~~{.bash}
materials/
├── Bentonite
│   └── behaviours
│       └── include
├── Concrete
│   └── behaviours
├── CrushedSalt
│   └── behaviours
├── VanadiumAlloy
│   ├── behaviours
│   └── properties
└── Wood
    └── behaviours
~~~~

## Storage of generic behaviours

Generic implementations are stored in the `generic-behaviours`
directory. Under this directory, the implementations are more or less
arbitraly classified by the main phenomon described, as follows:

~~~~{.bash}
generic-behaviours/
├── damage
├── damage_viscoplasticity
├── finitestrainsinglecrystal
├── heattransfer
├── hyperelasticity
├── hyperviscoelasticity
├── nonlinearelasticity
├── plasticity
├── viscoelasticity
└── viscoplasticity
~~~~

Those generic implementations have been introduced in the
`MFrontGallery` project to:
  
- tests if those implementations still compile and run as `̀MFront`
  evolve.
- show to solver developers how they could provide to their users a set
  of ready to use behaviours.

# Typical usage {#sec:mfm:introduction:usage}

After downloading or cloning the sources of the `MFrontGallery` project,
a typical usage of the project is divided in four steps (common to most
`cmake` projects):

- **Configuration**, which allows to select the interfaces to be used.
- **Compilation**, which builds the shared libraries associated wit the
  selected interfaces.
- **Unit testing**, which allows to verify that no regression occured.
- **Installation**, which can deploy the build shared libraries.

> ** Cloning the `master` branch of the `MFrontGallery` project**
> 
> The `master` branch of the `MFrontGallery` project can be cloned as
> follows:
> 
> ~~~~{.bash}
> $ git clone https://github.com/thelfer/MFrontGallery
> ~~~~

## Configuration

The sources are assumed to be in the `MFrontGallery` directory. While
not strictly required, it is convienient to create a `build` directory:

~~~~{.bash}
$ mkdir build
$ cd build
~~~~

The configuration step is triggered by calling `cmake`:

~~~~{.bash}
$ cmake  ../MFrontGallery/ -DCMAKE_BUILD_TYPE=Release     \
         -Denable-generic-behaviours=ON -Denable-ansys=ON
~~~~

The interfaces are selected by a set of `cmake` flags prefixed by
`enable`. In the previous command, we only selected the `generic` and
`ansys` interfaces.

> **`TFEL` executables**
>
> By default, the configuration step assumes that the various binaries
> provided by the `TFEL` project (including `mfront`) can be found in
> the current environment. See the [installation guide](install.html)
> for details.

The complete set of available flags are described in the [installation
guide](install.html).

The outputs of the previous command shows the generated libraries and their contents:

~~~~{.bash}
-- Adding library : HeatTransferBehaviours-generic (/home/th202608/codes/MFrontGallery/master/src/build3/generic-behaviours/heattransfer/generic/src/StationaryLinearHeatTransfer-generic.cxx;/home/th202608/codes/MFrontGallery/master/src/build3/generic-behaviours/heattransfer/generic/src/StationaryLinearHeatTransfer.cxx;/home/th202608/codes/MFrontGallery/master/src/build3/generic-behaviours/heattransfer/generic/src/StationaryNonLinearHeatTransfer-generic.cxx;/home/th202608/codes/MFrontGallery/master/src/build3/generic-behaviours/heattransfer/generic/src/StationaryNonLinearHeatTransfer.cxx;/home/th202608/codes/MFrontGallery/master/src/build3/generic-behaviours/heattransfer/generic/src/TransientLinearHeatTransfer-generic.cxx;/home/th202608/codes/MFrontGallery/master/src/build3/generic-behaviours/heattransfer/generic/src/TransientLinearHeatTransfer.cxx;/home/th202608/codes/MFrontGallery/master/src/build3/generic-behaviours/heattransfer/generic/src/TransientNonLinearHeatTransfer-generic.cxx;/home/th202608/codes/MFrontGallery/master/src/build3/generic-behaviours/heattransfer/generic/src/TransientNonLinearHeatTransfer.cxx)
~~~~~

Some `MFront` files are not compatible with the selected interface. For
example, the `ansys` interface only supports small and finite strain
behaviours. Generalized behaviours are then discarded as shown by the
following ouptut:

~~~~{.bash}
-- StationaryLinearHeatTransfer has been discarded for interface ansys (unsupported behaviour type)
-- StationaryNonLinearHeatTransfer has been discarded for interface ansys (unsupported behaviour type)
-- TransientLinearHeatTransfer has been discarded for interface ansys (unsupported behaviour type)
-- TransientNonLinearHeatTransfer has been discarded for interface ansys (unsupported behaviour type)
~~~~

## Compilation

The selected libraries can be built as follows:

~~~~{.bash}
$ cmake --build . --target all
~~~~

Various targets are avaiable.

## Unit tests

Unit tests can be executed as follows:

~~~~{.bash}
$ cmake --build . --target check
~~~~

A summary of the executed tests and their status is displayed, as
follows:

~~~~{.bash}
Test project /home/th202608/codes/MFrontGallery/master/src/build3
    Start 1: SemiImplicitModifiedCamClay_OpenGeoSys2020_Triax_ansys_UpWard_mtest
1/8 Test #1: SemiImplicitModifiedCamClay_OpenGeoSys2020_Triax_ansys_UpWard_mtest .........   Passed    0.02 sec
    Start 2: SemiImplicitModifiedCamClay_OpenGeoSys2020_Triax_ansys_DownWard_mtest
2/8 Test #2: SemiImplicitModifiedCamClay_OpenGeoSys2020_Triax_ansys_DownWard_mtest .......   Passed    0.02 sec
    Start 3: SemiImplicitModifiedCamClay_OpenGeoSys2020_Triax_ansys_ToNearest_mtest
3/8 Test #3: SemiImplicitModifiedCamClay_OpenGeoSys2020_Triax_ansys_ToNearest_mtest ......   Passed    0.02 sec
    Start 4: SemiImplicitModifiedCamClay_OpenGeoSys2020_Triax_ansys_TowardZero_mtest
4/8 Test #4: SemiImplicitModifiedCamClay_OpenGeoSys2020_Triax_ansys_TowardZero_mtest .....   Passed    0.02 sec
    Start 5: SemiImplicitModifiedCamClay_OpenGeoSys2020_Triax_generic_UpWard_mtest
5/8 Test #5: SemiImplicitModifiedCamClay_OpenGeoSys2020_Triax_generic_UpWard_mtest .......   Passed    0.02 sec
    Start 6: SemiImplicitModifiedCamClay_OpenGeoSys2020_Triax_generic_DownWard_mtest
6/8 Test #6: SemiImplicitModifiedCamClay_OpenGeoSys2020_Triax_generic_DownWard_mtest .....   Passed    0.02 sec
    Start 7: SemiImplicitModifiedCamClay_OpenGeoSys2020_Triax_generic_ToNearest_mtest
7/8 Test #7: SemiImplicitModifiedCamClay_OpenGeoSys2020_Triax_generic_ToNearest_mtest ....   Passed    0.02 sec
    Start 8: SemiImplicitModifiedCamClay_OpenGeoSys2020_Triax_generic_TowardZero_mtest
8/8 Test #8: SemiImplicitModifiedCamClay_OpenGeoSys2020_Triax_generic_TowardZero_mtest ...   Passed    0.02 sec

100% tests passed, 0 tests failed out of 8

Total Test time (real) =   0.13 sec
Built target check
~~~~

## Installation

The built shared libraries can be installed as follows:

~~~~{.bash}
$ cmake --build . --target install
~~~~

# Acknowledgements {.unnumbered}

The `MFrontGallery` project has been developped by CEA, EDF and
Framatome as part of a common effort to build a common, robust and
material knowledge management strategy to back safety critical studies
which meet the quality requirements imposed by the French Safety Authority
(ANS).

# References