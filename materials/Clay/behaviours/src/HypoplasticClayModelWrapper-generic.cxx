/*!
* \file   HypoplasticClayModelWrapper-generic.cxx
* \brief  This file implements the umat interface for the HypoplasticClayModelWrapper behaviour law
* \author Thomas Helfer
* \date   11 / 02 / 2021
*/

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

#include<iostream>
#include<cstdlib>
#include"TFEL/Material/OutOfBoundsPolicy.hxx"
#include"TFEL/Math/t2tot2.hxx"
#include"TFEL/Math/t2tost2.hxx"
#include"TFEL/Material/HypoplasticClayModelWrapper.hxx"
#include"MFront/GenericBehaviour/GenericBehaviourTraits.hxx"
#include"MFront/GenericBehaviour/Integrate.hxx"
#include"MFront/GenericBehaviour/HypoplasticClayModelWrapper-generic.hxx"

static tfel::material::OutOfBoundsPolicy&
HypoplasticClayModelWrapper_getOutOfBoundsPolicy(){
static auto policy = tfel::material::None;
return policy;
}

namespace mfront::gb{

template<>
struct GenericBehaviourTraits<tfel::material::HypoplasticClayModelWrapper<tfel::material::ModellingHypothesis::TRIDIMENSIONAL, real, false>>{
static constexpr auto hypothesis = tfel::material::ModellingHypothesis::TRIDIMENSIONAL;
static constexpr auto N = tfel::material::ModellingHypothesisToSpaceDimension<hypothesis>::value;
static constexpr auto StensorSize = tfel::material::ModellingHypothesisToStensorSize<hypothesis>::value;
static constexpr auto TensorSize = tfel::material::ModellingHypothesisToTensorSize<hypothesis>::value;
};

} // end of namespace mfront::gb

