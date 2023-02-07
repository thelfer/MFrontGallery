function(mfront_properties_java_library mat)
  set(lib "${mat}-java")
  if(MFM_PACKAGE)
    set(java_file       "${MFM_PACKAGE}/${mat}.java")
    set(java_class_file "${MFM_PACKAGE}/${mat}.class")
   else(MFM_PACKAGE)
     set(java_file       "${mat}.java")
     set(java_class_file "${mat}.class")
  endif(MFM_PACKAGE)
  set(mfront_files)
  parse_mfront_library_sources(${ARGN})
  if(EXISTS ${CMAKE_SOURCE_DIR}/materials/${mat})
    list(APPEND mfront_search_paths 
      "--search-path=${CMAKE_SOURCE_DIR}/materials/${mat}/properties")
  endif(EXISTS ${CMAKE_SOURCE_DIR}/materials/${mat})
  list(APPEND mfront_search_paths 
      "--search-path=${CMAKE_CURRENT_SOURCE_DIR}")
  get_material_property_dsl_options("java")
  foreach(source ${mfront_sources})
    add_mfront_property_sources(${lib} ${mat} "java" "${mfront_search_paths}" ${source})
  endforeach(source)
  # list of generated class files
  if(${lib}_SOURCES)
    list(REMOVE_DUPLICATES ${lib}_SOURCES)
  endif(${lib}_SOURCES)
  set(all_generated_files ${${lib}_SOURCES})
  list(APPEND all_generated_files
       ${CMAKE_CURRENT_BINARY_DIR}/java/java/${java_file}
       ${CMAKE_CURRENT_BINARY_DIR}/java/java/${java_class_file})    
  list(REMOVE_DUPLICATES all_generated_files)
  _get_mfront_command_line_arguments()
  set(mfront_args )
  list(APPEND mfront_args ${mfront_command_line_arguments})
  list(APPEND mfront_args ${mfront_search_paths})
  if(mfront_dsl_options)
    list(APPEND mfront_args ${mfront_dsl_options})
  endif(mfront_dsl_options)
  list(APPEND mfront_args "--interface=java")
  list(APPEND mfront_args ${${lib}_MFRONT_IMPLEMENTATION_PATHS})
  message(STATUS "mfront_args: ${${lib}_MFRONT_IMPLEMENTATION_PATHS}")
  if(MFM_PACKAGE)
    add_custom_command(
      OUTPUT  ${all_generated_files}
      COMMAND "${MFRONT}"
      ARGS "--@Package=${MFM_PACKAGE}"
      ARGS    ${mfront_args}
      DEPENDS ${${lib}_MFRONT_SOURCES}
      WORKING_DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}/java"
      COMMENT "mfront source ${mfront_files}")
  else(MFM_PACKAGE)
    add_custom_command(
      OUTPUT  ${all_generated_files}
      COMMAND "${MFRONT}"
      ARGS    ${mfront_args}
      DEPENDS ${${lib}_MFRONT_SOURCES}
      WORKING_DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}/java"
      COMMENT "mfront source ${mfront_files}")
  endif(MFM_PACKAGE)
  message(STATUS "Adding library : ${lib} (${${lib}_SOURCES})")
  add_library(${lib} SHARED ${${lib}_SOURCES})
  add_custom_command(
    OUTPUT  "${CMAKE_CURRENT_BINARY_DIR}/java/java/${java_class_file}"
    COMMAND "${Java_JAVAC_EXECUTABLE}"
    ARGS    "${CMAKE_CURRENT_BINARY_DIR}/java/java/${java_file}"
    DEPENDS "${CMAKE_CURRENT_BINARY_DIR}/java/java/${java_file}"
    WORKING_DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}/java/java"
    COMMENT "mfront source ${mfront_file}")
  add_custom_target(${mat}-jclass ALL
    DEPENDS "${CMAKE_CURRENT_BINARY_DIR}/java/java/${java_class_file}")
  target_include_directories(${lib}
    PRIVATE "${CMAKE_CURRENT_BINARY_DIR}/java/include"
    PRIVATE "${TFEL_INCLUDE_PATH}"
    PRIVATE "${JNI_INCLUDE_DIRS}")
  target_link_libraries(${lib} ${JAVA_LIBRARY})
  install(TARGETS ${lib} DESTINATION lib)
  if(MFM_PACKAGE)
    install(FILES ${CMAKE_CURRENT_BINARY_DIR}/java/java/${java_file}
      DESTINATION share/java/${MFM_PACKAGE})
    install(FILES ${CMAKE_CURRENT_BINARY_DIR}/java/java/${java_class_file}
      DESTINATION share/java/${MFM_PACKAGE})
  else(MFM_PACKAGE)
    install(FILES ${CMAKE_CURRENT_BINARY_DIR}/java/java/${java_file}
      DESTINATION share/java)
    install(FILES ${CMAKE_CURRENT_BINARY_DIR}/java/java/${java_class_file}
      DESTINATION share/java)
  endif(MFM_PACKAGE)
  add_dependencies(check ${lib})
