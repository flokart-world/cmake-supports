# Copyright (c) 2014-2020 Flokart World, Inc.
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

function (CMS_PRECOMPILE_HEADER_CXX _headerFile)
  set (_headerPath "${CMAKE_CURRENT_BINARY_DIR}/${_headerFile}")
  CMS_INCLUDE_DIRECTORIES(PRIVATE ${CMAKE_CURRENT_BINARY_DIR})
  get_directory_property (_findVersion CMS::FindVersion)

  if (CMS_ENABLE_PRECOMPILE_HEADERS
      AND (_findVersion VERSION_GREATER_EQUAL 0.0.7
           OR USE_PRECOMPILED_HEADER))
    file (READ "${_headerFile}.in" _headerInput)
    string (CONFIGURE "${_headerInput}" _headerOutput @ONLY)
    CMS_WRITE_FILE(${_headerPath} ${_headerOutput})
    CMS_ADD_PRECOMPILE_HEADERS($<$<COMPILE_LANGUAGE:CXX>:${_headerFile}>)
  else ()
    CMS_WRITE_FILE(${_headerPath} "// Precompiled headers are disabled.\n")
  endif ()
endfunction ()

function (_CMS_INIT_PCH_OPTION)
  if (CMakeSupports_FIND_VERSION VERSION_LESS 0.0.7)
    set (USE_PRECOMPILED_HEADER true CACHE BOOL
         "Whether to enable CMS_PRECOMPILE_HEADER_CXX function.")
    mark_as_advanced (USE_PRECOMPILED_HEADER)
  endif ()
endfunction ()

_CMS_INIT_PCH_OPTION()
