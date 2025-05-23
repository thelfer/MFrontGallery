# MFrontGallery

This project aims at gathering high quality, thoroughly tested, well
written, efficient and **ready-to-use** `MFront` implementations of
various material properties, behaviours and models.

The goals of the project is described in depth in this JOSS paper:

[![DOI](https://joss.theoj.org/papers/10.21105/joss.07742/status.svg)](https://doi.org/10.21105/joss.07742)

It is mainly decomposed in two parts:

- `generic-behaviours`: this part is dedicated to various mechanical
  behaviours that can be adapted to describe many materials. Those
  behaviours are sorted by category:
    - `hyperelasticity`
    - `hyperviscoelasticity`
    - `damage`
    - `plasticity`
    - `viscoelasticity`
    - `viscoplasticity`
- `materials`: this part gathers to specific materials.

The last purpose of this project is to show how to build a compilation
project for `MFront`'s properties, behaviours and models.

# Overview and usage

The file `docs/web/index.md` contains a full description of the project.

The file `docs/web/install.md` details how to use the project.

The official website is accessible here: <https://thelfer.github.io/MFrontGallery/web/index.html>

# Versions, branches, tags

## Versions

- the tags `MFrontGallery-2.0` and `MFrontGallery-2.1` are associated with `TFEL-4.2`.
- the tag `MFrontGallery-1.1` is meant to be build against `TFEL 3.3.0`
- the tag `MFrontGallery-1.0.1` is meant to be build against `TFEL 3.2.1`
- the tag `MFrontGallery-1.0` is meant to be build against `TFEL 3.2.0`

## Branches

- the `master` branch follows the evolution of the `master` branch of
  the `TFEL` project
- the `rliv-2.0` branch is associated with the branch `rliv-4.2` branch
  of `TFEL`.
- the `rliv-1.1` follows the evolution of the `3.3.x` series of the
  `TFEL` project.
- the `rliv-1.0` follows the evolution of the `3.2.x` series of the
  `TFEL` project.
