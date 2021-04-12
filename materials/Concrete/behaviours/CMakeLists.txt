mfront_behaviours_library(Concrete
  ConcreteBurger_EDF_CIWAP_2021
  ConcreteBurger_EDF_CIWAP_2021_v2)

astermtest(Concrete ConcreteBurger_EDF_CIWAP_2021-test1
  MTEST_FILE ConcreteBurger_EDF_CIWAP_2021-test1
  LIBRARY $<TARGET_FILE:ConcreteBehaviours-aster>
  BEHAVIOUR asterconcreteburger_edf_ciwap_2021
  REFERENCE_FILE ${CMAKE_CURRENT_SOURCE_DIR}/ConcreteBurger_EDF_CIWAP_2021-test1.ref)
astermtest(Concrete ConcreteBurger_EDF_CIWAP_2021-test2
  MTEST_FILE ConcreteBurger_EDF_CIWAP_2021-test2
  LIBRARY $<TARGET_FILE:ConcreteBehaviours-aster>
  BEHAVIOUR asterconcreteburger_edf_ciwap_2021
  REFERENCE_FILE ${CMAKE_CURRENT_SOURCE_DIR}/ConcreteBurger_EDF_CIWAP_2021-test2.ref)
astermtest(Concrete ConcreteBurger_EDF_CIWAP_2021-test3
  MTEST_FILE ConcreteBurger_EDF_CIWAP_2021-test3
  LIBRARY $<TARGET_FILE:ConcreteBehaviours-aster>
  BEHAVIOUR asterconcreteburger_edf_ciwap_2021
  REFERENCE_FILE ${CMAKE_CURRENT_SOURCE_DIR}/ConcreteBurger_EDF_CIWAP_2021-test3.ref)
astermtest(Concrete ConcreteBurger_EDF_CIWAP_2021-test4
  MTEST_FILE ConcreteBurger_EDF_CIWAP_2021-test4
  LIBRARY $<TARGET_FILE:ConcreteBehaviours-aster>
  BEHAVIOUR asterconcreteburger_edf_ciwap_2021
  REFERENCE_FILE ${CMAKE_CURRENT_SOURCE_DIR}/ConcreteBurger_EDF_CIWAP_2021-test4.ref)
astermtest(Concrete ConcreteBurger_EDF_CIWAP_2021-test5
  MTEST_FILE ConcreteBurger_EDF_CIWAP_2021-test5
  LIBRARY $<TARGET_FILE:ConcreteBehaviours-aster>
  BEHAVIOUR asterconcreteburger_edf_ciwap_2021
  REFERENCE_FILE ${CMAKE_CURRENT_SOURCE_DIR}/ConcreteBurger_EDF_CIWAP_2021-test5.ref)

astermtest(Concrete ConcreteBurger_EDF_CIWAP_2021_v2-test1
  MTEST_FILE ConcreteBurger_EDF_CIWAP_2021-test1
  LIBRARY $<TARGET_FILE:ConcreteBehaviours-aster>
  BEHAVIOUR asterconcreteburger_edf_ciwap_2021_v2
  REFERENCE_FILE ${CMAKE_CURRENT_SOURCE_DIR}/ConcreteBurger_EDF_CIWAP_2021-test1.ref)
astermtest(Concrete ConcreteBurger_EDF_CIWAP_2021_v2-test2
  MTEST_FILE ConcreteBurger_EDF_CIWAP_2021-test2
  LIBRARY $<TARGET_FILE:ConcreteBehaviours-aster>
  BEHAVIOUR asterconcreteburger_edf_ciwap_2021_v2
  REFERENCE_FILE ${CMAKE_CURRENT_SOURCE_DIR}/ConcreteBurger_EDF_CIWAP_2021-test2.ref)
astermtest(Concrete ConcreteBurger_EDF_CIWAP_2021_v2-test3
  MTEST_FILE ConcreteBurger_EDF_CIWAP_2021-test3
  LIBRARY $<TARGET_FILE:ConcreteBehaviours-aster>
  BEHAVIOUR asterconcreteburger_edf_ciwap_2021_v2
  REFERENCE_FILE ${CMAKE_CURRENT_SOURCE_DIR}/ConcreteBurger_EDF_CIWAP_2021-test3.ref)
astermtest(Concrete ConcreteBurger_EDF_CIWAP_2021_v2-test4
  MTEST_FILE ConcreteBurger_EDF_CIWAP_2021-test4
  LIBRARY $<TARGET_FILE:ConcreteBehaviours-aster>
  BEHAVIOUR asterconcreteburger_edf_ciwap_2021_v2
  REFERENCE_FILE ${CMAKE_CURRENT_SOURCE_DIR}/ConcreteBurger_EDF_CIWAP_2021-test4.ref)
astermtest(Concrete ConcreteBurger_EDF_CIWAP_2021_v2-test5
  MTEST_FILE ConcreteBurger_EDF_CIWAP_2021-test5
  LIBRARY $<TARGET_FILE:ConcreteBehaviours-aster>
  BEHAVIOUR asterconcreteburger_edf_ciwap_2021_v2
  REFERENCE_FILE ${CMAKE_CURRENT_SOURCE_DIR}/ConcreteBurger_EDF_CIWAP_2021-test5.ref)
