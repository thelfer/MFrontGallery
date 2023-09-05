/*!
* \file   HypoplasticClayModelWrapper-generic.hxx
* \brief  This file declares the umat interface for the HypoplasticClayModelWrapper behaviour law
* \author Thomas Helfer
* \date   11 / 02 / 2021
*/

#ifndef LIB_GENERIC_HYPOPLASTICCLAYMODELWRAPPER_HXX
#define LIB_GENERIC_HYPOPLASTICCLAYMODELWRAPPER_HXX

#include"TFEL/Config/TFELConfig.hxx"
#include"MFront/GenericBehaviour/BehaviourData.h"

#ifdef _WIN32
#ifndef NOMINMAX
#define NOMINMAX
#endif /* NOMINMAX */
#include <windows.h>
#ifdef small
#undef small
#endif /* small */
#endif /* _WIN32 */

#ifndef MFRONT_SHAREDOBJ
#define MFRONT_SHAREDOBJ TFEL_VISIBILITY_EXPORT
#endif /* MFRONT_SHAREDOBJ */

#ifndef MFRONT_EXPORT_SYMBOL
#define MFRONT_EXPORT_SYMBOL(TYPE, NAME, VALUE) \
  MFRONT_SHAREDOBJ extern TYPE NAME;            \
  MFRONT_SHAREDOBJ TYPE NAME = VALUE
#endif /* MFRONT_EXPORT_SYMBOL*/

#ifndef MFRONT_EXPORT_ARRAY_ARGUMENTS
#define MFRONT_EXPORT_ARRAY_ARGUMENTS(...) __VA_ARGS__
#endif /* MFRONT_EXPORT_ARRAY_ARGUMENTS */

#ifndef MFRONT_EXPORT_ARRAY_OF_SYMBOLS
#define MFRONT_EXPORT_ARRAY_OF_SYMBOLS(TYPE, NAME, SIZE, VALUE) \
  MFRONT_SHAREDOBJ extern TYPE NAME[SIZE];                      \
  MFRONT_SHAREDOBJ TYPE NAME[SIZE] = {VALUE}
#endif /* MFRONT_EXPORT_ARRAY_OF_SYMBOLS*/

#ifdef __cplusplus
extern "C"{
#endif /* __cplusplus */

MFRONT_SHAREDOBJ void
HypoplasticClayModelWrapper_setOutOfBoundsPolicy(const int);

MFRONT_SHAREDOBJ int
HypoplasticClayModelWrapper_Tridimensional_setParameter(const char *const,const double);

/*!
 * \param[in,out] d: material data
 */
MFRONT_SHAREDOBJ int HypoplasticClayModelWrapper_Tridimensional(mfront_gb_BehaviourData* const);

#ifdef __cplusplus
}
#endif /* __cplusplus */

#endif /* LIB_GENERIC_HYPOPLASTICCLAYMODELWRAPPER_HXX */
