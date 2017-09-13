macro(mfront_properties_java_library mat)
  set(lib "${mat}-java")
  set(mfront_files)
  if(MFM_PACKAGE)
    set(java_file       "${MFM_PACKAGE}/${mat}.java")
    set(java_class_file "${MFM_PACKAGE}/${mat}.class")
  else(MFM_PACKAGE)
    set(java_file       "${mat}.java")
    set(java_class_file "${mat}.class")
  endif(MFM_PACKAGE)
  foreach(source ${ARGN})
    set(mfront_file   "${CMAKE_CURRENT_SOURCE_DIR}/${source}.mfront")
    set(mfront_output "java/src/${source}-java.cxx")
    list(APPEND mfront_files "${mfront_file}")
    if(MFM_PACKAGE)
      add_custom_command(
	OUTPUT  "${mfront_output}"
	COMMAND "${MFRONT}"
	ARGS    "--search-path=${CMAKE_SOURCE_DIR}/materials/${mat}/properties"
	ARGS    "--@Package=${MFM_PACKAGE}"
	ARGS    "--interface=java" "${mfront_file}"
	DEPENDS "${mfront_file}"
	WORKING_DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}/java"
	COMMENT "mfront source ${mfront_file}")
    else(MFM_PACKAGE)
      add_custom_command(
	OUTPUT  "${mfront_output}"
	COMMAND "${MFRONT}"
	ARGS    "--search-path=${CMAKE_SOURCE_DIR}/materials/${mat}/properties"
	ARGS    "--interface=java" "${mfront_file}"
	DEPENDS "${mfront_file}"
	WORKING_DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}/java"
	COMMENT "mfront source ${mfront_file}")
    endif(MFM_PACKAGE)
    set(${lib}_SOURCES ${mfront_output} ${${lib}_SOURCES})
  endforeach(source)
  if(MFM_PACKAGE)
    add_custom_command(
      OUTPUT  "${CMAKE_CURRENT_BINARY_DIR}/java/java/${java_file}"
      COMMAND "${MFRONT}"
      ARGS    "--@Package=${MFM_PACKAGE}"
      ARGS    "--search-path=${CMAKE_SOURCE_DIR}/materials/${mat}/properties"
      ARGS    "--interface=java" ${mfront_files}
      DEPENDS ${mfront_files}
      WORKING_DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}/java"
      COMMENT "mfront source ${mfront_file}")
  else(MFM_PACKAGE)
    add_custom_command(
      OUTPUT  "${CMAKE_CURRENT_BINARY_DIR}/java/java/${java_file}"
      COMMAND "${MFRONT}"
      ARGS    "--search-path=${CMAKE_SOURCE_DIR}/materials/${mat}/properties"
      ARGS    "--interface=java" ${mfront_files}
      DEPENDS ${mfront_files}
      WORKING_DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}/java"
      COMMENT "mfront source ${mfront_file}")
  endif(MFM_PACKAGE)
  foreach(deps ${${mat}_mfront_properties_dependencies_java_SOURCES})
    set(${lib}_SOURCES ${deps} ${${lib}_SOURCES})
  endforeach(deps ${${mat}_mfront_properties_dependencies_java_SOURCES})
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
endmacro(mfront_properties_java_library mat)

macro(java_property_test mat file)
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
endmacro(java_property_test $(file))
