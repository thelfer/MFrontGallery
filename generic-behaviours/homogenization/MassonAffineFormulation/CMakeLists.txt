mfront_behaviours_library(MassonAffineFormulation
  Affine_formulation
  Affine_tensors
  )

STRING(COMPARE EQUAL "${CMAKE_SOURCE_DIR}" "${CMAKE_BINARY_DIR}" _insource)
if(NOT _insource)
  configure_file(polycrystal.csv polycrystal.csv)
endif()
  
genericmtest(MassonAffineFormulation Affine_formulation
  BEHAVIOUR Affine_formulation
  REFERENCE_FILE ${CMAKE_CURRENT_SOURCE_DIR}/references/Affine_formulation.ref)
  
genericmtest(MassonAffineFormulation Affine_tensors
  BEHAVIOUR Affine_tensors
  REFERENCE_FILE ${CMAKE_CURRENT_SOURCE_DIR}/references/Affine_tensors.ref)
