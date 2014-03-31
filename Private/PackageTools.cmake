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

  list (INSERT ${_prefix}_INCLUDE_DIRS 0 "${${_prefix}_INCLUDE_DIR}")
  list (INSERT ${_prefix}_LIBRARY_DIRS 0 "${${_prefix}_LIBRARY_DIR}")
endmacro ()

macro (CMS_PROMOTE_MODULE_DEFS _prefix)
  CMS_PROMOTE_TO_GLOBAL(${_prefix}_INCLUDE_DIRS)
  CMS_PROMOTE_TO_GLOBAL(${_prefix}_LIBRARY_DIRS)
  CMS_PROMOTE_TO_GLOBAL(${_prefix}_LIBRARIES)
endmacro ()

function (CMS_CONVERT_PACKAGE_DEFS _prefix _pc_prefix)
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
  set (${_prefix}_LIBRARIES "${${_pc_prefix}_LIBRARIES}")
  CMS_REPLACE_MODULE_DIRS(${_prefix} "${_include}" "${_lib}")
  CMS_PROMOTE_MODULE_DEFS(${_prefix})
endfunction ()

function (CMS_FIND_PACKAGE _prefix _package)
  CMS_ASSIGN_PACKAGE(${_prefix} "${_package}")
  PKG_CHECK_MODULES(_cms_pc_${_prefix} "${_package}")

  if (${_cms_pc_${_prefix}_FOUND})
    set (${_prefix}_VERSION_STRING "${_cms_pc_${_prefix}_VERSION}"
         PARENT_SCOPE)
    set (${_prefix}_FOUND true
         PARENT_SCOPE)
    CMS_CONVERT_PACKAGE_DEFS(${_prefix} _cms_pc_${_prefix})
  endif ()
endfunction ()

function (_CMS_CHECK_PACKAGE)
  if (NOT CMS_PACKAGE_DIR)
    message (FATAL_ERROR "Not in a package scope.")
  endif ()
endfunction ()

function (_CMS_CHECK_PACKAGE_PREFIX)
  if (NOT CMS_PACKAGE_PREFIX)
    message (FATAL_ERROR "Call CMS_SET_PACKAGE_PREFIX first.")
  endif ()
endfunction ()

function (CMS_BEGIN_PACKAGE _directory)
  # CMS_BEGIN_PACKAGE may be nested within CMS_IMPORT_MODULE.
  list (INSERT CMS_PACKAGE_STACK 0 "${CMS_PACKAGE_DIR}"
                                   "${CMS_PACKAGE_PREFIX}"
                                   "${CMS_PACKAGE_DEPENDENCY}")
  CMS_PROMOTE_TO_PARENT_SCOPE(CMS_PACKAGE_STACK)

  set (CMS_PACKAGE_DIR "${_directory}" PARENT_SCOPE)
  set (CMS_PACKAGE_PREFIX "" PARENT_SCOPE)
  CMS_NEW_OBJECT(CMS_PACKAGE_DEPENDENCY)
  CMS_PROMOTE_TO_PARENT_SCOPE(CMS_PACKAGE_DEPENDENCY)
endfunction ()

function (CMS_SET_PACKAGE_PREFIX _prefix)
  _CMS_CHECK_PACKAGE()
  set (CMS_PACKAGE_PREFIX "${_prefix}" PARENT_SCOPE)
endfunction ()

function (CMS_SET_PACKAGE_VERSION _version)
  _CMS_CHECK_PACKAGE()
  _CMS_CHECK_PACKAGE_PREFIX()
  set (${CMS_PACKAGE_PREFIX}_VERSION_STRING "${_version}" PARENT_SCOPE)
endfunction ()

function (CMS_SET_PACKAGE_DEPENDENCY)
  _CMS_CHECK_PACKAGE()

  while (ARGN)
    list (GET ARGN 0 _prefix)
    list (GET ARGN 1 _package)
    list (REMOVE_AT ARGN 0 1)
    CMS_IMPORT_MODULE(${_prefix} NAME ${_package})
    CMS_SET_ADD(${CMS_PACKAGE_DEPENDENCY} ${_prefix})
  endwhile ()

  CMS_PROMOTE_TO_PARENT_SCOPE(${CMS_PACKAGE_DEPENDENCY})
