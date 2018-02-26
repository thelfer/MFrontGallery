set(MFRONT_BEHAVIOURS_PLASTICITY_SOURCES
  IsotropicLinearHardeningPlasticity
  IsotropicLinearKinematicHardeningPlasticity
  Iwan
  GreenPerfectPlasticity
  Hosford1972PerfectPlasticity
  BarlatPerfectPlasticityYld200418p2090T3_Barlat2005
  DruckerPerfectPlasticity_Cazacu2001
  OrthotropicDruckerPerfectPlasticity2090T3_Cazacu2001
  OrthotropicDruckerPerfectPlasticityYdLin6016T4_Cazacu2001)

if(NOT MSVC)
  list(APPEND MFRONT_BEHAVIOURS_PLASTICITY_SOURCES JohnsonCook_s)
endif(NOT MSVC)

mfront_behaviours_library(Plasticity
  ${MFRONT_BEHAVIOURS_PLASTICITY_SOURCES})

astermtest(Plasticity asteriwan)
