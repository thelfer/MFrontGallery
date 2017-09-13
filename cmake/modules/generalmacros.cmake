############################################################################################################ 
# Append str to a string property of a target. 
# target:      string: target name. 
# property:            name of target’s property. e.g: COMPILE_FLAGS, or LINK_FLAGS 
# str:         string: string to be appended to the property 
macro(append_target_property target property str) 
  get_target_property(current_property ${target} ${property}) 
  if(NOT current_property) # property non-existent or empty 
      set_target_properties(${target} PROPERTIES ${property} ${str}) 
  else() 
      set_target_properties(${target} PROPERTIES ${property} "${current_property} ${str}") 
  endif() 
endmacro(append_target_property)

############################################################################################################ 
# Add/append compile flags to a target. 
# target: string: target name. 
# flags : string: compile flags to be appended 
macro(add_compile_flags target flags) 
  append_target_property(${target} COMPILE_FLAGS ${flags}) 
endmacro(add_compile_flags)

############################################################################################################ 
# Add/append link flags to a target. 
# target: string: target name. 
# flags : string: link flags to be appended 
macro(add_link_flags target flags) 
  append_target_property(${target} LINK_FLAGS ${flags}) 
endmacro(add_link_flags) 
