mfront_behaviours_library(Homogenization
  PonteCastaneda1992
  Taylor
  Sachs
  MericCailletaudSingleCrystalViscoPlasticity
  BetaRule
  Idiart_viscoelastic
  )
  
genericmtest(Homogenization PonteCastaneda1992
  BEHAVIOUR PonteCastaneda1992
  REFERENCE_FILE ${CMAKE_CURRENT_SOURCE_DIR}/references/PonteCastaneda1992.ref)
  
genericmtest(Homogenization Taylor
  BEHAVIOUR Taylor
  REFERENCE_FILE ${CMAKE_CURRENT_SOURCE_DIR}/references/Taylor.ref)

genericmtest(Homogenization Sachs
  BEHAVIOUR Sachs
  REFERENCE_FILE ${CMAKE_CURRENT_SOURCE_DIR}/references/Sachs.ref)
  
genericmtest(Homogenization BetaRule
  BEHAVIOUR BetaRule
  REFERENCE_FILE ${CMAKE_CURRENT_SOURCE_DIR}/references/BetaRule.ref)
  
genericmtest(Homogenization Idiart_viscoelastic
  BEHAVIOUR Idiart_viscoelastic
  REFERENCE_FILE ${CMAKE_CURRENT_SOURCE_DIR}/references/Idiart_viscoelastic.ref)
