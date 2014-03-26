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
#    3. This notice may not be removed or altered from any source
#    distribution.

function (CMS_ASSIGN_PACKAGE _prefix _package)
  set (${_prefix}_PACKAGE "${_package}" CACHE STRING "" FORCE)
  mark_as_advanced (${_prefix}_PACKAGE)
endfunction ()

macro (CMS_APPEND_PREFIX _prefix)
  list (APPEND CMS_IMPORTED_PREFIXES ${_prefix})
endmacro ()

function (CMS_PARSE_MODULE_ARGN _var_prefix _prefix)
  set (_module ${_prefix})
  set (_package ${_prefix})

  while (ARGN)
    list (GET ARGN 0 _first)

    if (_first STREQUAL "NAME")
      list (REMOVE_AT ARGN 0)

      if (NOT ARGN)
        message (FATAL_ERROR "Module name must be specified after NAME.")
      endif ()

      list (GET ARGN 0 _module)
      list (REMOVE_AT ARGN 0)
    elseif (_first STREQUAL "PACKAGE")
      list (REMOVE_AT ARGN 0)

      if (NOT ARGN)
        message (FATAL_ERROR
                 "Module package name must be specified after PACKAGE.")
      endif ()

      list (GET ARGN 0 _package)
      list (REMOVE_AT ARGN 0)
    elseif (_first STREQUAL "PASS")
      list (REMOVE_AT ARGN 0)
      break ()
    else ()
      break ()
    endif ()
  endwhile ()

  set (${_var_prefix}_module ${_module} PARENT_SCOPE)
  set (${_var_prefix}_package ${_package} PARENT_SCOPE)
  set (${_var_prefix}_reminder "${ARGN}" PARENT_SCOPE)
endfunction ()

macro (CMS_IMPORT_MODULE _prefix)
  CMS_PARSE_MODULE_ARGN(_cms_arg ${_prefix} "${ARGN}")

  if (NOT ${_prefix}_PACKAGE)
    CMS_ASSIGN_PACKAGE(${_prefix} ${_cms_arg_package})
  endif ()

  if (NOT ${_prefix}_FOUND)
    find_package (${_cms_arg_module} ${_cms_arg_reminder})
  endif ()

  if (${_prefix}_FOUND)
    CMS_APPEND_PREFIX(${_prefix})
  endif ()

  unset (_cms_arg_module)
  unset (_cms_arg_package)
  unset (_cms_arg_reminder)
endmacro ()

function (CMS_PREPARE_BUILD_OPTION _prefix _directory)
  set (_msg "Set true to build ${_directory} instead of installed one.")

  if (${_prefix}_FOUND)
    set (BUILD_${_prefix} false CACHE BOOL "${_msg}")
  else ()
    set (BUILD_${_prefix} true CACHE BOOL "${_msg}" FORCE)
  endif ()
endfunction ()

function (CMS_DIVIDE_FIND_PACKAGE_ARGS _version _after)
  unset (_before)
  unset (_stops)

  set (_stops
       MODULE
       COMPONENTS
       OPTIONAL_COMPONENTS
       NO_POLICY_SCOPE
       CONFIG
       NO_MODULE
       NO_POLICY_SCOPE
       NAMES
       CONFIGS
       HINTS
       PATHS
       PATH_SUFFIXES
       NO_DEFAULT_PATH
       NO_CMAKE_ENVIRONMENT_PATH
       NO_CMAKE_PATH
       NO_SYSTEM_ENVIRONMENT_PATH
       NO_CMAKE_PACKAGE_REGISTRY
       NO_CMAKE_BUILDS_PATH
       NO_CMAKE_SYSTEM_PATH
       NO_CMAKE_SYSTEM_PACKAGE_REGISTRY
       CMAKE_FIND_ROOT_PATH_BOTH
       ONLY_CMAKE_FIND_ROOT_PATH
       NO_CMAKE_FIND_ROOT_PATH)

  while (ARGN)
    list (GET ARGN 0 _first)

    if (_first STREQUAL "QUIET" OR _first STREQUAL "REQUIRED")
      message (FATAL_ERROR "${_first} must not be specified.")
    elseif (_first STREQUAL "PASS")
      list (REMOVE_AT ARGN 0)
      break ()
    else ()
      list (FIND _stops "${_first}" _shift)

      if (_shift LESS 0)
        list (APPEND _before "${_first}")
        list (REMOVE_AT ARGN 0)
      else ()
        break ()
      endif ()
    endif ()
  endwhile ()

  set (${_version} "${_before}" PARENT_SCOPE)
  set (${_after} "${ARGN}" PARENT_SCOPE)
endfunction ()

macro (CMS_IMPORT_BUNDLED_MODULE _prefix _directory)
  CMS_DIVIDE_FIND_PACKAGE_ARGS(_cms_module _cms_argn ${ARGN})

  if (NOT BUILD_${_prefix})
    CMS_IMPORT_MODULE(${_prefix} ${_cms_module} QUIET ${_cms_argn})
  endif ()

  CMS_PREPARE_BUILD_OPTION("${_prefix}" "${_directory}")

  if (BUILD_${_prefix})
    add_subdirectory ("${_directory}")
    set (${_prefix}_FOUND true)

    CMS_APPEND_PREFIX(${_prefix})
  endif ()
endmacro ()

macro (CMS_PROJECT_VAR_PREFIX _prefix)
  set (CMS_CURRENT_PREFIX "${_prefix}")
endmacro ()

macro (CMS_CHECK_PREFIX)
  if (NOT CMS_CURRENT_PREFIX)
    message (FATAL_ERROR "Variable prefix is not set.")
  endif ()
endmacro ()

macro (CMS_RESOLVE_DEPENDENCIES)
  CMS_CHECK_PREFIX()
  unset (${CMS_CURRENT_PREFIX}_INCLUDE_DIRS)
  unset (${CMS_CURRENT_PREFIX}_LIBRARY_DIRS)

  foreach (_prefix IN LISTS CMS_IMPORTED_PREFIXES)
    list (APPEND ${CMS_CURRENT_PREFIX}_INCLUDE_DIRS
                 "${${_prefix}_INCLUDE_DIRS}")
    list (APPEND ${CMS_CURRENT_PREFIX}_LIBRARY_DIRS
                 "${${_prefix}_LIBRARY_DIRS}")
    list (REMOVE_DUPLICATES ${CMS_CURRENT_PREFIX}_INCLUDE_DIRS)
    list (REMOVE_DUPLICATES ${CMS_CURRENT_PREFIX}_LIBRARY_DIRS)
  endforeach ()
endmacro ()

# Each project shouldn't inherit the parent's settings.
unset (CMS_CURRENT_PREFIX)
unset (CMS_IMPORTED_PREFIXES)
