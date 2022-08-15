mfront_behaviours_library(ChemicalReaction
  ChemicalReaction5
  ChemicalReaction5b
  ChemicalReaction5c
  ChemicalReaction5d
  ChemicalReaction5e
  ChemicalReaction6
  ChemicalReaction7)

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
