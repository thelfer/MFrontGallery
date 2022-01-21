find_package(Gnuplot)

macro(add_gnuplot name)
  set(commands)
  set(dependencies)
  foreach(_ARG ${ARGN})
    list(APPEND commands
      COMMAND ${GNUPLOT_EXECUTABLE} ${CMAKE_CURRENT_SOURCE_DIR}/${_ARG}.gnu
      COMMAND ${PS2PDF_CONVERTER} ${_ARG}.ps
      COMMAND pdfcrop --margin "2 2 2 2" ${_ARG}.pdf ${_ARG}.pdf)
    list(APPEND dependencies ${_ARG}.gnu)
  endforeach()
  add_custom_target(
    ${name}
    ${commands}
    DEPENDS ${dependencies}
    VERBATIM)
endmacro(add_gnuplot)
