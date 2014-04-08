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

function (CMS_PRECOMPILE_HEADER_CXX _header)
  CMS_CHECK_PREFIX()
  CMS_CHECK_TARGET()

  set (CMS_PCH_CXX_HEADER "${_header}")
  set (_header_file "${CMAKE_CURRENT_BINARY_DIR}/${_header}")
  include_directories ("${CMAKE_CURRENT_BINARY_DIR}")

  if (MSVC AND USE_PRECOMPILED_HEADER)
    configure_file ("${_header}.in" "${_header_file}" @ONLY)
    add_compile_options ("/Yu\"${_header}\"")

    get_filename_component (_header_name "${_header}" NAME_WE)
    set (_source "${CMAKE_CURRENT_BINARY_DIR}/${_header_name}.cpp")
    unset (_header_name)

    configure_file ("${CMS_PRIVATE_DIR}/PrecompiledHeader.cpp.in"
                    "${_source}" @ONLY)

    get_filename_component (_fullpath "${_source}" ABSOLUTE)
    list (APPEND CMS_ADDITIONAL_FILES "${_header}.in" "${_fullpath}")
    CMS_SOURCE_FILES_COMPILE_FLAGS("${_fullpath}" FLAGS
                                   "/Yc\"${CMS_PCH_CXX_HEADER}\"")

    set (CMS_PCH_CXX_SOURCE "${_fullpath}" PARENT_SCOPE)
    CMS_PROMOTE_TO_PARENT_SCOPE(CMS_PCH_CXX_HEADER)
    CMS_PROMOTE_TO_PARENT_SCOPE(CMS_ADDITIONAL_FILES)
    CMS_OBJMAP_PROMOTE_TO_PARENT_SCOPE(CMS_SOURCE_FLAGS)
  else ()
    file (WRITE "${_header_file}"
          "// Precompiled header is disabled or not supported.")
  endif ()
endfunction ()

function (_CMS_INIT_PCH_OPTION)
  set (USE_PRECOMPILED_HEADER true CACHE BOOL "Using precompiled header improves compilation speed, but may drop some missing includes.")
  mark_as_advanced (USE_PRECOMPILED_HEADER)
endfunction ()

if (MSVC)
  _CMS_INIT_PCH_OPTION()
endif ()
