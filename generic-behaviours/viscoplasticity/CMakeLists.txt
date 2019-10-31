set(MFRONT_BEHAVIOURS_VISCOPLASTICITY_SOURCES
  LoadInducedThermalStrain_Torelli2018
  IsotropicViscoplasticityAmstrongFredericKinematicHardening
  ImplicitNorton
  ChabocheViscoplasticity
  Hayhurst
  MericCailletaudSingleCrystalViscoPlasticity
  MericCailletaudSingleCrystalViscoPlasticityNumericalJacobian)

if(NOT MSVC)
  list(APPEND MFRONT_BEHAVIOURS_VISCOPLASTICITY_SOURCES
    JohnsonCook_ssr
    JohnsonCook_ssrt
    RusinekKlepaczko_ssrt)
endif(NOT MSVC)

mfront_behaviours_library(Viscoplasticity
 ${MFRONT_BEHAVIOURS_VISCOPLASTICITY_SOURCES})

astermtest(Viscoplasticity asterLoadInducedThermalStrain_Torelli2018-uniaxial)
astermtest(Viscoplasticity asterLoadInducedThermalStrain_Torelli2018-biaxial)
