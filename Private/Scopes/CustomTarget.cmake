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

if (CMS_SCOPE_CALL STREQUAL "INIT")
  function (CMS_SUBMIT_CUSTOM_TARGET _name)
    get_directory_property (_findVersion CMS::FindVersion)

    message (STATUS "Emitting the custom target ${_name}.")

    set (_options "")
    CMS_GET_PROPERTY(_commandLine CommandLine)
    CMS_GET_PROPERTY(_commands Commands)
    CMS_GET_PROPERTY(_dependencies Dependencies)
    CMS_GET_PROPERTY(_includeWithinAll IncludeWithinAll)
    CMS_GET_PROPERTY(_workingDirectory WorkingDirectory)
    CMS_GET_PROPERTY(_connectTerminal ConnectTerminal)
    CMS_PREPARE_TARGET(_files)

    if (_includeWithinAll)
      list (APPEND _options ALL)
    endif ()

    if (_commandLine)
      if (_findVersion VERSION_GREATER_EQUAL 0.0.7)
        message (WARNING "CommandLine property is deprecated."
                         " Use CMS_ADD_COMMAND function instead.")
      endif ()

      list (APPEND _options COMMAND ${_commandLine})
    endif ()

    if (_commandLine OR _commands)
      list (APPEND _options ${_commands})

      set (_dependencyFiles)
      set (_dependencyTargets)

      if (_dependencies)
        foreach (_item IN LISTS _dependencies)
          if (TARGET ${_item})
            list (APPEND _dependencyTargets ${_item})
          else ()
            list (APPEND _dependencyFiles ${_item})
          endif ()
        endforeach ()

        CMS_SET_PROPERTY(Dependencies ${_dependencyTargets})
      endif ()

      if (_dependencyFiles)
        list (APPEND _options DEPENDS ${_dependencyFiles})
      endif ()

      if (_workingDirectory)
        CMS_ASSERT_IDENTIFIER(${_workingDirectory})
        list (APPEND _options WORKING_DIRECTORY ${_workingDirectory})
      endif ()

      list (APPEND _options VERBATIM)
    endif ()

    if (_connectTerminal)
      list (APPEND _options USES_TERMINAL)
    endif ()

    if (_files)
      list (APPEND _options SOURCES ${_files})
    endif ()

    add_custom_target (${_name} ${_options})
    CMS_SUBMIT_DEPENDENCIES(${_name})
  endfunction ()
elseif (CMS_SCOPE_CALL STREQUAL "BEGIN")
  list (GET ARGN 0 _name)

  message (STATUS "Entering the custom target ${_name}.")
  CMS_DEFINE_TARGET(${_name})
  CMS_INHERIT_PROPERTY(ExportName)

  CMS_DEFINE_PROPERTY(CommandLine)
  CMS_DEFINE_PROPERTY(Commands)
  CMS_DEFINE_PROPERTY(ConnectTerminal)
  CMS_DEFINE_PROPERTY(IncludeWithinAll)
  CMS_DEFINE_PROPERTY(WorkingDirectory)

  CMS_STACK_PUSH("${_name}")
elseif (CMS_SCOPE_CALL STREQUAL "END")
  CMS_STACK_POP(_name)

  CMS_SUBMIT_CUSTOM_TARGET(${_name})
  message (STATUS "Leaving the custom target ${_name}.")
endif ()
