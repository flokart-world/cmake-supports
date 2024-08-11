# Copyright (c) 2024 Flokart World, Inc.
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

cmake_minimum_required (VERSION 3.16.6)
project (tests)
enable_testing ()

function (TESTS_ADD_CMAKE_SCENARIO _name)
  set (_projectName ${_name})
  if (ARGN)
    list (GET ARGN 0 _top)
    if (_top STREQUAL "PROJECT")
      list (GET ARGN 1 _projectName)
      list (REMOVE_AT ARGN 0 1)
    endif ()
  endif ()

  set (_options)
  if (ARGN)
    list (GET ARGN 0 _top)
    if (_top STREQUAL "OPTIONS")
      list (FIND ARGN PROPERTIES _delimPos)
      if (_delimPos LESS 0)
        list (SUBLIST ARGN 1 -1 _options)
        set (ARGN)
      else ()
        math (EXPR _beforeDelimPos "${_delimPos} - 1")
        list (SUBLIST ARGN 1 ${_beforeDelimPos} _options)
        list (SUBLIST ARGN ${_delimPos} -1 ARGN)
      endif ()
    endif ()
  endif ()

  if (ARGN)
    list (GET ARGN 0 _top)
    if (_top STREQUAL "PROPERTIES")
      list (REMOVE_AT ARGN 0)
    else ()
      message (FATAL_ERROR "Unrecognized parameter: ${_top}")
    endif ()
  endif ()

  set (
    _options
    -D "CMAKE_PREFIX_PATH=${CMAKE_SOURCE_DIR}/libraries"
    -D "CMakeSupports_DIR=${CMAKE_SOURCE_DIR}/.."
    -D "TESTS_PROJECT_NAME=${_projectName}"
    -B "${CMAKE_BINARY_DIR}/Projects"
    -S "${CMAKE_SOURCE_DIR}/Projects"
    ${_options}
  )

  add_test (
    NAME
      ${_name}
    COMMAND
      ${CMAKE_COMMAND}
      -D "TESTS_CONFIG_OPTIONS=${_options}"
      -D "TESTS_BINARY_DIR=${CMAKE_BINARY_DIR}/Projects"
      -P ${CMAKE_SOURCE_DIR}/ConfigureAndBuild.cmake
  )
  if (ARGN)
    set_tests_properties (${_name} PROPERTIES ${ARGN})
  endif ()
endfunction ()

add_subdirectory (Scenarios)
