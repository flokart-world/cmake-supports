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

function (CMS_TEST_QNAME_PROPERTY _ret _qname)
  get_property (_defined GLOBAL PROPERTY "${_qname}" DEFINED)

  CMS_RETURN(_ret \${_defined})
endfunction ()

function (CMS_DEFINE_QNAME_PROPERTY _qname)
  CMS_TEST_QNAME_PROPERTY(_defined "${_qname}")

  if (_defined)
    message (FATAL_ERROR "Property ${_qname} has already been defined.")
  else ()
    CMS_DEFINE_CMAKE_PROPERTY(GLOBAL PROPERTY "${_qname}")
  endif ()
endfunction ()

function (CMS_ASSERT_QNAME_PROPERTY _qname)
  CMS_TEST_QNAME_PROPERTY(_defined "${_qname}")

  if (NOT _defined)
    message (FATAL_ERROR "Property ${_qname} has not been defined.")
  endif ()
endfunction ()

function (CMS_GET_QNAME_PROPERTY _ret _qname)
  CMS_ASSERT_QNAME_PROPERTY("${_qname}")
  get_property (_values GLOBAL PROPERTY "${_qname}")

  CMS_RETURN(_ret \${_values})
endfunction ()

function (CMS_SET_QNAME_PROPERTY _qname)
  CMS_ASSERT_QNAME_PROPERTY("${_qname}")
  set_property (GLOBAL PROPERTY "${_qname}" ${ARGN})
endfunction ()

function (CMS_PREPEND_TO_QNAME_PROPERTY _qname)
  CMS_ASSERT_QNAME_PROPERTY("${_qname}")
  list (LENGTH ARGN _size)

  if (_size GREATER 0)
    CMS_GET_QNAME_PROPERTY(_values "${_qname}")
    list (INSERT _values 0 ${ARGN})

    CMS_SET_QNAME_PROPERTY("${_qname}" ${_values})
  endif ()
endfunction ()

function (CMS_APPEND_TO_QNAME_PROPERTY _qname)
  CMS_ASSERT_QNAME_PROPERTY("${_qname}")

  CMS_GET_QNAME_PROPERTY(_values "${_qname}")
  list (APPEND _values ${ARGN})

  CMS_SET_QNAME_PROPERTY("${_qname}" ${_values})
endfunction ()

function (CMS_STACK_PUSH _value)
  get_directory_property (_stack CMS::Scope::Stack)
  list (INSERT _stack 0 "${_value}")
  set_directory_properties (PROPERTIES CMS::Scope::Stack "${_stack}")
endfunction ()

function (CMS_STACK_POP _var)
  get_directory_property (_stack CMS::Scope::Stack)
  list (GET _stack 0 _value)
  list (REMOVE_AT _stack 0)
  set_directory_properties (PROPERTIES CMS::Scope::Stack "${_stack}")

  CMS_RETURN(_var [[${_value}]])
endfunction ()

function (CMS_PROPERTY_DEFINED _var _key)
  get_directory_property (_this CMS::Scope::This)

  if (_this)
    set (_qname "${_this}::${_key}")
    get_property (_defined GLOBAL PROPERTY "${_qname}" DEFINED)

    CMS_RETURN(_var [[${_defined}]])
  else ()
    CMS_RETURN(_var)
  endif ()
endfunction ()

function (CMS_DEFINE_PROPERTY _key)
  get_directory_property (_this CMS::Scope::This)

  if (_this)
    CMS_DEFINE_QNAME_PROPERTY("${_this}::${_key}")
  endif ()
endfunction ()

function (CMS_GET_PROPERTY _var _key)
  get_directory_property (_this CMS::Scope::This)

  if (_this)
    CMS_GET_QNAME_PROPERTY(_value "${_this}::${_key}")

    CMS_RETURN(_var \${_value})
  else ()
    CMS_RETURN(_var)
  endif ()
endfunction ()

function (CMS_SET_PROPERTY _key)
  get_directory_property (_this CMS::Scope::This)

  if (_this)
    CMS_SET_QNAME_PROPERTY("${_this}::${_key}" ${ARGN})
  endif ()
endfunction ()

function (CMS_PREPEND_TO_PROPERTY _key _value)
  get_directory_property (_this CMS::Scope::This)

  if (_this)
    list (INSERT ARGN 0 "${_value}")
    CMS_PREPEND_TO_QNAME_PROPERTY("${_this}::${_key}" ${ARGN})
  endif ()
