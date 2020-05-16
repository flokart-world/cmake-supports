# Copyright (c) 2020 Flokart World, Inc.
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

function (CMS_DEFAULT_COMPILE_OPTIONS _ret)
  set (_options -Wall -Wextra)
  CMS_RETURN(_ret [[${_options}]])
endfunction ()

function (_CMS_SETUP_LTO_OVERWRITE)
  set (_optConfigs MINSIZEREL RELEASE RELWITHDEBINFO)

  foreach (_lang IN ITEMS CXX C)
    set (_base CMS_${_lang}_FLAGS)

    foreach (_buildType IN LISTS _optConfigs)
      set (_varName "${_base}_${_buildType}_OVERWRITE")
      if (NOT ${_varName} MATCHES "^(.* )?-flto( .*)?$")
        string (JOIN " " "${_varName}" ${${_varName}} -flto)
      endif ()
    endforeach ()
  endforeach ()

  _CMS_EXPORT_OVERWRITTEN_FLAGS()
endfunction ()

function (_CMS_SETUP_COMPILER_SPECIFIC_RECOMMENDATION)
  foreach (_lang IN ITEMS CXX C)
    set (_varName "CMS_${_lang}_FLAGS_RELEASE_OVERWRITE")
    string (REGEX REPLACE "^((.* )?)-O3(( .*)?)$" [[\1-Ofast\3]]
                          "${_varName}" "${${_varName}}")
  endforeach ()

  set (_ltoIsAvailable true)

  if (CMAKE_CXX_COMPILER_ID STREQUAL "Clang")
    # Clang generates LLVM bitcode if -flto is specified. To link those
    # binaries, either the LLVM gold plugin or LLD is required.

    # Cygwin doesn't have LLD. Also, gold doesn't support Windows binaries.
    if (CYGWIN)
      set (_ltoIsAvailable false)
    endif ()
  endif ()

  if (_ltoIsAvailable)
    _CMS_SETUP_LTO_OVERWRITE()
  endif ()

  set (_nonDebugConfigs MINSIZEREL RELEASE)

  foreach (_buildType IN LISTS _nonDebugConfigs)
    foreach (_type IN ITEMS EXE MODULE SHARED)
      set (_varName "CMS_${_type}_LINKER_FLAGS_${_buildType}_OVERWRITE")
      if (NOT ${_varName} MATCHES "^(.* )?-Wl,(-s|--strip-all)( .*)?$")
        string (JOIN " " "${_varName}" ${${_varName}} -Wl,-s)
      endif ()
    endforeach ()
  endforeach ()

  _CMS_EXPORT_OVERWRITTEN_FLAGS()
endfunction ()

# If a toolchain file is used, we should consider that there would be many
# environment-specific stuffs. e.g. clang without gold nor lld, linker invoked
# directly (so -Wl,<opt> is ill-formed), etc.
if (NOT CMAKE_TOOLCHAIN_FILE)
  _CMS_SETUP_COMPILER_SPECIFIC_RECOMMENDATION()
endif ()
