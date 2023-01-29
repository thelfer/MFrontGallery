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

Since Version 4.1, `MFront` provides the `@UnitSystem` keyword to
specify the unit system used.

## External names (glossary and entry names)

The `setGlossaryName` and `setEntryName` methods allows to affect
so-called external names to `MFront`'s variables. Those external names
are the one seen from the calling solver. Those names must be explicit.

## Bounds and physical bounds

Bounds and physical bounds can be assigned to most variables in
`MFront`'s variables using the `@Bounds` and `@PhysicalBounds` methods.

## Consistent tangent operator

Most FEM implicit solvers requires a consistent tangent operator.

## Prediction operator

The prediction operator may be used by the `code_aster` solver for the
first iteration of each time step.

The elastic prediction operator is used by the `Abaqus/Explicit` solver
to determine the critical time step.

## Stored and dissipated energies

Stored and dissipated energies are used by the `Abaqus/Explicit` solver
to estimate energy lost by hourglassing.

## File encoding

Encode your file in `UTF-8` which is the de facto on most systems. This
encoding is enforced by
[`tfel-editor`](https://github.com/thelfer/tfel-editor).

# Unit testing