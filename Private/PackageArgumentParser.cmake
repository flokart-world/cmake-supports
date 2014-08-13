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

# This pseudo configuration is loaded by CMS_LOAD_PACKAGE() in Package.cmake.
# Assumes that variable _prefix and _packageName are given.

set (${_packageName}_FOUND true)

foreach (_member REQUIRED
                 QUIETLY
                 VERSION
                 VERSION_MAJOR
                 VERSION_MINOR
                 VERSION_PATCH
                 VERSION_TWEAK
                 VERSION_COUNT
                 VERSION_EXACT
                 COMPONENTS)
  set (${_prefix}_${_member} ${${_packageName}_FIND_${_member}})
endforeach ()

set (${_prefix}_REQUIRED_COMPONENTS "")
set (${_prefix}_OPTIONAL_COMPONENTS "")

foreach (_component IN LISTS ${_prefix}_COMPONENTS)
  if (${_packageName}_FIND_REQUIRED_${_component})
    set (_type REQUIRED)
  else ()
    set (_type OPTIONAL)
  endif ()

  list (APPEND ${_prefix}_${_type}_COMPONENTS ${_component})
endforeach ()
