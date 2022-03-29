---
title: Introducing small strain legacy `Abaqus/UMAT` implementations in `MFrontGallery`
author: Thomas Helfer, Eric Simo
date: 09/03/2022
lang: en-EN
colorlinks: true
link-citations: true
figPrefixTemplate: "$$i$$"
tblPrefixTemplate: "$$i$$"
secPrefixTemplate: "$$i$$"
eqnPrefixTemplate: "($$i$$)"
lstPrefixTemplate: "$$i$$"
abstract: |
  This document describes how to use `MFront` as a wrapper for an
  existing `UMAT` implementations, which is an interface introduced
  by the `Abaqus/Standard` finite element solver, of a small strain
  behaviour.
---

<!--
pandoc --pdf-engine=xelatex -f markdown --csl=iso690-numeric-en.csl  --bibliography=bibliography.bib --filter pandoc-crossref --citeproc -V geometry:a4paper,margin=2cm --highlight-style=tango --number-sections --variable urlcolor=blue --toc SmallStrainUmatWrapper.md -o SmallStrainUmatWrapper.pdf

# Introduction
-->

Implementing a constitutive model is a long tedious and error-prone
process, in particular for soils where a wide variety of phenomena must
be taken into account. Moreover, the implementation must satisfy the
interface requirements of the targeted solver.

While `MFront` greatly reduces the amount of work required to implement
a new behaviour, existing legacy implementations are highly valuable and
their re-implementation in `MFront` should only be considered with
caution considering the trade-offs. In our experience, such a
re-implementation increases the maintainability and portability, and
generally the numerical performances, but requires significant
development efforts.

In this work, we developed an alternative approach, which consists in
using `MFront` as a wrapper to the legacy implementations written using
the `UMAT` interface introduced by the `Abaqus/Standard` finite element
solver.

![Workflow for wrapping legacy model implementations in
`MFront`](img/SmallStrainUmatWrapper/mfront-wrapper.svg){#fig:umat_wrapper:workflow
width=90%}

The `MFront` wrapper:

- handles the transfer of the data from solver to the legacy
  implementation on input and output as illustrated in Figure
  @fig:umat_wrapper:workflow.
