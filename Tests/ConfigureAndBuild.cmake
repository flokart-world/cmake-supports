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

execute_process (
  COMMAND
    ${CMAKE_COMMAND} ${TESTS_CONFIG_OPTIONS}
  RESULT_VARIABLE
    _result
)
if (NOT _result EQUAL 0)
  message (FATAL_ERROR "Configuration finished with non-zero: ${_result}")
endif ()

execute_process (
  COMMAND
    ${CMAKE_COMMAND} --build "${TESTS_BINARY_DIR}"
  RESULT_VARIABLE
    _result
  ENCODING
    AUTO
)
if (NOT _result EQUAL 0)
  message (FATAL_ERROR "Build finished with non-zero: ${_result}")
endif ()
