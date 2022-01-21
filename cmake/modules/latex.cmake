find_package(LATEX COMPONENTS PDFLATEX BIBTEX)
if(NOT LATEX_FOUND)
  message(STATUS "pdflatex or bibtex are missing, generation of pdf documents from LaTeX is disabled")
endif(NOT LATEX_FOUND)