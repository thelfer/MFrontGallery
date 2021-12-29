---
title: Implementation of the Korthaus' behaviour for crushed salt
author: Thomas Helfer, Éric Simo, Christian Lerch
date: 17/11/2021
lang: en-EN
link-citations: true
colorlinks: true
figPrefixTemplate: "$$i$$"
tblPrefixTemplate: "$$i$$"
secPrefixTemplate: "$$i$$"
eqnPrefixTemplate: "($$i$$)"
abstract: |
  This paper is dedicated to the implementation a porous visco-plastic
  behaviour for crushed salt proposed by Korthaus based on the work of
  Heim et al.
---

\newcommand{\dtot}{\mathrm{d}}
\newcommand{\absvalue}[1]{{\left|#1\right|}}
\newcommand{\paren}[1]{{\left(#1\right)}}
\newcommand{\tenseur}[1]{\underline{#1}}
\newcommand{\tenseurq}[1]{\underline{\underline{\mathbf{#1}}}}
\newcommand{\tepsilonto}{\tenseur{\varepsilon}^{\mathrm{to}}}
\newcommand{\tdepsilonto}{\tenseur{\dot{\varepsilon}}^{\mathrm{to}}}
\newcommand{\tepsilonel}{\tenseur{\varepsilon}^{\mathrm{el}}}
\newcommand{\tepsilonin}{\tenseur{\varepsilon}^{\mathrm{in}}}
\newcommand{\tepsilonvp}{\tenseur{\varepsilon}^{\mathrm{vp}}}
\newcommand{\tepsilong}{\tenseur{\varepsilon}^{\mathrm{g}}}
\newcommand{\tdepsilonin}{\tenseur{\dot{\varepsilon}}^{\mathrm{in}}}
\newcommand{\tdepsilonvp}{\tenseur{\dot{\varepsilon}}^{\mathrm{vp}}}
\newcommand{\tdepsilong}{\tenseur{\dot{\varepsilon}}^{\mathrm{g}}}
\newcommand{\tsigma}{\underline{\sigma}}
\newcommand{\trace}[1]{{\mathrm{tr}\paren{#1}}}
\newcommand{\Frac}[2]{{{\displaystyle \frac{\displaystyle #1}{\displaystyle #2}}}}
\newcommand{\deriv}[2]{{\displaystyle \frac{\displaystyle \partial #1}{\displaystyle \partial #2}}}
\newcommand{\derivtot}[2]{{\displaystyle \frac{\displaystyle \dtot #1}{\displaystyle \dtot #2}}}
\newcommand{\sigmaeq}{\sigma_{\mathrm{eq}}}
\newcommand{\s}{\tenseur{s}}
\newcommand{\sel}{\tenseur{s}^{\mathrm{el}}}
\newcommand{\n}{\tenseur{n}}
\newcommand{\bts}[1]{{\left.#1\right|_{t}}}
\newcommand{\mts}[1]{{\left.#1\right|_{t+\theta\,\Delta\,t}}}
\newcommand{\ets}[1]{{\left.#1\right|_{t+\Delta\,t}}}

# Description

## Elasticity

The elasticity is assumed linear and isotropic, i.e. given by the
Hooke law:

\[
\begin{aligned}
\tsigma&=\tenseurq{D}\,\colon\,\tepsilonel\\
       &=\lambda\,\trace{\tepsilonel}\,\tenseur{I}+2\,\mu\,\tepsilonel\\
       &= K^{\star}\,\trace{\tepsilonel}\,\tenseur{I}+2\,\mu\,\paren{\tepsilonel-\Frac{1}{3}\,\trace{\tepsilonel}\,\tenseur{I}} \\
       &= K^{\star}\,\trace{\tepsilonel}\,\tenseur{I}+2\,\mu\,\sel 
\end{aligned}
\]
where:

- \(\tenseur{D}\) is the elastic stiffness tensor.
- \(\sel\) is the deviatoric part of the elastic strain:
  \[
  \sel = \tepsilonel-\Frac{1}{3}\,\trace{\tepsilonel}\,\tenseur{I}
  \]
- \(\lambda^{\star}\), \(\mu^{\star}\) and \(K^{\star}\) are
  respectively the first and second Lamé parameters and the bulk
  modulus.

For crushed salt, the buldmodulus is a function of the porosity and can be defined by: 
\[
K^{\star} = K \cdot e^{-c_k \cdot \eta \cdot \left(\dfrac{1-\eta_0}{1-\eta}\right)} 
\]
where:

- $K^{\star}$: compression modulus of crushed salt  
- $K$: compression modulus of rock salt 
- $c_k$: material constant $c_k= 50.46$
- $\eta$: porosity 
- $\eta_0$: is a reference porosity

The Poisson's ratio \(\nu^{\star}\) of crushed salt and rock salt
\(\nu\) are assumed equal, thus:
\[
\nu^{\star} = \nu 
\]

The Young' modulus \(E^{\star}\) of crushed salt can thus be derived as: 
\[
\begin{aligned}
E^{\star} &= 3 (1-2 \cdot \nu^{\star}) \cdot K^{\star} \\
          &= 3 (1-2 \cdot \nu) \cdot K  \cdot e^{-c_k \cdot \eta \cdot \left(\dfrac{1-\eta_0}{1-\eta}\right)}
\end{aligned}
\]

## Viscoplastic part

### Expression of the viscoplastic strain rate

The inelastic strain \(\tepsilonin\) is split as the sum of two
contributions \(\tepsilonvp\) and \(\tepsilong\) which respectively
describe the viscoplastic deformation of single salt grains and the
relative displacement between grains, as follows:
\[
\tdepsilonin =  \tdepsilonvp + \tdepsilong
\]{#eq:viscoplastic_split}

In repository conditions, the grain displacement phenomenon can be
neglected, but it may a role in certain conditions.

## Grain deformation contribution

The grain deformation strain rate tensor \(\tdepsilonvp\) follows an
associated Norton-Hoff behaviour based on a Green stress criterion. This
criterion is expressed as:
\[
\sigmaeq = \sqrt{h_1\paren{\eta} \, p^{2}+h_2\paren{\eta} \, q^{2}}
\]
where:

- \(p\) is the hydrostatic stress:
  \[p=\Frac{1}{3}\,\trace{\sigma}\]
- \(q\) is the second invariant of the deviatoric stress \(\s\):
  \[q=\sqrt{\s\,\colon\,\s}\]

Various models can be derived from the choice of the functions
\(h_1\paren{\eta}\) and \(h_2\paren{\eta}\). In Korthaus's work, the
following expressions are used:
\[
\begin{aligned}
h_1\paren{\eta} &= \Frac{a}{\left( \eta^{-c}-\eta_0^{-c}\right)^m} \\
h_2\paren{\eta} &= b_1 + b_2 \, h_1
\end{aligned}
\]
with:

- $a, c, m$: material constant $[-]$
- $b_1, b_2$: material constant $[-]$, $b_2= 1$ in Korthaus approach

> **A potential numerical issue**
> 
> The expression of \(h_{1}\) diverges as the porosity \(\eta\) tends to
> the reference porosity \(\eta_{0}\). To avoid numerical issues, a
> numerical parameter $\Delta$ is introduced in the implementation.

<!--
\marginnote{\esnote{to prevent singularity $\eta= \min{(\eta, \eta_0-\Delta)}$ is to be implemented}\\ \thnote{I thought that \(\eta_{0}\) was an inaccessible reference porosity ? If so, what is the use of \(\Delta\) ?}}[-2cm]
-->

The normal \(\n\) to the Green criterion is given by:
\[
\begin{aligned}
\n&=\deriv{\sigmaeq}{\tsigma}=\Frac{1}{2\,\sigmaeq}\,\deriv{}{\tsigma}\paren{h_1\paren{\eta} \, p^{2}+h_2\paren{\eta} \, q^{2}}\\
  &=\Frac{1}{2\,\sigmaeq}\paren{2\,p\,\deriv{p}{\tsigma}+2\,q\,\deriv{q}{\tsigma}}\\
  &=\Frac{1}{\sigmaeq}\paren{\Frac{1}{3} \, h_1\paren{\eta} \, p \, \tenseur{I} + h_2\paren{\eta} \, \tenseur{s}}
\end{aligned}
\]

Finally, the viscoplastic strain rate can be expressed as follows:

\[
 \tdepsilonvp = A_{\mathrm{vp}} \, \exp\paren{-\Frac{Q_c}{R_m \, T}} \, \sigmaeq^{n_{\mathrm{vp}}}\,\n
\]{#eq:grain_def1}


with: 

- \(A_{\mathrm{vp}}\): Norton coefficient
- \(n_{\mathrm{vp}}\): Norton exponent
- \(Q_c\): activation energy in \([J \, mol^{-1}]\)
- \(R_m= 8.314~ J \, mol^{-1} \, K^{-1}\): gas constant  
- \(T\): temperature in [K] 

The expression may we rewritten as follows:

\[
 \tdepsilonvp = \dot{\varepsilon}_{0} \, \exp\paren{-\Frac{T_{a}}{T}} \, \paren{\Frac{\sigmaeq}{\sigma_{0}}}^{n_{\mathrm{vp}}}\,\n
\]

where:

- \(\sigma_{0}\) is a reference equivalent stress that may be chosen arbitrarly.
- \(\dot{\varepsilon}_{0}\) is a reference strain rate:
  \[
  \dot{\varepsilon}_{0}=A_{\mathrm{vp}}\,\sigma_{0}^{n_{\mathrm{vp}}}
  \]
- \(T_{a}\) is an activation temperature given by:
  \[
  T_{a}=\Frac{Q_c}{R_{m}}
  \]

## Porosity evolution

The porosity evolution is given by:
\[
\dot{\eta} = \left(1-\eta\right)\,\trace{\tdepsilonto}
\]

The porosity is however bounded between \(0\) and the reference porosity
\(\eta_{0}\).

This ordinary differential equation can be integrated exactly between
\(t\) and \(t+\theta\,\Delta\,t\) by separation of variables:
\[
\int_{t}^{t+\theta\,\Delta\,t}\Frac{\dot{\eta}}{1-\eta}\,\dtot t =
\int_{t}^{t+\theta\,\Delta\,t}\trace{\tdepsilonto}\,\dtot t
\Leftrightarrow
-\log\paren{\Frac{1-\mts{\eta}}{1-\bts{\eta}}} =
\theta\,\trace{\Delta\,\tepsilonto}
\]

Finally, the porosity at the middle of the time step and the porosity at the end of time step are given by:
\[
\mts{\eta} = 1 - \paren{1-\bts{\eta}}\,\exp\paren{-\theta\,\trace{\Delta\,\tepsilonto}}
\]{#eq:porosity:mts}
and
\[
\ets{\eta} = 1 - \paren{1-\bts{\eta}}\,\exp\paren{-\trace{\Delta\,\tepsilonto}}
\]{#eq:porosity:ets}

For the computation of the consistent tangent operator, the expression
of the derivatives of those quantities with respect to the total strain
increment \(\Delta\tepsilonto\) will be required:
\[
\left\{
\begin{aligned}
\deriv{\mts{\eta}}{\Delta\,\tepsilonto} &=
\paren{1-\bts{\eta}}\,\theta\,\exp\paren{-\theta\,\trace{\Delta\,\tepsilonto}}\,\tenseur{I} = \theta\,\paren{1-\mts{\eta}}\,\tenseur{I}\\
\deriv{\ets{\eta}}{\Delta\,\tepsilonto} &=
\paren{1-\bts{\eta}}\,\exp\paren{\trace{\Delta\,\tepsilonto}}\,\tenseur{I}
= \paren{1-\ets{\eta}}\,\tenseur{I} \\
\end{aligned}
\right.
\]{#eq:porosity:derivatives}

# Implementation

## Choice of the integration variable

The elastic strain is the only integration variable required.

## Residual

The residual associated with the elastic strain can be expressed as
follows:

\[
\begin{aligned}
f_{\tepsilonel}
&= \Delta\,\tepsilonel+\Delta\,\tepsilonvp-\Delta\,\tepsilonto\\
&= \Delta\,\tepsilonel+\Delta\,t\,\dot{\varepsilon}_{0} \, \exp\paren{-\Frac{T_{a}}{\mts{T}}} \, \paren{\Frac{\mts{\sigmaeq}}{\sigma_{0}}}^{n_{\mathrm{vp}}}\,\mts{\n}-\Delta\,\tepsilonto\\
&= \Delta\,\tepsilonel+\Delta\,t\,f_{\mathrm{vp}}\paren{\mts{\sigmaeq}}\,\mts{\n}-\Delta\,\tepsilonto
\end{aligned}
\]
where \(f_{\mathrm{vp}}\paren{\mts{\sigmaeq}}=\dot{\varepsilon}_{0} \, \exp\paren{-\Frac{T_{a}}{\mts{T}}} \, \paren{\Frac{\mts{\sigmaeq}}{\sigma_{0}}}^{n_{\mathrm{vp}}}\)

The jacobian of the implicit system is given by:
\[
\deriv{f_{\tepsilonel}}{\Delta\,\tepsilonel}
=\tenseurq{I}+
\Delta\,t\,\n\,\otimes\,\deriv{f_{\mathrm{vp}}}{\Delta\,\tepsilonel}+
\Delta\,t\,f_{\mathrm{vp}}\paren{\mts{\sigmaeq}}\,\deriv{\mts{\n}}{\Delta\,\tepsilonel}
\]

where:

\[
\begin{aligned}
\deriv{f_{\mathrm{vp}}}{\Delta\,\tepsilonel}
&=\deriv{f_{\mathrm{vp}}}{\mts{\sigmaeq}}\,\deriv{\mts{\sigmaeq}}{\mts{\tsigma}}\,\colon\,\deriv{\mts{\tsigma}}{\mts{\tepsilonel}}\,\colon\,\deriv{\mts{\tepsilonel}}{\Delta\,\tepsilonel}\\
&=\theta\,\deriv{f_{\mathrm{vp}}}{\mts{\sigmaeq}}\,\mts{\n}\,\colon\,\deriv{\mts{\tsigma}}{\mts{\tepsilonel}}\\
&=\theta\,\deriv{f_{\mathrm{vp}}}{\mts{\sigmaeq}}\,\mts{\n}\,\colon\,\mts{\tenseurq{D}}\\
\end{aligned}
\]

\[
\begin{aligned}
\deriv{\mts{\n}}{\Delta\,\tepsilonel}
&=\deriv{\mts{\n}}{\mts{\tsigma}}\,\colon\,\deriv{\mts{\tsigma}}{\mts{\tepsilonel}}\,\colon\,\deriv{\mts{\tepsilonel}}{\Delta\,\tepsilonel}\\
&=\theta\,\deriv{\mts{\n}}{\mts{\tsigma}}\,\colon\,\deriv{\mts{\tsigma}}{\mts{\tepsilonel}}\\
&=\theta\,\deriv{\mts{\n}}{\mts{\tsigma}}\,\colon\,\mts{\tenseurq{D}}\\
\end{aligned}
\]

<!--
//\Delta\,t\,\deriv{f_{\mathrm{vp}}}{\mts{\sigmaeq}}\,\deriv{\mts{\sigmaeq}}{\mts{\tsigma}}\,\colon\,\deriv{\mts{\tsigma}}{\mts{\tepsilonel}}\,\colon\,\deriv{\mts{\tepsilonel}}{\Delta\,\tepsilonel} \\
&=\tenseurq{I}+\theta\,\Delta\,t\,\deriv{f_{\mathrm{vp}}}{\mts{\sigmaeq}}\,\mts{\n}\,\colon\,\deriv{\mts{\tsigma}}{\mts{\tepsilonel}}\\
\end{aligned}
\]
-->

## Computation of the consistent tangent operator

While the implementation of the behaviour integration per se is trivial,
the computation of the consistent tangent operator is particularly
involved.

\[
\begin{aligned}
\deriv{\ets{\tsigma}}{\Delta\,\tepsilonto}
&= 
\deriv{}{\Delta\,\tepsilonto}\left[K^{\star}\paren{\ets{\eta}}\,\trace{\ets{\tepsilonel}}\,\tenseur{I}+2\,\mu\paren{\ets{\eta}}\,\ets{\sel}\,\tenseur{I}\right]\\
&= \trace{\ets{\tepsilonel}}\,\tenseur{I}\,\otimes\,\deriv{K^{\star}}{\Delta\,\tepsilonto}+
2\,\ets{\sel}\,\otimes\,\deriv{\mu^{\star}}{\Delta\,\tepsilonto}+
\ets{\tenseurq{D}}\,\colon\,\deriv{\ets{\tepsilonel}}{\Delta\,\tepsilonto}\\
&= \paren{\trace{\ets{\tepsilonel}}\,\deriv{K^{\star}}{\ets{f}}\,\tenseur{I}+
2\,\deriv{\mu^{\star}}{\ets{f}}\,\ets{\sel}}\,\otimes\,\deriv{\ets{\eta}}{\Delta\,\tepsilonto}+
\ets{\tenseurq{D}}\,\colon\,\deriv{\Delta\,\tepsilonel}{\Delta\,\tepsilonto}
\end{aligned}
\]

The derivative \(\deriv{\Delta\,\tepsilonel}{\Delta\,\tepsilonto}\) can
be obtained by the implicit function theorem as follows:

\[
\begin{aligned}
&&f_{\tepsilonel}\paren{\Delta\,\tepsilonel\paren{\Delta\,\tepsilonto},\Delta\,\tepsilonto} = 0\\
&\Rightarrow&\quad\derivtot{f_{\tepsilonel}}{\Delta\,\tepsilonto} = 0\\
&\Rightarrow&
\deriv{f_{\tepsilonel}}{\Delta\,\tepsilonel}\,\colon\,\deriv{\Delta\,\tepsilonel}{\Delta\,\tepsilonto}=-\deriv{f_{\tepsilonel}}{\Delta\,\tepsilonto}\\
&\Rightarrow&
\deriv{\Delta\,\tepsilonel}{\Delta\,\tepsilonto}=-\paren{\deriv{f_{\tepsilonel}}{\Delta\,\tepsilonel}}^{-1}\,\colon\,\deriv{f_{\tepsilonel}}{\Delta\,\tepsilonto}
\end{aligned}
\]

with:

\[
\begin{aligned}
\deriv{f_{\tepsilonel}}{\Delta\,\tepsilonto}
&=-\tenseurq{I}+\Delta\,t\,\deriv{}{\Delta\,\tepsilonto}\left[f_{\mathrm{vp}}\,\mts{\n}\right]\\
&=-\tenseurq{I}+\Delta\,t\,\left[\mts{\n}\,\otimes\,\deriv{f_{\mathrm{vp}}}{\Delta\,\tepsilonto}+f_{\mathrm{vp}}\,\deriv{\mts{\n}}{\Delta\,\tepsilonto}\right]\\
&=-\tenseurq{I}+\Delta\,t\,\left[
\deriv{f_{\mathrm{vp}}}{\mts{\eta}}\mts{\n}+f_{\mathrm{vp}}\,\deriv{\mts{\n}}{\mts{\eta}}\right]\,\otimes\,\deriv{\mts{\eta}}{\Delta\,\tepsilonto}\\
\end{aligned}
\]

The derivative of \(f_{\mathrm{vp}}\) with respect to the porosity \(\mts{\eta}\) is:
\[
\deriv{f_{\mathrm{vp}}}{\mts{\eta}}=\deriv{f_{\mathrm{vp}}}{\mts{\sigmaeq}}\,\deriv{\mts{\sigmaeq}}{\mts{\eta}}
\]

The partial derivative of the equivalent stress \(\mts{\sigmaeq}\) with
respect to the porosity \(\mts{\eta}\) step is given by:

\[
\deriv{\mts{\sigmaeq}}{\mts{\eta}} = \Frac{1}{2\,\sigmaeq}\left[p^{2}\,\deriv{h_{1}}{\mts{\eta}}+q^{2}\,\deriv{h_{2}}{\mts{\eta}}\right]
\]

The partial derivative of the normal \(\mts{\n}\) with respect to the
porosity \(\mts{\eta}\) is given by:
\[
\begin{aligned}
\deriv{\mts{\n}}{\mts{\eta}}
&=&\deriv{}{\mts{\eta}}\left[\Frac{1}{\mts{\sigmaeq}}\,\paren{\Frac{1}{3} \, h_1\paren{\mts{\eta}} \, p \, \tenseur{I} + h_2\paren{\mts{\eta}} \, \tenseur{s}}\right]\\
&=&\Frac{-1}{\mts{\sigmaeq^{2}}}\,\,\deriv{\sigmaeq}{\mts{\eta}}\,\paren{\Frac{1}{3} \, h_1\paren{\mts{\eta}} \, p \, \tenseur{I} + h_2\paren{\mts{\eta}} \, \tenseur{s}}\\
&&+\Frac{1}{\mts{\sigmaeq}}\,\paren{\Frac{1}{3} \, \deriv{h_1}{\mts{\eta}} \, p \, \tenseur{I} + \deriv{h_2}{\mts{\eta}} \, \tenseur{s}}\\
&=&\Frac{1}{\mts{\sigmaeq}}\,\left[\Frac{1}{3} \, \deriv{h_1}{\mts{\eta}} \, p \, \tenseur{I} + \deriv{h_2}{\mts{\eta}} \, \tenseur{s}-\deriv{\sigmaeq}{\mts{\eta}}\,\mts{n}\right]\\
\end{aligned}
\]

<!--
In equation #eq:grain_def1, one assumes an associated flowrule $F=Q$ following: 

\begin{align}
F(p,q)&=Q = h_1 \, p^2+h_2 \, q^2 \\
\Frac{\partial F}{\partial \sigma_{ij}}  &= 2 \, \left(\Frac{1}{3} \, h_1 \, p \, \delta_{ij} + h_2 \, S_{ij} \right)
\end{align}

The viscoplastic strain rate of intact rock salt can be expressed by 
\[\label{eq_grain_def2}
\dot{vp_{\varepsilon_{ij}}} = A \,   e^{-\Frac{Q_c}{R_m \, T}} \, \left( \sigma_{eff} \right)^5 \, \Frac{\partial \sigma_{eff}}{\partial \sigma_{ij}} = \dot{G_{\varepsilon_{ii}}} + \dot{A_{\varepsilon_{ii}}} \Bigr\rvert_{= 0}
\]

with:

$A$: flow factor, $ A= 2.083 \, 10^{-36} ~Pa^{-5} \, s^{-1}$

$Q_c$: activation energy, $Q_c = 54.21 \, 10^3~ J \, mol^{-1} $

$R_m$: gas constant

$T$: absolute temperature in  $[K]$

$\sigma_{eff}$: effective stress , $\sigma_{eff} = \sqrt{1.5 \, q}$

$\sigma_{ij}$: stress tensor 
\hfill \break
Equation \ref{eq_grain_def2} can be considered as the viscoplastic strain rate of crushed salt when the porosity tends to zero, thus this equation is similar to the expression of the grain deformation strain tensor given by 
\[\label{eq_grain_def3}
\dot{G_{\varepsilon_{ij}}} = g \, \left( \Frac{1}{3} \, h_1 \, p \, \delta_{ij} + h_2 \, S_{ij} \right)
\]

with:

$g$: dissipation factor in $[Pa \, s^{-1}]$
\hfill \break

when the grain displacement phenomenon is neglected:
\[\label{eq_grain_def4}
\dot{vp_{\varepsilon_{ij}}} = \dot{G_{\varepsilon_{ii}}} + \dot{A_{\varepsilon_{ii}}} \Bigr\rvert_{= 0}
\]

By equalizing equation \ref{eq_grain_def1} and \ref{eq_grain_def3}, one gets: 
\[\label{equality}
A \,   \dot e^{-\Frac{Q_c}{R_m \, T}} \, \left( \sigma_{eff} \right)^5 \, \Frac{\partial \sigma_{eff}}{\partial \sigma_{ij}} = g \, \left( \Frac{1}{3} \, h_1 \, p \, \delta_{ij} + h_2 \, S_{ij} \right)
\]
\marginnote{\esnote{I could not derive \ref{dissipation} from \ref{equality}}}

It follows by analogy the following expression of the dissipation factor: 

\[\label{dissipation}
g = \Frac{A_{\mathrm{vp}}}{2} \, e^{-\Frac{Q_c}{R_m \, T}} \, \left( h_1 \, p^2+h_2 \, q^2 \right)^2
\]

\hfill \break
The parameters $h_1$ and $h_2$ depend on the porosity and has been described by several authors. Here are some expressions:

\paragraph{Breiderich approach:}  This approach exhibit a discontinuity at $\eta_0=0$ which makes it unsuitable for numerical implementation \cite{Breiderich1994}. 

for $\eta > 0$,
\[
h_1 = \Frac{1-(\tan \Phi)^2 \, 0.03997 \, e^{(8.947 \, \eta)}}{(P_{max})^2}
\]

for $\eta=0$, 
\[
h_1 = 0
\]

$P_{max}$: the pressure needed to compact the crushed from the initial porosity of $\eta_0$ to $\eta$. 
\[
p_{max} = \Frac{c_{p0}}{c_{p1}} \, \left( \left(\Frac{1-\eta}{1-\eta_0}\right)^{c_{p1}} -1 \right)
\]

with:

$c_{p0}$: material constant $c_{p0}= 19.5 \, 10^6 Pa$

$c_{p1}$: material constant $c_{p1}= 9.4$

$\tan \Phi$: friction angle, $\tan \Phi = 0.59$ 

$\eta_0$: theoretical initial porosity, the highest possible porosity that the material can have, $\eta_0 = 0.38$ 


\hfill \break
$h_2$ is determined by: 
\[
h_2 = 1.737 \, 10^{-15} \left[Pa^{-2}\right] + 1.627 \, h_1
\]


\paragraph{Hein approach:} this is the original approach and is unfortunately over parametrized in the sense that $a_1$ and $\tan \Phi$ have the same meaning. 

\[
h_1 = \Frac{1-a_1 \, (\tan \Phi)^2 \, e^{(a_2 \, \eta)}}{(P_{max})^2}
\]
\[
h_2 = b_1 + b_2 \, h_1
\]
with:

$a_1, a_2$: material constant $[-]$

$b_1$: material constant $[1/Pa^2]$

$b_2$: material constant $[-]$

\paragraph{Korthaus approach:} this approach has been put forward in order to solve the overparametrization of the original Hein approach. This is the approach to be used in the Mfront implementation. 
\[
h_1 = \Frac{a}{\left( \eta^{-c}-\eta_0^{-c}\right)^m} 
\]
\[
h_2 = b_1 + b_2 \, h_1
\]
with:

$a, c, m$: material constant $[-]$

$b_1, b_2$: material constant $[-]$, $b_2= 1$ in Korthaus approach

$\Delta$: Numerical Parameter to be introduced in the implementation 
\marginnote{\esnote{to prevent singularity $\eta= \min{(\eta, \eta_0-\Delta)}$ is to be implemented}\\ \thnote{I thought that \(\eta_{0}\) was an inaccessible reference porosity ? If so, what is the use of \(\Delta\) ?}}[-2cm]

\marginnote{\thnote{Can you provide the reference for the work of Korthaus ?}}[0cm]

\subsubsection{Grain displacement strain rate tensor}
The grain displacement strain rate is given by: 

\[
\dot{A_{\varepsilon_{ii}}}= g \, h_3 \, ( q + n \, p) \, \left( \Frac{1}{3} \, n \, \delta_{ij} + \Frac{1}{q} \, S_{ij} \right)
\]

with: 

$h_3$: material constant depended on the porosity in  $\left[Pa^{-2}\right]$  

$n$: dilation factor (angle?)

$g$: dissipation factor and given by: 


With regard to the grain displacement phenomenon, Christian  proposes not to implement it yet. The formulation has to be enhanced with consideration of energy. This will happen in a R\&D-project that has just started. The equations should be implement although in Mfront. As soon as the new formulation will be developed, this equation can then be changed in Mfront.
Thus, one can assume for the moment: 
\[
h_3 = 0
\]
 


\section{Some peculiarities of the model}
In the FLAC3D implementation, it is assumed that volumetric compaction can only take place if the mean stress is compressive. Furthermore, a cap is assumed so that no further compaction arises once the intact salt density has been reached. 

We can use the same approach for our implementation. A cap can be assumed when the porosity is equal to 0. The model only works for compressive stress. In extension, the porosity should remain equal to initial porosity. A further increase of permeability due to extension cannot take place because the material does not exhibit a tensile strength. \marginnote{\thnote{This seem equivalent to impose that the porosity may only decrease. Are you ok with this statement}\\\esnote{yes, basically we are bounding the porosity to be equal to $\eta_0$ in extension, and $\eta_0$ cannot be smaller than zero in compression}}[-2cm]



\section{Model parameters}
The following parameters have been taken from the KOMPASS project. They are based on actual knowledge and data of the material and should be used as starting point in the implementation. 

\begin{align*}
    material~constant~~a &= 0.01648 & [-]  \\
    material~constant~~c &= 0.1 & [-] \\
    material~constant~~m &= 2.25 & [-] \\
    material~constant~~b_1 &= 0.9 & [-] \\
    material~constant~~b_2 &= 1 & [-] \\\marginnote{\esnote{@TN: which unit do you want to be used in OpenGeoSys ? in FLAC3D we are working  mostly in days. How long can the .vtu result file in OGS be. One million year in second leads to a very long file name}}
    flow~factor~~A_{\mathrm{vp}} &= 0.0942 \, 10^{-6} & [Pa^{-1} \, d^{-1}] \\
    flow~factor~~A_{\mathrm{vp}} &= 1.090278 \, 10^{-12} & [Pa^{-1} \, s^{-1}] \\
    E-modulus~of~intact~rock~salt~~E &= 25 & [GPa] \\
    Poisson~ratio~of~intact~rock~salt~~\nu &= 0.25 & [-] \\
    initial~porosity~for~simulation~~\eta_{ini} &= 0.167  & [-]\\
    theoretical~initial~porosity~~ \eta_0 &= 0.35  & [-] \\
    activation~energy~~Q_c &= 54 \, 10^3 & [J \, mol^{-1} ] \\
    gas~constant~~R_m &= 8.314 & [J \, mol^{-1} \, K^{-1}] \\
    temperature~~T &= 323 & [K] \\
    material~constant~~c_k &= 9 & [-]
\end{align*}

\section{About the units of $A^{*}$}

Equation \eqref{eq_grain_def1} can be rewritten as follows:

\[
 \underline{\dot{G}} = A^{*} \, \exp\left(-\Frac{Q_c}{R_m \, T}\right)\,\,\,\sigmaeq^{n_{\mathrm{vp}}}\,\,\,\underline{n} = A^{**}\,\,\,\sigmaeq^{n_{\mathrm{vp}}}\,\,\,\underline{n} 
\]

For numerical stability, it is worth introducing a reference stress \(\sigma_{0}\) as follows:

\[
\underline{\dot{G}} = A^{*}\,\exp\left(-\Frac{Q_c}{R_m \, T}\right)\,\,\,\sigma_{0}^{n_{\mathrm{vp}}}\,\,\,\left(\Frac{\sigmaeq}{\sigma_{0}}\right)^{n_{\mathrm{vp}}}\,\,\,\underline{n} = \dot{\varepsilon}_{0}\,\,\,\exp\left(-\Frac{Q_c}{R_m \, T}\right)\,\,\,\left(\Frac{\sigmaeq}{\sigma_{0}}\right)^{n_{\mathrm{vp}}}\,\,\,\underline{n}
\]

\marginnote{\esnote{we are discussing with Christian about your proposition and we think it is a good idea. A suitable value for $\sigma_0$ is $1 MPa$}}[-4cm]

\marginnote{\esnote{But why do we force the parameter $A_{\mathrm{vp}}$ to be in $MPa$ when we can work is SI units or let the freedom to the user to choose which units he wants.} \thnote{My bad, \(\sigmaeq\) shall be in \(Pa\) so \(A^{*}\) has the unit \(Pa^{-n}\,\,\,s^{-1}\). In pratice the unit of the stress shall be derived from the one of the Young modulus.}}



where \(\dot{\varepsilon}_{0}=A^{*}\,\,\,\sigma_{0}^{n_{\mathrm{vp}}}\) is a reference strain rate.


This expression shows that \(A^{*}\) has the unit \(PA^{-n}\,\,\,s^{-1}\) (or \(PA^{-n}\,\,\,d^{-1}\)).

It would be nice to choose a reference stress suitable for the application (for example \(\sigma_{0}=10^{6}\,\,\,Pa\)) and derive the value  \(\dot{\varepsilon}_{0}\)

-->