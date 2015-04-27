# Copyright (c) 2014-2015 Flokart World, Inc.
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

include (FindPackageHandleStandardArgs)

macro (CMS_REPLACE_MODULE_DIRS _prefix _old_include _old_lib)
  list (REMOVE_ITEM ${_prefix}_INCLUDE_DIRS "${_old_include}")
  list (INSERT ${_prefix}_INCLUDE_DIRS 0 "${${_prefix}_INCLUDE_DIR}")

  if (${_prefix}_LIBRARY_DIRS)
    list (REMOVE_ITEM ${_prefix}_LIBRARY_DIRS "${_old_lib}")
    list (INSERT ${_prefix}_LIBRARY_DIRS 0 "${${_prefix}_LIBRARY_DIR}")
  endif ()
endmacro ()

macro (CMS_PROMOTE_MODULE_DEFS _prefix)
  CMS_PROMOTE_TO_GLOBAL(${_prefix}_INCLUDE_DIRS)
  CMS_PROMOTE_TO_GLOBAL(${_prefix}_LIBRARIES)

  if (${_prefix}_LIBRARY_DIRS)
    CMS_PROMOTE_TO_GLOBAL(${_prefix}_LIBRARY_DIRS)
  endif ()
endmacro ()

function (CMS_CONVERT_PACKAGE_DEFS _prefix _pc_prefix)
  # Workaround against the issue where paths with spaces becomes lists.
  CMS_JOIN(_include " " ${${_pc_prefix}_INCLUDEDIR})
  CMS_JOIN(_libdir " " ${${_pc_prefix}_LIBDIR})

  set (${_prefix}_INCLUDE_DIR "${_include}"
       CACHE PATH "Where the library headers are placed.")
  set (${_prefix}_LIBRARY_DIR "${_libdir}"
       CACHE PATH "Where the library binaries are placed.")
  mark_as_advanced (${_prefix}_INCLUDE_DIR
                    ${_prefix}_LIBRARY_DIR)

  set (${_prefix}_INCLUDE_DIRS "${${_pc_prefix}_INCLUDE_DIRS}")

  set (_libs "${${_pc_prefix}_LIBRARIES}")
  unset (_libFiles)

  foreach (_lib IN LISTS _libs)
    string (TOUPPER ${_lib} _suffix)
    set (_varName "${_prefix}_LIBRARY_${_suffix}")

    find_library (${_varName} NAMES "${_lib}"
                              HINTS ${${_pc_prefix}_LIBRARY_DIRS})
    mark_as_advanced (${_varName})

    list (APPEND _libFiles ${${_varName}})
  endforeach ()

  list (REMOVE_DUPLICATES _libFiles)
  set (${_prefix}_LIBRARIES ${_libFiles})

  CMS_REPLACE_MODULE_DIRS(${_prefix} "${_include}" "${_libdir}")
  CMS_PROMOTE_MODULE_DEFS(${_prefix})
endfunction ()

function (CMS_FIND_PACKAGE _prefix _package)
  PKG_CHECK_MODULES(_cms_pc_${_prefix} "${_package}")

  if (${_cms_pc_${_prefix}_FOUND})
    set (${_prefix}_VERSION_STRING "${_cms_pc_${_prefix}_VERSION}"
         PARENT_SCOPE)
    set (${_prefix}_FOUND true
         PARENT_SCOPE)
    CMS_CONVERT_PACKAGE_DEFS(${_prefix} _cms_pc_${_prefix})
  endif ()
endfunction ()

function (CMS_DECLARE_PROVIDED_TARGETS _package)
  foreach (_component IN LISTS ${_package}_FIND_COMPONENTS)
    if (${_package}_FIND_REQUIRED_${_component})
      list (FIND ARGN ${_component} _index)

      if (_index EQUAL -1)
        set (${_package}_FOUND false PARENT_SCOPE)
        set (${_package}_NOT_FOUND_MESSAGE
             "${_package} doesn't provide ${_component}."
             PARENT_SCOPE)
        break ()
      endif ()
    endif ()
  endforeach ()
endfunction ()

function (CMS_LOAD_CONFIG_AS_MODULE _name _path)
  set (_options "${${_name}_FIND_VERSION}")

  if (${_name}_FIND_EXACT)
    list (APPEND _options EXACT)
  endif ()

  if (${_name}_FIND_QUIETLY)
    list (APPEND _options QUIET)
  endif ()

  if (${_name}_FIND_REQUIRED)
    list (APPEND _options REQUIRED)
  endif ()

  if (${_name}_FIND_COMPONENTS)
    list (APPEND _options COMPONENTS)

    foreach (_component IN LISTS ${_name}_FIND_COMPONENTS)
      if (${_name}_FIND_REQUIRED_${_component})
        list (APPEND _options "${_component}")
      endif ()
    endforeach ()
  endif ()

  find_package ("${_name}" ${_options} CONFIG PATHS "${_path}" NO_DEFAULT_PATH)
  FIND_PACKAGE_HANDLE_STANDARD_ARGS("${_name}" CONFIG_MODE)

  CMS_PROMOTE_TO_PARENT_SCOPE(${_name}_FOUND)
endfunction ()