endfunction ()

function (CMS_APPEND_TO_PROPERTY _key _value)
  get_directory_property (_this CMS::Scope::This)

  if (_this)
    list (INSERT ARGN 0 "${_value}")
    CMS_APPEND_TO_QNAME_PROPERTY("${_this}::${_key}" ${ARGN})
  endif ()
endfunction ()

function (CMS_DEFINE_COMMON_PROPERTIES)
  CMS_DEFINE_PROPERTY(CompileOptions)
  CMS_DEFINE_PROPERTY(CompileDefinitions)
  CMS_DEFINE_PROPERTY(ExportName)
  CMS_DEFINE_PROPERTY(IncludeDirectories)
  CMS_DEFINE_PROPERTY(LinkDirectories)
  CMS_DEFINE_PROPERTY(LinkLibraries)
  CMS_DEFINE_PROPERTY(Parent)
  CMS_DEFINE_PROPERTY(ProvidedPackages)
  CMS_DEFINE_PROPERTY(ProvidedTargets)
  CMS_DEFINE_PROPERTY(PublicHeaders)
  CMS_DEFINE_PROPERTY(PublicHeaderDirectories)
  CMS_DEFINE_PROPERTY(RequiredPackages)
  CMS_DEFINE_PROPERTY(RequiredVariables)
  CMS_DEFINE_PROPERTY(SourceGroups)
  CMS_DEFINE_PROPERTY(Type)
  CMS_DEFINE_PROPERTY(Version)
endfunction ()

function (CMS_ADD_COMPILE_OPTIONS)
  CMS_APPEND_TO_PROPERTY(CompileOptions ${ARGN})
endfunction ()

function (CMS_OPTIONS_DISABLE_MSVC_WARNINGS _ret)
  if (ARGN)
    if (MSVC)
      set (_options "")

      foreach (_number IN LISTS ARGN)
        list (APPEND _options "/wd${_number}")
      endforeach ()

      CMS_RETURN(_ret [[${_options}]])
    else ()
      CMS_RETURN(_ret)
    endif ()
  else ()
    message (FATAL_ERROR "At least one argument must be specified.")
  endif ()
endfunction ()

function (CMS_DISABLE_MSVC_WARNINGS)
  CMS_OPTIONS_DISABLE_MSVC_WARNINGS(_options ${ARGN})
  CMS_ADD_COMPILE_OPTIONS(PRIVATE ${_options})

  # TODO : Delete them.
  CMS_DISABLE_MSVC_WARNINGS_OLD(${ARGN})
  CMS_PROMOTE_TO_PARENT_SCOPE(CMS_DISABLED_MSVC_WARNINGS)
endfunction ()

function (CMS_ADD_DEFINITIONS)
  CMS_APPEND_TO_PROPERTY(CompileDefinitions ${ARGN})

  # TODO : Delete them.
  CMS_ADD_DEFINITIONS_OLD(${ARGN})
  CMS_PROMOTE_TO_PARENT_SCOPE(CMS_DEFINITIONS)
endfunction ()

function (CMS_EXPAND_VARIABLES _ret)
  set (_expanded "")

  while (ARGN)
    list (GET ARGN 0 _head)
    list (REMOVE_AT ARGN 0)

    if (_head MATCHES "^@.*@$")
      CMS_GET_VARIABLE_EXPR(_expr ${_head})
      list (APPEND _expanded "${_expr}")
    else ()
      list (APPEND _expanded "${_head}")
    endif ()
  endwhile ()

  CMS_RETURN(_ret [[${_expanded}]])
endfunction ()

function (CMS_INCLUDE_DIRECTORIES)
  if (ARGN)
    CMS_EXPAND_VARIABLES(_expanded ${ARGN})
    CMS_APPEND_TO_PROPERTY(IncludeDirectories "${_expanded}")
  else ()
    message (FATAL_ERROR "At least one argument must be specified.")
  endif ()
endfunction ()

function (CMS_LINK_DIRECTORIES)
  if (ARGN)
    CMS_EXPAND_VARIABLES(_expanded ${ARGN})
    CMS_APPEND_TO_PROPERTY(LinkDirectories "${_expanded}")
  else ()
    message (FATAL_ERROR "At least one argument must be specified.")
  endif ()
