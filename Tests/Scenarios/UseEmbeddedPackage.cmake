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
  use-embedded-package-with-bundled-module
  PROJECT
    use-embedded-package
  OPTIONS
    -D BUILD_OurSubModule=ON
  PROPERTIES
    PASS_REGULAR_EXPRESSION "Hello!"
)

TESTS_ADD_CMAKE_SCENARIO(
  use-embedded-package-without-bundled-module
  PROJECT
    use-embedded-package
  OPTIONS
    -D BUILD_OurSubModule=OFF
  PROPERTIES
    PASS_REGULAR_EXPRESSION "Hello!"
    FAIL_REGULAR_EXPRESSION "Falling back to buliding the bundled one"
)

TESTS_ADD_CMAKE_SCENARIO(
  use-embedded-package-via-installed-module
  PROJECT
    use-embedded-package
  OPTIONS
    -D CMAKE_MODULE_PATH=${CMAKE_SOURCE_DIR}/Modules
    -D BUILD_OurSubModule=OFF
  PROPERTIES
    PASS_REGULAR_EXPRESSION "Hello!"
    FAIL_REGULAR_EXPRESSION "Falling back to buliding the bundled one"
)
