# Copyright (c) 2014 Flokart World, Inc.
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
# THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.

macro (CMS_WARN_UNSET_ENV _name)
  set (_env_${_name} "$ENV{${_name}}")

  if (NOT _env_${_name})
    message (WARNING "${_name} environment is not set.")
  endif ()

  unset (_env_${_name})
endmacro ()

macro (CMS_REINIT_CACHE _name _value _type _desc)
  if (NOT CMS_REINIT_${_name})
    set (${_name} "${_value}" CACHE ${_type} "${_desc}" FORCE)
    set (CMS_REINIT_${_name} true CACHE INTERNAL "")
  endif ()
endmacro ()

macro (CMS_INSTALL_MODULE _name)
  set (_var CMS_MODULE_${_name})
  set (_filename "Find${_name}.cmake")
  find_file (${_var} ${_filename}
             PATHS "${CMAKE_CURRENT_SOURCE_DIR}"
                   "${CMAKE_CURRENT_SOURCE_DIR}/cmake"
             NO_DEFAULT_PATH)
  mark_as_advanced (${_var})

  if (NOT ${_var})
    message (FATAL_ERROR "${_filename} not found!")
  endif ()

  install (FILES "${${_var}}" DESTINATION "${CMS_MODULE_DIR}")
endmacro ()

macro (CMS_INSTALL_DOTPC _name)
  set (_var CMS_DOTPC_${_name})
  set (_filename "${_name}.pc.in")
  find_file (${_var} ${_filename} PATHS "${CMAKE_CURRENT_SOURCE_DIR}"
             NO_DEFAULT_PATH)
  mark_as_advanced (${_var})

  if (NOT ${_var})
    message (FATAL_ERROR "${_filename} not found!")
  endif ()

  set (_dotpc "${PROJECT_BINARY_DIR}/${_name}.pc")
  configure_file (${${_var}} "${_dotpc}" @ONLY)
  install (FILES "${_dotpc}" DESTINATION "${CMS_DOTPC_DIR}")
endmacro ()

macro (CMS_FIND_PACKAGE _varname _libname)
  PKG_CHECK_MODULES(_pc_${_varname} ${_libname})

  if (${_pc_${_varname}_FOUND})
    set (${_varname}_INCLUDE_DIRS ${_pc_${_varname}_INCLUDE_DIRS})
    set (${_varname}_LIBRARY_DIRS ${_pc_${_varname}_LIBRARY_DIRS})
    set (${_varname}_FOUND true)
  endif ()
endmacro ()

# Here starts the initialization.

find_package (PkgConfig REQUIRED)

set (CMS_BASE_DIR "${CMAKE_CURRENT_LIST_DIR}")
set (CMS_PRIVATE_DIR "${CMS_BASE_DIR}/Private")
set (CMS_INSTALL_DIR "${CMS_BASE_DIR}/Installed")
set (CMS_MODULE_DIR "${CMS_INSTALL_DIR}/Modules")
set (CMS_DOTPC_DIR "${CMS_INSTALL_DIR}/DotPCFiles")
set (CMS_INSTALL_PREFIX "$ENV{CMS_INSTALL_PREFIX}")

list (APPEND CMAKE_MODULE_PATH "${CMS_BASE_DIR}/Modules")
list (APPEND CMAKE_MODULE_PATH "${CMS_MODULE_DIR}")

CMS_WARN_UNSET_ENV("PKG_CONFIG_PATH")

if (CMS_INSTALL_PREFIX)
  CMS_REINIT_CACHE(CMAKE_INSTALL_PREFIX
                   "${CMS_INSTALL_PREFIX}/${CMAKE_PROJECT_NAME}" PATH
                   "Install path prefix, prepended onto install directories.")
endif ()

# TODO : Rename it to CMS_TOOLSET_SUFFIX_CXX
if (NOT CXX_TOOLSET_SUFFIX)
  include ("${CMS_PRIVATE_DIR}/SetToolsetSuffixCxx.cmake")
endif ()

include ("${CMS_PRIVATE_DIR}/PrecompiledHeaderCxx.cmake")
