# Copyright (c) 2014-2020 Flokart World, Inc.
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

if (NOT DEFINED CMS_MSVC_WARNING_STYLE)
  cmake_policy (GET CMP0092 CMS_MSVC_WARNING_STYLE)
endif ()

cmake_minimum_required (VERSION 3.16.6)

macro (CMS_RETURN _var)
  set ("${${_var}}" "${ARGN}" PARENT_SCOPE)
endmacro ()

macro (CMS_PROMOTE_TO_PARENT_SCOPE _var)
  set (${_var} "${${_var}}" PARENT_SCOPE)
endmacro ()

macro (CMS_PROMOTE_TO_GLOBAL _var)
  set (${_var} "${${_var}}" CACHE INTERNAL "" FORCE)
endmacro ()

function (CMS_ASSERT_IDENTIFIER)
  list (LENGTH ARGN _size)

  if (NOT _size EQUAL 1)
    message (FATAL_ERROR "${ARGN} was given as an identifier.")
  endif ()
endfunction ()

function (CMS_DEFINE_CMAKE_PROPERTY)
  define_property (${ARGN} BRIEF_DOCS "Used by CMS" FULL_DOCS "Used by CMS")
endfunction ()

function (CMS_ENSURE_CMAKE_PROPERTY)
  get_property (_defined ${ARGN} DEFINED)

  if (NOT _defined)
    CMS_DEFINE_CMAKE_PROPERTY(${ARGN})
  endif ()
endfunction ()

function (CMS_JOIN _ret _separator)
  set (_string "")

  while (ARGN)
    list (GET ARGN 0 _part)
    list (REMOVE_AT ARGN 0)

    if (_string STREQUAL "")
      set (_string "${_part}")
    else ()
      set (_string "${_string}${_separator}${_part}")
    endif ()
  endwhile ()

  set (${_ret} "${_string}" PARENT_SCOPE)
endfunction ()

function (CMS_WARN_UNSET_ENV _name)
  set (_env "$ENV{${_name}}")

  if (NOT _env)
    message (WARNING "${_name} environment is not set.")
  endif ()
endfunction ()

function (CMS_MODIFY_CACHE _name)
  get_property (_defined CACHE "${_name}" PROPERTY HELPSTRING SET)

  if (_defined)
    set_property (CACHE "${_name}" PROPERTY VALUE "${ARGN}")
  else ()
    message (FATAL_ERROR "Cache variable ${_name} is not defined.")
  endif ()
endfunction ()

function (CMS_REINIT_CACHE _name)
  get_property (_defined CACHE "${_name}" PROPERTY HELPSTRING SET)

  if (_defined)
    list (FIND CMS_MODIFIED "${_name}" _index)

    if (NOT _index EQUAL -1)
      return ()
    endif ()

    CMS_MODIFY_CACHE("${_name}" "${ARGN}")
  else ()
    set ("${_name}" "${ARGN}" CACHE STRING "")
  endif ()

  set_property (CACHE CMS_MODIFIED APPEND PROPERTY VALUE "${_name}")
endfunction ()

function (CMS_WRITE_FILE _filename)
  CMS_JOIN(_newContent "" ${ARGN})

  if (EXISTS "${_filename}")
    file (READ "${_filename}" _oldContent)

    if (_newContent STREQUAL _oldContent)
      return ()
    endif ()
  endif ()

  file (WRITE "${_filename}" "${_newContent}")
endfunction ()

# Here starts the global initialization.

function (CMS_INIT_GLOBAL)
  mark_as_advanced (CMakeSupports_DIR)
  get_property (_initialized DIRECTORY PROPERTY CMS::Initialized DEFINED)

  if (NOT _initialized)
    set (CMS_MODIFIED ""
         CACHE STRING "Cache variables that have been modified by CMS.")
    mark_as_advanced (CMS_MODIFIED)

    include ("${CMS_PRIVATE_DIR}/Configuration.cmake")
    include ("${CMS_PRIVATE_DIR}/Executable.cmake")
    include ("${CMS_PRIVATE_DIR}/Library.cmake")
    include ("${CMS_PRIVATE_DIR}/Package.cmake")
    include ("${CMS_PRIVATE_DIR}/PackageTools.cmake")
    include ("${CMS_PRIVATE_DIR}/PrecompiledHeaderCxx.cmake")
    include ("${CMS_PRIVATE_DIR}/Scope.cmake")
    include ("${CMS_PRIVATE_DIR}/SetToolsetSuffixCxx.cmake")
    include ("${CMS_PRIVATE_DIR}/Target.cmake")

    if (PKG_CONFIG_FOUND)
      CMS_WARN_UNSET_ENV("PKG_CONFIG_PATH")
    endif ()

    if (CMS_INSTALL_PREFIX AND CMAKE_INSTALL_PREFIX_INITIALIZED_TO_DEFAULT)
      CMS_REINIT_CACHE(CMAKE_INSTALL_PREFIX
                       "${CMS_INSTALL_PREFIX}/${CMAKE_PROJECT_NAME}")
    endif ()

    CMS_DEFINE_CMAKE_PROPERTY(DIRECTORY PROPERTY CMS::Initialized INHERITED)
    CMS_DEFINE_CMAKE_PROPERTY(DIRECTORY PROPERTY CMS::FindVersion INHERITED)
  endif ()
endfunction ()

function (CMS_INIT_DIRECTORY)
  get_property (_initialized DIRECTORY PROPERTY CMS::Initialized SET)

  if (NOT _initialized)
    list (APPEND CMAKE_MODULE_PATH
          "${CMS_BASE_DIR}/Modules"
          "${CMS_MODULE_DIR}"
          ${CMS_MODULE_PATH}
          $ENV{CMS_MODULE_PATH})
    CMS_PROMOTE_TO_PARENT_SCOPE(CMAKE_MODULE_PATH)

    add_library (CMSVariables UNKNOWN IMPORTED)
    set_directory_properties (PROPERTIES CMS::Initialized true)
  endif ()

  set_directory_properties (PROPERTIES
                            CMS::FindVersion ${CMakeSupports_FIND_VERSION})
endfunction ()

set (CMS_BASE_DIR "${CMAKE_CURRENT_LIST_DIR}")
set (CMS_PRIVATE_DIR "${CMS_BASE_DIR}/Private")
set (CMS_INSTALL_DIR "${CMS_BASE_DIR}/Installed")
set (CMS_MODULE_DIR "${CMS_INSTALL_DIR}/Modules")
set (CMS_PYLIB_DIR "${CMS_BASE_DIR}/Tools/pylib")

if (NOT CMS_GLOBAL_LIST_FILE)
  set (CMS_GLOBAL_LIST_FILE "$ENV{CMS_GLOBAL_LIST_FILE}")
endif ()

include ("${CMS_PRIVATE_DIR}/Compiler.cmake")

if (CMS_GLOBAL_LIST_FILE)
  include ("${CMS_GLOBAL_LIST_FILE}")
endif ()

if (NOT CMS_INSTALL_PREFIX)
  set (CMS_INSTALL_PREFIX "$ENV{CMS_INSTALL_PREFIX}")
endif ()

set (CMAKE_WARN_DEPRECATED true)
find_package (PkgConfig)

CMS_INIT_GLOBAL()
CMS_INIT_DIRECTORY()
