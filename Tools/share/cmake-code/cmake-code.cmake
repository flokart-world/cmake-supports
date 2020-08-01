# Copyright (c) 2020 Flokart World, Inc.
# All rights reserved.
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

get_filename_component (_scriptDir "${CMAKE_SCRIPT_MODE_FILE}" DIRECTORY)
get_filename_component (_cmsBaseDir "${_scriptDir}/../../.." ABSOLUTE)
list (PREPEND CMAKE_PREFIX_PATH ${_cmsBaseDir})

find_package (CMakeSupports 0.0.7 REQUIRED)
find_package (Python3 REQUIRED)
find_program (_ninjaPath ninja REQUIRED)

set (_index 1)
while (_index LESS CMAKE_ARGC)
  set (_arg "${CMAKE_ARGV${_index}}")
  math (EXPR _index "${_index} + 1")
  if (_arg STREQUAL "--")
    break ()
  endif ()
endwhile ()

set (_args)
while (_index LESS CMAKE_ARGC)
  list (APPEND _args "${CMAKE_ARGV${_index}}")
  math (EXPR _index "${_index} + 1")
endwhile ()

execute_process (COMMAND "${Python3_EXECUTABLE}"
                         "${_scriptDir}/cmake-code.py"
                         --cmake-path "${CMAKE_COMMAND}"
                         --ninja-path "${_ninjaPath}"
                         ${_args})
