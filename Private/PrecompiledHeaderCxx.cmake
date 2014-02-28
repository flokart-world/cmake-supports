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

macro (CMS_PREPARE_PCH_CXX _header)
  set (CMS_PCH_CXX_HEADER "${_header}")
  set (_header_file "${PROJECT_BINARY_DIR}/${_header}")

  if (MSVC AND USE_PRECOMPILED_HEADER)
    configure_file ("${_header}.in" "${_header_file}" @ONLY)
    add_compile_options ("/Yu\"${_header}\"")

    get_filename_component (_header_name "${_header}" NAME_WE)
    set (CMS_PCH_CXX_SOURCE "${PROJECT_BINARY_DIR}/${_header_name}.cpp")
    unset (_header_name)

    configure_file ("${CMS_PRIVATE_DIR}/PrecompiledHeader.cpp.in"
                    "${CMS_PCH_CXX_SOURCE}" @ONLY)

    list (APPEND CMS_ADDITIONAL_FILES "${_header}.in" "${CMS_PCH_CXX_SOURCE}")
  else ()
    file (WRITE "${_header_file}" "")
  endif ()

  unset (_header_file)
endmacro ()

macro (CMS_CONFIGURE_PCH_CXX)
  if (MSVC AND CMS_PCH_CXX_SOURCE)
    set_source_files_properties (FILES "${CMS_PCH_CXX_SOURCE}"
                                 PROPERTIES
                                 COMPILE_FLAGS "/Yc\"${CMS_PCH_CXX_HEADER}\"")
  endif ()
endmacro ()

if (MSVC)
  set (USE_PRECOMPILED_HEADER true CACHE BOOL "Using precompiled header improves compilation speed but may drop some missing includes.")
  mark_as_advanced (USE_PRECOMPILED_HEADER)
endif ()
