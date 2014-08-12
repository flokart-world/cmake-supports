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

  message (STATUS "Entering the C++ library ${_name}.")

  if (WIN32)
    set (_prefix "lib")
  else ()
    set (_prefix "")
  endif ()

  string (REGEX REPLACE "^lib" "" _coreName "${_name}")
  set (_outputName "${_prefix}${_coreName}${CMS_TOOLSET_SUFFIX_CXX}")

  if (WIN32)
    set (_outputName "${_outputName}-mt")
  endif ()

  CMS_DEFINE_LIBRARY("${_name}")
  CMS_SET_PROPERTY(LinkerLanguage CXX)
  CMS_SET_PROPERTY(OutputName "${_outputName}")
  CMS_SET_PROPERTY(OutputSuffixDebug -gd)

  CMS_STACK_PUSH("${_name}")
elseif (CMS_SCOPE_CALL STREQUAL "END")
  CMS_STACK_POP(_name)
  CMS_GET_PROPERTY(_version Version)

  string (REGEX REPLACE "^((\\d+)(\\.\\d+)?).*$" "\\1" _suffix "${_version}")
  string (REPLACE "." "_" _suffix "${_suffix}")

  if (_suffix)
    CMS_SET_PROPERTY(OutputSuffixVersion "-${_suffix}")
  endif ()

  CMS_SUBMIT_LIBRARY("${_name}")

  message (STATUS "Leaving the C++ library ${_name}.")
endif ()
