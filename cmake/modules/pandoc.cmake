find_program(MFM_PANDOC NAMES pandoc pandoc.exe)
find_program(MFM_PANDOC_CROSSREF NAMES pandoc-crossref pandoc-crossref.exe)
mark_as_advanced(MFM_PANDOC)
mark_as_advanced(MFM_PANDOC_CROSSREF)
if(MFM_PANDOC)
  message(STATUS "Enabling generation of documentation based on pandoc")
  set(MFM_HAVE_PANDOC ON)
  if(NOT MFM_PANDOC_CROSSREF)
    message(STATUS "pandoc-crossref not found: references to equations, figures, tables, sections won't be generated")
  endif(NOT MFM_PANDOC_CROSSREF)
elseif(MFM_PANDOC)
  message(STATUS "Disabling generation of documentation based on pandoc")
  set(MFM_HAVE_PANDOC OFF)
endif(MFM_PANDOC)

if(MFM_PANDOC)
  message(STATUS "pandoc:          ${MFM_PANDOC}")
elseif(MFM_PANDOC)
  message(STATUS "pandoc:          not found")
endif(MFM_PANDOC)
if(MFM_PANDOC_CROSSREF)
  message(STATUS "pandoc-crossref: ${MFM_PANDOC_CROSSREF}")
elseif(MFM_PANDOC_CROSSREF)
  message(STATUS "pandoc-crossref: not found")
endif(MFM_PANDOC_CROSSREF)

function(pandoc_html_base target markdown_file html_file)
  if(MFM_PANDOC)
    set(pandoc_args)
    set(pandoc_dependencies)
    list(APPEND pandoc_dependencies ${markdown_file})
    list(APPEND pandoc_args "-f" "markdown-markdown_in_html_blocks+tex_math_single_backslash+grid_tables")
    if(MFM_PANDOC_CROSSREF)
      list(APPEND pandoc_args "--filter" "pandoc-crossref")
      if(EXISTS "${CMAKE_SOURCE_DIR}/docs/web/pandoc-crossref.yaml")
        list(APPEND pandoc_args "-M" "crossrefYaml=${CMAKE_SOURCE_DIR}/docs/web/pandoc-crossref.yaml")
        list(APPEND pandoc_dependencies "${CMAKE_SOURCE_DIR}/docs/web/pandoc-crossref.yaml")
      endif(EXISTS "${CMAKE_SOURCE_DIR}/docs/web/pandoc-crossref.yaml")
    endif(MFM_PANDOC_CROSSREF)
    if(EXISTS "${CMAKE_SOURCE_DIR}/docs/web/bibliography.bib")
      list(APPEND pandoc_args "--citeproc")
      list(APPEND pandoc_args "--bibliography=${CMAKE_SOURCE_DIR}/docs/web/bibliography.bib")
      list(APPEND pandoc_dependencies "${CMAKE_SOURCE_DIR}/docs/web/bibliography.bib")
    endif(EXISTS "${CMAKE_SOURCE_DIR}/docs/web/bibliography.bib")
    if(EXISTS "${CMAKE_SOURCE_DIR}/docs/web/mfm-template.html")
      list(APPEND pandoc_args "--template=${CMAKE_SOURCE_DIR}/docs/web/mfm-template.html")
      list(APPEND pandoc_dependencies "${CMAKE_SOURCE_DIR}/docs/web/mfm-template.html")
    endif(EXISTS "${CMAKE_SOURCE_DIR}/docs/web/mfm-template.html")
    if(EXISTS "${CMAKE_SOURCE_DIR}/docs/web/iso690-numeric-en.csl")
      list(APPEND pandoc_args "--csl=${CMAKE_SOURCE_DIR}/docs/web/iso690-numeric-en.csl")
      list(APPEND pandoc_dependencies "${CMAKE_SOURCE_DIR}/docs/web/iso690-numeric-en.csl")
    endif(EXISTS "${CMAKE_SOURCE_DIR}/docs/web/iso690-numeric-en.csl")
    if(EXISTS "${CMAKE_SOURCE_DIR}/docs/web/css/main.css")
      list(APPEND pandoc_dependencies "${CMAKE_SOURCE_DIR}/docs/web/css/main.css")
    endif(EXISTS "${CMAKE_SOURCE_DIR}/docs/web/css/main.css")
    list(APPEND pandoc_args "--mathjax")
    list(APPEND pandoc_args "--highlight-style=tango")
    list(APPEND pandoc_args "--email-obfuscation=javascript")
    list(APPEND pandoc_args "--default-image-extension=svg")
    ADD_CUSTOM_COMMAND(
      OUTPUT    ${html_file}
      DEPENDS   ${pandoc_dependencies}
      COMMAND   ${MFM_PANDOC}
      ARGS      ${pandoc_args}
      ARGS      ${ARGN}
      ARGS      ${markdown_file} -o ${html_file})
    add_custom_target(${target}-html ALL DEPENDS ${html_file})
    add_dependencies(website ${target}-html)
    if(MFM_APPEND_SUFFIX)
      install(FILES ${html_file}
        DESTINATION share/doc/mfm-${MFM_SUFFIX}/web
        COMPONENT website)
    else(MFM_APPEND_SUFFIX)
      install(FILES ${html_file}
        DESTINATION share/doc/mfm/web
        COMPONENT website)
    endif(MFM_APPEND_SUFFIX)
  endif(MFM_PANDOC)
endfunction(pandoc_html_base)

function(pandoc_html file)
    pandoc_html_base(${file}
                     ${CMAKE_CURRENT_SOURCE_DIR}/${file}.md
                     ${CMAKE_CURRENT_BINARY_DIR}/${file}.html
                     ${ARGN})
endfunction(pandoc_html)