- the definition of appropriate metadata which considerably simplifies
  the behaviour integration in the solver, in particular if the
  [`MFrontGenericInterfaceSupport`
  library](https://thelfer.github.io/mgis/web/index.html) (`MGIS`) is
  used by the targeted solver [@Helfer2020;@cea_mgis_2021].

<!--
The latest version of this document can be found here:
<https://thelfer.github.io/MFrontGallery/web/SmallStrainUmatWrapper.html>.
-->

# Description of the wrapped `UMAT` implementation and role of the wrapper

In this tutorial, we use a sightly modified version of the `umat.f` file
delivered with the `CalculiX` finite element solver which implements an
isotropic elastic behaviour in `3D`. This implementation is reported in
Listing @lst:umat_wrapper:umat_source_code of Appendix
@sec:umat_wrapper:umat_source_code.

This implementation is written in `Fortran 77` which may lead to a
portability issue as the name of the resulting function is
implementation defined. We will discard this issue for the moment and
come by to it later by rewritting this function in `Fortran 95` using
the `BIND(C)` attribute in Section @sec:umat_wrapper:fortran95.

This implementation has no state variables and requires two material
properties: the Young' modulus and the Poisson' ratio.

The number of arguments effectively used by the subroutine is here very
small compared to the total number of arguments:

- `stress`: an array containing the values of the stress at the
  beginning of the time step on input and the values of the stress at
  the end of the time step on output.
- `ddsdde`: an array containing the values of the consistent tangent
  operator on output. As the behaviour is linear elastic, the consistent
  tangent operator is simply the stiffness matrix.
- `stran`: an array containing the values of the strain at the beginning
  of the time step.
- `dstran`: an array containing the values of the strain increment
  during the time step.
- `props`: an array containing the material properties.

It is important to note that this implementation does not make any check
of its arguments. For example, the user may pass any number of material
properties, which may lead to segmentation faults at best or to spurious
results difficult to debug at worse. It is interesting to note that
`MFront` will ensure the correct usage of the wrapped behaviour and
automatically generate the correct checks.

The `UMAT` interface uses the so-called Voigt conventions to store
symmetric tensors as vectors. `MFront` uses a different convention, as
described in [its
documentation](https://thelfer.github.io/tfel/web/tensors.html)
[@cea_edf_tfel_tensors_2021]. Conversion functions are thus required on
input and output of the `UMAT` implementation.

Special care must also be taken regarding the consistent tangent
operator. Not only shall the difference of conventions be taken into
account, but also the fact that `fortran` uses a column-major convention
to store matrices while the `TFEL/Math` library uses a row-major
convention. Basically, this means that the consistent tangent operator
must transposed. In the case of linear elasticity, the stiffness matrix
is obviously symmetric, but this is not the general case.

In this case, the wrapper shall:

1. convert the strain, the strain increment and stress tensors on input
2. pass the material properties on input.
3. convert the stress tensor and the stiffness matrix on output.

The conversion functions required by Steps 1 and 3 will be the same for
all wrappers of `UMAT` implementations. Moreover, the same conversion
functions could also be used when wrapping `VUMAT` behaviours used by
`Abaqus/Explicit`. It is then convenient to implement them in a
dedicated header file, called `MFrontUmatWrapper.hxx` in the following,
using `C++` template functions. This header is described in Section
@sec:umat_wrapper:MFrontUmatWrapper.

Step 2 is a bit more interesting to discuss as it exposes important
design choices, as discussed in Section @sec:umat_wrapper:material_properties.

# Description of the `MFrontUmatWrapper.hxx`  header file {#sec:umat_wrapper:MFrontUmatWrapper}

The `MFrontUmatWrapper.hxx` header file defines conversion functions
that can be used by any `UMAT` and `VUMAT` wrappers to convert stress,
strain and consistent tangent operators.

- `convertStrainToAbaqus`, which computes the strain tensor using
  `̀UMAT` conventions from the `MFront` strain tensor. This function can
  also be used for the strain increment tensor.
- `convertStressToAbaqus`, which computes the stress tensor using
  `̀UMAT` conventions from the `MFront` stress tensor.
- `convertStressFromAbaqus`, which computes the `MFront` stress tensor
  from the `UMAT` result.
- `convertStiffnessMatrixFromAbaqus`, which computes the `MFront`
  stiffness matrix for the `UMAT` result.

To avoid runtime checks, those functions use a the modelling hypothesis
as a first template parameter. We use here the fact that `MFront`'
behaviours are also templated by the modelling hypothesis, which is then
known at compile-time.

Since `Abaqus/Explicit` handles computations in simple and double
precision, the conversion function takes the numeric type as a second
template parameter.

All the convertion functions are declared in the `mfront_umat_wrapper`
namespace.

Listing @lst:umat_wrapper:convertStrainToAbaqus provide an
implementation, limited to the tridimensional case, of the
`convertStrainToAbaqus` function.

~~~~{#lst:umat_wrapper:convertStrainToAbaqus .cxx caption="Source code of the `convertStrainToAbaqus` function"}
  template <Hypothesis H, typename NumType>
  void convertStrainToAbaqus(AbaqusRealType *const e,
                             const NumType *const strain) {
    if constexpr (H == Hypothesis::TRIDIMENSIONAL) {
      constexpr auto cste = tfel::math::Cste<NumType>::sqrt2;
      e[0] = strain[0];
      e[1] = strain[1];
      e[2] = strain[2];
      e[3] = strain[3] * cste;
      e[4] = strain[4] * cste;
      e[5] = strain[5] * cste;
    } else {
      tfel::raise("Unsupported hypothesis");
    }
  }  // end of convertStrainToAbaqus
~~~~

# Treatment of the material properties {#sec:umat_wrapper:material_properties}

The treatment of the material properties deserves a special discussion.

The first choice that one has to make is whether the final behaviour
shall be specific to a given material and self-contained or be generic.
You may refer to the [front page](index.html) of the project for a
detailled discussion about those concepts.

Of course, in the case of the simple example treated in this document,
this kind of considerations seems largely overkill. For the sake of the
discussion, let us however pretend that we are considering an non
trivial `UMAT` behaviour.

## The generic behaviour case

Material properties, introduced by the `@MaterialProperty` keyword,
imposes that the solver provides the required material coefficients.

For the sake of simplicity, we choose that the `MFront` behaviour
require the same material properties than the `UMAT` implementation,
i.e. the Young' modulus and the Poisson' ratio. But other choices could
have been discussed and we could have chosen another pair of elastic
properties, for example the Lamé' coefficients: with such a choice, the
wrapper then would need to compute the Young' modulus and the Poisson'
ratio before calling the `UMAT` behaviour.

Another choice now have to be made: shall we declare an array of
material properties or shall we declare two distinct material properties
? As usual, each solution have drawbacks and avantages, as now
discussed.

### Declaring an array of material properties

Declaring an array of material properties has one pratical advantage as
it already meets the requirements that the material properties shall be
stored in a continuous array.

This array of material properties could be declared as follows:

~~~~{.cxx}
//! elastic material properties
@MaterialProperty real emps[2];
emps.setEntryName("ElasticProperties");
~~~~

Before calling the `UMAT` implementation, a pointer to the beginning of the
array can be retrieved as follows:

~~~~{.cxx}
const auto* const props = emps.data();
~~~~

From the point of view of the developper of the `MFront` wrapper, this
may seem very convenient and straightforward.

However, from the end-user point of view, this solution may seem less
attractive. In particular, if the solver that he uses relies on the
metadata exported by `MFront`, it will require the end-user to define
two material properties named respectively `ElasticProperties[0]` and
`ElasticProperties[1]`. One may agree that those names are not very
explicit.

Of course, this seems articifial when considering only two material
properties, but this may not be as evident for complex behaviours
requiring several dozen of material properties as the amount of work
required to develop the wrapper increases. This remark can be directly
transposed to internal state variables, if any.

### Declaring two distinct material properties

The Young' modulus and the Poisson' ratio can be declared as follows:

~~~~{.cxx}
@MaterialProperty stress E;
E.setGlossaryName("YoungModulus");
@MaterialProperty real nu;
nu.setGlossaryName("PoissonRatio");
~~~~

This is more explicit and potentially more attractive for the end-user
if the solver that he uses relies on the metadata exported by `MFront`.

Before calling the `UMAT` implementation, one shall create an array of
floating-point values and initialize its values as follows:

~~~~{.cxx}
const real props[2] = {E,nu};
~~~~

Again, this is straightforward when only two material properties are
considered, but the effort grows significantly as the number of material
properties increases.

> **About the usage of quantities**
>
> One may notice that we have declared the Young' modulus as a variable
> of type `stress`. This is only informative as long as support for
> quantities has not been enabled (using the `@UseQt` keyword).
>
> It is highly discouraged to enable support for quantities when
> creating a wrapper as it generates an extra layer of complexity
> for an *a priori* doubtful gain.

## The self-contained case

Various approaches may be followed to implement a self-contained
behaviour. The most standard is to use parameters. Again, one have the
choice between using an array of parameters or two distinct parameters
with similar advantages and drawbacks.

# Implementation of the `UMAT` wrapper in `MFront`

## A quick overview of `fortran 77`/`C++` interoperability

The `umat` function has the following prototype in `fortran` (see
Appendix @sec:umat_wrapper:umat_source_code):

~~~~{.fortran}
     subroutine umat(stress,statev,ddsdde,sse,spd,scd,
     &  rpl,ddsddt,drplde,drpldt,
     &  stran,dstran,time,dtime,temp,dtemp,predef,dpred,cmname,
     &  ndi,nshr,ntens,nstatv,props,nprops,coords,drot,pnewdt,
     &  celent,dfgrd0,dfgrd1,noel,npt,layer,kspt,kstep,kinc)
!
      implicit none
!
      character*80 cmname
!
      integer ndi,nshr,ntens,nstatv,nprops,noel,npt,layer,kspt,
     &  kstep,kinc
!
      real*8 stress(ntens),statev(nstatv),
     &  ddsdde(ntens,ntens),ddsddt(ntens),drplde(ntens),
     &  stran(ntens),dstran(ntens),time(2),celent,
     &  props(nprops),coords(3),drot(3,3),dfgrd0(3,3),dfgrd1(3,3),
     &  sse,spd,scd,rpl,drpldt,dtime,temp,dtemp,predef,dpred,
     &  pnewdt
~~~~

This prototype is equivalent to the following `C` declaration:

~~~~{.cxx}
void umat_(
    double *const,       /*< STRESS, stress                   */
    double *const,       /*< STATEV, internal state variables */
    double *const,       /*< DDSDDE, tangent operator         */
    double *const,       /*< SSE */
    double *const,       /*< SPD */
    double *const,       /*< SCD */
    double *const,       /*< RPL */
    double *const,       /*< DDSDDT */
    double *const,       /*< DRPLDE */
    double *const,       /*< DRPLDT */
    const double *const, /*< STRAN, strain tensor    */
    const double *const, /*< DSTRAN, strain increment */
    const double *const, /*< TIME */
    const double *const, /*< DTIME, time increment   */
    const double *const, /*< TEMP, temperature      */
    const double *const, /*< DTEMP, temperature increment    */
    const double *const, /*< PREDEF, external state variables */
    const double *const, /*< DPRED, external state variables increments   */
    const char *const,   /*< CMNAME */
    const int *const,    /*< NDI */
    const int *const,    /*< NSHR */
    const int *const,    /*< NTENS, number of components of tensors */
    const int *const,    /*< NSTATV, number of internal state variables */
    const double *const, /*< PROPS, material properties */
    const int *const,    /*< NPROPS, number of material properties */
    const double *const, /*< COORDS */
    const double *const, /*< DROT, incremental rotation matrix */
    const double *const, /*< PNEWDT, estimation of the next time increment */
    const double *const, /*< CELENT */
    const double *const, /*< DFGRD0 */
    const double *const, /*< DFGRD1 */
    const int *const,    /*< NOEL */
    const int *const,    /*< NPT */
    const int *const,    /*< LAYER */
    const int *const,    /*< KSPT */
    const int *const,    /*< KSTEP */
    int *const,          /*< KINC */
    const int /* hidden fortran parameter */);
}
~~~~

Note that the name chosen for this function follows `gfortan`' mangling
scheme for fortran functions, i.e. the `fortran` `umat` function is
exported as `umat_`. This is not portable. So is the type of the hidden
parameter holding the size of the `CMNAME` parameter.

For real world use, we strongly advice to either:

- modify the wrapped function and rewrite it in `Fortran 2003`.
- create an intermediate `fortran` function with proper `C` bindings.

In both cases, we also stronly advice to remove useless parameters.

We do not do this in this tutorial at this stage for the sake of
generality and will show a more satisfying solution in Section
@sec:umat_wrapper:fortran95.

One shall not that all parameters are passed as pointers, except the
hidden fortran parameter.

## Choice of the domain specific language`MFront`

~~~~{.cxx}
@DSL Default;
~~~~

## Some metadata

~~~~{.cxx}
@Behaviour SmallStrainUmatWrapper;
@Author Thomas Helfer;
@Date 11 / 02 / 2021;
~~~~

## Restricting the allowed modelling hypothesis

The conversion functions are limited to the tridimensional modelling
hypothesis. Trying to use them with another modelling hypothesis would
result in a compile-time error.

The `@ModellingHypothesis` keyword allows to only generate the
tridimensional version of this behaviour:

~~~~{.cxx}
@ModellingHypothesis Tridimensional;
~~~~

## Including the `MFrontUmatWrapper` file

The `@Includes` code block can be use to include the
`MFrontUmatWrapper.hxx` header and declare the `umat_` function as
follows:

~~~~{.cxx}
@Includes {
#include "MFrontUmatWrapper.hxx"

#ifndef MFRONT_UMAT_FUNCTION_DECLARATION
#define MFRONT_UMAT_FUNCTION_DECLARATION 1
extern "C" {

void umat_(
    AbaqusRealType *const /* STRESS */, /* stress                   */
    AbaqusRealType *const /* STATEV */, /* internal state variables */
    AbaqusRealType *const /* DDSDDE */, /* tangent operator         */
    AbaqusRealType *const /* SSE */,
    AbaqusRealType *const /* SPD */,
    AbaqusRealType *const /* SCD */,
    AbaqusRealType *const /* RPL */,
    AbaqusRealType *const /* DDSDDT */,
    AbaqusRealType *const /* DRPLDE */,
    AbaqusRealType *const /* DRPLDT */,
    const AbaqusRealType *const /* STRAN */,  /* strain tensor    */
    const AbaqusRealType *const /* DSTRAN */, /* strain increment */
    const AbaqusRealType *const /* TIME */,
    const AbaqusRealType *const /* DTIME */,  /* time increment   */
    const AbaqusRealType *const /* TEMP */,   /* temperature      */
    const AbaqusRealType *const /* DTEMP */,  /* temperature increment    */
    const AbaqusRealType *const /* PREDEF */, /* external state variables */
    const AbaqusRealType *const /* DPRED */, /* external state variables increments   */
    const char *const /* CMNAME */,
    const AbaqusIntegerType *const /* NDI */,
    const AbaqusIntegerType *const /* NSHR */,
    const AbaqusIntegerType *const /* NTENS */, /* number of components of tensors */
    const AbaqusIntegerType *const /* NSTATV */, /* number of internal state variables */
    const AbaqusRealType *const /* PROPS */, /* material properties */
    const AbaqusIntegerType *const /* NPROPS */, /* number of material properties */
    const AbaqusRealType *const /* COORDS */,
    const AbaqusRealType *const /* DROT, incremental rotation matrix */,
    const AbaqusRealType *const /* PNEWDT, estimation of the next time increment */,
    const AbaqusRealType *const /* CELENT */,
    const AbaqusRealType *const /* DFGRD0 */,
    const AbaqusRealType *const /* DFGRD1 */,
    const AbaqusIntegerType *const /* NOEL */,
    const AbaqusIntegerType *const /* NPT */,
    const AbaqusIntegerType *const /* LAYER */,
    const AbaqusIntegerType *const /* KSPT */,
    const AbaqusIntegerType *const /* KSTEP */,
    AbaqusIntegerType *const /* KINC */,
    const int /* hidden fortran parameter */);

} // end of extern "C"
#endif MFRONT_UMAT_FUNCTION_DECLARATION 1
}
~~~~

In the `umat_` function declaration, we used to type aliases,
`AbaqusIntegerType` and `AbaqusRealType`, which is usually a good
practice. Here, we recognize that this is a bit overkill, if not
pedantic.

## Elastic properties

Following the discussion of Section
@sec:umat_wrapper:material_properties, we choose here to declare two
distincts material properties:

~~~~{.cxx}
@MaterialProperty stress E;
E.setGlossaryName("YoungModulus");
@MaterialProperty real nu;
nu.setGlossaryName("PoissonRatio");
~~~~

## Local variable

In our implementation, it will be usefull to store the values of the
consistent tangent operator computed by the `UMAT` implementation in a
local variable, as discussed in Section
@sec:umat_wrapper:tangent_operator.

~~~~{.cxx}
@LocalVariable StiffnessTensor K;
~~~~~

## Implementation of the behaviour integration

The behaviour integration is performed in the `@Integrator` code block.

~~~~{.cxx}
@Integrator {
~~~~

We first define the `̀KINC` integer which will hold the returned value
of the `UMAT` implementation. It is initialized to `1` and is only
modified by the `UMAT` implementation in case of integration failure.

~~~~{.cxx}
  AbaqusIntegerType KINC = 1;
~~~~

We then define a lot of variables which are part of the `UMAT` interface
but unused by the implementation that we are interfacing in this
tuturial:

~~~~{.cxx}
  // unused variables
  const AbaqusRealType dfgrd0[9] = {0, 0, 0,  //
                                    0, 1, 0,  //
                                    0, 0, 1};
  const AbaqusRealType dfgrd1[9] = {0, 0, 0,  //
                                    0, 1, 0,  //
                                    0, 0, 1};
  const AbaqusRealType drot[9] = {1, 0, 0,  //
                                  0, 1, 0,  //
                                  0, 0, 1};
  const AbaqusIntegerType KSTEP[3u] = {0, 0, 0};
  AbaqusRealType sse, spd, scd, rpl;
  AbaqusRealType ddsddt[6];
  AbaqusRealType drplde[6];
  AbaqusRealType drpldt;
  AbaqusRealType time[2];
  AbaqusRealType pred[1];
  AbaqusRealType dpred[1];
  AbaqusRealType isvs[1];
  AbaqusRealType coords[3] = {0, 0, 0};
  AbaqusRealType celent;
  AbaqusRealType rdt;
  const char name[81] =
      "Elasticity                              "  //
      "                                        ";
  AbaqusIntegerType layer;
  AbaqusIntegerType kspt;
~~~~

As those variables are passed by pointers, we could directly pass the
null pointers to the `UMAT` implementation, i.e. the `nullptr` value. We
define those unused variables to facilitate the extension to more
complex `UMAT` implementations.

Note that we define the `name` variable as an array of 81 characters to
take into account the `C` terminating characters '\0'.

The material properties are stored in a temporary array, as follows:

~~~~{.cxx}
const AbaqusRealType props[2] = {E,nu};
~~~~

The next step is to convert the strain, strain increment and stress. We
first define the array that will hold the converted values and call the
conversion functions.

~~~~{.cxx}
  AbaqusRealType e[6];
  AbaqusRealType de[6];
  AbaqusRealType s[6];
  mfront_umat_wrapper::convertStrainToAbaqus<hypothesis>(e, &eto[0]);
  mfront_umat_wrapper::convertStrainToAbaqus<hypothesis>(de, &deto[0]);
  mfront_umat_wrapper::convertStressToAbaqus<hypothesis>(s, &sig[0]);
~~~~

We then define the various integer constants required by the `UMAT`
interface:

~~~~{.cxx}
  const auto nprops = static_cast<AbaqusIntegerType>(2);
  const auto nstatv = static_cast<AbaqusIntegerType>(0);
  const auto ntens = static_cast<AbaqusIntegerType>(6);
  const auto ndi = static_cast<AbaqusIntegerType>(3);
  const auto nshr = static_cast<AbaqusIntegerType>(3);
  const auto noel = static_cast<AbaqusIntegerType>(0);
  const auto npt = static_cast<AbaqusIntegerType>(0);
~~~~

Note that the values of `ntens` (number of components of the stress
tensor), `ndi` (number of diagonal components of the stress tensor) and
`nshr` (number of shear components of the stress tensor) shall be
modified if other modelling hypothesis has to be supported.

Finally, we can now call the `UMAT` implementation as follows:

~~~~{.cxx}
  umat_(
      s,        /* stress                   */
      &isvs[0], /* &isvs[0], internal state variables */
      &K(0, 0), /* tangent operator         */
      &sse, &spd, &scd, &rpl, ddsddt, drplde, &drpldt,
      e,                         /* strain tensor    */
      de,                        /* strain increment */
      time,                      //
      &dt,                       /* time increment   */
      &T,                        /* temperature      */
      &dT,                       /* temperature increment    */
      pred,                      /* &esvs[0], external state variables */
      dpred,                     /* &desvs[0], external state variables */
      name, &ndi, &nshr, &ntens, /* number of components of tensors */
      &nstatv,                   /* number of internal state variables */
      &mps[0],                   /* material properties                   */
      &nprops,                   /* number of material properties */
      coords, drot,              /* rotation matrix                       */
      &rdt,                      /* estimation of the next time increment */
      &celent, dfgrd0, dfgrd1, &noel, &npt, &layer, &kspt, KSTEP,
      &KINC, 80);
~~~~

After the call, one checks that the behaviour integration succeeded by
testing the value of the `KINC` variable:

~~~~{.cxx}
  if(KINC != 1){
    return FAILURE;
  }
~~~~

If can of success, one converts the stress back to the `MFront` tensor:

~~~~{.cxx}
  mfront_umat_wrapper::convertStressFromAbaqus<hypothesis>(&sig[0], s);
}
~~~~

## Conversion of the tangent operator {#sec:umat_wrapper:tangent_operator}

The `@TangentOperator` is only called, after the behaviour integration,
if the consistent tangent operator has been requested by the solver. We
can use this code block for the conversion of the consistent tangent
operator as follows:

~~~~{.cxx}
@TangentOperator {
  static_cast<void>(smt);
  mfront_umat_wrapper::convertStiffnessMatrixFromAbaqus<hypothesis>(&Dt(0, 0),
                                                                    &K(0, 0));
}
~~~~

This optional conversion of the consistent tangent operator in a
separate code block is the main reason why we stored the values of the
consistent tangent operator in the local variable `K`.

# Compiling the wrapper outside the `MFrontGallery`

Firt this first test, we will compile the `umat` file in a seperate
shared library that will be linked to the shared library generated by
`MFront`. This is convenient as it does not require the user to handle
the complexity of generating shared libraries built with different
languages (`C++` and `fortran`) and barely relies on the standard
compilation process provided by `MFront`.

## Compiling the `umat.f` file

In this tutorial, we compile the `umat.f` file as a shared library as
follows:

~~~~{.bash}
$ gfortran -O2 --shared -fPIC -DPIC umat.f -o libUmat.so
~~~~

## Compiling the `MFront` wrapper

The compilation of the `MFront` wrapper is almost standard:

~~~~{.bash}
$ mfront -I $(pwd) --obuild --interface=generic SmallStrainUmatWrapper.mfront \
  --@Link='{"-L ../ -lUmat"}'
~~~~

Two things must be noted about this command:

- We use the `-I` flag to add the current directory to the compiler'
  header paths. This allows the compiler to find the
  `MFrontUmatWrapper.hxx` header.
- We added additional link directives using the `@Link` keyword to link
  the generated shared library with the `libUmat.so` library. As the
  generated shared library is built in the `src` subdirectory, we must
  add the parent directory to the linker' paths using the flag `-L ../`.
  We could have added this keyword in the `MFront` file but, as a matter
  of taste, we don't like having relative paths inside an `MFront` file.

## Running a simple test with `MTest`

At this stage, we are able to test our wrapper in `MTest` using this
simple uniaxial test:

~~~~{.cxx}
@ModellingHypothesis "Tridimensional";
@Behaviour<generic> "src/libBehaviour.so" "SmallStrainUmatWrapper";

// material properties
@MaterialProperty<constant> "YoungModulus" 150e9;
@MaterialProperty<constant> "PoissonRatio" 0.3;

// external state variable
@ExternalStateVariable "Temperature" 293.15;

@ImposedStrain "EXX" {0 : 0, 1: -1.e-2};

@Times{0, 1 in 10};
~~~~

This script can be executed as follows:

~~~~{.bash}
$ mtest SmallStrainUmatWrapper.mtest
~~~~

> **Updating `LD_LIBRARY_PATH` **
> 
> Note that on some systems, one shall add the current directory to the
> `LD_LIBRARY_PATH` environment variable before calling `mtest` to find
> the `libUmat.so` library, as follows:
> 
> ~~~~{.bash}
> $ export LD_LIBRARY_PATH=$(pwd):$LD_LIBRARY_PATH
> ~~~~

# A better solution {#sec:umat_wrapper:fortran95}

The previous implementation can be improved in several ways. In this
section, we propose a new implementations which:

- Reduces the number of parameters to the minimum, as the `UMAT`
  implementation effectively uses only a very limited subset of the
  arguments required by the `UMAT` interface.
- Solves the portability issue using the `BIND(C)` attribute.

## Modification of the `fortran` sources

The first thing to do is to rename the file `umat.f` in `umat.f90` which
is a more or less standard file extension for free-form fortran source
greater than `Fortran 90` (extension like `f95` and `f03` does not seem
to be supported by build systems and text editors, as explained
[here](https://fortranwiki.org/fortran/show/File+extensions)).

After converting the code to free form and removing the unused
variables, the `umat2` subroutine has the following declaration:

~~~~{.fortran}
subroutine umat2(stress, ddsdde, stran, dstran, ntens, props, nprops) &
  BIND(C,NAME="umat2")
~~~~

See Listing @lst:umat_wrapper:umat2_source_code in Appendix
@sec:umat_wrapper:umat2_source_code for the full code of the `umat2`
subroutine.

The `NAME` option specifies the name of the exported symbol. This is the
name of the function on the `C++` side. This name is now perfectly
portable across implementations.

## Modification of the `MFront` wrapper

Two code blocks of the `MFront` wrapper must be changed:

- The `@Includes` code block to change the declaration of the `umat`
  function.
- The `@Integrator` code block to change the call of the `umat`
  function.

### Modifying the `@Includes` code block

The `@Includes` code block is now much shorter, as follows:

~~~~{.cxx}
@Includes {
#include "MFrontUmatWrapper.hxx"

#ifndef MFRONT_UMAT2_FUNCTION_DECLARATION
#define MFRONT_UMAT2_FUNCTION_DECLARATION 1

extern "C" {

void umat2(
    AbaqusRealType *const,          /* STRESS,  stress                   */
    AbaqusRealType *const,          /* DDSDDE,  tangent operator         */
    const AbaqusRealType *const,    /* STRAN, strain tensor    */
    const AbaqusRealType *const,    /* DSTRAN,  strain increment */
    const AbaqusIntegerType *const, /* NTENS, number of components of tensors */
    const AbaqusRealType *const,    /* PROPS, material properties */
    const AbaqusIntegerType *const  /* NPROPS, number of material properties*/
);

} // end of extern "C"

#endif MFRONT_UMAT2_FUNCTION_DECLARATION 1

} // end of @Includes
~~~~

### Modifying the `@Integrator` code block

Once useless variables are removed, the source code of the `@Integrator`
code block is also much shorter:

~~~~{.cxx}
@Integrator {
  //
  const AbaqusRealType props[2] = {E, nu};
  //
  AbaqusRealType e[6];
  AbaqusRealType de[6];
  AbaqusRealType s[6];
  //
  mfront_umat_wrapper::convertStrainToAbaqus<hypothesis>(e, &eto[0]);
  mfront_umat_wrapper::convertStrainToAbaqus<hypothesis>(de, &deto[0]);
  mfront_umat_wrapper::convertStressToAbaqus<hypothesis>(s, &sig[0]);
  //
  const auto nprops = static_cast<AbaqusIntegerType>(2);
  const auto ntens = static_cast<AbaqusIntegerType>(6);
  //
  umat2(s,         /* stress              */
        &K(0, 0),  /* tangent operator    */
        e,         /* strain tensor       */
        de,        /* strain increment    */
        &ntens,    /* number of components of the stress tensor*/
        &props[0], /* material properties */
        &nprops    /* number of material properties*/
  );
  //
  mfront_umat_wrapper::convertStressFromAbaqus<hypothesis>(&sig[0], s);
}
~~~~

As a rule of thumb, reducing the number of arguments passed from `C++`
to `fortran` to the bare minimum is highly recommended as there is no
way for the compiler of the linker to check the consistency of those
arguments. It is the responsability of the developper to make the `C++`
call match the `fortran` declaration. This is the source of hours of
painful debugging.

# Introducing the wrapped implementation in `MFrontGallery`

## The `MFrontUserWrapper.hxx` header

The `MFrontUserWrapper.hxx` header may be shared between several
wrappers. Such headers may be rightfully be placed in the `include`
directory at the root of the `MFrontGallery` project.

If it exists, this directory is automatically added to the compiler'
include path by the [`cmake` infrastructure](cmake-infrastructure.html).

However, as the project grows, such shared utility headers may multiply,
with the risk of a cluttering of the `include` directory.

To sort things out, we choose to create an `MFront/Wrappers`
subdirectory. We also choose to rename the file `UmatWrapper.hxx` to
avoid a redundant `MFront`.

## Building the libraries

We choose to create two libraries `v1` and `v1` for each versions of the
wrapped behaviour. Those directories are placed in the
`unit-tests/mfront-wrappers/fortran/umat/` directory.

> **The `enable-fortran-behaviours-wrappers` options**
>
> The subdirectories of the `mfront-wrappers/fortran` directory are only
> treated if the `enable-fortran-behaviours-wrappers` has been set to
> `ON` at the `cmake` configuration stage (see the
> [install page](install.html) for details).
>
> This options ensures that proper support of `Fortran` language has
> been set up.

The content of those directories is the following:

~~~~{.bash}
mfront-wrappers/fortran/umat
├── mfront-wrappers/fortran/umat/v1
│   ├── mfront-wrappers/fortran/umat/v1/CMakeLists.txt
│   ├── mfront-wrappers/fortran/umat/v1/SmallStrainUmatWrapper_v1.mfront
│   └── mfront-wrappers/fortran/umat/v1/umat.f
└── mfront-wrappers/fortran/umat/v2
    ├── mfront-wrappers/fortran/umat/v2/CMakeLists.txt
    ├── mfront-wrappers/fortran/umat/v2/SmallStrainUmatWrapper_v2.mfront
    └── mfront-wrappers/fortran/umat/v2/umat2.f90
~~~~

For the sake of clarity, the `MFront` implementations have been renamed
and the name of the generated behaviours changes accordingly.

### Second version of the wrapper

The contents of the `CMakeLists.txt` are very simple for the second
version, as shown by the following listing:

~~~~{.cmake}
mfront_behaviours_library(UmatWrapperV2
  SmallStrainUmatWrapperV2
  umat2.f90)
~~~~

The `mfront_behaviour_library` function is described in the documentation
of the [cmake infrastructure](cmake-infrastructure.html) of the project.

This call to the `mfront_behaviour_library` function generates the following output:

~~~~{.bash}
-- Adding library : UMATWRAPPERV2CALCULIXBEHAVIOURS
  (mfront-wrappers/fortran/umat/v2/calculix/src/calculixSmallStrainUmatWrapper_v2.cxx;
   mfront-wrappers/fortran/umat/v2/calculix/src/SmallStrainUmatWrapper_v2.cxx;umat2.f90)
-- Adding library : UMATWRAPPERV2ANSYSBEHAVIOURS
  (mfront-wrappers/fortran/umat/v2/ansys/src/ansysSmallStrainUmatWrapper_v2.cxx;
   mfront-wrappers/fortran/umat/v2/ansys/src/SmallStrainUmatWrapper_v2.cxx;umat2.f90)
-- Adding library : UMATWRAPPERV2ABAQUSBEHAVIOURS
  (mfront-wrappers/fortran/umat/v2/abaqus/src/abaqusSmallStrainUmatWrapper_v2.cxx;
   mfront-wrappers/fortran/umat/v2/abaqus/src/SmallStrainUmatWrapper_v2.cxx;umat2.f90)
-- SmallStrainUmatWrapper_v2 has been discarded for interface cyrano
  (behaviour does not support any of the  'AxisymmetricalGeneralisedPlaneStrain'
   or  'AxisymmetricalGeneralisedPlaneStress modelling' hypothesis)
-- Only external sources provided for library UmatWrapperV2Behaviours-cyrano for
   interface cyrano. The generation of this library is disabled by default.
   It can be enabled by using the GENERATE_WITHOUT_MFRONT_SOURCES option
-- SmallStrainUmatWrapper_v2 has been discarded for interface epx
  (small strain behaviours are not supported)
-- Only external sources provided for library UmatWrapperV2Behaviours-epx for
   interface epx. The generation of this library is disabled by default.
   It can be enabled by using the GENERATE_WITHOUT_MFRONT_SOURCES option
-- Adding library : UmatWrapperV2DianaFEABehaviours
  (mfront-wrappers/fortran/umat/v2/dianafea/src/DianaFEASmallStrainUmatWrapper_v2.cxx;
   mfront-wrappers/fortran/umat/v2/dianafea/src/SmallStrainUmatWrapper_v2.cxx;umat2.f90)
-- Adding library : UmatWrapperV2Behaviours-aster
  (mfront-wrappers/fortran/umat/v2/aster/src/asterSmallStrainUmatWrapper_v2.cxx;
   mfront-wrappers/fortran/umat/v2/aster/src/SmallStrainUmatWrapper_v2.cxx;umat2.f90)
-- Adding library : UmatWrapperV2Behaviours
  (mfront-wrappers/fortran/umat/v2/castem/src/umatSmallStrainUmatWrapper_v2.cxx;
   mfront-wrappers/fortran/umat/v2/castem/src/SmallStrainUmatWrapper_v2.cxx;umat2.f90)
-- Adding library : UmatWrapperV2Behaviours-generic
  (mfront-wrappers/fortran/umat/v2/generic/src/SmallStrainUmatWrapper_v2-generic.cxx;
   mfront-wrappers/fortran/umat/v2/generic/src/SmallStrainUmatWrapper_v2.cxx;umat2.f90)
~~~~

This output shows that:

- The wrapped behaviour is not compatible with some interfaces
  (`cyrano`, `europlexus` for instance) for reasons explicitely stated
  in the previous output.
- No library is generated by default if no `MFront` sources are
  compatible with the given interface. This could be changed by passing
  the `GENERATE_WITHOUT_MFRONT_SOURCES` option to the
  `mfront_behaviour_library` function.

> **Compiling the `fortran` sources in a separate shared library**
>
> Contrary to the standalone example, the `fortran` sources are compiled
> in the same shared library than the `MFront` file. Note that the
> `fortran` sources are compiled once for each interfaces.
>
> Another strategy would be to compile the `fortran` file in a separate
> shared library and link the `MFront` shared libraries to this shared
> library. This can be done as follows:
>
> ~~~~{.cmake}
> add_library(UmatImplementations SHARED umat2.f90)
> mfm_install_library(UmatImplementations)
> 
> mfront_behaviours_library(UmatWrapperV2
>  SmallStrainUmatWrapper_v2
>  LINK_LIBRARIES UmatImplementations)
> ~~~~

### First version of the wrapper

The `CMakeLists.txt` file for the first version of the wrapper is a bit
more involved as we try to avoid the portability issue by compiling the
`UmatWrapper_v2` only if:

- the `fortran` compiler is `gfortran`.
- the targeted system is `Linux`.

This is illustrated by the following script:

~~~~{.cxx}
if(GNU_FORTRAN_COMPILER AND (${CMAKE_SYSTEM_NAME} STREQUAL "Linux"))
  mfront_behaviours_library(UmatWrapperV1
    SmallStrainUmatWrapper_v1
    umat.f)
endif()
~~~~

The `GNU_FORTRAN_COMPILER` variable is automatically defined by the
`cmake` infrastructure of the project.

<!--
# Acknowledgements

The development of TFEL/MFront is conducted in the framework of the
`PLEIADES` project, which is supported financially by the French
Alternative Energies and Atomic Energy Commission (CEA), Électricité de
France (EDF) and Framatome.

We also acknowledge contributions from Thomas Nagel and David Mašín
during the genesis of this project. The funding by BGE mbH, the German
federal company for radioactive waste is greatly acknowledged.

\appendix
-->

# Appendix

## Source code of the `UMAT` subroutine {#sec:umat_wrapper:umat_source_code}

The source code of the `umat2` subroutine is reported in Listing @lst:umat_wrapper:umat_source_code.

~~~~{#lst:umat_wrapper:umat_source_code .fortran caption="Source code of the `UMAT` subroutine"}
     subroutine umat(stress,statev,ddsdde,sse,spd,scd,
     &  rpl,ddsddt,drplde,drpldt,
     &  stran,dstran,time,dtime,temp,dtemp,predef,dpred,cmname,
     &  ndi,nshr,ntens,nstatv,props,nprops,coords,drot,pnewdt,
     &  celent,dfgrd0,dfgrd1,noel,npt,layer,kspt,kstep,kinc)
!
      implicit none
!
      character*80 cmname
!
      integer ndi,nshr,ntens,nstatv,nprops,noel,npt,layer,kspt,
     &  kstep,kinc
!
      real*8 stress(ntens),statev(nstatv),
     &  ddsdde(ntens,ntens),ddsddt(ntens),drplde(ntens),
     &  stran(ntens),dstran(ntens),time(2),celent,
     &  props(nprops),coords(3),drot(3,3),dfgrd0(3,3),dfgrd1(3,3),
     &  sse,spd,scd,rpl,drpldt,dtime,temp,dtemp,predef,dpred,
     &  pnewdt
!
      integer i,j
      real*8 e,un,al,um,am1,am2
!
      e=props(1)
      un=props(2)
      al=un*e/(1.d0+un)/(1.d0-2.d0*un)
      um=e/2.d0/(1.d0+un)
      am1=al+2.d0*um
      am2=um
!
!     stress
!      
      stress(1)=stress(1)+am1*dstran(1)+al*(dstran(2)+dstran(3))
      stress(2)=stress(2)+am1*dstran(2)+al*(dstran(1)+dstran(3))
      stress(3)=stress(3)+am1*dstran(3)+al*(dstran(1)+dstran(2))
      stress(4)=stress(4)+am2*dstran(4)
      stress(5)=stress(5)+am2*dstran(5)
      stress(6)=stress(6)+am2*dstran(6)
!
!     stiffness
!
      do i=1,6
         do j=1,6
            ddsdde(i,j)=0.d0
         enddo
      enddo
      ddsdde(1,1)=al+2.d0*um
      ddsdde(1,2)=al
      ddsdde(2,1)=al
      ddsdde(2,2)=al+2.d0*um
      ddsdde(1,3)=al
      ddsdde(3,1)=al
      ddsdde(2,3)=al
      ddsdde(3,2)=al
      ddsdde(3,3)=al+2.d0*um
      ddsdde(4,4)=um
      ddsdde(5,5)=um
      ddsdde(6,6)=um
!
!     END EXAMPLE LINEAR ELASTIC MATERIAL
!
      return
      end
~~~~

## Source code of the `umat2` subroutine in `Fortran 2003` {#sec:umat_wrapper:umat2_source_code}

The source code of the `umat2` subroutine is reported in Listing @lst:umat_wrapper:umat2_source_code.

~~~~{#lst:umat_wrapper:umat2_source_code .fortran caption="Source code of the `umat2` subroutine"}
subroutine umat2(stress, ddsdde, stran, dstran, ntens, props, nprops) BIND(C,NAME="umat2")
!
implicit none
integer ntens,nprops
real*8 stress(ntens), ddsdde(ntens,ntens),stran(ntens), dstran(ntens), props(nprops)
!
integer i,j
real*8 e,un,al,um,am1,am2
!
e=props(1)
un=props(2)
al=un*e/(1.d0+un)/(1.d0-2.d0*un)
um=e/2.d0/(1.d0+un)
am1=al+2.d0*um
am2=um
!      
stress(1)=stress(1)+am1*dstran(1)+al*(dstran(2)+dstran(3))
stress(2)=stress(2)+am1*dstran(2)+al*(dstran(1)+dstran(3))
stress(3)=stress(3)+am1*dstran(3)+al*(dstran(1)+dstran(2))
stress(4)=stress(4)+am2*dstran(4)
stress(5)=stress(5)+am2*dstran(5)
stress(6)=stress(6)+am2*dstran(6)
!
do i=1,6
   do j=1,6
      ddsdde(i,j)=0.d0
   enddo
enddo
ddsdde(1,1)=al+2.d0*um
ddsdde(1,2)=al
ddsdde(2,1)=al
ddsdde(2,2)=al+2.d0*um
ddsdde(1,3)=al
ddsdde(3,1)=al
ddsdde(2,3)=al
ddsdde(3,2)=al
ddsdde(3,3)=al+2.d0*um
ddsdde(4,4)=um
ddsdde(5,5)=um
ddsdde(6,6)=um
return
end subroutine umat2
~~~~


# References
