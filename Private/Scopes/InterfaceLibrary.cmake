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
#    3. This notice may not be removed or altered from any source distribution.

if (CMS_SCOPE_CALL STREQUAL "INIT")
  function (CMS_FILTER_SCOPED_PROPERTY _propertyName)
    set (_result "")
    set (_append false)

    CMS_GET_PROPERTY(_values ${_propertyName})

    foreach (_value IN LISTS _values)
      if (_value STREQUAL "PRIVATE")
        set (_append false)
      elseif (_value MATCHES "^(DEFAULT|INTERFACE|PUBLIC)$")
        set (_append true)
        list (APPEND _result INTERFACE)
      else ()
        if (_append)
          list (APPEND _result ${_value})
        endif ()
      endif ()
    endforeach ()

    CMS_SET_PROPERTY(${_propertyName} ${_result})
  endfunction ()
elseif (CMS_SCOPE_CALL STREQUAL "BEGIN")
  list (GET ARGN 0 _name)

  message (STATUS "Entering the interface library ${_name}.")

  CMS_DEFINE_TARGET_SCOPE(${_name})

  CMS_INHERIT_PROPERTY(ExportName)
  CMS_FILTER_SCOPED_PROPERTY(CompileDefinitions)
  CMS_FILTER_SCOPED_PROPERTY(CompileOptions)
  CMS_FILTER_SCOPED_PROPERTY(IncludeDirectories)
  CMS_FILTER_SCOPED_PROPERTY(LinkLibraries)

  CMS_STACK_PUSH("${_name}")
elseif (CMS_SCOPE_CALL STREQUAL "END")
  CMS_STACK_POP(_name)

  CMS_PREPARE_TARGET_SCOPE()
  add_library (${_name} INTERFACE)
  CMS_SUBMIT_TARGET_SCOPE(${_name} INTERFACE INTERFACE)

  message (STATUS "Leaving the interface library ${_name}.")
endif ()
