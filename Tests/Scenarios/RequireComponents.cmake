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

TESTS_ADD_CMAKE_SCENARIO(
  require-components-fully-satisfied
  PROJECT
    require-components
  OPTIONS
    -D BUILD_OurSubModule=ON
    -D BUILD_OurExecutable=ON
    -D "RequireComponents_COMPONENTS=my-lib our-lib"
)

TESTS_ADD_CMAKE_SCENARIO(
  require-components-missing-and-producing-error
  PROJECT
    require-components
  OPTIONS
    -D BUILD_OurSubModule=ON
    -D BUILD_OurExecutable=ON
    -D "RequireComponents_COMPONENTS=my-lib our-lib invalid-lib"
  PROPERTIES
    PASS_REGULAR_EXPRESSION
      "some[ \n]+required[ \n]+components[ \n]+are[ \n]+missing:[ \n]+invalid-lib"
)
