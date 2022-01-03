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
  users a set of ready-to-use (mechanical) behaviours which can be
  parametrized by their users to match their needs.
2. The second one is to show how to set up a high-quality material
  knowledge management project based on
  [`MFront`](https://thelfer.github.io/tfel/web/index.html), able to
  meet the requirements of safety-critical studies as discussed in
  Section @sec:mfm:introduction:safety_critical_studies.

The distinction between those two approaches is profound and discussed
in depth in Sections @sec:mfm:introduction:statement_of_need and
@sec:mfm:introduction:typical_use_case.

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
integration process to guarantee that no regression would happen as
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
> documentation, examples, etc.

In particular, the project provides:

- a [`cmake`](https://cmake.org) infrastructure that can be duplicated
  in (academic or industrial) derived projects. This infrastructure allows:
  - to compile `MFront` sources using all interfaces supported
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
    `XML` result files conforming to the `JUnit` standard that can
    readily be used by continuous integration platforms such as
    [jenkins](https://www.jenkins.io/).
  - generate the documentation associated with the stored implementations.

  [This page](creating-derived-project.html) describes how to create a
  derived project based on the same infrastructure as the
  `MFrontGallery`.
- a documentation of best practices to handle material knowledge
  implemented using `MFront` implementations
- a set of high-quality `MFront` implementations.

Section @sec:mfm:introduction:statement_of_need discusses why a new
approach to material knowledge management is needed in the context of
safety criticial studies.

Section @sec:mfm:introduction:typical_use_case describes some typical
use case of projects derived from `MFrontGallery`.

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
which can evolve with time due to various physical phenomena (plasticity,
viscoplaticity, damage, phase change, swelling due to dessication,
etc.).

The knowledge that one may have about a given material can be represented
in different forms. Here, the following categorization is employed:

- **Material properties** are defined here as functions of the current
  state of the material.
- **Behaviours** describe how a material evolves and reacts locally due
  to gradients inside the material. Here, the material reaction is
  associated with fluxes (or forces) thermodynamically conjugated with
  the gradients.
- **Point-wise models** describe the evolution of some internal state
  variables with the evolution of other state variables. Point-wise
  models may be seen as behaviours without gradients.

## Requirements related to safety-critical studies {#sec:mfm:introduction:safety_critical_studies}

The `MFrontGallery` project has been developed to address various
issues related to material knowledge management for safety-critical
studies:

- **Intellectual property**: Material knowledge reflects the know-how of
  industrials and shall be kept private for various reasons. For
  example, some mechanical behaviours result from years of experimental
  testing in dedicated facilities and are thus highly valuable. In some
  cases, material knowledge can be a competitive advantage.
- **Portability**: safety-critical studies may involve several partners
  which use different solvers for independent assessment and review. 
  From the same `MFront` source file, the
  `MFrontGallery` can generate shared libraries for all the solvers of
  interest.
- **Maintainability over decades**: Some safety-critical studies can be
  used to design buildings, plants, or technological systems for 
  operation periods of decades or more. Over such
  periods of time, both the solvers and the material knowledge will
  evolve. The safety-critical studies, however, on which design choices
  or decisions were based, need to remain accessible or reproducible.
- **Continuous integration and unit testing**: Each implementation has
  associated unit tests with can check no-regression during the
  development of `MFront`.
- **Documentation**: the project can generate the documentation
  associated with the various implementations in an automated manner.

## Implementations and classification {#sec:mfm:introduction:implementations}

`MFront` implementations can be classified in two main categories:

- **self-contained**, which denotes implementations that contain all the
  physical information (e.g., model equations and parameters).
- **generic**, which denotes implementations for which the solver is 
  required to provide additional physical information to the material 
  treated, e.g. the values of certain parameters. Those "generic"
  implementations are usually shipped with solvers as ready-to-use
  behaviours.

An alternative way of expressing the disctinction between self-contained
and generic implementations is to consider that generic implementations
only describe a set of constitutive equations while self-contained
implementations describes a set of constitutive equations
**and** the material coefficients identified on a well-defined set of
  experiments for a particular material.

In practice, the physical information contained in self-contained
implementations may be more complex than a set of material coefficients.
For example, the Young modulus of a material may be defined by an
analytical formula and can't thus be reduced to a set of constants. This
analytical formula shall be part of a self-contained mechanical
behaviour implementation. Of course, this analytical formula could be
included in the set of constitutive equations and parametrized to
retrieve a bit of genericity. In our experience, such a hybrid approach is
fragile, less readable and and cumbersome. Moreover it does not address 
the main issue of generic behaviours which is the management of the physical
information in a reliable and robust way.

## Discussion

Introducing generic implementations in solvers can be very useful for
rapid prototyping by the end-users. They can also be useful for behaviours
with little specificity (e.g. linear elasticity, von Mises plasticity) 
often used in general analyses relying on a more frequent and ad-hoc 
re-parameterization. However, such generic
implementations raise the issue of how to manage the physical
information used in engineering studies, particularly safety-critical ones.

For the sake of simplicity, we will first consider the case where the solver
provide all the generic implementations required by the users and
discuss in a second case the situation of external implementations (such as
`UMAT` behaviours in `Abaqus`).

### A basic standard solution: using input files of the solver to define materials

Most commonly, the physical information will be in the input file of
the considered solver, generally in a section dedicated to the
definition of the materials.

But the input files not only contain that physical information but
also the boundary conditions, load step information, numerical parameters, 
discretization information, etc. 
for the simulation it is meant to describe.

When a new simulation is considered, physical information, i.e. the
material definition section, is often copy-pasted to a new input file.

Such input files are also generally shared by engineers which will
modify them to their own needs.

Things get even worse if this physical information must be
shared with another team which uses a different solver. In general, the
physical information is manually adapted to input file format of the new solver,
an operation which is error-prone for a large number of reasons, 
including non-consistent parameter definitions, unit conversions, or 
plain-and-simple copy errors.

In the end, our experience shows that it is practically impossible to track
physical information reliably in this way, particularly if the knowledge of the
materials evolves over time.

### A more elaborate solution

A more elaborate solution consists in splitting the input file in
multiple ones and separating the material declarations from the rest.
One can thus maintain a database of ready-to-use material definitions.

A variant of this approach is to have specific keywords allowing to
request specific material definitions.

In each case, the physical information is associated to a label. If this
information evolves, one may just have to create a new label.

The solution is elegant and the physical information is no longer
duplicated with every change of geometry or boundary conditions. 

However, this approach still has severe drawbacks:

- When the database is maintened by the developer of the code, new
  material definitions can only be available when a new release of the
  solver is made.
- It may be limited to the solver's built-in generic implementation and
  is thus not extensible.
- It does not solve the issue regarding the portability of the physical
  information to another solver.

### Solution based on user-defined subroutines

 - can be either generic or self-contained in the above sense
 - often outdated interfaces or languages, very solver-specific
 - information transfer limited by what the interface provides
 - version compatibility issues (solver release that changed an interface, compilers)
 - use of the model in another solver typically requires re-implementation (Hypela2, ...)

### Conclusions

According to the experience of the authors, a rigorous material
knowledge management suitable for safety-critical studies is only
possible if self-contained implementations are considered.

## Solutions provided by the `MFrontGallery` project

The `MFrontGallery` is based on the assumption that the solvers of
interest (note the plural) can use shared libraries generated by the
`MFront` code generator [@Helfer2015;@cea_edf_mfront_2021].

This assumption allows to **decouple the material knowledge management
from the development (source code) of the solvers of interest**.

### Code re-use and "self-contained" implementations

However, an important argument in favor of generic implementation is
**code-reuse**. `MFront` provides several techniques to facilitate code
  factorisation between implementations as described in the ["Best
  practices" page](best-practices.html)

# Typical use case of projects derived from `MFrontGallery` {#sec:mfm:introduction:typical_use_case}

## Generic behaviours delivered along with a general purpose solver

## Domain-specific tools built-in on top of general purpose solver

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
arbitraly classified by the main phenomenon described, as follows:

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

These generic implementations have been introduced in the
`MFrontGallery` project to:
  
- test if those implementations still compile and run as `̀MFront`
  evolves.
- show to solver developers how they could provide to their users a set
  of ready-to-use behaviours.

# Typical usage {#sec:mfm:introduction:usage}

After downloading or cloning the sources of the `MFrontGallery` project,
a typical usage of the project is divided in four steps (common to most
`cmake` projects):

- **Configuration**, which allows to select the interfaces to be used.
- **Compilation**, which builds the shared libraries associated with the
  selected interfaces.
- **Unit testing**, which allows to verify that no regression has occured.
- **Installation**, which can deploy the built shared libraries.

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
not strictly required, it is convienient to create a `build` directory
(here, at the same level as the `MFrontGallery` directory):

~~~~{.bash}
$ mkdir build
$ cd build
~~~~

The configuration step is triggered by calling `cmake`, e.g.:

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

The `MFrontGallery` project has been developed by CEA, EDF and
Framatome as part of a common effort to build a common and robust
material knowledge management strategy to back safety-critical studies
which meet the quality requirements imposed by the French Safety Authority
(ANS).

# References