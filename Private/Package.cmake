# Copyright (c) 2014 Flokart World, Inc.
#
# This software is provided 'as-is', without any express or implied
# warranty. In no event will the authors be held liable for any damages
# arising from the use of this software.
# 
# Permission is granted to anyone to use this software for any purpose,
# including commercial applications, and to alter it and redistribute it
# freely, subject to the following restrictions:
# 
#    1. The origin of this software must not be misrepresented; you must not
#    claim that you wrote the original software. If you use this software
#    in a product, an acknowledgment in the product documentation would be
#    appreciated but is not required.
# 
#    2. Altered source versions must be plainly marked as such, and must not be
#    misrepresented as being the original software.
# 
#    3. This notice may not be removed or altered from any source distribution.

function (CMS_QUALIFY_PACKAGE_PREFIX _ret _name)
  CMS_RETURN(_ret CMS::Package::Prefix[\${_name}])
endfunction ()

function (CMS_QUALIFY_VARIABLE _ret _name)
  CMS_RETURN(_ret CMS::Package::Variable[\${_name}])
endfunction ()

function (CMS_REGISTER_PACKAGE _name)
  if (ARGN)
    list (GET ARGN 0 _prefix)
  else ()
    set (_prefix "${_name}")
  endif ()

  CMS_QUALIFY_PACKAGE_PREFIX(_qname ${_name})
  CMS_ENSURE_CMAKE_PROPERTY(GLOBAL PROPERTY ${_qname})
  set_property (GLOBAL PROPERTY "${_qname}" "${_prefix}")
endfunction ()

function (CMS_GET_PACKAGE_PREFIX _ret _name)
  CMS_QUALIFY_PACKAGE_PREFIX(_qname ${_name})
  get_property (_prefix GLOBAL PROPERTY "${_qname}")

  CMS_RETURN(_ret \${_prefix})
endfunction ()

function (CMS_PACKAGE_INTERFACE _ret _package)
  CMS_RETURN(_ret "CMSPackageInterfaces::\${_package}")
endfunction ()

function (CMS_DEFINE_PACKAGE_INTERFACE _package _prefix)
  CMS_PACKAGE_INTERFACE(_target ${_package})

  if (${_prefix}_LIBRARY_DIRS)
    link_directories (${${_prefix}_LIBRARY_DIRS})
  endif ()

  add_library (${_target} INTERFACE IMPORTED)

  if (${_prefix}_INCLUDE_DIRS)
    set_target_properties (${_target} PROPERTIES
        INTERFACE_INCLUDE_DIRECTORIES "${${_prefix}_INCLUDE_DIRS}")
  endif ()

  if (${_prefix}_LIBRARIES)
    set_target_properties (${_target} PROPERTIES
        INTERFACE_LINK_LIBRARIES "${${_prefix}_LIBRARIES}")
  endif ()
endfunction ()

function (CMS_TEST_PACKAGE _ret _name)
  CMS_PACKAGE_INTERFACE(_target ${_name})

  if (TARGET "${_target}")
    CMS_RETURN(_ret true)
  else ()
    CMS_RETURN(_ret false)
  endif ()
endfunction ()

function (CMS_LOAD_PACKAGE _name)
  CMS_TEST_PACKAGE(_loaded ${_name})

  if (NOT _loaded)
    set (_prefix "${_name}")

    if (ARGN)
      list (GET ARGN 0 _top)

      if (_top STREQUAL "PREFIX")
        list (GET ARGN 1 _prefix)
        list (REMOVE_AT ARGN 0 1)
      endif ()
    endif ()

    find_package ("${_name}" ${ARGN})

    if (${_prefix}_FOUND)
      CMS_REGISTER_PACKAGE(${_name} ${_prefix})
      CMS_DEFINE_PACKAGE_INTERFACE(${_name} ${_prefix})
    endif ()
  endif ()
endfunction ()

function (CMS_ENSURE_PACKAGES)
  if (ARGN)
    foreach (_package IN LISTS ARGN)
      CMS_GET_PACKAGE_PREFIX(_prefix ${_package})
      CMS_LOAD_PACKAGE(${_package} PREFIX ${_prefix})
    endforeach ()
  endif ()
endfunction ()

function (CMS_LOAD_VARIABLE _name)
  CMS_QUALIFY_VARIABLE(_qname ${_name})
  get_property (_defined TARGET CMSVariables PROPERTY ${_qname} DEFINED)

  if (NOT _defined)
    CMS_DEFINE_CMAKE_PROPERTY(TARGET PROPERTY ${_qname})
    set_target_properties (CMSVariables PROPERTIES ${_qname} "${${_name}}")
  endif ()
endfunction ()

function (CMS_GET_VARIABLE_EXPR _ret _name)
  CMS_QUALIFY_VARIABLE(_qname ${_name})
  get_property (_defined TARGET CMSVariables PROPERTY ${_qname} DEFINED)

  if (_defined)
    CMS_RETURN(_ret "$<TARGET_PROPERTY:CMSVariables,\${_qname}>")
  else ()
    message (FATAL_ERROR "Variable ${_name} is not loaded.")
  endif ()
endfunction ()
