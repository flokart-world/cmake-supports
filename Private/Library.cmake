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

function (CMS_DEFINE_LIBRARY _name)
  CMS_DEFINE_TARGET(${_name})
  CMS_INHERIT_PROPERTY(ExportName)
endfunction ()

function (CMS_SUBMIT_LIBRARY _name)
  message (STATUS "Emitting the library ${_name}.")

  CMS_PREPARE_TARGET(_files)
  add_library (${_name} ${_files})
  CMS_SUBMIT_TARGET(${_name})
endfunction ()
