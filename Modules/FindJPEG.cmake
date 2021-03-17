# - Find JPEG
# Find the native JPEG includes and library
# This module defines
#  JPEG_INCLUDE_DIR, where to find jpeglib.h, etc.
#  JPEG_LIBRARIES, the libraries needed to use JPEG.
#  JPEG_FOUND, If false, do not try to use JPEG.
# also defined, but not for general use are
#  JPEG_LIBRARY, where to find the JPEG library.

#=============================================================================
# Copyright 2001-2021 Kitware, Inc.
# Copyright 2014-2021 Flokart World, Inc.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions
# are met:
# 
# * Redistributions of source code must retain the above copyright
#   notice, this list of conditions and the following disclaimer.
# 
# * Redistributions in binary form must reproduce the above copyright
#   notice, this list of conditions and the following disclaimer in the
#   documentation and/or other materials provided with the distribution.
# 
# * Neither the names of Kitware, Inc., nor the names of Contributors
#   may be used to endorse or promote products derived from this
#   software without specific prior written permission.
# 
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
# "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
# LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
# A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
# HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
# SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
# LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
# DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
# THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
# (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
# OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#=============================================================================

set (JPEG_LIBRARIES)
find_package (libjpeg-turbo QUIET CONFIG)

if (libjpeg-turbo_FOUND)
  get_target_property (_includeHints
                       libjpeg-turbo::jpeg
                       INTERFACE_INCLUDE_DIRECTORIES)

  set (JPEG_LIBRARY libjpeg-turbo::jpeg
       CACHE FILEPATH "Path to the library file or name of the library target")
else ()
  PKG_CHECK_MODULES(PC_JPEG QUIET libjpeg)
  set (_includeHints ${PC_JPEG_INCLUDE_DIRS})

  set (JPEG_NAMES ${JPEG_NAMES} jpeg libjpeg)
  set (_hints "${PC_JPEG_LIBDIR}/Release"
              "${PC_JPEG_LIBDIR}/Debug"
              ${PC_JPEG_LIBRARY_DIRS})

  find_library (JPEG_LIBRARY NAMES ${JPEG_NAMES} HINTS ${_hints})

  foreach (_name IN LISTS PC_JPEG_LIBRARIES)
    string (TOUPPER ${_name} _suffix)

    if (NOT _suffix STREQUAL "JPEG")
      find_library (JPEG_LIBRARY_${_suffix} NAMES ${_name} HINTS ${_hints})
      mark_as_advanced (JPEG_LIBRARY_${_suffix})

      list (APPEND JPEG_LIBRARIES ${JPEG_LIBRARY_${_suffix}})
    endif ()
  endforeach ()

  set (JPEG_INCLUDE_DIRS "${PC_JPEG_INCLUDE_DIRS}")
  CMS_REPLACE_MODULE_DIRS(JPEG
                          "${PC_JPEG_INCLUDEDIR}"
                          "${PC_JPEG_LIBDIR}")
endif ()

find_path(JPEG_INCLUDE_DIR NAMES jpeglib.h HINTS "${_includeHints}")
list (INSERT JPEG_INCLUDE_DIRS 0 "${JPEG_INCLUDE_DIR}")
list (REMOVE_DUPLICATES JPEG_INCLUDE_DIRS)

list (APPEND JPEG_LIBRARIES "${JPEG_LIBRARY}")
list (REMOVE_DUPLICATES JPEG_LIBRARIES)

if(JPEG_INCLUDE_DIR)
  file(GLOB _JPEG_CONFIG_HEADERS_FEDORA "${JPEG_INCLUDE_DIR}/jconfig*.h")
  file(GLOB _JPEG_CONFIG_HEADERS_DEBIAN "${JPEG_INCLUDE_DIR}/*/jconfig.h")
  set(_JPEG_CONFIG_HEADERS
    "${JPEG_INCLUDE_DIR}/jpeglib.h"
    ${_JPEG_CONFIG_HEADERS_FEDORA}
    ${_JPEG_CONFIG_HEADERS_DEBIAN})
  foreach (_JPEG_CONFIG_HEADER IN LISTS _JPEG_CONFIG_HEADERS)
    if (NOT EXISTS "${_JPEG_CONFIG_HEADER}")
      continue ()
    endif ()
    file(STRINGS "${_JPEG_CONFIG_HEADER}"
      jpeg_lib_version REGEX "^#define[\t ]+JPEG_LIB_VERSION[\t ]+.*")

    if (NOT jpeg_lib_version)
      continue ()
    endif ()

    string(REGEX REPLACE "^#define[\t ]+JPEG_LIB_VERSION[\t ]+([0-9]+).*"
      "\\1" JPEG_VERSION "${jpeg_lib_version}")
    break ()
  endforeach ()
  unset(jpeg_lib_version)
  unset(_JPEG_CONFIG_HEADER)
  unset(_JPEG_CONFIG_HEADERS)
  unset(_JPEG_CONFIG_HEADERS_FEDORA)
  unset(_JPEG_CONFIG_HEADERS_DEBIAN)
endif()

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(JPEG
  REQUIRED_VARS JPEG_LIBRARY JPEG_INCLUDE_DIR
  VERSION_VAR JPEG_VERSION)

# Deprecated declarations.
set (NATIVE_JPEG_INCLUDE_PATH ${JPEG_INCLUDE_DIR} )
if(JPEG_LIBRARY)
  get_filename_component (NATIVE_JPEG_LIB_PATH ${JPEG_LIBRARY} PATH)
endif()

mark_as_advanced (JPEG_LIBRARY
                  JPEG_INCLUDE_DIR)