#ifdef __cplusplus
extern "C"{
#endif /* __cplusplus */

MFRONT_EXPORT_SYMBOL(const char*, HypoplasticClayModelWrapper_author, "Thomas Helfer");

MFRONT_EXPORT_SYMBOL(const char*, HypoplasticClayModelWrapper_date, "11 / 02 / 2021");

MFRONT_EXPORT_SYMBOL(const char*, HypoplasticClayModelWrapper_description, "");

MFRONT_EXPORT_SYMBOL(const char*, HypoplasticClayModelWrapper_build_id, "");

MFRONT_EXPORT_SYMBOL(const char*, HypoplasticClayModelWrapper_mfront_ept, "HypoplasticClayModelWrapper");

MFRONT_EXPORT_SYMBOL(const char*, HypoplasticClayModelWrapper_tfel_version, "4.1.0-dev");

MFRONT_EXPORT_SYMBOL(unsigned short, HypoplasticClayModelWrapper_mfront_mkt, 1u);

MFRONT_EXPORT_SYMBOL(const char*, HypoplasticClayModelWrapper_mfront_interface, "Generic");

MFRONT_EXPORT_SYMBOL(const char*, HypoplasticClayModelWrapper_src, "HypoplasticClayModelWrapper.mfront");

MFRONT_EXPORT_SYMBOL(unsigned short, HypoplasticClayModelWrapper_nModellingHypotheses, 1u);

MFRONT_EXPORT_ARRAY_OF_SYMBOLS(const char *, HypoplasticClayModelWrapper_ModellingHypotheses, 1, MFRONT_EXPORT_ARRAY_ARGUMENTS("Tridimensional"));

MFRONT_EXPORT_SYMBOL(unsigned short, HypoplasticClayModelWrapper_nMainVariables, 1u);

MFRONT_EXPORT_SYMBOL(unsigned short, HypoplasticClayModelWrapper_nGradients, 1u);

MFRONT_EXPORT_ARRAY_OF_SYMBOLS(int, HypoplasticClayModelWrapper_GradientsTypes, 1, MFRONT_EXPORT_ARRAY_ARGUMENTS(1));

MFRONT_EXPORT_ARRAY_OF_SYMBOLS(const char *, HypoplasticClayModelWrapper_Gradients, 1, MFRONT_EXPORT_ARRAY_ARGUMENTS("Strain"));

MFRONT_EXPORT_SYMBOL(unsigned short, HypoplasticClayModelWrapper_nThermodynamicForces, 1u);

MFRONT_EXPORT_ARRAY_OF_SYMBOLS(int, HypoplasticClayModelWrapper_ThermodynamicForcesTypes, 1, MFRONT_EXPORT_ARRAY_ARGUMENTS(1));

MFRONT_EXPORT_ARRAY_OF_SYMBOLS(const char *, HypoplasticClayModelWrapper_ThermodynamicForces, 1, MFRONT_EXPORT_ARRAY_ARGUMENTS("Stress"));

MFRONT_EXPORT_SYMBOL(unsigned short, HypoplasticClayModelWrapper_nTangentOperatorBlocks, 2u);

MFRONT_EXPORT_ARRAY_OF_SYMBOLS(const char *, HypoplasticClayModelWrapper_TangentOperatorBlocks, 2, MFRONT_EXPORT_ARRAY_ARGUMENTS("Stress",
"Strain"));

MFRONT_EXPORT_SYMBOL(unsigned short, HypoplasticClayModelWrapper_BehaviourType, 1u);

MFRONT_EXPORT_SYMBOL(unsigned short, HypoplasticClayModelWrapper_BehaviourKinematic, 1u);

MFRONT_EXPORT_SYMBOL(unsigned short, HypoplasticClayModelWrapper_SymmetryType, 0u);

MFRONT_EXPORT_SYMBOL(unsigned short, HypoplasticClayModelWrapper_ElasticSymmetryType, 0u);

MFRONT_EXPORT_SYMBOL(unsigned short, HypoplasticClayModelWrapper_api_version, 1u);

MFRONT_EXPORT_SYMBOL(unsigned short, HypoplasticClayModelWrapper_TemperatureRemovedFromExternalStateVariables, 1u);

MFRONT_EXPORT_SYMBOL(unsigned short, HypoplasticClayModelWrapper_Tridimensional_UsableInPurelyImplicitResolution, 0u);

MFRONT_EXPORT_SYMBOL(unsigned short, HypoplasticClayModelWrapper_Tridimensional_nMaterialProperties, 22u);

MFRONT_EXPORT_ARRAY_OF_SYMBOLS(const char *, HypoplasticClayModelWrapper_Tridimensional_MaterialProperties, 22, MFRONT_EXPORT_ARRAY_ARGUMENTS("mps[0]",
"mps[1]","mps[2]","mps[3]","mps[4]","mps[5]",
"mps[6]","mps[7]","mps[8]","mps[9]","mps[10]",
"mps[11]","mps[12]","mps[13]","mps[14]","mps[15]",
"mps[16]","mps[17]","mps[18]","mps[19]","mps[20]",
"mps[21]"));

MFRONT_EXPORT_SYMBOL(unsigned short, HypoplasticClayModelWrapper_Tridimensional_nInternalStateVariables, 16u);
MFRONT_EXPORT_ARRAY_OF_SYMBOLS(const char *, HypoplasticClayModelWrapper_Tridimensional_InternalStateVariables, 16, MFRONT_EXPORT_ARRAY_ARGUMENTS("isvs[0]",
"isvs[1]","isvs[2]","isvs[3]","isvs[4]","isvs[5]",
"isvs[6]","isvs[7]","isvs[8]","isvs[9]","isvs[10]",
"isvs[11]","isvs[12]","isvs[13]","isvs[14]","isvs[15]"));

MFRONT_EXPORT_ARRAY_OF_SYMBOLS(int, HypoplasticClayModelWrapper_Tridimensional_InternalStateVariablesTypes, 16, MFRONT_EXPORT_ARRAY_ARGUMENTS(0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0));

MFRONT_EXPORT_SYMBOL(unsigned short, HypoplasticClayModelWrapper_Tridimensional_nExternalStateVariables, 0u);
MFRONT_EXPORT_SYMBOL(const char * const *, HypoplasticClayModelWrapper_Tridimensional_ExternalStateVariables, nullptr);

MFRONT_EXPORT_SYMBOL(const int *, HypoplasticClayModelWrapper_Tridimensional_ExternalStateVariablesTypes, nullptr);

MFRONT_EXPORT_SYMBOL(unsigned short, HypoplasticClayModelWrapper_Tridimensional_nParameters, 2u);

MFRONT_EXPORT_ARRAY_OF_SYMBOLS(const char *, HypoplasticClayModelWrapper_Tridimensional_Parameters, 2, MFRONT_EXPORT_ARRAY_ARGUMENTS("minimal_time_step_scaling_factor",
"maximal_time_step_scaling_factor"));

MFRONT_EXPORT_ARRAY_OF_SYMBOLS(int, HypoplasticClayModelWrapper_Tridimensional_ParametersTypes, 2, MFRONT_EXPORT_ARRAY_ARGUMENTS(0,0));

MFRONT_EXPORT_SYMBOL(double, HypoplasticClayModelWrapper_Tridimensional_minimal_time_step_scaling_factor_ParameterDefaultValue, 0.1);

MFRONT_EXPORT_SYMBOL(double, HypoplasticClayModelWrapper_Tridimensional_maximal_time_step_scaling_factor_ParameterDefaultValue, 1.7976931348623e+308);

MFRONT_EXPORT_SYMBOL(unsigned short, HypoplasticClayModelWrapper_Tridimensional_requiresStiffnessTensor, 0u);

MFRONT_EXPORT_SYMBOL(unsigned short, HypoplasticClayModelWrapper_Tridimensional_requiresThermalExpansionCoefficientTensor, 0u);

MFRONT_EXPORT_SYMBOL(unsigned short, HypoplasticClayModelWrapper_Tridimensional_nInitializeFunctions, 0u);

MFRONT_EXPORT_SYMBOL(const char * const *, HypoplasticClayModelWrapper_Tridimensional_InitializeFunctions, nullptr);


MFRONT_EXPORT_SYMBOL(unsigned short, HypoplasticClayModelWrapper_Tridimensional_nPostProcessings, 0u);

MFRONT_EXPORT_SYMBOL(const char * const *, HypoplasticClayModelWrapper_Tridimensional_PostProcessings, nullptr);


MFRONT_EXPORT_SYMBOL(unsigned short, HypoplasticClayModelWrapper_Tridimensional_ComputesInternalEnergy, 0u);

MFRONT_EXPORT_SYMBOL(unsigned short, HypoplasticClayModelWrapper_Tridimensional_ComputesDissipatedEnergy, 0u);

MFRONT_SHAREDOBJ void
HypoplasticClayModelWrapper_setOutOfBoundsPolicy(const int p){
if(p==0){
HypoplasticClayModelWrapper_getOutOfBoundsPolicy() = tfel::material::None;
} else if(p==1){
HypoplasticClayModelWrapper_getOutOfBoundsPolicy() = tfel::material::Warning;
} else if(p==2){
HypoplasticClayModelWrapper_getOutOfBoundsPolicy() = tfel::material::Strict;
} else {
std::cerr << "HypoplasticClayModelWrapper_setOutOfBoundsPolicy: invalid argument\n";
}
}

MFRONT_SHAREDOBJ int
HypoplasticClayModelWrapper_Tridimensional_setParameter(const char *const key,const double value){
using tfel::material::HypoplasticClayModelWrapperTridimensionalParametersInitializer;
auto& i = HypoplasticClayModelWrapperTridimensionalParametersInitializer::get();
try{
i.set(key,value);
} catch(std::runtime_error& e){
std::cerr << e.what() << std::endl;
return 0;
}
return 1;
}

MFRONT_SHAREDOBJ int HypoplasticClayModelWrapper_Tridimensional(mfront_gb_BehaviourData* const d){
using namespace tfel::material;
using real = mfront::gb::real;
constexpr auto h = ModellingHypothesis::TRIDIMENSIONAL;
using Behaviour = HypoplasticClayModelWrapper<h,real,false>;
const auto r = mfront::gb::integrate<Behaviour>(*d, Behaviour::STANDARDTANGENTOPERATOR, HypoplasticClayModelWrapper_getOutOfBoundsPolicy());
return r;
} // end of HypoplasticClayModelWrapper_Tridimensional

#ifdef __cplusplus
}
#endif /* __cplusplus */

