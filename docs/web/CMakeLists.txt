pandoc_html(index "--toc" "--number-sections" "--toc-depth=2")
pandoc_html(install "--toc")
pandoc_html(faq "--toc")
pandoc_html(cmake-infrastructure "--toc")
pandoc_html(creating-derived-project "--toc")
pandoc_html(best-practices "--toc")
pandoc_html(contributing "--toc")
pandoc_html(contributors "--toc" "--toc-depth=2")
pandoc_html(Burger_EDF_CIWAP_2021 "--toc" "--toc-depth=2")
pandoc_html(CrushedSaltKorthausBehaviour "--toc" "--toc-depth=2")
pandoc_html(SmallStrainUmatWrapper "--toc" "--number-sections" "--toc-depth=2")

if(MFM_APPEND_SUFFIX)
  install(DIRECTORY js css img
    DESTINATION share/doc/mfm-${MFM_SUFFIX}/web
    COMPONENT website
    PATTERN ".svn" EXCLUDE)
#  install(FILES 404.html apple-touch-icon-precomposed.png 
#    CHANGELOG.md CONTRIBUTING.md crossdomain.xml favicon.ico
#    humans.txt LICENSE.md README.md robots.txt TODO.md
#    DESTINATION share/doc/mfm-${MFM_SUFFIX}/web
#    COMPONENT website)
else(MFM_APPEND_SUFFIX)
  install(DIRECTORY js css img
    DESTINATION share/doc/mfm/web
    COMPONENT website
    PATTERN ".svn" EXCLUDE)
#  install(FILES 404.html apple-touch-icon-precomposed.png 
#    CHANGELOG.md CONTRIBUTING.md crossdomain.xml favicon.ico
#    humans.txt LICENSE.md README.md robots.txt TODO.md
#    DESTINATION share/doc/mfm/web
#    COMPONENT website)
endif(MFM_APPEND_SUFFIX)
