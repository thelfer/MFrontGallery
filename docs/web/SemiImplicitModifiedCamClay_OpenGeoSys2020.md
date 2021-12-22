---
title: Implementation of the modified Cam Clay model in MFront/OpenGeoSys
author: Christian Silbermann, Thomas Nagel
date: 18/12/2021
lang: en-EN
numbersections: true
link-citations: true
colorlinks: true
figPrefixTemplate: "$$i$$"
tblPrefixTemplate: "$$i$$"
secPrefixTemplate: "$$i$$"
eqnPrefixTemplate: "($$i$$)"
abstract: |
  This report describes the implementation of the basic modified Cambridge
  (Cam) clay material model for small strains in the open-source
  multi-field software `OpenGeoSys`. For this, the set of
  constitutive equations is outlined and summarized. For the sake of
  simplicity, the elastic material parameters are kept constant
  since the usual dependencies on the porosity may violate thermodynamical
  consistency. Therefore, the model is called *basic* modified Cam
  clay model. An implicit numerical solution scheme is presented with
  additional options of refinement and stabilization. Based on the
  interface `MFront`, the implementation is outlined briefly. Then,
  numerical studies are presented for a single integration point using
  `MTest`, and eventually for meshes consisting of one or
  multiple finite elements using `OpenGeoSys`.
---

