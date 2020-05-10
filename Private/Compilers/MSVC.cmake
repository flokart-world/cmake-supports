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

set (_permissiveByDefault false)

if (CMakeSupports_FIND_VERSION VERSION_LESS 0.0.7)
  set (_permissiveByDefault true)
endif ()

set (_lto /GL)
if (CMAKE_CXX_COMPILER_ID STREQUAL "Clang")
  set (_lto -flto)
endif ()

foreach (_lang CXX C)
  set (_base CMAKE_${_lang}_FLAGS)
  set (_flags ${${_base}})
  string (REGEX REPLACE [[/W3(( .*)?)$]] [[/W4\1 /fp:fast]] _flags ${_flags})

  if (NOT _permissiveByDefault)
    set (_flags "${_flags} /permissive-")
    if (CMAKE_${_lang}_COMPILER_ID STREQUAL "Clang")
      set (_flags "${_flags} -fno-ms-compatibility")
    endif ()
  endif ()

  CMS_REINIT_CACHE(${_base} ${_flags})

  CMS_REINIT_CACHE(${_base}_MINSIZEREL
                   "${${_base}_MINSIZEREL} /GS- ${_lto}")
  CMS_REINIT_CACHE(${_base}_RELEASE
                   "${${_base}_RELEASE} /GS- ${_lto}")
  CMS_REINIT_CACHE(${_base}_RELWITHDEBINFO
                   "${${_base}_RELWITHDEBINFO} /GS- ${_lto}")
endforeach ()

if (CMAKE_CXX_COMPILER_ID STREQUAL "MSVC")
  foreach (_type EXE MODULE SHARED STATIC)
    set (_base CMAKE_${_type}_LINKER_FLAGS)

    CMS_REINIT_CACHE(${_base}_MINSIZEREL
                     "${${_base}_MINSIZEREL} /LTCG")
    CMS_REINIT_CACHE(${_base}_RELEASE
                     "${${_base}_RELEASE} /LTCG")
    CMS_REINIT_CACHE(${_base}_RELWITHDEBINFO
                     "${${_base}_RELWITHDEBINFO} /LTCG:INCREMENTAL")
  endforeach ()
endif ()
