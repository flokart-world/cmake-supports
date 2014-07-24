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
  set (ENABLE_TESTING true CACHE BOOL "Set true to enable testing")

  function (CMS_ENABLE_TESTING)
    if (ENABLE_TESTING)
      enable_testing ()
    endif ()
  endfunction ()
elseif (CMS_SCOPE_CALL STREQUAL "BEGIN")
  list (GET ARGN 0 _name)

  CMS_DEFINE_TARGET("${_name}")

  CMS_STACK_PUSH("${_name}")
elseif (CMS_SCOPE_CALL STREQUAL "END")
  CMS_STACK_POP(_name)

  CMS_SUBMIT_EXECUTABLE("${_name}")
  add_test (NAME "${_name}" COMMAND "${_name}")
endif ()
