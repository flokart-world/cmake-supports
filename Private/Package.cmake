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
  CMS_ASSERT_IDENTIFIER(${_name})
  CMS_RETURN(_ret CMS::Package::Prefix[\${_name}])
endfunction ()

function (CMS_QUALIFY_VARIABLE _ret _name)
  CMS_ASSERT_IDENTIFIER(${_name})
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
  CMS_RETURN(_ret CMSPackageInterfaces::\${_package})
endfunction ()

function (CMS_PACKAGE_DOMAIN _ret _package)
  CMS_RETURN(_ret CMS::Package::Domain[\${_package}])
endfunction ()

function (CMS_PACKAGE_COMPONENTS _ret _package)
  CMS_RETURN(_ret CMS::Package::Components[\${_package}])
endfunction ()

function (CMS_ADD_TO_CMAKE_TARGET_PROPERTY _target _property)
  get_property (_defined TARGET ${_target} PROPERTY ${_property} DEFINED)

  if (_defined)
    get_target_property (_values ${_target} ${_property})
    list (APPEND _values ${ARGN})
    list (REMOVE_DUPLICATES _values)
  else ()
    set (_values ${ARGN})
  endif ()

  set_target_properties (${_target} PROPERTIES ${_property} "${_values}")
endfunction ()

# This function may be called more than once for a package within a same
# scope, due to set of required components.
function (CMS_DEFINE_PACKAGE_INTERFACE _package _prefix)
  CMS_PACKAGE_INTERFACE(_target ${_package})

  if (${_prefix}_LIBRARY_DIRS)
    link_directories (${${_prefix}_LIBRARY_DIRS})
  endif ()

  if (NOT TARGET ${_target})
    add_library (${_target} INTERFACE IMPORTED)
  endif ()

  if (${_prefix}_INCLUDE_DIRS)
    CMS_ADD_TO_CMAKE_TARGET_PROPERTY(${_target}
                                     INTERFACE_INCLUDE_DIRECTORIES
                                     ${${_prefix}_INCLUDE_DIRS})
  endif ()

  if (${_prefix}_LIBRARIES)
    CMS_ADD_TO_CMAKE_TARGET_PROPERTY(${_target}
                                     INTERFACE_LINK_LIBRARIES
                                     ${${_prefix}_LIBRARIES})
  endif ()

  CMS_PACKAGE_DOMAIN(_qname "${_target}")
  CMS_ENSURE_CMAKE_PROPERTY(GLOBAL PROPERTY "${_qname}")
  set_property (GLOBAL PROPERTY "${_qname}" FOREIGN)

  CMS_PACKAGE_COMPONENTS(_qname ${_target})
  CMS_ENSURE_CMAKE_PROPERTY(GLOBAL PROPERTY ${_qname})
  get_cmake_property (_components ${_qname})
  list (APPEND _components ${ARGN})
  list (REMOVE_DUPLICATES _components)
  set_property (GLOBAL PROPERTY ${_qname} "${_components}")
endfunction ()

function (CMS_SUBMIT_PACKAGE _package)
  CMS_REGISTER_PACKAGE(${_package})
  CMS_PACKAGE_INTERFACE(_target ${_package})
  add_library (${_target} INTERFACE IMPORTED GLOBAL)

  CMS_PACKAGE_DOMAIN(_qname "${_target}")
  CMS_DEFINE_CMAKE_PROPERTY(GLOBAL PROPERTY "${_qname}")
  set_property (GLOBAL PROPERTY "${_qname}" LOCAL)

  CMS_PACKAGE_COMPONENTS(_qname ${_target})
  CMS_DEFINE_CMAKE_PROPERTY(GLOBAL PROPERTY ${_qname})
  set_property (GLOBAL PROPERTY ${_qname} "${ARGN}")
endfunction ()

