set(ABAQUS_CPPFLAGS)

function(getAbaqusBehaviourName name)
  string(TOUPPER "${name}" uname)
  set(lib "${uname}ABAQUSBEHAVIOURS" PARENT_SCOPE)
endfunction(getAbaqusBehaviourName)

