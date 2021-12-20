pandoc_html(index)
pandoc_html(OrthotropicGeneralizedMaxwell)

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