endfunction ()

function (CMS_LINK_LIBRARIES)
  if (ARGN)
    CMS_EXPAND_VARIABLES(_expanded ${ARGN})
    CMS_APPEND_TO_PROPERTY(LinkLibraries "${_expanded}")
  else ()
    message (FATAL_ERROR "At least one argument must be specified.")
  endif ()
endfunction ()

function (CMS_GROUP_FILE _category _relative _absolute)
  get_filename_component (_subdir "${_relative}" DIRECTORY)

  if (_subdir)
    string (REPLACE "/" "\\" _group "${_subdir}")
    set (_group "${_category}\\${_group}")
  else ()
    set (_group "${_category}")
  endif ()

  set (_propertyName "SourceGroup[${_group}]")
  CMS_PROPERTY_DEFINED(_defined "${_propertyName}")

  if (NOT _defined)
    CMS_DEFINE_PROPERTY("${_propertyName}")
    CMS_APPEND_TO_PROPERTY(SourceGroups "${_group}")
  endif ()

  CMS_APPEND_TO_PROPERTY("${_propertyName}" "${_absolute}")
endfunction ()

function (CMS_ADD_PUBLIC_HEADERS)
  if (ARGN)
    get_directory_property (_this CMS::Scope::This)

    if (_this)
      foreach (_file IN LISTS ARGN)
        get_filename_component (_fullPath "${_file}" ABSOLUTE)
        CMS_GROUP_FILE("Header Files" "${_file}" "${_fullPath}")
        CMS_APPEND_TO_PROPERTY(PublicHeaders "${_fullPath}")

        get_filename_component (_directory "${_file}" DIRECTORY)
        install (FILES "${_file}" DESTINATION "include/${_directory}")
      endforeach ()

      CMS_APPEND_TO_PROPERTY(PublicHeaderDirectories
                             "${CMAKE_CURRENT_SOURCE_DIR}")
    endif ()
  else ()
    message (FATAL_ERROR "At least one argument must be specified.")
  endif ()
endfunction ()

function (CMS_USE_PACKAGE _name)
  get_directory_property (_this CMS::Scope::This)

  if (_this)
    CMS_LOAD_PACKAGE("${_name}" ${ARGN})
    CMS_TEST_PACKAGE(_loaded "${_name}")

    if (_loaded)
      CMS_APPEND_TO_PROPERTY(RequiredPackages ${_name})
    endif ()
  endif ()
endfunction ()

function (CMS_USE_VARIABLE _name)
  get_directory_property (_this CMS::Scope::This)

  if (_this)
    CMS_LOAD_VARIABLE("${_name}")
    CMS_APPEND_TO_PROPERTY(RequiredVariables ${_name})
  endif ()
endfunction ()

function (CMS_IMPORT_PACKAGE _name)
  CMS_USE_PACKAGE("${_name}" ${ARGN})
  CMS_TEST_PACKAGE(_loaded "${_name}")

  if (_loaded)
    CMS_PACKAGE_INTERFACE(_target "${_name}")
    CMS_LINK_LIBRARIES(${_target})
  endif ()
endfunction ()

function (CMS_NORMALIZE_DEPENDENCY)
  CMS_GET_PROPERTY(_requiredPackages RequiredPackages)
  CMS_GET_PROPERTY(_providedPackages ProvidedPackages)
  list (REMOVE_DUPLICATES _requiredPackages)

  if (_providedPackages)
    list (REMOVE_ITEM _requiredPackages "${_providedPackages}")
  endif ()

  CMS_SET_PROPERTY(RequiredPackages "${_requiredPackages}")

  CMS_GET_PROPERTY(_requiredVariables RequiredVariables)
  list (REMOVE_DUPLICATES _requiredVariables)
  CMS_SET_PROPERTY(RequiredVariables "${_requiredVariables}")
endfunction ()

function (CMS_QUALIFY_NAMESPACE _qname _name)
  CMS_RETURN(_qname CMSUser::\${_name})
endfunction ()

