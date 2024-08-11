# Copyright (c) 2014-2024 Flokart World, Inc.
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

function (CMS_MODULE_SWITCH _ret _name)
  set (_switch "BUILD_${_name}")
  option (${_switch} "Set true to build the bundled ${_name}." true)

  CMS_RETURN(_ret \${_switch})
endfunction ()

if (CMS_SCOPE_CALL STREQUAL "INIT")
  include (CMakePackageConfigHelpers)

  function (CMS_BUILD_MODULE _name)
    set (_module "${CMAKE_CURRENT_BINARY_DIR}/Find${_name}.cmake")

    set (_cmakeDir "share/cmake/${_name}")
    set (_cmakeTargets "${_name}Targets.cmake")

    set (_cmakePrefix "${CMAKE_CURRENT_BINARY_DIR}/${_cmakeDir}/${_name}")
    set (_cmakeConfig "${_cmakePrefix}Config.cmake")
    set (_cmakeConfigVersion "${_cmakePrefix}ConfigVersion.cmake")

    CMS_GET_PROPERTY(_requiredPackages RequiredPackages)
    CMS_GET_PROPERTY(_providedPackages ProvidedPackages)
    CMS_GET_PROPERTY(_providedTargets ProvidedTargets)
    CMS_GET_PROPERTY(_providedVariables ProvidedVariables)
    CMS_GET_PROPERTY(_version Version)
    CMS_GET_PROPERTY(_compatibility Compatibility)

    WRITE_BASIC_PACKAGE_VERSION_FILE(${_cmakeConfigVersion}
                                     VERSION ${_version}
                                     COMPATIBILITY ${_compatibility})

    set (_configLines
         "find_package (CMakeSupports ${CMakeSupports_VERSION} REQUIRED)")

    foreach (_package IN LISTS _requiredPackages)
      CMS_REPLAY_PACKAGE_ARGS(_packageParams ${_package} REQUIRED)
      CMS_JOIN(_suffix " " ${_packageParams})

      list (APPEND _configLines "CMS_LOAD_PACKAGE(\"${_package}\" ${_suffix})")
    endforeach ()

    if (_providedTargets)
      install (EXPORT "${_name}"
               DESTINATION "${_cmakeDir}"
               FILE "${_cmakeTargets}")

      export (EXPORT "${_name}" FILE "${_cmakePrefix}Targets.cmake")

      list (APPEND _configLines
            "include (\"\${CMAKE_CURRENT_LIST_DIR}/${_name}Targets.cmake\")")
    endif ()

    foreach (_package IN LISTS _providedPackages)
      CMS_QUALIFY_NAMESPACE(_ns ${_package})
      CMS_GET_QNAME_PROPERTY(_targets ${_ns}::ProvidedTargets)
      list (LENGTH _targets _size)

      if (_size EQUAL 0)
        set (_suffix "")
      else ()
        CMS_JOIN(_suffix " " ${_targets})
        set (_suffix " ${_suffix}")
      endif ()

      list (APPEND _configLines
            "CMS_PROVIDE_PACKAGE(\"${_package}\"${_suffix})")

      CMS_GET_QNAME_PROPERTY(_variables "${_ns}::ProvidedVariables")
      foreach (_varName IN LISTS _variables)
        CMS_GET_QNAME_PROPERTY(_value "${_ns}::Variable[${_varName}]")
        string (CONFIGURE "@_value@" _value ESCAPE_QUOTES)
        list (
          APPEND
          _configLines
          "CMS_PROVIDE_VARIABLE(\"${_package}\" \"${_varName}\" \"${_value}\")"
        )
      endforeach ()
    endforeach ()

    CMS_JOIN(_targetList " " ${_providedTargets})
    list (APPEND _configLines
          "CMS_DECLARE_PROVIDED_TARGETS(${_name} ${_targetList})"
          "mark_as_advanced (${_name}_DIR)")

    string (CONFIGURE "@_providedVariables@" _varList ESCAPE_QUOTES)
    list (
      APPEND _configLines
      "set (${_name}_CMakeSupportsVariables \"${_varList}\")"
    )
    foreach (_varName IN LISTS _providedVariables)
      CMS_GET_PROPERTY(_value "Variable[${_varName}]")
      string (CONFIGURE "@_value@" _value ESCAPE_QUOTES)
      list (
        APPEND
        _configLines
        "set (${_name}_${_varName} \"${_value}\")"
      )
    endforeach ()

    CMS_JOIN(_configBody "\n" ${_configLines})
    file (WRITE ${_cmakeConfig} "${_configBody}\n")

    install (FILES ${_cmakeConfig} ${_cmakeConfigVersion}
             DESTINATION ${_cmakeDir})

    file (WRITE ${_module}
          "CMS_LOAD_CONFIG_AS_MODULE(${_name} \"${CMAKE_INSTALL_PREFIX}\")\n")
    install (FILES ${_module} DESTINATION ${CMS_MODULE_DIR})

    CMS_SUBMIT_PACKAGE(${_name} ${_providedTargets})
    _CMS_FINALIZE_VARIABLES("${_name}")
    export (PACKAGE ${_name})
  endfunction ()
elseif (CMS_SCOPE_CALL STREQUAL "SKIP")
  list (GET ARGN 0 _name)

  # For user convenience, option entry is added regardless of skipping.
  CMS_MODULE_SWITCH(_switch ${_name})
elseif (CMS_SCOPE_CALL STREQUAL "BEGIN")
  list (GET ARGN 0 _name)
  CMS_GET_PROPERTY(_parentType Type)

  # All nested modules are assumed to be bundled ones.
  if (_parentType STREQUAL "None")
    set (_build true)
  else ()
    CMS_MODULE_SWITCH(_switch ${_name})

    if (NOT ${_switch})
      CMS_USE_PACKAGE(${_name} QUIET)
      CMS_TEST_PACKAGE(_loaded ${_name})

      if (NOT _loaded)
        message (
          WARNING
          "Building ${_name} was turned off, but we couldn't find any "
          "prebuilt package. Falling back to buliding the bundled one..."
        )
        CMS_MODIFY_CACHE(${_switch} true)
      endif ()
    endif ()

    set (_build "${${_switch}}")
  endif ()

  if (_build)
    message (STATUS "Entering the module ${_name}.")

    CMS_DEFINE_NAMESPACE("${_name}")
    CMS_DEFINE_PROPERTY(Compatibility)
    CMS_DEFINE_PROPERTY(ProvidedVariables)

    CMS_SET_PROPERTY(Compatibility AnyNewerVersion)
    CMS_SET_PROPERTY(ExportName ${_name})

    CMS_STACK_PUSH("${_name}")
  else ()
    CMS_SKIP_SCOPE()
  endif ()
elseif (CMS_SCOPE_CALL STREQUAL "END")
  CMS_STACK_POP(_name)

  CMS_IMPORT_TARGET_DEPENDENCIES()
  CMS_BUILD_MODULE("${_name}")

  CMS_ADD_TO_PARENT_PROPERTY(RequiredPackages "${_name}")
  CMS_ADD_TO_PARENT_PROPERTY(RequiredComponents[${_name}])

  message (STATUS "Leaving the module ${_name}.")
endif ()
