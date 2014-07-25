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

cmake_minimum_required (VERSION 3.0.0)

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

function (CMS_NEW_OBJECT _ret)
  math (EXPR _next "${CMS_NEXT_OBJECT} + 1")
  set (${_ret} CMS_OBJECT_${CMS_NEXT_OBJECT} PARENT_SCOPE)
  set (CMS_NEXT_OBJECT ${_next} CACHE INTERNAL "" FORCE)
endfunction ()

##
# class Set
#

function (CMS_SET_CONTAINS _ret _set _value)
  list (FIND ${_set} "${_value}" _index)

  if (_index LESS 0)
    set (${_ret} false PARENT_SCOPE)
  else ()
    set (${_ret} true PARENT_SCOPE)
  endif ()
endfunction ()

function (CMS_SET_ADD _set _value)
  CMS_SET_CONTAINS(_exists ${_set} "${_value}")

  if (NOT _exists)
    list (APPEND ${_set} "${_value}")
    CMS_PROMOTE_TO_PARENT_SCOPE(${_set})
  endif ()
endfunction ()

function (CMS_SET_REMOVE _set _value)
  list (REMOVE_ITEM ${_set} "${_value}")
  CMS_PROMOTE_TO_PARENT_SCOPE(${_set})
endfunction ()

##
# class Map
#

macro (CMS_MAP_PROMOTE_TO_PARENT_SCOPE _map)
  CMS_PROMOTE_TO_PARENT_SCOPE(${_map}_KEYS)
  CMS_PROMOTE_TO_PARENT_SCOPE(${_map}_VALUES)
endmacro ()

function (CMS_MAP_CLEAR _map)
  unset (${_map}_KEYS)
  unset (${_map}_VALUES)
  CMS_MAP_PROMOTE_TO_PARENT_SCOPE(${_map})
endfunction ()

function (CMS_MAP_CONTAINS_KEY _ret _map _key)
  list (FIND ${_map}_KEYS "${_key}" _index)

  if (_index LESS 0)
    set (${_ret} false PARENT_SCOPE)
  else ()
    set (${_ret} true PARENT_SCOPE)
  endif ()
endfunction ()

function (CMS_MAP_GET _ret _map _key)
  list (FIND ${_map}_KEYS "${_key}" _index)

  if (_index LESS 0)
    set (${_ret} NOTFOUND PARENT_SCOPE)
  else ()
    list (GET ${_map}_VALUES ${_index} ${_ret})
    CMS_PROMOTE_TO_PARENT_SCOPE(${_ret})
  endif ()
endfunction ()

function (CMS_MAP_PUT _map _key _value)
  list (FIND ${_map}_KEYS "${_key}" _index)

  if (_index LESS 0)
    list (APPEND ${_map}_KEYS "${_key}")
    list (APPEND ${_map}_VALUES "${_value}")
  else ()
    list (INSERT ${_map}_VALUES ${_index} "${_value}")
    math (EXPR _index "${_index} + 1")
    list (REMOVE_AT ${_map}_VALUES ${_index})
  endif ()

  CMS_MAP_PROMOTE_TO_PARENT_SCOPE(${_map})
endfunction ()

function (CMS_MAP_REMOVE _map _key)
  list (FIND ${_map}_KEYS "${_key}" _index)

  if (NOT (_index LESS 0))
    list (REMOVE_AT ${_map}_KEYS ${_index})
    list (REMOVE_AT ${_map}_VALUES ${_index})
    CMS_MAP_PROMOTE_TO_PARENT_SCOPE(${_map})
  endif ()
endfunction ()

##
# class ObjectMap
#

macro (CMS_OBJMAP_PROMOTE_TO_PARENT_SCOPE _map)
  CMS_MAP_PROMOTE_TO_PARENT_SCOPE(${_map})

  foreach (_obj IN LISTS ${_map}_VALUES)
    CMS_PROMOTE_TO_PARENT_SCOPE(${_obj})
  endforeach ()
endmacro ()