function (CMS_DEFINE_NAMESPACE _name)
  CMS_ASSERT_IDENTIFIER(${_name})
  get_directory_property (_parent CMS::Scope::This)

  if (_parent)
    CMS_QUALIFY_NAMESPACE(_qname "${_name}")
    set_directory_properties (PROPERTIES CMS::Scope::This "${_qname}")
    CMS_DEFINE_COMMON_PROPERTIES()
    CMS_SET_PROPERTY(Parent "${_parent}")
    CMS_SET_PROPERTY(Type "${CMS_SCOPE_TYPE}")
  endif ()
endfunction ()

function (CMS_INHERIT_PROPERTY _key)
  CMS_GET_PROPERTY(_parent Parent)

  if (_parent)
    CMS_GET_QNAME_PROPERTY(_value "${_parent}::${_key}")

    if (_value)
      CMS_SET_PROPERTY("${_key}" "${_value}")
    endif ()
  endif ()
endfunction ()

function (CMS_APPEND_TO_PARENT_PROPERTY _key)
  if (ARGN)
    CMS_GET_PROPERTY(_parent Parent)

    if (_parent)
      CMS_APPEND_TO_QNAME_PROPERTY("${_parent}::${_key}" "${ARGN}")
    endif ()
  else ()
    message (FATAL_ERROR "At least one argument must be specified.")
  endif ()
endfunction ()

function (CMS_PROPAGATE_PROPERTY _key)
  CMS_GET_PROPERTY(_value "${_key}")

  if (_value)
    CMS_APPEND_TO_PARENT_PROPERTY("${_key}" "${_value}")
  endif ()
endfunction ()

function (CMS_SKIP_SCOPE)
  get_directory_property (_skip CMS::Scope::SkipOver)

  if (CMS_SCOPE_CALL STREQUAL "BEGIN" AND _skip EQUAL 0)
    set_directory_properties (PROPERTIES
                              CMS::Scope::SkipOver 1
                              CMS::Scope::This "")
  else ()
    message (FATAL_ERROR "CMS_SKIP_SCOPE call is allowed only in scope entry.")
  endif ()
endfunction ()

function (CMS_BEGIN CMS_SCOPE_TYPE)
  get_directory_property (_this CMS::Scope::This)
  CMS_STACK_PUSH("${_this}")

  get_directory_property (_skip CMS::Scope::SkipOver)

  if (_skip EQUAL 0)
    set (CMS_SCOPE_CALL BEGIN)
    include ("${CMS_PRIVATE_DIR}/Scopes/${CMS_SCOPE_TYPE}.cmake")
  else ()
    math (EXPR _skip "${_skip} + 1")
    set_directory_properties (PROPERTIES CMS::Scope::SkipOver "${_skip}")
  endif ()

  CMS_STACK_PUSH("${CMS_SCOPE_TYPE}")
endfunction ()

function (CMS_END)
  CMS_STACK_POP(CMS_SCOPE_TYPE)

  get_directory_property (_skip CMS::Scope::SkipOver)

  if (_skip EQUAL 0)
    set (CMS_SCOPE_CALL END)
    include ("${CMS_PRIVATE_DIR}/Scopes/${CMS_SCOPE_TYPE}.cmake")
  else ()
    math (EXPR _skip "${_skip} - 1")
    set_directory_properties (PROPERTIES CMS::Scope::SkipOver "${_skip}")
  endif()

  CMS_STACK_POP(_this)
  set_directory_properties (PROPERTIES CMS::Scope::This "${_this}")
endfunction ()

# Here starts the global initialization.

set (CMS_SCOPE_CALL INIT)
file (GLOB _scopes "${CMS_PRIVATE_DIR}/Scopes/*.cmake")

foreach (_scope IN LISTS _scopes)
  include ("${_scope}")
endforeach ()

CMS_DEFINE_CMAKE_PROPERTY(GLOBAL PROPERTY CMS::Scope)
CMS_DEFINE_CMAKE_PROPERTY(DIRECTORY PROPERTY CMS::Scope::Stack)
CMS_DEFINE_CMAKE_PROPERTY(DIRECTORY PROPERTY CMS::Scope::This INHERITED)
CMS_DEFINE_CMAKE_PROPERTY(DIRECTORY PROPERTY CMS::Scope::SkipOver INHERITED)

set_property (GLOBAL PROPERTY CMS::Scope::This CMSRoot)
set_property (GLOBAL PROPERTY CMS::Scope::SkipOver 0)

CMS_DEFINE_COMMON_PROPERTIES()
CMS_SET_PROPERTY(Type None)
