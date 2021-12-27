/*!
 * \file   MFrontUmatWrapper.hxx
 * \brief
 * \author Thomas Helfer
 * \date   11/02/2021
 */

#ifndef LIB_MFRONT_UMAT_WRAPPER_HXX
#define LIB_MFRONT_UMAT_WRAPPER_HXX

#include "TFEL/Material/ModellingHypothesis.hxx"
#include "TFEL/Math/ST2toST2/UmatNormaliseTangentOperator.hxx"

extern "C" {

//! \brief a simple alias
typedef double AbaqusRealType;
//! \brief a simple alias
typedef int AbaqusIntegerType;

void umat_hcea_(
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
    const AbaqusRealType
        *const /* DPRED */, /* external state variables increments   */
    const char *const /* CMNAME */,
    const AbaqusIntegerType *const /* NDI */,
    const AbaqusIntegerType *const /* NSHR */,
    const AbaqusIntegerType
        *const /* NTENS */, /* number of components of tensors */
    const AbaqusIntegerType
        *const /* NSTATV */, /* number of internal state variables */
    const AbaqusRealType *const /* PROPS */, /* material properties */
    const AbaqusIntegerType
        *const /* NPROPS */, /* number of material properties */
    const AbaqusRealType *const /* COORDS */,
    const AbaqusRealType  *const /* DROT, incremental rotation matrix */, 
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
}

namespace mfront_umat_wrapper {

  //! a simple alias
  using Hypothesis = tfel::material::ModellingHypothesis::Hypothesis;

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

  template <Hypothesis H, typename NumType>
  void convertStressToAbaqus(AbaqusRealType *const s, const NumType *const sig) {
    if constexpr (H == Hypothesis::TRIDIMENSIONAL) {
      constexpr auto icste = tfel::math::Cste<NumType>::isqrt2;
      s[0] = sig[0];
      s[1] = sig[1];
      s[2] = sig[2];
      s[3] = sig[3] * icste;
      s[4] = sig[4] * icste;
      s[5] = sig[5] * icste;
    } else {
      tfel::raise("Unsupported hypothesis");
    }
  }  // end of convertStressToAbaqus

  template <Hypothesis H, typename NumType>
  void convertStressFromAbaqus(NumType *const sig, const AbaqusRealType *const s) {
    if constexpr (H == Hypothesis::TRIDIMENSIONAL) {
      constexpr auto cste = tfel::math::Cste<NumType>::sqrt2;
      sig[0] = s[0];
      sig[1] = s[1];
      sig[2] = s[2];
      sig[3] = s[3] * cste;
      sig[4] = s[4] * cste;
      sig[5] = s[5] * cste;
    } else {
      tfel::raise("Unsupported hypothesis");
    }
  }  // end of convertStressFromAbaqus

  template <Hypothesis H, typename NumType>
  void convertStiffnessMatrixFromAbaqus(NumType *const D,
                                        const AbaqusRealType *const K) {
    if constexpr (H == Hypothesis::TRIDIMENSIONAL) {
      tfel::math::UmatNormaliseTangentOperatorBase<3u, NumType>::exe(D, K);
    } else {
      tfel::raise("Unsupported hypothesis");
    }
  }  // end of convertStiffnessMatrixFromAbaqus

}  // end of namespace mfront_umat_wrapper

#endif /* LIB_MFRONT_UMAT_WRAPPER_HXX */
