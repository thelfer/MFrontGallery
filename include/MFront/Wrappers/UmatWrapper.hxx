/*!
 * \file   UmatWrapper.hxx
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
