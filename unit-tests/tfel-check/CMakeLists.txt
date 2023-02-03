tfel_check(python)

if(enable-castem-behaviours)
  getCastem21BehaviourName(Viscoplasticity)
  tfel_check(castem
    SUBSTITUTION library "$<TARGET_FILE:${lib}>")
endif(enable-castem-behaviours)