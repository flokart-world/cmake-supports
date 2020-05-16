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

function (CMS_DEBUG_CONFIGURATIONS _ret)
  get_property (_configs GLOBAL PROPERTY DEBUG_CONFIGURATIONS)

  CMS_RETURN(_ret \${_configs})
endfunction ()

function (CMS_OPTIMIZED_CONFIGURATIONS _ret)
  set (_configs ${CMAKE_CONFIGURATION_TYPES})
  CMS_DEBUG_CONFIGURATIONS(_debugConfigs)
  list (REMOVE_ITEM _configs ${_debugConfigs})

  CMS_RETURN(_ret \${_configs})
endfunction ()

function (CMS_EXPR_TRUE_IF_DEBUG _ret)
  CMS_DEBUG_CONFIGURATIONS(_debugConfigs)
  list (LENGTH _debugConfigs _size)

  if (_size GREATER 1)
    set (_matches "")

    foreach (_config IN LISTS _debugConfigs)
      list (APPEND _matches "$<CONFIG:${_config}>")
    endforeach ()

    CMS_JOIN(_conditions "," ${_matches})
    CMS_RETURN(_ret "$<OR:\${_conditions}>")
  else ()
    CMS_RETURN(_ret "$<CONFIG:\${_debugConfigs}>")
  endif ()
endfunction ()

# It does just what CMake can internally do.
function (CMS_CONDITIONAL_EXPR_IF_DEBUG _ret _valueIfDebug _valueElse)
  CMS_EXPR_TRUE_IF_DEBUG(_debug)

  set (_exprIfDebug "$<${_debug}:${_valueIfDebug}>")
  set (_exprElse "$<$<NOT:${_debug}>:${_valueElse}>")

  CMS_RETURN(_ret \${_exprIfDebug}\${_exprElse})
endfunction ()

function (_CMS_OVERWRITE_VARIABLE _varName)
  CMS_REINIT_CACHE(CMAKE_${_varName} ${CMS_${_varName}_OVERWRITE})
endfunction ()

get_property (_values GLOBAL PROPERTY DEBUG_CONFIGURATIONS)

if (NOT _values)
  # Frees us from default handling of this property.
  set_property (GLOBAL PROPERTY DEBUG_CONFIGURATIONS "Debug")
endif ()

foreach (_purpose IN ITEMS C
                           CXX
                           EXE_LINKER
                           MODULE_LINKER
                           SHARED_LINKER
                           STATIC_LINKER)
  _CMS_OVERWRITE_VARIABLE(${_purpose}_FLAGS)
  foreach (_buildType IN LISTS CMS_DEFAULT_CONFIGURATION_TYPES)
    _CMS_OVERWRITE_VARIABLE(${_purpose}_FLAGS_${_buildType})
  endforeach ()
endforeach ()
