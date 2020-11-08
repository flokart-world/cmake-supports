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

function (CMS_DEFAULT_COMPILE_OPTIONS _ret)
  get_directory_property (_findVersion CMS::FindVersion)
  set (_options)
  if (CMAKE_CXX_COMPILER_ID STREQUAL "Clang"
      AND _findVersion VERSION_GREATER_EQUAL 0.0.7)
    # TODO : Append some useful options.
  endif ()
  CMS_RETURN(_ret [[${_options}]])
endfunction ()

function (_CMS_SETUP_COMPILER_SPECIFIC_RECOMMENDATION)
  set (_lto /GL)
  if (CMAKE_CXX_COMPILER_ID STREQUAL "Clang")
    set (_lto -flto)
  endif ()

  set (_optConfigs MINSIZEREL RELEASE RELWITHDEBINFO)

  foreach (_lang IN ITEMS CXX C)
    set (_base CMS_${_lang}_FLAGS)

    if (NOT CMS_MSVC_WARNING_STYLE STREQUAL "NEW")
      set (_varName "${_base}_OVERWRITE")
      string (REGEX REPLACE "^((.* )?)/W3(( .*)?)$" [[\1/W4\3]]
                            "${_varName}" "${${_varName}}")

      if (NOT ${_varName} MATCHES "^(.* )?/fp:")
        string (JOIN " " "${_varName}" ${${_varName}} /fp:fast)
      endif ()

      if (CMakeSupports_FIND_VERSION VERSION_GREATER_EQUAL 0.0.7)
        if (NOT ${_varName} MATCHES "^(.* )?/permissive-?( .*)?$")
          string (JOIN " " "${_varName}" ${${_varName}} /permissive-)
        endif ()
      endif ()
    endif ()

    foreach (_buildType IN LISTS _optConfigs)
      set (_varName "${_base}_${_buildType}_OVERWRITE")
      if (NOT ${_varName} MATCHES "^(.* )?/GS-?( .*)?$")
        string (JOIN " " "${_varName}" ${${_varName}} /GS-)
      endif ()
      if (NOT ${_varName} MATCHES "^(.* )?${_lto}( .*)?$")
        string (JOIN " " "${_varName}" ${${_varName}} ${_lto})
      endif ()
    endforeach ()
  endforeach ()

  if (_lto STREQUAL "/GL")
    foreach (_buildType IN LISTS _optConfigs)
      set (_hasGL false)

      foreach (_lang IN ITEMS CXX C)
        set (_varName "CMS_${_lang}_FLAGS_${_buildType}_OVERWRITE")
        if (${_varName} MATCHES "^(.* )?/GL( .*)?$")
          set (_hasGL true)
        endif ()
      endforeach ()

      if (_hasGL)
        foreach (_type IN ITEMS EXE MODULE SHARED STATIC)
          set (_varName "CMS_${_type}_LINKER_FLAGS_${_buildType}_OVERWRITE")
          if (NOT ${_varName} MATCHES "^(.* )?/LTCG([: ].*)?$")
            set (_ltcg /LTCG)
            if (${_varName} MATCHES "^(.* )?/INCREMENTAL( .*)?$")
              set (_ltcg /LTCG:INCREMENTAL)
            endif ()
            string (JOIN " " "${_varName}" ${${_varName}} ${_ltcg})
          endif ()
        endforeach ()
      endif ()
    endforeach ()
  endif ()

  _CMS_EXPORT_OVERWRITTEN_FLAGS()
endfunction ()

_CMS_SETUP_COMPILER_SPECIFIC_RECOMMENDATION()
