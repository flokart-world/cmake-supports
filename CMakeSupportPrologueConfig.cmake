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

set (CMS_DIR "${CMAKE_CURRENT_LIST_DIR}")
set (CMS_MODULE_DIR "${CMS_DIR}/Modules/Installed")
set (CMS_PACKAGE_DIR "$ENV{PKG_CONFIG_PATH}")
set (CMS_INSTALL_PREFIX "$ENV{CMAKE_INSTALL_PREFIX}")

if (NOT CMS_PACKAGE_DIR)
  message (WARNING "PKG_CONFIG_PATH environment is not set.")
endif ()

list (APPEND CMAKE_MODULE_PATH "${CMS_DIR}") # for compatibility
list (APPEND CMAKE_MODULE_PATH "${CMS_DIR}/Modules")
list (APPEND CMAKE_MODULE_PATH "${CMS_MODULE_DIR}")

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
                   "${CMAKE_CURRENT_SOURCE_DIR}/cmake")

  if (NOT ${_var})
    message (FATAL_ERROR "${_filename} not found!")
  endif ()

  install (FILES "${${_var}}" DESTINATION "${CMS_MODULE_DIR}")
endmacro ()

macro (CMS_INSTALL_PACKAGE _name)
  set (_var CMS_PACKAGE_${_name})
  set (_filename "${_name}.pc.in")
  find_file (${_var} ${_filename} PATHS "${CMAKE_CURRENT_SOURCE_DIR}")

  if (NOT ${_var})
    message (FATAL_ERROR "${_filename} not found!")
  endif ()

  set (_dotpc "${PROJECT_BINARY_DIR}/${_name}.pc")
  configure_file (${${_var}} "${_dotpc}" @ONLY)

  if (CMS_PACKAGE_DIR)
    install (FILES "${_dotpc}" DESTINATION "${CMS_PACKAGE_DIR}")
  else ()
    message (FATAL_ERROR "No destination to install ${_name}.")
  endif ()
endmacro ()

if (CMS_INSTALL_PREFIX)
  CMS_REINIT_CACHE(CMAKE_INSTALL_PREFIX
                   "${CMS_INSTALL_PREFIX}/${CMAKE_PROJECT_NAME}" PATH
                   "Install path prefix, prepended onto install directories.")
endif ()

if (NOT CXX_TOOLSET_SUFFIX)
  include (SetCxxToolsetSuffix)
endif ()