function (CMS_OBJMAP_GET _ret _map _key)
  CMS_MAP_GET(${_ret} ${_map} "${_key}")

  if (NOT ${_ret})
    CMS_NEW_OBJECT(${_ret})
    CMS_PROMOTE_TO_PARENT_SCOPE(${${_ret}})

    CMS_MAP_PUT(${_map} "${_key}" ${${_ret}})
    CMS_MAP_PROMOTE_TO_PARENT_SCOPE(${_map})
  endif ()

  CMS_PROMOTE_TO_PARENT_SCOPE(${_ret})
endfunction ()

##
# End of classes
#

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

# Here starts the global initialization.

function (CMS_INIT_GLOBAL)
  get_property (_initialized DIRECTORY PROPERTY CMS::Initialized DEFINED)

  if (NOT _initialized)
    set (CMS_MODIFIED ""
         CACHE STRING "Cache variables that have been modified by CMS.")
    mark_as_advanced (CMS_MODIFIED)

    include ("${CMS_PRIVATE_DIR}/Compiler.cmake")
    include ("${CMS_PRIVATE_DIR}/Executable.cmake")
    include ("${CMS_PRIVATE_DIR}/Library.cmake")
    include ("${CMS_PRIVATE_DIR}/Package.cmake")
    include ("${CMS_PRIVATE_DIR}/PackageTools.cmake")
    include ("${CMS_PRIVATE_DIR}/PrecompiledHeaderCxx.cmake")
    include ("${CMS_PRIVATE_DIR}/Scope.cmake")
    include ("${CMS_PRIVATE_DIR}/SetToolsetSuffixCxx.cmake")
    include ("${CMS_PRIVATE_DIR}/SourceFilePropertyMap.cmake")
    include ("${CMS_PRIVATE_DIR}/SourceGroupMap.cmake")
    include ("${CMS_PRIVATE_DIR}/Target.cmake")

    CMS_WARN_UNSET_ENV("PKG_CONFIG_PATH")

    if (CMS_INSTALL_PREFIX)
      CMS_REINIT_CACHE(CMAKE_INSTALL_PREFIX
                       "${CMS_INSTALL_PREFIX}/${CMAKE_PROJECT_NAME}")
    endif ()

    CMS_DEFINE_CMAKE_PROPERTY(DIRECTORY PROPERTY CMS::Initialized INHERITED)
  endif ()
endfunction ()

function (CMS_INIT_DIRECTORY)
  get_property (_initialized DIRECTORY PROPERTY CMS::Initialized SET)

  if (NOT _initialized)
    list (APPEND CMAKE_MODULE_PATH
          "${CMS_BASE_DIR}/Modules"
          "${CMS_MODULE_DIR}")
    CMS_PROMOTE_TO_PARENT_SCOPE(CMAKE_MODULE_PATH)

    add_library (CMSVariables INTERFACE IMPORTED)
    set_directory_properties (PROPERTIES CMS::Initialized true)
  endif ()
endfunction ()

set (CMS_BASE_DIR "${CMAKE_CURRENT_LIST_DIR}")
set (CMS_PRIVATE_DIR "${CMS_BASE_DIR}/Private")
set (CMS_INSTALL_DIR "${CMS_BASE_DIR}/Installed")
set (CMS_MODULE_DIR "${CMS_INSTALL_DIR}/Modules")
set (CMS_INSTALL_PREFIX "$ENV{CMS_INSTALL_PREFIX}")

if (NOT CMS_MEMORY_INITIALIZED)
  set (CMS_NEXT_OBJECT 0 CACHE INTERNAL "" FORCE)
  set (CMS_MEMORY_INITIALIZED true)
endif ()

set (CMAKE_WARN_DEPRECATED true)
find_package (PkgConfig REQUIRED)

CMS_INIT_GLOBAL()
CMS_INIT_DIRECTORY()

# Here starts the project initialization.

unset (CMS_ADDITIONAL_FILES)

include ("${CMS_PRIVATE_DIR}/ModuleBuilder.cmake")
include ("${CMS_PRIVATE_DIR}/ModuleFinder.cmake")
