set (_targetsDefined true)
foreach (_lib IN ITEMS ext-a ext-b-variant1 ext-b-variant2)
  if (NOT TARGET ${_lib})
    set (_targetsDefined false)
    break()
  endif ()
endforeach ()

if (NOT _targetsDefined)
  add_library (ext-a INTERFACE IMPORTED)
  target_sources (ext-a INTERFACE ${CMAKE_CURRENT_LIST_DIR}/src/a.c)

  add_library (ext-b-variant1 INTERFACE IMPORTED)
  target_sources (ext-b-variant1 INTERFACE ${CMAKE_CURRENT_LIST_DIR}/src/b1.c)

  add_library (ext-b-variant2 INTERFACE IMPORTED)
  target_sources (ext-b-variant2 INTERFACE ${CMAKE_CURRENT_LIST_DIR}/src/b2.c)
endif ()

set (OurExternalLib_FOUND true)

CMS_DECLARE_PROVIDED_TARGETS(
  OurExternalLib
  ext-a ext-b-variant1 ext-b-variant2
)

if (OurExternalLib_FOUND)
  set (OurExternalLib_VERSION 0.5.9)
  set (OurExternalLib_LIBRARIES ${OurExternalLib_FIND_COMPONENTS})
endif ()
