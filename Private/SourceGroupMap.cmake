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

function (_CMS_GET_GROUP_BY_PATH _ret _path)
  get_filename_component (_directory "${_path}" DIRECTORY)

  if (_directory)
    string (REPLACE "/" "\\" _group "${_directory}")
  else ()
    unset (_group)
  endif ()

  set (${_ret} "${_group}" PARENT_SCOPE)
endfunction ()

##
# class SourceGroupMap : ObjectMap
#

function (CMS_SGM_WRITE _map)
  while (${_map}_KEYS)
    list (GET ${_map}_KEYS 0 _group)
    list (REMOVE_AT ${_map}_KEYS 0)
    list (GET ${_map}_VALUES 0 _files)
    list (REMOVE_AT ${_map}_VALUES 0)

    source_group ("${_group}" FILES ${${_files}})
  endwhile ()
endfunction ()

function (CMS_SGM_ADD_FILES _map _prefix)
  if (ARGN)
    foreach (_file IN LISTS ARGN)
      _CMS_GET_GROUP_BY_PATH(_group "${_file}")
      get_filename_component (_fullpath "${_file}" ABSOLUTE)

      if (_group)
        CMS_OBJMAP_GET(_files ${_map} "${_prefix}\\${_group}")
        list (APPEND ${_files} "${_fullpath}")
      endif ()
    endforeach ()

    CMS_OBJMAP_PROMOTE_TO_PARENT_SCOPE(${_map})
  else ()
    message (FATAL_ERROR "No file specified.")
  endif ()
endfunction ()
