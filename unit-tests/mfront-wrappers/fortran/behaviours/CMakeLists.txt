add_library(MFrontGalleryFortranBehaviours SHARED
  elasticity.f95)
set_target_properties(MFrontGalleryFortranBehaviours
  PROPERTIES Fortran_MODULE_DIRECTORY
  "${CMAKE_BINARY_DIR}/mfront-wrappers/fortran/behaviours/modules")

mfront_behaviours_library(FortranBehavioursMFrontWrappers
  Elasticity
  ElasticityRK
  LINK_LIBRARIES MFrontGalleryFortranBehaviours)