# Copyright (c) 2014-2020 Flokart World, Inc.
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

include_guard ()

# CMAKE_CONFIGURATION_TYPES is empty on single-configuration build systems.
# For enumerating variables of default flags, use this instead.
set (CMS_DEFAULT_CONFIGURATION_TYPES DEBUG MINSIZEREL RELEASE RELWITHDEBINFO)

if (CMAKE_CXX_COMPILER_ID MATCHES "^(.*Clang|GNU)$")
  set (CMS_GNUCXX_COMPATIBLE true)
endif ()

# Gives the global list file a chance to hook them.
foreach (_purpose IN ITEMS C
                           CXX
                           EXE_LINKER
                           MODULE_LINKER
                           SHARED_LINKER
                           STATIC_LINKER)
  set (CMS_${_purpose}_FLAGS_OVERWRITE "${CMAKE_${_purpose}_FLAGS}")
  foreach (_buildType IN LISTS CMS_DEFAULT_CONFIGURATION_TYPES)
    set (CMS_${_purpose}_FLAGS_${_buildType}_OVERWRITE
         "${CMAKE_${_purpose}_FLAGS_${_buildType}}")
  endforeach ()
endforeach ()

# To be used from functions which set up the recommended flags.
macro (_CMS_EXPORT_OVERWRITTEN_FLAGS)
  foreach (_purpose IN ITEMS C
                             CXX
                             EXE_LINKER
                             MODULE_LINKER
                             SHARED_LINKER
                             STATIC_LINKER)
    CMS_PROMOTE_TO_PARENT_SCOPE(CMS_${_purpose}_FLAGS_OVERWRITE)
    foreach (_type IN LISTS CMS_DEFAULT_CONFIGURATION_TYPES)
      CMS_PROMOTE_TO_PARENT_SCOPE(CMS_${_purpose}_FLAGS_${_type}_OVERWRITE)
    endforeach ()
  endforeach ()
endmacro ()

if (MSVC)
  include ("${CMAKE_CURRENT_LIST_DIR}/Compilers/MSVC.cmake")
elseif (CMS_GNUCXX_COMPATIBLE)
  include ("${CMAKE_CURRENT_LIST_DIR}/Compilers/GNUCompatible.cmake")
else ()
  include ("${CMAKE_CURRENT_LIST_DIR}/Compilers/Unknown.cmake")
endif ()
