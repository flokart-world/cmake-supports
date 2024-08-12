# Copyright (c) 2014-2024 Flokart World, Inc.
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

function (CMS_REGISTER_PACKAGE _name)
  CMS_ASSERT_IDENTIFIER(${_name})

  if (ARGN)
    list (GET ARGN 0 _prefix)
  else ()
    set (_prefix ${_name})
  endif ()

  CMS_QUALIFY_PACKAGE_PREFIX(_qname ${_name})
  CMS_ENSURE_CMAKE_PROPERTY(GLOBAL PROPERTY ${_qname})
  set_property (GLOBAL PROPERTY ${_qname} ${_prefix})
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

function (_CMS_PACKAGE_VARIABLE _ret _varId)
  CMS_RETURN(_ret CMS::Package::Variable[\${_varId}])
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
  CMS_ASSERT_IDENTIFIER(${_package})
  CMS_PACKAGE_INTERFACE(_target ${_package})

  if (${_prefix}_LIBRARY_DIRS)
    link_directories (${${_prefix}_LIBRARY_DIRS})
  endif ()

  if (NOT TARGET ${_target})
    add_library (${_target} INTERFACE IMPORTED)
  endif ()

  if (${_prefix}_INCLUDE_DIR)
    set (_includes "${${_prefix}_INCLUDE_DIR}")
  else ()
    unset (_includes)
  endif ()

  if (${_prefix}_INCLUDE_DIRS)
    list (APPEND _includes ${${_prefix}_INCLUDE_DIRS})
  endif ()

  if (_includes)
    list (REMOVE_DUPLICATES _includes)

    CMS_ADD_TO_CMAKE_TARGET_PROPERTY(${_target}
        INTERFACE_INCLUDE_DIRECTORIES ${_includes})
  endif ()

  if (${_prefix}_LIBRARIES)
    set (_mode false)
    unset (_libs)

    foreach (_term IN LISTS ${_prefix}_LIBRARIES)
      if (_mode)
        if (_mode STREQUAL "optimized")
          list (APPEND _libs "$<$<NOT:$<CONFIG:Debug>>:${_term}>")
        else ()
          list (APPEND _libs "$<$<CONFIG:Debug>:${_term}>")
        endif ()

        set (_mode false)
      elseif (_term STREQUAL "optimized" OR _term STREQUAL "debug")
        set (_mode ${_term})
      else ()
        list (APPEND _libs "${_term}")
      endif ()
    endforeach ()

    CMS_ADD_TO_CMAKE_TARGET_PROPERTY(${_target}
                                     INTERFACE_LINK_LIBRARIES ${_libs})
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

function (CMS_PROVIDE_VARIABLE _package _varName)
  CMS_PACKAGE_INTERFACE(_target "${_package}")
  CMS_ASSERT_IDENTIFIER("${_varName}")
  if (TARGET ${_target})
    get_target_property (_providedVariables ${_target} CMS::ProvidedVariables)
    list (FIND _providedVariables "${_varName}" _foundAt)
    if (_foundAt LESS 0)
      list (APPEND _providedVariables "${_varName}")
      set_target_properties (
        ${_target}
        PROPERTIES CMS::ProvidedVariables "${_providedVariables}"
      )
    endif ()

    _CMS_PACKAGE_VARIABLE(_qname "${_package}::${_varName}")
    CMS_ENSURE_CMAKE_PROPERTY(GLOBAL PROPERTY "${_qname}")
    set_property (GLOBAL PROPERTY "${_qname}" "${ARGN}")
  else ()
    message (FATAL_ERROR "Package ${_package} is not provided.")
  endif ()
endfunction ()

function (_CMS_FETCH_VARIABLE _ret _package _varName)
  CMS_PACKAGE_INTERFACE(_target "${_package}")
  CMS_ASSERT_IDENTIFIER("${_varName}")
  if (TARGET ${_target})
    get_target_property (_providedVariables ${_target} CMS::ProvidedVariables)
    list (FIND _providedVariables "${_varName}" _foundAt)
    if (_foundAt LESS 0)
      message (
        FATAL_ERROR
        "Package variable ${_varName} on ${_package} is not provided."
      )
    else ()
      _CMS_PACKAGE_VARIABLE(_qname "${_package}::${_varName}")
      get_cmake_property (_value "${_qname}")
      CMS_RETURN(_ret \${_value})
    endif ()
  else ()
    message (FATAL_ERROR "Package ${_package} is not provided.")
  endif ()
endfunction ()

