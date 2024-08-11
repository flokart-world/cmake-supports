add_library (our-lib INTERFACE IMPORTED)
target_sources (our-lib INTERFACE ${CMAKE_CURRENT_LIST_DIR}/../../../src/functions.c)

CMS_PROVIDE_PACKAGE("OurPseudoPackage" our-lib)
CMS_PROVIDE_VARIABLE("OurPseudoPackage" "OurLibraries" "our-lib")
CMS_DECLARE_PROVIDED_TARGETS(OurSubModule our-lib)
set (OurSubModule_CMakeSupportsVariables "Greeting")
set (OurSubModule_Greeting "Hello!")
