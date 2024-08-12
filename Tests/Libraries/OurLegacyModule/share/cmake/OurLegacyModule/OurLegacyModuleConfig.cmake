CMS_LOAD_PACKAGE(OurExternalLib REQUIRED COMPONENTS ext-a)

if (NOT TARGET our-lib)
  add_library (our-lib INTERFACE IMPORTED)
  set_target_properties (
    our-lib
    PROPERTIES
      INTERFACE_LINK_LIBRARIES CMSPackageInterfaces::OurExternalLib
  )
endif ()

CMS_DECLARE_PROVIDED_TARGETS(OurLegacyModule our-lib)