endfunction ()

function (CMS_SET_PACKAGE_COMPONENTS)
  _CMS_CHECK_PACKAGE()

  while (ARGN)
    list (GET ARGN 0 _component)
    list (GET ARGN 1 _library)
    list (REMOVE_AT ARGN 0 1)
    CMS_MAP_PUT(CMS_IMPORTED_COMPONENTS "${_component}" "${_library}")
  endwhile ()

  CMS_MAP_PROMOTE_TO_PARENT_SCOPE(CMS_IMPORTED_COMPONENTS)
endfunction ()

function (CMS_END_PACKAGE)
  _CMS_CHECK_PACKAGE()
  _CMS_CHECK_PACKAGE_PREFIX()

  unset (${CMS_PACKAGE_PREFIX}_INCLUDE_DIRS CACHE)
  unset (${CMS_PACKAGE_PREFIX}_LIBRARY_DIRS CACHE)

  set (${CMS_PACKAGE_PREFIX}_INCLUDE_DIR "${CMS_PACKAGE_DIR}/include"
       CACHE PATH "Where the ${CMS_PACKAGE_PREFIX} headers are placed.")
  set (${CMS_PACKAGE_PREFIX}_LIBRARY_DIR "${CMS_PACKAGE_DIR}/lib"
       CACHE PATH "Where the ${CMS_PACKAGE_PREFIX} binaries are placed.")

  set (${CMS_PACKAGE_PREFIX}_INCLUDE_DIRS
       "${${CMS_PACKAGE_PREFIX}_INCLUDE_DIR}")
  set (${CMS_PACKAGE_PREFIX}_LIBRARY_DIRS
       "${${CMS_PACKAGE_PREFIX}_LIBRARY_DIR}")

  if (${CMS_PACKAGE_DEPENDENCY})
    foreach (_prefix IN LISTS ${CMS_PACKAGE_DEPENDENCY})
      list (APPEND ${CMS_PACKAGE_PREFIX}_INCLUDE_DIRS
                   "${${_prefix}_INCLUDE_DIRS}")
      list (APPEND ${CMS_PACKAGE_PREFIX}_LIBRARY_DIRS
                   "${${_prefix}_LIBRARY_DIRS}")
    endforeach ()
  endif ()

  list (REMOVE_DUPLICATES ${CMS_PACKAGE_PREFIX}_INCLUDE_DIRS)
  list (REMOVE_ITEM ${CMS_PACKAGE_PREFIX}_INCLUDE_DIRS "")
  list (REMOVE_DUPLICATES ${CMS_PACKAGE_PREFIX}_LIBRARY_DIRS)
  list (REMOVE_ITEM ${CMS_PACKAGE_PREFIX}_LIBRARY_DIRS "")

  CMS_PROMOTE_TO_GLOBAL(${CMS_PACKAGE_PREFIX}_INCLUDE_DIRS)
  CMS_PROMOTE_TO_GLOBAL(${CMS_PACKAGE_PREFIX}_LIBRARY_DIRS)

  set (${CMS_PACKAGE_PREFIX}_FOUND true PARENT_SCOPE)

  list (GET CMS_PACKAGE_STACK 0 CMS_PACKAGE_DIR)
  list (GET CMS_PACKAGE_STACK 1 CMS_PACKAGE_PREFIX)
  list (GET CMS_PACKAGE_STACK 2 CMS_PACKAGE_DEPENDENCY)
  CMS_PROMOTE_TO_PARENT_SCOPE(CMS_PACKAGE_DIR)
  CMS_PROMOTE_TO_PARENT_SCOPE(CMS_PACKAGE_PREFIX)
  CMS_PROMOTE_TO_PARENT_SCOPE(CMS_PACKAGE_DEPENDENCY)

  list (REMOVE_AT CMS_PACKAGE_STACK 0 1 2)
  CMS_PROMOTE_TO_PARENT_SCOPE(CMS_PACKAGE_STACK)
endfunction ()
