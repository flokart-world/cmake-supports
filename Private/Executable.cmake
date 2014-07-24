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

function (CMS_DEFINE_EXECUTABLE _name)
  CMS_DEFINE_TARGET(${_name})
  CMS_DEFINE_SCOPE_PROPERTY(GUI)

  if (MSVC)
    CMS_DEFINE_SCOPE_PROPERTY(EntryPoint)

    if (WIN32)
      CMS_DEFINE_SCOPE_PROPERTY(WinMain)
    endif ()
  endif ()
endfunction ()

function (CMS_SUBMIT_EXECUTABLE _name)
  message (STATUS "Emitting the executable ${_name}.")

  CMS_GET_PROPERTY(_gui GUI)

  if (WIN32 AND _gui)
    set (_options WIN32)
  elseif (APPLE AND DARWIN_MAJOR_VERSION GREATER 9)
    set (_options MACOSX_BUNDLE)
  else ()
    set (_options "")
  endif ()

  if (MSVC)
    CMS_GET_PROPERTY(_entryPoint EntryPoint)

    if (NOT _entryPoint AND WIN32)
      CMS_GET_PROPERTY(_winMain WinMain)

      if (NOT _winMain)
        set (_entryPoint "mainCRTStartup")
      endif ()
    endif ()

    if (_entryPoint)
      CMS_APPEND_TO_PROPERTY(LinkFlags "/ENTRY:${_entryPoint}")
    endif ()
  endif ()

  CMS_PREPARE_TARGET(_files)
  list (APPEND _options ${_files})
  add_executable (${_name} ${_options})
  CMS_SUBMIT_TARGET(${_name})
endfunction ()