\newcommand{\tensor}[1]{\underline{#1}}
\newcommand{\tensorf}[1]{\underline{\underline{#1}}}
\newcommand{\ppkt}{\,\colon\,}
\newcommand{\D}{\text{D}}
\newcommand{\c}{\text{c}}
\newcommand{\d}{\text{d}}
\newcommand{\e}{\text{e}}
\newcommand{\p}{\text{p}}
\newcommand{\with}{\text{with}}
\newcommand{\trace}{\mathrm{trace}}
\newcommand{\divergence}{\mathrm{div}}
\newcommand{\minus}{-}
\newcommand{\inv}{{-1}}
\newcommand{\dyad}{\,\otimes\,}

# Introduction

The Cambridge (Cam) clay model describes the stress-dependent
deformation behaviour of cohesive soils. Thereby, effects like

- elasto-plastic deformation,
- irreversible (plastic) pore compaction,
- hardening and softening,
- consolidation,
- different loading and unloading stiffness

can be considered. Typical applications for the Cam clay model are the
calculation of soil strata, for example in geomechanical simulations.
The goal of this technical report is a consistent and clear presentation
of the basic modified Cam clay model ready for implementation and
practical use in continuum mechanical simulations using FEM. Here, the
material model interface `MFront` is used. For the sake of compactness,
a symbolic tensor notation is used where the number of underscores
indicates the order of the tensor object.

# Constitutive equations

## Preliminaries

In the small-strain setting there is an additive split of the linear
strain tensor reading
\[
  \tensor\varepsilon = \tensor\varepsilon_\e + \tensor\varepsilon_\p \ .
\]

The generalized Hooke's law relates elastic strains with stresses as
\[
  \tensor\sigma = \tensor{D}\ppkt\tensor\varepsilon_\e \ .
\]

Splitting the stress tensor\footnote{In soil mechanics, this would be
the effective stress tensor. As the context is clear here, we refrain
from writing $\tensor\sigma'$. Note also that a mechanical sign
convention is used in contrast to the soil mechanical concepts.} with
respect to deviatoric and volumetric parts yields

\[
  \tensor\sigma = \tensor\sigma^\D + \frac{1}{3}I_1(\tensor\sigma)\tensor{I} \ .
\]
Therewith, the von-Mises stress and the hydrostatic pressure is defined as
\[
  q \coloneqq \sqrt{\dfrac{3}{2}\ \tensor\sigma^\D\ppkt\tensor\sigma^\D} \quad,\quad p \coloneqq -\frac{1}{3}I_1(\tensor\sigma) \ .
\]
Consequently, positive values of $p$ represent a pressure whereas negative values represent hydrostatic tension, as expected.
With this, the stress tensor split reads $\tensor\sigma = \tensor\sigma^\D - p\tensor{I}$. Later the following derivatives will be required:
\[
  \frac{\partial q}{\partial \tensor\sigma} = \frac{3}{2}\ \frac{\tensor\sigma^\D}{q}\quad,\quad \frac{\partial p}{\partial \tensor\sigma} = -\frac{1}{3}\ \tensor{I} \ .
\]
Dealing with porous media there is a kinematic relation between porosity and volumetric strain. Let the total volume of an REV be divided into a pore volume and the solid volume:
\[
  V = V_{\text{S}} + V_{\text{P}} \ .
\]
Now, the porosity is defined as the pore volume fraction, i.\,e. $\phi=V_{\text{P}}/V$. Evaluating the mass balance equation of the porous solid yields the porosity evolution in the form
\[\label{eq:porEvolution}
  \dot{\phi} - \phi\divergence(\dot{\vec{u}}) = \trace(\dot{\tensor\varepsilon}) \ .
\]
Exploiting $\divergence(\dot{\vec{u}})\equiv \trace(\dot{\tensor\varepsilon})$ and separating the variables, this differential equation can be solved in a straightforward manner (cf. App.).

If the elastic volume changes are small compared to the plastic ones, the porosity (evolution) can be calculated from $\varepsilon^\text{V}_\p$ only. Instead of the porosity $\phi$, the pore number $e=V_{\text{P}} / V_{\text{S}}$ can equally be used with the relations

\[\label{eq:e-phiRelation}
  e = \frac{\phi}{1-\phi} \quad\with\quad 1+e = (1-\phi)^\inv \ .
\]

## System of equations

The following set of equations fully describes the basic modified Cam
clay model. Elasticity is

\[\label{eq:linearElasticity}
  \tensor\sigma = \tensor{D}\ppkt\left(\tensor\varepsilon - \tensor\varepsilon_\p \right) \ .
\]

Then, the \emph{modified} Cam clay yield function with the parameters
$M$ and $p_\c(e)$ is given by

\[
  f \coloneqq q^2 + M p(p-p_\c) \leq 0 \ .
\]

An associated flow rule (normality rule) is used to obtain the plastic
flow as\footnote{Note that we deviate here from the classical form by
means of normalizing the yield function gradient in stress space. This
was done in an effort to maintain consistency in the units, as the MCC
yield function has dimensions of stress squared in contrast to the usual
units of stress.}

\[\label{eq:flowRule}
  \dot{\tensor\varepsilon}_\p = \dot{\varLambda}_\p\ \tensor{n} \quad\with\quad \tensor{n} =\frac{\tensor{m}}{\|\tensor{m}\|} \quad,\quad \tensor{m} = \frac{\partial f}{\partial \tensor\sigma} \ .
\]

where $\dot{\varLambda}_\p$ denotes the plastic multiplier such that
$\d{\varLambda}_\p$ is the plastic increment and $\tensor{n}$ gives the
direction of the plastic flow. The plastic volume change rate is
obtained from:

\[
  \dot{\varepsilon}_\p^\text{V} = \trace(\dot{\tensor\varepsilon}_\p) = \dot{\varLambda}_\p\,\trace(\tensor{n})\ . %\tensor{I}\ppkt\tensor{n}
\]

The so-called pre-consolidation pressure $p_\c$ represents the yield
stress under isotropic compression and evolves as:

\[\label{eq:evolutionPc}
  \dot{p}_\c = \minus\dot{\varepsilon}_\p^\text{V} \vartheta(e)\ p_\c \quad\with\quad p_\c\big{|}_{t=0} = p_{\c 0} \ .
\]

This way, the pre-consolidation pressure increases in case of plastic
compaction, i.\,e. $\dot{\varepsilon}_\p^\text{V}<0$. Moreover, the
pre-consolidation pressure remains constant during purely elastic
loading. Furthermore, the parameter $\vartheta$ depends on the pore
number $e$ or the porosity $\phi$, respectively:

\[
  \vartheta(e) = \frac{1+e}{\lambda - \kappa} = \frac{1}{(\lambda - \kappa)(1 - \phi)} = \vartheta(\phi) \ ,
\]

where the material constants $\lambda, \kappa$ represent the slope of
the virgin normal consolidation line and the normal swelling line,
respectively (with $\lambda>\kappa$), in a semi-logarithmic $(1+e)-\ln
p$ plot. This gives:

\[
  \dot{p}_\c = -\dot{\varepsilon}_\p^\text{V} \left(\frac{1+e}{\lambda - \kappa}\right)\ p_\c \ .
\]

With the porosity evolution given by formula \eqref{eq:porEvolution},
the system of constitutive equations for the modified Cam clay model is
closed. This way, all the basic effects $1.-5.$ are captured.

In order to refine effect $5.$, namely load-path dependent elastic
stiffness, an evolution equation for the hydrostatic pressure and the
elastic volumetric strain, respectively, has to be added
@Callari1998:

\[\label{eq:evolutionP}
  \dot{p} = -\dot{\varepsilon}_\e^\text{V} \left(\frac{1+e}{\kappa}\right)\ p \ .
\]

As a consequence, the compression modulus becomes load-path-dependent,
too. Then, care must be taken that the constitutive equations are still
thermodynamically consistent @Borja1998. I also seems
counter-intuitive that the bulk modulus should increase with the pore
number. For these reasons and for the sake of simplicity, linear
elasticity is used here. This means instead of \eqref{eq:evolutionP}
holds

\[\label{eq:constK}
  \dot{p} = -\dot{\varepsilon}_\e^\text{V}\ K \ ,
\]

which is automatically fulfilled applying linear elasticity
\eqref{eq:linearElasticity} with a constant bulk modulus $K$.

# Numerical solution

## Total implicit solution scheme

For a time integration, the total values at the next instant of time are
calculated from the current values and the increments, i.\,e.

\[
\begin{align}
  \tensor\varepsilon_\e &\coloneqq {}^{k+1}\tensor\varepsilon_\e = {}^{k}\tensor\varepsilon_\e + \theta\varDelta \tensor\varepsilon_\e\ , \\
  \varLambda_p &\coloneqq {}^{k+1}\varLambda_p = {}^{k}\varLambda_p + \theta\varDelta \varLambda_p\ , \\
  p_\c &\coloneqq {}^{k+1}p_\c = {}^{k}p_\c + \theta\varDelta p_\c\ , \\
  \phi &\coloneqq {}^{k+1}\phi = {}^{k}\phi + \theta\varDelta\phi \ ,
\end{align}
\]

The discretized incremental evolution equation now read
\[
\begin{align}
  \varDelta\tensor\varepsilon_\p &= \varDelta{\varLambda}_\p\ \tensor{n}\ , \\
  \varDelta{\varepsilon}_\p^\text{V} &= \varDelta{\varLambda}_\p\,\trace(\tensor{n})\ , \\  
  \varDelta{p}_\c &= -\varDelta{\varepsilon}_\p^\text{V} \vartheta(e)\ p_\c\ , \\
  \varDelta\phi &= (1-\phi) \varDelta\varepsilon^\text{V} \ .
\end{align}
\]

With this, the discretized set of equations has the form

\[\label{eq:incrementalSystem}
\begin{align}
  \tensor{D}_{\!\varepsilon_\e} &= \varDelta\tensor\varepsilon_\e + \varDelta\varLambda_p\ \tensor{n} - \varDelta\tensor\varepsilon = \tensor0 \ ,\\
  f_{\!\varLambda_p} &= q^2 + M^2(p^2 - p\,p_\c) = 0 \ , \label{eq:flp}\\ %\dfrac{1}{E^2}
  f_{p_\c} &= \varDelta p_\c + \varDelta\varepsilon_\p^\text{V} \vartheta(\phi)\ p_\c = 0 \ , \label{eq:fpc} \\
  f_{\phi} &= \varDelta\phi - (1-\phi) \varDelta\varepsilon^\text{V} = 0 \ , \label{eq:fphi}
\end{align}
\]

where the total values are the values at the next instant of time, meaning $q={}^{k+1}q, p={}^{k+1}p$. For the partial derivatives the functional dependencies are required. They read

\[\label{eq:functionalDependence}
\begin{align}
  \tensor{D}_{\!\varepsilon_\e} &= \tensor{D}_{\!\varepsilon_\e}(\varDelta\tensor\varepsilon_\e, \varDelta\varLambda_p, \varDelta p_\c) \ ,\\
  f_{\!\varLambda_p} &= f_{\varLambda_p}(\varDelta\tensor\varepsilon_\e, \varDelta p_\c) \ , \\
  f_{p_\c} &= f_{p_\c}(\varDelta\tensor\varepsilon_\e, \varDelta\varLambda_p, \varDelta p_\c, \varDelta\phi)\ , \\
  f_{\phi} &= f_{\phi}(\varDelta\phi) \ ,
\end{align}
\]

where it was taken into account, that $q(\tensor\sigma),
p(\tensor\sigma)$ and $\tensor\sigma(\varDelta\tensor\varepsilon_\e)$
and $\tensor{n}(q, p, p_\c)$ and
$\varDelta\varepsilon_\p^\text{V}(\varDelta\varLambda_p, \tensor{n})$.

For the solution of the incremental set of equations \eqref{eq:incrementalSystem} with the Newton-Raphson method the partial derivatives with respect to the increments of the unknowns are required. They read

\[\label{eqset:partialDerivatives}
\begin{align}
  \frac{\partial\tensor{D}_{\!\varepsilon_\e}}{\partial\varDelta\tensor\varepsilon_\e} &= \tensorf{I} + \varDelta\varLambda_p\frac{\partial\tensor{n}}{\partial\varDelta\tensor\varepsilon_\e} \quad\with\quad \tensorf{I}=\vec{e}_a\dyad\vec{e}_b\dyad\vec{e}_a\dyad\vec{e}_b \ ,
  \\
  \frac{\partial\tensor{D}_{\!\varepsilon_\e}}{\partial\varDelta\varLambda_p} &= \tensor{n}\ ,
  \\
  \frac{\partial\tensor{D}_{\!\varepsilon_\e}}{\partial\varDelta p_\c} &= \varDelta\varLambda_p \ \frac{\partial\tensor{n}}{\partial\varDelta p_\c} ,
  \\[2mm]
  \frac{\partial f_{\!\varLambda_p}}{\partial\varDelta\tensor\varepsilon_\e} &= \frac{\partial f_{\!\varLambda_p}}{\partial \tensor\sigma} : \frac{\partial \tensor\sigma}{\partial \tensor\varepsilon_\e} : \frac{\partial\tensor\varepsilon_\e}{\partial\varDelta\tensor\varepsilon_\e} = \tensor{m} : \tensor{D}\ \theta\ , %: \theta\tensorf{I}
  \\
  \frac{\partial f_{\!\varLambda_p}}{\partial\varDelta p_\c} &= \frac{f_{\!\varLambda_p}}{\partial p_\c}\ \frac{\partial p_\c}{\partial \varDelta p_\c}
                                                              = -p M^2\, \theta\ , 
  \\[2mm]
  \frac{\partial f_{p_\c}}{\partial\varDelta\tensor\varepsilon_\e} &= \frac{\partial f_{p_\c}}{\partial\tensor{n}} : \frac{\partial\tensor{n}}{\partial\varDelta\tensor\varepsilon_\e}\ , 
  \\
  \frac{\partial f_{p_\c}}{\partial\varDelta\varLambda_p} &= \frac{\partial f_{p_\c}}{\partial\varDelta\varepsilon_\p^\text{V}}\ \frac{\partial\varDelta\varepsilon_\p^\text{V}}{\partial\varLambda_p} = \vartheta p_\c\,\trace(\tensor{n})\ ,
  \\
  \frac{\partial f_{p_\c}}{\partial\varDelta p_\c} &= 1 + \vartheta\varDelta\varepsilon_\p^\text{V}\theta + \frac{\partial f_{p_\c}}{\partial\tensor{n}} : \frac{\partial\tensor{n}}{\partial\varDelta p_\c}\ ,
  \\
  \frac{\partial f_{p_\c}}{\partial\varDelta\phi} &= \varDelta\varepsilon_\p^\text{V} p_\c \frac{\partial\vartheta(\phi)}{\partial\phi}\ \frac{\partial\phi}{\partial\varDelta\phi} 
                                                   = \frac{\varDelta\varepsilon_\p^\text{V} p_\c\,\theta }{(\lambda - \kappa)(1 - \phi)^2}\ , 
                                                   = \frac{\varDelta\varepsilon_\p^\text{V} p_\c\,\vartheta\,\theta }{(1 - \phi)}\ , 
  \\[2mm]
  \frac{\partial f_{\phi}}{\partial\varDelta\phi} &= 1 + \theta\varDelta\varepsilon^\text{V} \ .
\end{align}
\]

All other partial derivatives vanish according to the (missing)
dependencies \eqref{eq:functionalDependence}. Using the normalized flow
direction $\tensor{n}$, the derivatives with respect to some variable
$X$ can be obtained with the following rule:

\begin{align}
  \frac{\partial\tensor{n}}{\partial X} = \frac{1}{m}\left\{\frac{\partial\tensor{m}}{\partial X} - \frac{1}{2}\,\tensor{n}\dyad\frac{1}{m}\frac{\partial m^2}{\partial X} \right\}\quad\with\quad m=\|\tensor{m}\| \ .
\end{align}

Now, the missing expressions in overview \eqref{eqset:partialDerivatives} can be calculated as

\begin{align}
  \tensor{m} &= \frac{\partial f}{\partial \tensor\sigma} = \frac{\partial f}{\partial q}\,\frac{\partial q}{\partial \tensor\sigma} 
                                            +\frac{\partial f}{\partial p}\,\frac{\partial p}{\partial \tensor\sigma} 
                                           = 3\tensor\sigma^\D - \dfrac{M^2}{3}(2p-p_\c) \tensor{I} \ , 
  \\
  m^2 &= \tensor{m} : \tensor{m} = 6q^2 + \dfrac{M^4}{3}(2p-p_\c)^2 \qquad , \quad \tensor{n} = \tensor{m}/m \ , 
  \\
  \frac{\partial\tensor{m}}{\partial\tensor\varepsilon_\e} &= \left\{ \frac{\partial\tensor{m}}{\partial q}\,\frac{\partial q}{\partial \tensor\sigma} 
                                                              + \frac{\partial\tensor{m}}{\partial p}\,\frac{\partial p}{\partial \tensor\sigma} \right\}
                                                              : \frac{\partial \tensor\sigma}{\partial \tensor\varepsilon_\e} 
                                                      = \left\{ 3\tensorf{P} + \dfrac{2}{9} M^2 \tensor{I}\dyad\tensor{I} \right\} : \tensor{D} \ , 
  \\
  \frac{\partial m^2}{\partial\tensor\varepsilon_\e} &= \left\{ \frac{\partial m^2}{\partial q}\,\frac{\partial q}{\partial \tensor\sigma} 
                                                                      +\frac{\partial m^2}{\partial p}\,\frac{\partial p}{\partial \tensor\sigma} \right\}
                                                                      : \frac{\partial \tensor\sigma}{\partial \tensor\varepsilon_\e} 
  = \left\{ 18\tensor\sigma^\D - \dfrac{4}{9} M^4 (2p-p_\c)\tensor{I} \right\} : \tensor{D} \ , 
  \\
  \frac{\partial\tensor{n}}{\partial\varDelta\tensor\varepsilon_\e} &= 
  \frac{1}{m}\left\{\frac{\partial\tensor{m}}{\partial\tensor\varepsilon_\e} - \frac{1}{2}\,\tensor{n}\dyad\frac{1}{m}\frac{\partial m^2}{\partial\tensor\varepsilon_\e} \right\} :  
  \frac{\partial\tensor\varepsilon_\e}{\partial\varDelta\tensor\varepsilon_\e} \ ,
  \\
  \frac{\partial\tensor{n}}{\partial\varDelta p_\c} &= 
  \frac{1}{m}\left\{\frac{\partial\tensor{m}}{\partial p_\c} - \frac{1}{2}\,\tensor{n}\dyad\frac{1}{m}\frac{\partial m^2}{\partial p_\c} \right\} 
  \frac{\partial p_\c}{\partial\varDelta p_\c} = \frac{M^2}{3m}\left\{\tensor{I} + M^2(2p-p_\c)\,\tensor{n}/m \right\} \theta\ , 
  \\
  \frac{\partial f_{p_\c}}{\partial\tensor{n}} &= \frac{f_{p_\c}}{\partial\varDelta\varepsilon_\p^\text{V}}\, \frac{\partial\varDelta\varepsilon_\p^\text{V}}{\partial\tensor{n}} 
                                            = p_\c\vartheta\ \varDelta\varLambda_p \tensor{I} \ .
\end{align}

The solution of System \eqref{eq:incrementalSystem} can be accomplished
based on the Karush Kuhn Tucker conditions with an elastic predictor and
a plastic corrector step. This leads to a radial return mapping
algorithm (also known as active set search). Alternatively, the case
distinction can be avoided using the Fischer-Burmeister complementary
condition [@Ashrafi2016;@Bartel2019]. Both methods can be used in MFront
[@Helfer2015;@Helfer2020].


## Numerical refinement and stabilization {#sec:stabilization}

It is recommended to normalize all residuals
\eqref{eq:incrementalSystem} to some similar order of magnitude, e.\,g.
as strains. For this, equation \eqref{eq:flp} can be divided by some
characteristic value:

\begin{align}
  f_{\!\varLambda_p} &= f / \hat{f} = \left\{q^2 + M^2(p^2 - p\,p_\c)\right\} / (E\,p_{\c0}) \ .
  %f_{p_\c} &= \left\{ \varDelta p_\c + \varDelta\varepsilon_\p^\text{V} \vartheta(\phi)\ p_\c \right\} / E
\end{align}

Here $\hat{f} = E\,p_{\c0}$ was chosen with the elastic modulus and the
initial value of the pre-consolidation pressure. Of course, this has to
be considered in the corresponding partial derivatives
{(\ref{eqset:partialDerivatives}d--f)}.

Instead of applying the same procedure to $f_{p_\c}$ it is advantageous
to directly normalize the corresponding independent variable $p_\c$.
Then, the new reduced integration variable is

\[
  p_\c^r\coloneqq p_\c / \hat{p}_\c = p_\c / p_{\c0} \ .
\]

Thus, the partial derivatives with respect to $p_\c$ have to be replaced as

\[
  \frac{\partial (\ast)}{\partial p_\c} \rightarrow \frac{\partial (\ast)}{\partial p_\c^r} = \frac{1}{\hat{p}_\c} \frac{\partial (\ast)}{\partial p_\c} \ .
\]

Consequently, all integration variables $\tensor\varepsilon_\e,
\varLambda_p, p_\c^r, \phi $ are dimensionless, strain-like variables,
which improves the condition number of the set of equations.

In order to stabilize the numerical behaviour two more minor
modifications are beneficial. The first one regards some (initial) state
with zero stress. Then $f=0$ is indicating potential plastic loading,
but plastic flow \eqref{eq:flowRule} is undetermined. To prevent this
case, a small (ambient) pressure $p_\text{amb}$ can be added to the
hydrostatic pressure, i.\,e.

\[
  p \coloneqq \minus I_1(\tensor\sigma)/3 + p_\text{amb} \ .
\]

Hence, a small initial elastic range is provided.

Another problem occurs in case of strong softening and dilatancy:
$p_\c\rightarrow 0$ and the yield surface contracts until it degenerates
to a single point such that the direction of plastic flow is undefined.
In order to limit the decrease of $p_\c$ to some minimal
pre-consolidation pressure $p^\text{min}_\c$ the evolution equation
\eqref{eq:evolutionPc} is modified to

\[\label{eq:pcMin}
  \dot{p}_\c = \minus\dot{\varepsilon}_\p^\text{V} \vartheta(e)\ (p_\c - p^\text{min}_\c) \quad\with\quad p_\c\big{|}_{t=0} = p_{\c0} \ ,
\]

where the normalization from above can be applied again. A reasonably
small value for $p^\text{min}_\c$ can be, e.\,g., the ambient
atmospheric pressure. The modifications need to be considered in
Eq.~\eqref{eq:fpc} and its derivatives.

## Semi-explicit solution scheme {#sec:semi-explicit}

The number of equations in System \eqref{eq:incrementalSystem} can be
reduced exploiting the minor influence of the porosity in a given time
step. Since $\phi$ usually does not significantly change during the
strain increment, it can be updated explicitly at the end of the time
step [@Borja1990]. Exploiting formula \eqref{eq:evolutionPhi} yields

\begin{align}
  {}^{k+1}\!\phi &= 1 -\, (1-{}^{k}\!\phi) \exp(\minus\Delta\varepsilon^\text{V}) \quad\text{or}\\
  {}^{k+1}\!\phi &= {}^{k}\!\phi + \Delta\phi \quad\with\quad \Delta\phi = (1-{}^{k}\!\phi) \left[ 1- \exp(\minus\Delta\varepsilon^\text{V}) \right]\ .
\end{align}

Thus, the residual equation \eqref{eq:fphi} and the corresponding
derivatives can be omitted. The pore number follows directly from the
new porosity value using the relation

\[
  1 + \,{}^{k+1}\!e = \frac{1}{1-\, {}^{k+1}\!\phi} %\quad\with\quad 1-\phi = (1-{}^{0}\!\phi) \exp(\minus\varepsilon^\text{V})
   \ .
\]

# Implementation into `MFront`

For the `MFront` implementation the domain specific language (DSL)
`Implicit` was used, cf. [@Helfer2015;Marois2020]. The coupling to
`OpenGeoSys` [@Kolditz2012a;Bilke2019] is done using `MGIS`
[@Helfer2020]. The implementation is part of the `OpenGeoSys` source
code, cf. <https://gitlab.opengeosys.org>.

In the preamble of the `MFront` code the parameters are specified and
integration variables are declared. Note that a \emph{state variable} is
a persistent variable and an integration variable, whereas an
\emph{auxiliary state variable} is also persistent but no integration
variable.

~~~{.cxx}
// environmental parameters (default values)
@Parameter stress pamb = 1e+3; //Pa
@PhysicalBounds pamb in [0:*[;
pamb.setEntryName("AmbientPressure");

// material parameters
@MaterialProperty stress young;
@PhysicalBounds young in [0:*[;
young.setGlossaryName("YoungModulus");
...
@StateVariable real lp;
lp.setGlossaryName("EquivalentPlasticStrain");
@IntegrationVariable strain rpc;
@AuxiliaryStateVariable stress pc;
pc.setEntryName("PreConsolidationPressure");
@AuxiliaryStateVariable real phi;
phi.setGlossaryName("Porosity");
...
~~~~

The semi-explicit solution scheme is then implemented with three basic
steps:

~~~~{.cxx}
@InitLocalVariables{
  //elastic predictor step
}
@Integrator{
  //plastic corrector step
}
@UpdateAuxiliaryStateVariables{
  //explicit porosity update
}
~~~~

# Numerical studies

## Consolidated plane strain simple shear test using `MTest` {#sec:mtestResults}

`MFront` provides the tool `MTest` for testing the implemented
material behaviour at a single material point (integration point), see
[@Helfer2015]. For this, non-monotonic loading sequences can be
prescribed in terms of stress and strain trajectories.

In order to test the consolidation behaviour, plane strain simple shear
tests were conducted with the same initial state but three different
loading trajectories. To be precise, first the hydrostatic pressure $p$
was increased until $0.25\,p_{\c0}, 0.5\,p_{\c0}$ or $0.75\,p_{\c0}$.
This results in the so-called overconsolidation ratios (OCR) of $4, 2,
4/3$. From this hydrostatic stress state, shear is applied up to the
strain $\varepsilon_{xy}=0.01$.

+------------------+-------+-------+------------------------+------------------------+----------+-----------------+------------------------+
| $E\,(Pa)$        | $\nu$ | $M$   | $\lambda$              | $\kappa$               | $\phi_0$ | $p_\c0\,(Pa)$   | $p_{\text{amb}}\,(Pa)$ |
+:================:+:=====:+:=====:+:======================:+:======================:+:========:+:===============:+:======================:+
| $150\cdot10^{9}$ | $0.3$ | $1.5$ | $7.7\cdot10^{\minus3}$ | $6.6\cdot10^{\minus4}$ | $0.44$   | $30\cdot10^{6}$ | $0\cdot10^{3}$         |
+------------------+-------+-------+------------------------+------------------------+----------+-----------------+------------------------+

: Material parameters for the basic modified Cam clay model {#tbl:matParaCamClay}

The material parameters are given in Table @tbl:matParaCamClay. It
should be noted that only the difference $\lambda - \kappa$ plays a role
in the basic model with \emph{constant} elastic parameters. Considering
the OCR, there are three different cases (cf. Figure
@fig:mtestShear3cases):

![Consolidated shear test for three typical OCR values:
$\varepsilon_\p^\text{V}>0$ causes softening, whereas
$\varepsilon_\p^\text{V}<0$ (compaction) results in
hardening.](img/SemiImplicitModifiedCamClay_OpenGeoSys2020/ParamStudy_ConsolidatedShearTest.svg){#fig:mtestShear3cases
width=90%}

For $\text{OCR}>2$ the shearing is accompanied by a plastic expansion
(dilatancy) with $\varepsilon_\p^\text{V}>0$, which causes softening
until the critical state is reached.

For $\text{OCR}=2$ shearing until yield leads directly to the critical
state. Considering the state of the soil (porosity, stress, volume) this
is a natural asymptotic state. Further shearing does not alter that
state anymore. Hence, there is ideal plastic behaviour.

For $\text{OCR}<2$ the shearing is accompanied by a plastic compaction
(contractant flow, consolidation) with $\varepsilon_\p^\text{V}<0$,
which causes hardening until the critical state is reached.

%TODO: OCR=1 means normally consolidated, OCR>1 describes an over-consolidated state
%TODO: OCR=maximum pressure (=pre-consolidation pressure) / current pressure

![Consolidated shear test for 3 typical OCR values: depicted are the
different stress trajectories, the critical state line (CSL) and the
final yield
surfaces.](img/SemiImplicitModifiedCamClay_OpenGeoSys2020/ParamStudy_YieldSurface.svg){#fig:mtestShear3casesYield
width=90%}

The stress trajectories, and the final yield surfaces are illustrated in
the $p,q$-space together with the initial yield surface and the critical
state line (CSL).

Now, the same consolidated shear loading is applied, but there are two
different initial states: a high value of the initial pre-consolidation
pressure $p_{\c0}$ resembles a heavily pre-consolidated, compacted
(dense) soil material, whereas a low value of $p_{\c0}$ resembles a
loosened initial state.

![Consolidated shear test for two different initial pre-consolidation
pressures.](img/SemiImplicitModifiedCamClay_OpenGeoSys2020/ParamStudy_ConsolidatedShearTest-pc.svg){#fig:mtestShear2cases
width=90%}

![Consolidated shear test for two different initial pre-consolidation
pressures: the CSL and the final state including the final yield surface
are
equal.](img/SemiImplicitModifiedCamClay_OpenGeoSys2020/ParamStudy_YieldSurface-pc.svg){#fig:mtestShear2casesYield
width=90%}

As can be seen in Figures @fig:mtestShear2cases and
@fig:mtestShear2casesYield, the materials thrive to the same
(asymptotic) critical state, since the CSL is identical. However, this
is either accomplished by hardening (contraction) or softening
(dilatancy).

## Plane strain simple shear test with one FE using `OpenGeoSys`

As a next step the shear test from the previous section was repeated
using `OpenGeoSys`, but without consolidation phase. A unit
square domain was meshed with only one finite element. At the boundaries
(top, bottom, left, right) Dirichlet boundary conditions~(BCs) were
prescribed. The top boundary was loaded by a linear ramp from time $0$
to $1\,$s. The material parameters were taken from
Table @tbl:matParaCamClay with only one difference: As the test has
no pre-consolidation phase, it is starting from zero stress and due to
the reasons explained in Section @sec:stabilization some small initial
ambient pressure $p_\text{amb}=1\cdot10^{3}$\,Pa was added.

\footnote{If the test is stress-controlled and the material is initially
on the critical state with zero stress, this causes an infinite strain
increment and no convergence can be expected.}

+------------+-----------+---------------+----------------------+-------------+----------------+
| Test       | BC left   | BC right      | BC top               | BC bottom   | behaviour      |
+:==========:+:=========:+:=============:+:====================:+:===========:+:==============:+
| Shear $xy$ | free      | free          | $u_x=-0.05t$         | $u_x=u_y=0$ | no convergence |
+------------+-----------+---------------+----------------------+-------------+----------------+
| Shear $xy$ | free      | free          | $u_x=-0.05t, u_y=0$  | $u_x=u_y=0$ | convergence    |
+------------+-----------+---------------+----------------------+-------------+----------------+

: Convergence behaviour for different shear loadings and BCs. {#tbl:shear1FE}

![Test results for different BCs according to Table @tbl:shear1FE: the
top boundary is either confined (`left`) or free
(`right`).](img/SemiImplicitModifiedCamClay_OpenGeoSys2020/SimpleShearTest.svg){#fig:shear1FE
width=90%}

In order to have true simple shear the top BC $u_y=0$ has to be applied.
Else there is a tilting effect, and the deformation consists of shear
and bending. As this is related to some parts with dominant tension
stresses, convergence cannot be achieved with the Cam clay model (cf.
next section). Note also that for pure shear $\varepsilon^\text{V}=0$
and the volume and porosity thus remain constant. %(even for
$\varepsilon^\text{V}\neq 0$)


## Plane strain simple biaxial test with one FE using `OpenGeoSys`

It must be noted that the Cam clay model is primarily intended to
capture the shear behaviour of soil materials \emph{without} cohesion.
Hence, the uniaxial stress states with free boundaries cannot be
sustained just as these states cannot be reached in reality. As an
example, uniaxial tension causes pronounced lateral stretching due to
plastic volume increase (dilatancy). The application of some minimal
pre-consolidation pressure can help to stabilize the simulation, but
convergence cannot be expected in general.

Still, the biaxial tension/compression behaviour can be simulated to a
certain degree. The Table @tbl:biaxial1FE shows under which conditions
convergence can be expected. In the converged cases a homogeneous
solution was obtained as expected.

+-------------------------+-----------+---------------+----------------------+-------------+-------------+
| Test                    | BC left   | BC right      | BC top               | BC bottom   | convergence |
+=========================+===========+===============+======================+=============+=============+
| Uniax. compr. $y$       | $u_x=0$   | free          | $u_y=-0.05t$         | $u_y=0$     | no          |
+-------------------------+-----------+---------------+----------------------+-------------+-------------+
| Uniax. tension $y$      | $u_x=0$   | free          | $u_y=+0.05t$         | $u_y=0$     | no          |
+-------------------------+-----------+---------------+----------------------+-------------+-------------+
| Biaxial compr. $x,y$    | $u_x=0$   | $u_x=-0.05 t$ | $u_y=-0.05t$         | $u_y=0$     | yes         |
+-------------------------+-----------+---------------+----------------------+-------------+-------------+
| Biaxial tension $x,y$   | $u_x=0$   | $u_x=+0.05 t$ | $u_y=+0.05t$         | $u_y=0$     | (yes)       |
+-------------------------+-----------+---------------+----------------------+-------------+-------------+
| Biaxial mixed $x,y$     | $u_x=0$   | $u_x=+0.05 t$ | $u_y=-0.05t$         | $u_y=0$     | yes         |
+-------------------------+-----------+---------------+----------------------+-------------+-------------+
| Biaxial mixed $x,y$     | $u_x=0$   | $u_x=-0.05 t$ | $u_y=+0.05t$         | $u_y=0$     | yes         |
+-------------------------+-----------+---------------+----------------------+-------------+-------------+

: Convergence behaviour for different biaxial loadings and BCs {#tbl:biaxial1FE}

It is interesting to note that the biaxial tension test can be simulated
with the Cam clay model. In order to achieve convergence the drop of the
pre-consolidation pressure has to be limited. For this, either the value
of the parameter difference $\lambda - \kappa$ is increased or some
minimal value $p^\text{min}_\c$ has to be ensured according to
Eq.~\eqref{eq:pcMin}.

![Biaxial test results for different BCs: shown are the mixed cases from
Table
@tbl:biaxial1FE.](img/SemiImplicitModifiedCamClay_OpenGeoSys2020/BiaxialTest.svg){#fig:biaxial1FE
width=90%}

## Axially-symmetric triaxial compression test

As a benchmark to existing results an axially-symmetric triaxial
compression test was performed. For this, a cylindrical domain of height
$100$\,m and radius $25$\,m is meshed with $100\times 25$ finite
elements. At the left and bottom boundaries symmetry BCs of Dirichlet
type are prescribed. The top and right boundaries are loaded by
prescribing an axial and a confining pressure $p_{\text{con}}$,
respectively. The loading consists of two stages, similar to
\autoref{sec:mtestResults}: iI) a linear ramp until a hydrostatic stress
state with $p=p_{\text{con}}=200\,$kPa is reached (with an OCR=$1$) and
ii) a further increase of the axial pressure while the confining
pressure $p_{\text{con}}$ is held constant. As the simulation time is
irrelevant it is again set to $1\,$s. The material parameters are taken
from \autoref{tab:matParaCamClayTriax}.

+-----------------+-------+-------+------------------------+------------------------+----------+------------------+-------------------+
| $E (Pa)$        | $\nu$ | $M$   | $\lambda$              | $\kappa$               | $\phi_0$ | $p_\c0 (Pa)      | $p_\textamb (Pa)$ |
+:===============:+:=====:+:=====:+:======================:+:======================:+:========:+:================:+:=================:+
| $52\cdot10^{6}$ | $0.3$ | $1.2$ | $7.7\cdot10^{\minus2}$ | $6.6\cdot10^{\minus3}$ | $0.44$   | $200\cdot10^{3}$ | $1\cdot10^{3}$    |
+-----------------+-------+-------+------------------------+------------------------+----------+------------------+-------------------+

: Material parameters for the basic modified Cam clay model {#tbl:matParaCamClayTriax}

The material and loading parameters were chosen such that the stress
trajectory approaches the CSL from the right but does not meet it (cf.
Figure @fig:triaxStressTrajectory). When this happens there will be zero
resistance to plastic flow causing an infinite strain increment in the
stress-controlled test and no convergence can be expected. The tendency
can already be seen in Figure @fig:triaxStressStrain with the steep
increase of the equivalent plastic strain.

\begin{figure}[h!]\centering
  \includegraphics[width=0.4\textwidth]{pdf/TriaxCamClay_StressControl_ux.png}\vspace{10mm}
  \includegraphics[width=0.4\textwidth]{pdf/TriaxCamClay_StressControl_uy.png}
  \caption{Triaxial benchmark results: shown are the displacement coefficients in the radial (here $x$) and the vertical (here $y$) direction. }\label{fig:triaxDisplacement}
\end{figure}

The curve of the pre-consolidation pressure (cf. Figure
@fig:triaxStressStrain top) shows monotonic hardening related to the
plastic compaction (cf. Figure @fig:triaxStressStrain bottom).

\begin{figure}[h!]
  \includegraphics[width=0.52\textwidth]{pdf/TriaxCamClay_StressControl_StressCurves.png}
  \includegraphics[width=0.52\textwidth]{pdf/TriaxCamClay_StressControl_StrainCurves.png}
  \caption{Triaxial benchmark results: shown is the evolution of stress (`left`, unit Pa) and strain measures (`right`) at some arbitrary integration point.}\label{fig:triaxStressStrain}
\end{figure}

\begin{figure}[h!]\centering
  \includegraphics[width=1.0\textwidth]{pdf/TriaxCamClay_StressControl_Trajectory.png}
  \caption{Triaxial benchmark results: depicted is the stress trajectory and the evolving yield surface as well as the CSL.}\label{fig:triaxStressTrajectory}
\end{figure}

In order to check the accuracy of the numerical results, they were
compared to an analytical solution [@Peric2006] for proportional
loading. For this, the straight stress path from $(q=0,
p=p_{\text{con}})$ until the final state is considered (cf.
\autoref{fig:triaxStressTrajectory}). The plot of the von-Mises stress
over the corresponding equivalent strain defined by
$\varepsilon_{\text{q}}^2= {\tfrac{2}{3}\
\tensor\varepsilon^\D\ppkt\tensor\varepsilon^\D}$ shows accurate
agreement between numerical and analytical solution (cf. also the
appendix). Minor deviations might arise from the assumption
\eqref{eq:evolutionP} [@Peric2006], whereas a constant bulk modulus
according to Eq. \eqref{eq:constK} was applied here. Considering the
radial and circumferential strains another peculiarity is found (cf.
Figure @fig:triaxStressStrains): The initial plastic compaction causes
lateral (i.\,e. radial and circumferential) contraction. However, with
increasing axial compression this necessarily turns into expansion. Note
also that for this \emph{numerical} test the magnitude of the strains is
beyond the scope of the linear strain measure.

\begin{figure}[h!]
  \includegraphics[width=0.52\textwidth]{pdf/ModCamClay_TriaxStudy_Strains.pdf}
  \includegraphics[width=0.52\textwidth]{pdf/ModCamClay_TriaxStudy_NumVsAnal.pdf}
  \caption{Triaxial benchmark results: depicted are the strain trajectories (`left`) and a comparison between analytical and numerical solution (`right`).}\label{fig:triaxStressStrains}
\end{figure}

As an alternative the test can, of course, also be conducted
displacement-controlled. However, in doing so it was found that the
homogeneous solution becomes unstable and strain localization occurs at
the top of the domain. Apparently, at some integration points softening
sets in even though the homogeneous solution only shows monotonic
hardening. Varying the mesh size and topology, convergence could be
achieved in some cases, indicating a strong mesh dependency.

# Concluding remarks

The presented Cam clay material model has a simple structure, but can
capture several characteristic phenomena of soil materials very well.
However, it must be considered with caution when applied to realistic
finite element simulations. The major limitations have two origins:
first, the missing cohesion and second, the dilatant/softening part of
the captured material behaviour. The provided numerical refinements can
stabilize this only to a limited degree. It seems that the softening can
cause a pronounced strain localization, which requires special
strategies for regularization of the underlying ill-posed mathematical
problem [@Manica2018]. In order to include finite cohesion different
modifications of the Cam clay model have been proposed [@Gaume2018].
Finally, mechanical loading in the vicinity of the critical state can
easily cause large deformations, a finite strain formulation should be
considered in the future [@Borja1998;@Callari1998].

# Appendix

\subsection*{Numerical convergence behavior of the modified Cam clay implementation}

In order to check the convergence rate of the Cam clay implementation the consolidated shear test from Section~\ref{sec:mtestResults} was considered again. The parameters were taken from \autoref{tab:matParaCamClay}. The hydrostatic pressure $p$ was increased until $0.66\,p_{\c0}$ resulting in an OCR of $1.5$. From this hydrostatic stress state, shear is applied up to the strain $\varepsilon_{xy}=5\cdot10^{-4}$ within $20$ time steps.

\begin{figure}[h!]%\centering
  \includegraphics[width=1.04\textwidth]{pdf/convergence_plot.pdf}
  \caption{Convergence plot: depicted is the norm of the residuals from the global iteration (colored) and the local iteration (grey) using the modified Cam clay `MFront` implementation and `MTest`. Within the first $12$ steps the behavior is purely elastic (`top`), followed by contractant plastic flow (`bottom`).}\label{fig:convergencePlot}
\end{figure}

%with slight hardening (compaction)

As can be seen in \autoref{fig:convergencePlot}, convergence is achieved
in one step in the elastic stage (`top`). In the plastic stage
(`bottom`), the typical acceleration of convergence when approaching the
solution is observed (asymptotic quadratic convergence). However, the
convergence depends on the plastic flow behavior dictated by the
parameters $M$, $\lambda\minus\kappa$ and $p_{\c0}$ and can reduce to
super-linear (order $\in [1,2]$).

\subsection*{Orthotropic modified Cam clay model implementation}

The implementation of the modified Cam clay model can be extended to orthotropic elastic behavior using the so-called standard bricks within `MFront`. Thus just one line of code need to be added:

~~~~{.cxx}
@Brick StandardElasticity;
@OrthotropicBehaviour<Pipe>;
~~~~

As a consequence the nine independent constants of orthotropic elasticity are already declared.

~~~~{.cxx}
// material parameters
// Note: YoungModulus and PoissonRatio defined as parameters
// Note: Glossary names are already given; entry names are newly defined
@MaterialProperty real M;
@PhysicalBounds M in [0:*[;
M.setEntryName("CriticalStateLineSlope");
...
~~~~

However, from the physical point of view it might be more realistic to
consider the anisotropy both for the elastic and plastic behavior.

\subsection*{Analytical expressions for porosity and pre-consolidation pressure evolution}

Given is the evolution equation for the porosity:

\[
  \dot{\phi} - \phi\divergence(\dot{\vec{u}}) = \trace(\dot{\tensor\varepsilon}) \quad\with\quad \varepsilon^\text{V} = \trace({\tensor\varepsilon}) \ .
\]

Exploiting $\divergence(\dot{\vec{u}})\equiv \trace(\dot{\tensor\varepsilon})$ and separating the variables yields the form
\[
  \frac{\d\phi}{1-\phi} = \d\varepsilon^\text{V} \ .
\]
Integration over some time increment $\varDelta t$ with $\phi(t)={}^{k\!}\phi$ and $\phi(t+\varDelta t)={}^{k+1\!}\phi$ as well as $\Delta\varepsilon^\text{V}={}^{k+1\!}\varepsilon^\text{V}-{}^{k\!}\varepsilon^\text{V}$ as the volumetric strain increment, i.\,e.
\[
  \int\limits_{{}^{k\!}\phi}^{{}^{k+1\!}\phi} \frac{\d\phi}{1-\phi} = \int\limits_{{}^{k\!}\varepsilon^\text{V}}^{{}^{k+1\!}\varepsilon^\text{V}} \d\varepsilon^\text{V} \ .
\]
then results in the incremental solution
\[\label{eq:evolutionPhi}
  1 -\, {}^{k+1}\!\phi = (1-{}^{k}\!\phi) \exp(\minus\Delta\varepsilon^\text{V}) \ .
\]
Integration over the whole process time span with the initial values $\phi(t=0)={}^{0\!}\phi$ and $\varepsilon^\text{V}(t=0)=0$ results in
\[\label{eq:totalEvolutionPhi}
  1-\phi = (1-{}^{0}\!\phi) \exp(\minus\varepsilon^\text{V}) \ .
\]
Combining \eqref{eq:totalEvolutionPhi} with \eqref{eq:evolutionPc} finally yields the evolution of the pre-consolidation pressure:
\[
  \dot{p}_\c = -\frac{\dot{\varepsilon}_\p^\text{V} p_\c}{(\lambda - \kappa)(1-{}^{0}\!\phi) \exp(\minus\varepsilon^\text{V})}  \ .
\]

\subsection*{Analytical solution of the Cam clay model for proportional loading}

A straight stress path from $(p,q)=(0, p_{\c0})$ until the final state $(p,q)=(387387, 330129)\ $Pa is considered:
%(cf. \autoref{fig:triaxStressTrajectory}). the von-Mises stress $q$ over
\[
    q = k\,(p-p_{\c0}) \ .
\]

The analytical solution [@Peric2006] for the corresponding equivalent
strain $\varepsilon_{\text{q}}^2= {\tfrac{2}{3}\
\tensor\varepsilon^\D\ppkt\tensor\varepsilon^\D}$ reads

\[
    \varepsilon_{\text{q}} = \varepsilon^\e_{\text{q}} + \varepsilon^\p_{\text{q}}
\]

and to be precise, using the abbreviations $C = (\lambda\minus\kappa)$
and $\alpha = 3(1-2\nu) / (2(1+\nu))$ it is

\begin{align}
    (1+e_0)\,\varepsilon^\e_{\text{q}} &= \ln\left[\left(1-\frac{q}{kp}\right)^{\frac{2Ck}{k^2-M^2}-\frac{\kappa k}{3\alpha}}\right]\ ,\\
    (1+e_0)\,\varepsilon^\p_{\text{q}} &= \ln\left[\left(1-\frac{q}{Mp}\right)^{\frac{Ck}{M(M-k)}} 
                                          \cdot\left(1+\frac{q}{Mp}\right)^{\frac{Ck}{M(M+k)}}\right]
                                          - 2 \frac{C}{M}\arctan\left(\frac{q}{Mp}\right)\ .
\end{align}

-->

# References