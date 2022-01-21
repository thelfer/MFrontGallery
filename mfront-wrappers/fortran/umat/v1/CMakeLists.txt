if(GNU_FORTRAN_COMPILER AND (${CMAKE_SYSTEM_NAME} STREQUAL "Linux"))
  mfront_behaviours_library(UmatWrapperV1
    SmallStrainUmatWrapper_v1
    umat.f)
endif()
