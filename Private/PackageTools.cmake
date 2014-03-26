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

macro (CMS_REPLACE_MODULE_DIRS _prefix _old_include _old_lib)
  list (REMOVE_ITEM ${_prefix}_INCLUDE_DIRS ${_old_include})
  list (REMOVE_ITEM ${_prefix}_LIBRARY_DIRS ${_old_lib})

  list (APPEND ${_prefix}_INCLUDE_DIRS "${${_prefix}_INCLUDE_DIR}")
  list (APPEND ${_prefix}_LIBRARY_DIRS "${${_prefix}_LIBRARY_DIR}")
endmacro ()

macro (CMS_PROMOTE_MODULE_DIRS _prefix)
  CMS_PROMOTE_TO_GLOBAL(${_prefix}_INCLUDE_DIRS)
  CMS_PROMOTE_TO_GLOBAL(${_prefix}_LIBRARY_DIRS)
endmacro ()

function (CMS_CONVERT_PACKAGE_DIRS _prefix _pc_prefix)
  # Workaround against the issue where paths with spaces becomes lists.
  CMS_JOIN(_include " " ${${_pc_prefix}_INCLUDEDIR})
  CMS_JOIN(_lib " " ${${_pc_prefix}_LIBDIR})

  set (${_prefix}_INCLUDE_DIR "${_include}"
       CACHE PATH "Where the library headers are placed.")
  set (${_prefix}_LIBRARY_DIR "${_lib}"
       CACHE PATH "Where the library binaries are placed.")
  mark_as_advanced (${_prefix}_INCLUDE_DIR
                    ${_prefix}_LIBRARY_DIR)

  set (${_prefix}_INCLUDE_DIRS "${${_pc_prefix}_INCLUDE_DIRS}")
  set (${_prefix}_LIBRARY_DIRS "${${_pc_prefix}_LIBRARY_DIRS}")
  CMS_REPLACE_MODULE_DIRS(${_prefix}
                          "${${_pc_prefix}_INCLUDEDIR}"
                          "${${_pc_prefix}_LIBDIR}")
  CMS_PROMOTE_MODULE_DIRS(${_prefix})
endfunction ()

function (CMS_FIND_PACKAGE _prefix _package)
  CMS_ASSIGN_PACKAGE(${_prefix} "${_package}")
  PKG_CHECK_MODULES(_cms_pc_${_prefix} "${_package}")

  if (${_cms_pc_${_prefix}_FOUND})
    set (${_prefix}_VERSION_STRING "${_cms_pc_${_prefix}_VERSION}"
         PARENT_SCOPE)
    set (${_prefix}_FOUND true
         PARENT_SCOPE)
    CMS_CONVERT_PACKAGE_DIRS(${_prefix} _cms_pc_${_prefix})
  endif ()
endfunction ()
