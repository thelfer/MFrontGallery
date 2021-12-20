mfront_behaviours_library(Viscoelasticity
  GeneralizedMaxwell
  OrthotropicGeneralizedMaxwell
# This directory is not automatically added to the search path 
  SEARCH_PATH generic-behaviours/viscoelasticity)

astermtest(Viscoelasticity
  OrthotropicGeneralizedMaxwellRadialTest
  BEHAVIOUR asterorthotropicgeneralizedmaxwell
  REFERENCE_FILE ${CMAKE_CURRENT_SOURCE_DIR}/references/OrthotropicGeneralizedMaxwellRadialTest.ref)
astermtest(Viscoelasticity
  OrthotropicGeneralizedMaxwellHoopTest
  BEHAVIOUR asterorthotropicgeneralizedmaxwell
  REFERENCE_FILE ${CMAKE_CURRENT_SOURCE_DIR}/references/OrthotropicGeneralizedMaxwellHoopTest.ref)
astermtest(Viscoelasticity
  OrthotropicGeneralizedMaxwellAxialTest
  BEHAVIOUR asterorthotropicgeneralizedmaxwell
  REFERENCE_FILE ${CMAKE_CURRENT_SOURCE_DIR}/references/OrthotropicGeneralizedMaxwellAxialTest.ref)
