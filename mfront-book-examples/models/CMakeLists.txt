mfront_models_library(ChemicalReaction
  ChemicalReaction1
  ChemicalReaction2
  ChemicalReaction3
  ChemicalReaction4)

mfront_behaviours_library(ChemicalReaction
  ChemicalReaction3b
  ChemicalReaction5
  ChemicalReaction5b
  ChemicalReaction5c
  ChemicalReaction5d
  ChemicalReaction5e
  ChemicalReaction6
  ChemicalReaction7)

# tests based on the generic interface
genericmtest(ChemicalReaction ChemicalReaction1
  LIBRARY $<TARGET_FILE:ChemicalReactionModels-generic>)
genericmtest(ChemicalReaction ChemicalReaction2
  LIBRARY $<TARGET_FILE:ChemicalReactionModels-generic>)
genericmtest(ChemicalReaction ChemicalReaction3
  LIBRARY $<TARGET_FILE:ChemicalReactionModels-generic>)
genericmtest(ChemicalReaction ChemicalReaction4
  LIBRARY $<TARGET_FILE:ChemicalReactionModels-generic>)

genericmtest(ChemicalReaction ChemicalReactionVaryingTemperature2
  LIBRARY $<TARGET_FILE:ChemicalReactionModels-generic>
  REFERENCE_FILE ${CMAKE_CURRENT_SOURCE_DIR}/ChemicalReactionVaryingTemperature.ref)
genericmtest(ChemicalReaction ChemicalReactionVaryingTemperature3
  LIBRARY $<TARGET_FILE:ChemicalReactionModels-generic>
  REFERENCE_FILE ${CMAKE_CURRENT_SOURCE_DIR}/ChemicalReactionVaryingTemperature.ref)
genericmtest(ChemicalReaction ChemicalReactionVaryingTemperature4
  LIBRARY $<TARGET_FILE:ChemicalReactionModels-generic>
  REFERENCE_FILE ${CMAKE_CURRENT_SOURCE_DIR}/ChemicalReactionVaryingTemperature.ref)

genericmtest(ChemicalReaction ChemicalReaction3b
  LIBRARY $<TARGET_FILE:ChemicalReactionBehaviours-generic>)
genericmtest(ChemicalReaction ChemicalReaction5
  MTEST_FILE ChemicalReaction5
  LIBRARY $<TARGET_FILE:ChemicalReactionBehaviours-generic>
  BEHAVIOUR ChemicalReaction5)
genericmtest(ChemicalReaction ChemicalReaction5b
  MTEST_FILE ChemicalReaction5
  LIBRARY $<TARGET_FILE:ChemicalReactionBehaviours-generic>
  BEHAVIOUR ChemicalReaction5b)
genericmtest(ChemicalReaction ChemicalReaction5c
  MTEST_FILE ChemicalReaction5
  LIBRARY $<TARGET_FILE:ChemicalReactionBehaviours-generic>
  BEHAVIOUR ChemicalReaction5c)
genericmtest(ChemicalReaction ChemicalReaction5d
  MTEST_FILE ChemicalReaction5
  LIBRARY $<TARGET_FILE:ChemicalReactionBehaviours-generic>
  BEHAVIOUR ChemicalReaction5d)
genericmtest(ChemicalReaction ChemicalReaction5e
  MTEST_FILE ChemicalReaction5
  LIBRARY $<TARGET_FILE:ChemicalReactionBehaviours-generic>
  BEHAVIOUR ChemicalReaction5e)
genericmtest(ChemicalReaction ChemicalReaction6
  MTEST_FILE ChemicalReaction6
  LIBRARY $<TARGET_FILE:ChemicalReactionBehaviours-generic>
  BEHAVIOUR ChemicalReaction6)
genericmtest(ChemicalReaction ChemicalReaction7
  MTEST_FILE ChemicalReaction7
  LIBRARY $<TARGET_FILE:ChemicalReactionBehaviours-generic>
  BEHAVIOUR ChemicalReaction7)
