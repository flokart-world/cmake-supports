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

CMS_BEGIN(Module OurModule)
  CMS_SET_PROPERTY(Version 1.0.0)

  CMS_BEGIN(Executable test-executable-a)
    CMS_IMPORT_PACKAGE(OurExternalLib REQUIRED COMPONENTS ext-a)
    CMS_ADD_SOURCE_FILES(main_calling_a.c)
  CMS_END()

  CMS_BEGIN(Executable test-executable-b1)
    CMS_IMPORT_PACKAGE(OurExternalLib REQUIRED COMPONENTS ext-b-variant1)
    CMS_ADD_SOURCE_FILES(main_calling_b.c a.c)
  CMS_END()

  CMS_BEGIN(Executable test-executable-b2)
    CMS_IMPORT_PACKAGE(OurExternalLib REQUIRED COMPONENTS ext-b-variant2)
    CMS_ADD_SOURCE_FILES(main_calling_b.c a.c)
  CMS_END()

  CMS_BEGIN(Executable test-executable-ab1)
    CMS_IMPORT_PACKAGE(OurExternalLib REQUIRED COMPONENTS ext-a ext-b-variant1)
    CMS_ADD_SOURCE_FILES(main_calling_both.c)
  CMS_END()

  CMS_BEGIN(Executable test-executable-b1-again)
    CMS_IMPORT_PACKAGE(OurExternalLib REQUIRED COMPONENTS ext-b-variant1)
    CMS_ADD_SOURCE_FILES(main_calling_b.c a.c)
  CMS_END()

  CMS_BEGIN(Executable test-executable-ab2)
    CMS_IMPORT_PACKAGE(OurExternalLib REQUIRED COMPONENTS ext-a ext-b-variant2)
    CMS_ADD_SOURCE_FILES(main_calling_both.c)
  CMS_END()
CMS_END()
