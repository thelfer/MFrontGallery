---
title: Best practices
author: Thomas Helfer, Maxence Wangermez
date: 18/12/2021
lang: en-EN
link-citations: true
colorlinks: true
figPrefixTemplate: "$$i$$"
tblPrefixTemplate: "$$i$$"
secPrefixTemplate: "$$i$$"
eqnPrefixTemplate: "($$i$$)"
---

# General advices

When creating a material database based on `MFrontGallery` (see [this
page](creating-derived-project.html) for details), do not mix generic
and self-contained implementations (see [this page](index.html) for
details).

When creating a material database of self-contained implementations, the
unit system of all implementations must be consistent. See Section
@sec:mfm:mfront:units for details.

# MFront implementations

## Consistent units {#sec:mfm:mfront:units}

When creating a material database of self-contained implementations, we
highly recommend providing a consistent unit system to make all
implementations consistent.

We also highly recommend using the international system of unit. Since
Version 4.1, `MFront` provides the `@UnitSystem` keyword to specify the
unit system used.

## External names (glossary and entry names)

The `setGlossaryName` and `setEntryName` methods allows to affect
so-called external names to `MFront`'s variables. Those external names
are the one seen from the calling solver.

For entry names, the name chosen must be explicit.

## Bounds and physical bounds

Bounds and physical bounds can be assigned to most variables in
`MFront`'s variables using the `@Bounds` and `@PhysicalBounds` keywords.

Since Version 4.1, physical bounds may be automatically declared for
variables associated with a glossary name if the unit system is
specified (see `@UnitSystem` keyword).

For example, if a variable has the glossary name `Porosity`, and the
international system of units is used, then this variable is automically
associated with the physical bounds \(0\) (lower bound) and \(1\) (upper
bound).

## Consistent tangent operator

Most finite element implicit solvers requires a tangent operator,
generally the consistent tangent operator (see @simo_consistent_1985 for
details). If your implementation does not provide one, you may have
runtime errors.

## Prediction operator

The prediction operator may be used by the `code_aster` solver for the
first iteration of each time step.

The elastic prediction operator is used by the `Abaqus/Explicit` solver
to determine the critical time step.

## Stored and dissipated energies

Stored and dissipated energies are used by the `Abaqus/Explicit` solver
to estimate energy lost by hourglassing.

## File encoding

Encode your file in `UTF-8` which is the *de facto* standard on most
systems.

Note that this encoding is automatically used by the
[`tfel-editor`](https://github.com/thelfer/tfel-editor) editor.

# Unit testing

`MFrontGallery` provides several `cmake` functions to declare tests
based on [`MTest`](https://thelfer.github.io/tfel/web/mtest.html).

# Documentation

We highly recommend that every implementation has a detailled
description as a markdown file. `MFrontGallery` provide a dedicated
`cmake` function to create a convert such file in webpages thanks to
[`pandoc`](https://pandoc.org). Various examples are available in the
project:

- [Implementation of the Korthaus' behaviour for crushed salt](CrushedSaltKorthausBehaviour.html)
- [The `Burger_EDF_CIWAP_2021` constitutive law for concrete creep and shrinkage](Burger_EDF_CIWAP_2021.html)
- [Implementation of the modified Cam Clay behaviour. Tests in `MTest` and `OpenGeoSys`](SemiImplicitModifiedCamClay_OpenGeoSys2020.html)

# References