function (CMS_TEST_PACKAGE _ret _name)
  CMS_PACKAGE_INTERFACE(_target ${_name})

  if (TARGET "${_target}")
    CMS_PACKAGE_COMPONENTS(_qname ${_target})
    get_cmake_property (_loadedComponents ${_qname})

    if (_loadedComponents)
      list (REMOVE_ITEM ARGN ${_loadedComponents})
    endif ()

    list (LENGTH ARGN _length)

    if (_length EQUAL 0)
      CMS_RETURN(_ret true)
    else ()
      CMS_RETURN(_ret false)
    endif ()
  else ()
    CMS_RETURN(_ret false)
  endif ()
endfunction ()

function (CMS_GET_PACKAGE_DOMAIN _ret _name)
  CMS_ASSERT_IDENTIFIER(${_name})

  CMS_PACKAGE_INTERFACE(_target "${_name}")
  CMS_PACKAGE_DOMAIN(_qname ${_target})
  get_cmake_property (_domain ${_qname})

  CMS_RETURN(_ret \${_domain})
endfunction ()

function (CMS_PARSE_REQUIRED_COMPONENTS _ret)
  if (ARGN)
    list (GET ARGN 0 _top)

    if (_top STREQUAL "PREFIX")
      list (GET ARGN 1 _prefix)
      list (REMOVE_AT ARGN 0 1)
    endif ()
  endif ()

  set (_packageName CMS_PARSE_ARGUMENTS)
  set (_prefix CMS_PACKAGE)

  find_package (${_packageName} ${ARGN}
                CONFIG CONFIGS PackageArgumentParser.cmake
                       PATHS ${CMS_PRIVATE_DIR}
                       NO_DEFAULT_PATH)
  mark_as_advanced (${_packageName}_DIR)

  CMS_RETURN(_ret [[${${_prefix}_REQUIRED_COMPONENTS}]])
endfunction ()

function (CMS_LOAD_PACKAGE _name)
  CMS_PARSE_REQUIRED_COMPONENTS(_components ${ARGN})

  # We are not sure how we should handle optional components.
  # Right now, they are entirely ignored around the dependency management.
  CMS_TEST_PACKAGE(_loaded ${_name} ${_components})

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
      CMS_DEFINE_PACKAGE_INTERFACE(${_name} ${_prefix} ${_components})
    endif ()
  endif ()
endfunction ()

function (CMS_PROVIDE_PACKAGE _name)
  CMS_ASSERT_IDENTIFIER(${_name})
  CMS_TEST_PACKAGE(_loaded ${_name})

  if (NOT _loaded)
    CMS_REGISTER_PACKAGE(${_name} ${_prefix})
    CMS_DEFINE_PACKAGE_INTERFACE(${_name} ${_prefix} ${ARGN})
  endif ()
endfunction ()

function (CMS_TEST_VARIABLE _ret _name)
  CMS_QUALIFY_VARIABLE(_qname ${_name})
  get_property (_defined TARGET CMSVariables PROPERTY ${_qname} DEFINED)

  CMS_RETURN(_ret \${_defined})
endfunction ()

function (CMS_TRANSFER_VARIABLE _name)
  CMS_QUALIFY_VARIABLE(_qname ${_name})
  CMS_DEFINE_CMAKE_PROPERTY(TARGET PROPERTY ${_qname})
  set_target_properties (CMSVariables PROPERTIES ${_qname} "${${_name}}")
endfunction ()

function (CMS_LOAD_VARIABLE _name)
  CMS_TEST_VARIABLE(_defined ${_name})

  if (NOT _defined)
    CMS_TRANSFER_VARIABLE(${_name})
  endif ()
endfunction ()

function (CMS_REGISTER_VARIABLE _name)
  CMS_TEST_VARIABLE(_defined ${_name})

  if (_defined)
    message (FATAL_ERROR "Variable ${_name} has already been registered.")
  else ()
    CMS_TRANSFER_VARIABLE(${_name})
  endif ()
endfunction ()

function (CMS_GET_VARIABLE _ret _name)
  CMS_QUALIFY_VARIABLE(_qname ${_name})
  get_target_property (_value CMSVariables ${_qname})

  CMS_RETURN(_ret \${_value})
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

function (CMS_SET_VARIABLE _name _value)
  set (${_name} ${_value})
  CMS_REGISTER_VARIABLE(${_name})
endfunction ()
