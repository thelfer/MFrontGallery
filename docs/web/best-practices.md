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

# MFront implementations

## Consistent units

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

## Prediction operator

## Stored and dissipated energy

## File encoding

Encode your file in `UTF-8` which is the de facto on most systems. This
encoding is enforced by
[`tfel-editor`](https://github.com/thelfer/tfel-editor).

# Unit testing