function (CMS_TEST_PACKAGE _ret _name)
  CMS_PACKAGE_INTERFACE(_target ${_name})

  if (TARGET ${_target})
    CMS_PACKAGE_COMPONENTS(_qname ${_target})
    get_cmake_property (_loadedComponents ${_qname})

    if (ARGN)
      if (_loadedComponents)
        list (REMOVE_ITEM ARGN ${_loadedComponents})
      endif ()

      list (LENGTH ARGN _length)

      if (_length EQUAL 0)
        CMS_RETURN(_ret true)
      else ()
        CMS_GET_PACKAGE_DOMAIN(_domain "${_name}")
        if (_domain STREQUAL "LOCAL")
          message (
            FATAL_ERROR
            "Package ${_name} is being built within this project, "
            "but some required components are missing: ${ARGN}"
          )
        endif ()
        CMS_RETURN(_ret false)
      endif ()
    else ()
      CMS_RETURN(_ret true)
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

function (_CMS_PARSE_PACKAGE_ARGUMENTS _outArgs _outOutVars)
  set (_outVars)

  if (ARGN)
    list (FIND ARGN "OUT_VARS" _delimPos)
    if (_delimPos GREATER_EQUAL 0)
      list (LENGTH ARGN _len)
      math (EXPR _begin "${_delimPos} + 1")
      if (_begin LESS _len)
        list (SUBLIST ARGN ${_begin} -1 _outVars)
        list (SUBLIST ARGN 0 ${_delimPos} ARGN)
      else ()
        list (REMOVE_AT ARGN ${_delimPos})
      endif ()
    endif ()
  endif ()

  CMS_RETURN(_outArgs \${ARGN})
  CMS_RETURN(_outOutVars \${_outVars})
endfunction ()

function (CMS_LOAD_PACKAGE _name)
  CMS_ASSERT_IDENTIFIER(${_name})

  set (_prefix "${_name}")
  if (ARGN)
    list (GET ARGN 0 _top)

    if (_top STREQUAL "PREFIX")
      list (GET ARGN 1 _prefix)
      list (REMOVE_AT ARGN 0 1)
    endif ()
  endif ()

  _CMS_PARSE_PACKAGE_ARGUMENTS(ARGN _outVars ${ARGN})
  CMS_PARSE_REQUIRED_COMPONENTS(_components ${ARGN})

  CMS_TEST_PACKAGE(_loaded ${_name} ${_components})

  set (_incompatibleOutVars ${_outVars})
  list (REMOVE_ITEM _incompatibleOutVars ${_name}_FOUND)

  if (_loaded AND NOT _incompatibleOutVars)
    set (${_name}_FOUND true)
  else ()
    if (_loaded)
      CMS_GET_PACKAGE_DOMAIN(_domain "${_name}")
      if (_domain STREQUAL "LOCAL")
        message (
          FATAL_ERROR
          "As the package ${_name} is bundled in the project, it is not "
          "possible to load this package again with incompatible OUT_VARS: "
          "${_incompatibleOutVars}"
        )
      endif ()
    endif ()

    find_package ("${_name}" ${ARGN})

    if (${_name}_FOUND)
      CMS_REGISTER_PACKAGE(${_name} ${_prefix})
      CMS_DEFINE_PACKAGE_INTERFACE(${_name} ${_prefix} ${_components})
      if (${_prefix}_CMakeSupportsVariables)
        foreach (_varName IN LISTS ${_prefix}_CMakeSupportsVariables)
          set (_value "${${_prefix}_${_varName}}")
          CMS_PROVIDE_VARIABLE("${_name}" "${_varName}" ${_value})
        endforeach ()
      endif ()
    endif ()
  endif ()

  foreach (_varName IN LISTS _outVars)
    CMS_PROMOTE_TO_PARENT_SCOPE(${_varName})
  endforeach ()
endfunction ()

function (CMS_PROVIDE_PACKAGE _name)
  CMS_ASSERT_IDENTIFIER(${_name})
  CMS_TEST_PACKAGE(_loaded ${_name})

  if (NOT _loaded)
    CMS_REGISTER_PACKAGE(${_name})
  endif ()

  CMS_PACKAGE_INTERFACE(_target ${_name})

  if (NOT TARGET ${_target})
    # A provided package corresponds to an embedded(virtual) package.
    # It prevents non-global library from being added.
    add_library (${_target} INTERFACE IMPORTED GLOBAL)
  endif ()

  CMS_DEFINE_PACKAGE_INTERFACE(${_name} ${_name} ${ARGN})
endfunction ()

function (CMS_LOAD_VARIABLE _name)
  message (
    FATAL_ERROR
    "CMS_LOAD_VARIABLE is no longer supported. Please rebuild your package."
  )
endfunction ()
