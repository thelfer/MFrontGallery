set(MFRONT_BEHAVIOURS_VISCOPLASTICITY_SOURCES
  IsotropicViscoplasticityAmstrongFredericKinematicHardening
  ImplicitNorton
  ChabocheViscoplasticity
  Hayhurst)

if(NOT MSVC)
  list(APPEND MFRONT_BEHAVIOURS_VISCOPLASTICITY_SOURCES
    JohnsonCook_ssr
    JohnsonCook_ssrt
    RusinekKlepaczko_ssrt)
endif(NOT MSVC)

mfront_behaviours_library(Viscoplasticity
 ${MFRONT_BEHAVIOURS_VISCOPLASTICITY_SOURCES})