endfunction(mfront_properties_java_library mat)

function(java_property_test mat file)
  if(WIN32)
    set(CLASSPATH_SEPARATOR ";")
  else(WIN32)
    set(CLASSPATH_SEPARATOR ":")
  endif(WIN32)
  if(MFM_JAVA_INTERFACE)
    set(lib "${mat}-java")
    if(EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/${file}.java.in")
      if(MFM_PACKAGE)
	    set(MFM_JAVA_PACKAGE_IMPORT "import ${MFM_PACKAGE}.${mat}")
	    set(MFM_JAVA_PACKAGE_SUFFIX "${MFM_PACKAGE}.")
      else(MFM_PACKAGE)
	    set(MFM_JAVA_PACKAGE_IMPORT )
	    set(MFM_JAVA_PACKAGE_SUFFIX )
      endif(MFM_PACKAGE)
      set(java_source ${CMAKE_CURRENT_BINARY_DIR}/java/${file}.java)
      configure_file(${CMAKE_CURRENT_SOURCE_DIR}/${file}.java.in
	${java_source} @ONLY)
    else(EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/${file}.java.in")
      set(java_source ${CMAKE_CURRENT_SOURCE_DIR}/${file}.java)
    endif(EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/${file}.java.in")
    add_custom_command(
      OUTPUT  "${CMAKE_CURRENT_BINARY_DIR}/java/${file}.class"
      COMMAND "${Java_JAVAC_EXECUTABLE}"
      ARGS    "-cp" "${CMAKE_CURRENT_BINARY_DIR}/java/java/"
      ARGS    "-d" "${CMAKE_CURRENT_BINARY_DIR}/java"
      ARGS    "${java_source}"
      DEPENDS "${java_source}"
      WORKING_DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}/java"
      COMMENT "javac ${java_source}")
    add_custom_target(${file}-jclass
      DEPENDS "${CMAKE_CURRENT_BINARY_DIR}/java/${file}.class")
    add_dependencies(check ${file}-jclass)
    add_test(NAME ${file}-java
      COMMAND ${Java_JAVA_EXECUTABLE}
      -cp "${CMAKE_CURRENT_BINARY_DIR}/java/java/${CLASSPATH_SEPARATOR}." ${file}
      DEPENDS ${file}-jclass ${lib}
      WORKING_DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}/java")
    if((CMAKE_HOST_WIN32) AND (NOT MSYS))
      set_property(TEST ${file}-java APPEND
	PROPERTY ENVIRONMENT "LD_LIBRARY_PATH=$<TARGET_FILE_DIR:${lib}>;$ENV{LD_LIBRARY_PATH}")
      set_property(TEST ${file}-java  APPEND
	PROPERTY ENVIRONMENT "CLASSPATH=${CMAKE_CURRENT_BINARY_DIR}/java/java;$ENV{CLASSPATH}")
    else((CMAKE_HOST_WIN32) AND (NOT MSYS))
      set_property(TEST ${file}-java APPEND
	PROPERTY ENVIRONMENT "CLASSPATH=${CMAKE_CURRENT_BINARY_DIR}/java/java:$ENV{CLASSPATH}")
      set_property(TEST ${file}-java APPEND
	PROPERTY ENVIRONMENT "LD_LIBRARY_PATH=$<TARGET_FILE_DIR:${lib}>:$ENV{LD_LIBRARY_PATH}")
    endif((CMAKE_HOST_WIN32) AND (NOT MSYS))
  endif(MFM_JAVA_INTERFACE)
endfunction(java_property_test $(file))
