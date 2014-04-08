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

##
# class SourceFilePropertyMap : ObjectMap
#

function (CMS_SFPM_ADD_VALUES _map _delimiter _item)
  if (ARGN)
    unset (_files)

    while (ARGN)
      list (GET ARGN 0 _arg)
      list (REMOVE_AT ARGN 0)

      if (_arg STREQUAL "${_delimiter}")
        break()
      else ()
        list (APPEND _files "${_arg}")
      endif ()
    endwhile ()

    if (ARGN)
      foreach (_file IN LISTS _files)
        CMS_OBJMAP_GET(_properties ${_map} "${_file}")
        list (APPEND ${_properties} "${ARGN}")
      endforeach ()

      CMS_OBJMAP_PROMOTE_TO_PARENT_SCOPE(${_map})
    else ()
      message (FATAL_ERROR "No ${item} specified.")
    endif ()
  else ()
    message (FATAL_ERROR "No file specified.")
  endif ()
endfunction ()

##
# class SourceFileDefinitionMap : SourceFilePropertyMap
#

function (CMS_SFDM_WRITE _map)
  while (${_map}_KEYS)
    list (GET ${_map}_KEYS 0 _file)
    list (REMOVE_AT ${_map}_KEYS 0)
    list (GET ${_map}_VALUES 0 _properties)
    list (REMOVE_AT ${_map}_VALUES 0)

    set_source_files_properties ("${_file}" PROPERTIES
                                 COMPILE_DEFINITIONS "${${_properties}}")
  endwhile ()
endfunction ()

##
# class SourceFileFlagMap : SourceFilePropertyMap
#

function (CMS_SFFM_WRITE _map)
  while (${_map}_KEYS)
    list (GET ${_map}_KEYS 0 _file)
    list (REMOVE_AT ${_map}_KEYS 0)
    list (GET ${_map}_VALUES 0 _properties)
    list (REMOVE_AT ${_map}_VALUES 0)

    unset (_value)

    foreach (_part IN LISTS ${_properties})
      if (_value)
        set (_value "${_value} ${_part}")
      else ()
        set (_value "${_part}")
      endif ()
    endforeach ()

    set_source_files_properties ("${_file}" PROPERTIES
                                 COMPILE_FLAGS ${_value})
  endwhile ()
endfunction ()
