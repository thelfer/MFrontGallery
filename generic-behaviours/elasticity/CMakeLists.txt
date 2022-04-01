mfront_behaviours_library(Elasticity
  WoodOrthotropicElasticity_2022
  SEARCH_PATH generic-behaviours/viscoelasticity)

foreach(tn test1)
  genericmtest(Elasticity
    WoodOrthotropicElasticity_2022_test1
    BEHAVIOUR WoodOrthotropicElasticity_2022)
  astermtest(Elasticity
    WoodOrthotropicElasticity_2022_test1
    BEHAVIOUR asterwoodorthotropicelasticity_2022)
  castemmtest(Elasticity
    WoodOrthotropicElasticity_2022_test1
    BEHAVIOUR umatwoodorthotropicelasticity_2022)
endforeach()