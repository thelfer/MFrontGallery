mfront_behaviours_library(UmatWrapperV2
  SmallStrainUmatWrapper_v2
  umat2.f90)

# Alternative implementation
#  
# add_library(UmatImplementations SHARED umat2.f90)
# mfm_install_library(UmatImplementations)
#
# mfront_behaviours_library(UmatWrapper_v2
#   SmallStrainUmatWrapper_v2
#   LINK_LIBRARIES UmatImplementations)


