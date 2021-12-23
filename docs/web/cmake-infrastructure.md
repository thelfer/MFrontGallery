---
title: CMake infrastructure
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

# The `cmake/modules` directory

## Main files

# Main functions

## The `mfront_properties_library` function

### Usage

~~~{.cmake}
mfront_properties_library(VanadiumAlloy
  VanadiumAlloy_YoungModulus_SRMA)
~~~

## The `mfront_behaviours_library` function

### Usage

~~~{.cmake}
mfront_behaviours_library(Plasticity
  GreenPerfectPlasticity)
~~~

## Functions related to tests based on `MTest`

## The `pandoc_html` function

