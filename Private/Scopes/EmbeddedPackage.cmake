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
  # Nothing to do
elseif (CMS_SCOPE_CALL STREQUAL "BEGIN")
  list (GET ARGN 0 _name)
  CMS_GET_PROPERTY(_parentType Type)

  if (NOT _parentType STREQUAL "None"
      AND NOT _parentType STREQUAL "Module"
      AND NOT _parentType STREQUAL "EmbeddedPackage")
    message (FATAL_ERROR "EmbeddedPackage must not be child of target.")
  endif ()

  message (STATUS "Entering the embedded package ${_name}.")

  CMS_DEFINE_NAMESPACE("${_name}")
  CMS_INHERIT_PROPERTY(ExportName)

  CMS_STACK_PUSH("${_name}")
elseif (CMS_SCOPE_CALL STREQUAL "END")
  CMS_STACK_POP(_name)

  CMS_NORMALIZE_DEPENDENCY()
  CMS_REGISTER_PACKAGE("${_name}")

  CMS_PROPAGATE_PROPERTY(ProvidedPackages)
  CMS_PROPAGATE_PROPERTY(ProvidedTargets)
  CMS_PROPAGATE_PROPERTY(RequiredPackages)
  CMS_PROPAGATE_PROPERTY(RequiredVariables)

  CMS_APPEND_TO_PARENT_PROPERTY(ProvidedPackages "${_name}")

  message (STATUS "Leaving the embedded package ${_name}.")
endif ()
