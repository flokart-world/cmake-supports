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
  include (CMakePackageConfigHelpers)

  function (CMS_BUILD_MODULE _name)
    set (_module "${CMAKE_CURRENT_BINARY_DIR}/Find${_name}.cmake")

    set (_cmakeDir "share/cmake/${_name}")
    set (_cmakeTargets "${_name}Targets.cmake")

    set (_cmakePrefix "${CMAKE_CURRENT_BINARY_DIR}/${_cmakeDir}/${_name}")
    set (_cmakeConfig "${_cmakePrefix}Config.cmake")
    set (_cmakeConfigVersion "${_cmakePrefix}ConfigVersion.cmake")

    CMS_GET_PROPERTY(_requiredPackages RequiredPackages)
    CMS_GET_PROPERTY(_requiredVariables RequiredVariables)
    CMS_GET_PROPERTY(_providedPackages ProvidedPackages)
    CMS_GET_PROPERTY(_providedTargets ProvidedTargets)
    CMS_GET_PROPERTY(_version Version)
    CMS_GET_PROPERTY(_compatibility Compatibility)

    WRITE_BASIC_PACKAGE_VERSION_FILE(${_cmakeConfigVersion}
                                     VERSION ${_version}
                                     COMPATIBILITY ${_compatibility})

    set (_configLines
         "find_package (CMakeSupports ${CMakeSupports_VERSION} REQUIRED)")

    foreach (_package IN LISTS _requiredPackages)
      CMS_GET_PACKAGE_PREFIX(_prefix ${_package})

      if (_prefix STREQUAL _package)
        list (APPEND _configLines
              "CMS_LOAD_PACKAGE(\"${_package}\" REQUIRED)")
      else ()
        list (APPEND _configLines
              "CMS_LOAD_PACKAGE(\"${_package}\" PREFIX ${_prefix} REQUIRED)")
      endif ()
    endforeach ()

    foreach (_variable IN LISTS _requiredVariables)
      list (APPEND _configLines "CMS_LOAD_VARIABLE(${_variable})")
    endforeach ()

    install (EXPORT "${_name}"
             DESTINATION "${_cmakeDir}"
             FILE "${_cmakeTargets}")

    export (EXPORT "${_name}" FILE "${_cmakePrefix}Targets.cmake")

    list (APPEND _configLines
          "include (\"\${CMAKE_CURRENT_LIST_DIR}/${_name}Targets.cmake\")")

    foreach (_package IN LISTS _providedPackages)
      list (APPEND _configLines "CMS_REGISTER_PACKAGE(\"${_package}\")")
    endforeach ()

    CMS_JOIN(_configBody "\n" ${_configLines})
    file (WRITE ${_cmakeConfig} "${_configBody}\n")

    install (FILES ${_cmakeConfig} ${_cmakeConfigVersion}
             DESTINATION ${_cmakeDir})

    file (WRITE ${_module}
          "CMS_LOAD_CONFIG_AS_MODULE(${_name} \"${CMAKE_INSTALL_PREFIX}\")\n")
    install (FILES ${_module} DESTINATION ${CMS_MODULE_DIR})

    CMS_REGISTER_PACKAGE(${_name})
    export (PACKAGE ${_name})
  endfunction ()
elseif (CMS_SCOPE_CALL STREQUAL "BEGIN")
  list (GET ARGN 0 _name)
  CMS_GET_PROPERTY(_parentType Type)

  # All nested modules are assumed to be bundled ones.
  if (_parentType STREQUAL "None")
    set (_build true)
  else ()
    set (_switch "BUILD_${_name}")
    set (${_switch} false CACHE BOOL "Set true to build the bundled ${_name}.")

    if (NOT ${_switch})
      CMS_USE_PACKAGE(${_name} QUIET)
      CMS_TEST_PACKAGE(_loaded ${_name})

      if (NOT _loaded)
        CMS_MODIFY_CACHE(${_switch} true)
      endif ()
    endif ()

    set (_build "${${_switch}}")
  endif ()

  if (_build)
    message (STATUS "Entering the module ${_name}.")

    CMS_DEFINE_NAMESPACE("${_name}")
    CMS_DEFINE_PROPERTY(Compatibility)

    CMS_SET_PROPERTY(Compatibility AnyNewerVersion)
    CMS_SET_PROPERTY(ExportName ${_name})

    CMS_STACK_PUSH("${_name}")
  else ()
    CMS_SKIP_SCOPE()
  endif ()
elseif (CMS_SCOPE_CALL STREQUAL "END")
  CMS_STACK_POP(_name)

  CMS_NORMALIZE_DEPENDENCY()
  CMS_BUILD_MODULE("${_name}")

  CMS_APPEND_TO_PARENT_PROPERTY(RequiredPackages "${_name}")

  message (STATUS "Leaving the module ${_name}.")
endif ()
