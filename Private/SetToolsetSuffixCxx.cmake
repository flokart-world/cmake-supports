# cf. https://cmake.org/licensing/
#=============================================================================
# Copyright 2000-2018 Kitware, Inc. and Contributors
# Copyright 2014-2020 Flokart World, Inc.
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions
# are met:
# 
# * Redistributions of source code must retain the above copyright
#   notice, this list of conditions and the following disclaimer.
# 
# * Redistributions in binary form must reproduce the above copyright
#   notice, this list of conditions and the following disclaimer in the
#   documentation and/or other materials provided with the distribution.
# 
# * Neither the names of Kitware, Inc., the Insight Software Consortium,
#   nor the names of their contributors may be used to endorse or promote
#   products derived from this software without specific prior written
#   permission.
# 
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
# "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
# LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
# A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
# HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
# SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
# LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
# DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
# THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
# (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
# OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#=============================================================================

# Copied from FindBoost.cmake
function(_Boost_COMPILER_DUMPVERSION _OUTPUT_VERSION)
  string(REGEX REPLACE "([0-9]+)\\.([0-9]+)(\\.[0-9]+)?" "\\1\\2"
    _boost_COMPILER_VERSION ${CMAKE_CXX_COMPILER_VERSION})

  set(${_OUTPUT_VERSION} ${_boost_COMPILER_VERSION} PARENT_SCOPE)
endfunction()

# Based on the function with same name in FindBoost.cmake
function(_Boost_GUESS_COMPILER_PREFIX _ret)
  if("x${CMAKE_CXX_COMPILER_ID}" STREQUAL "xIntel")
    if(WIN32)
      set (_boost_COMPILER "-iw")
    else()
      set (_boost_COMPILER "-il")
    endif()
  elseif (GHSMULTI)
    set(_boost_COMPILER "-ghs")
  elseif("x${CMAKE_CXX_COMPILER_ID}" STREQUAL "xMSVC")
    if(NOT CMAKE_CXX_COMPILER_VERSION VERSION_LESS 19.20)
      set(_boost_COMPILER "-vc142")
    elseif(NOT CMAKE_CXX_COMPILER_VERSION VERSION_LESS 19.10)
      set(_boost_COMPILER "-vc141")
    elseif(NOT CMAKE_CXX_COMPILER_VERSION VERSION_LESS 19)
      set(_boost_COMPILER "-vc140")
    elseif(NOT CMAKE_CXX_COMPILER_VERSION VERSION_LESS 18)
      set(_boost_COMPILER "-vc120")
    elseif(NOT CMAKE_CXX_COMPILER_VERSION VERSION_LESS 17)
      set(_boost_COMPILER "-vc110")
    elseif(NOT CMAKE_CXX_COMPILER_VERSION VERSION_LESS 16)
      set(_boost_COMPILER "-vc100")
    elseif(NOT CMAKE_CXX_COMPILER_VERSION VERSION_LESS 15)
      set(_boost_COMPILER "-vc90")
    elseif(NOT CMAKE_CXX_COMPILER_VERSION VERSION_LESS 14)
      set(_boost_COMPILER "-vc80")
    elseif(NOT CMAKE_CXX_COMPILER_VERSION VERSION_LESS 13.10)
      set(_boost_COMPILER "-vc71")
    elseif(NOT CMAKE_CXX_COMPILER_VERSION VERSION_LESS 13) # Good luck!
      set(_boost_COMPILER "-vc7") # yes, this is correct
    else() # VS 6.0 Good luck!
      set(_boost_COMPILER "-vc6") # yes, this is correct
    endif()
  elseif (BORLAND)
    set(_boost_COMPILER "-bcb")
  elseif(CMAKE_CXX_COMPILER_ID STREQUAL "SunPro")
    set(_boost_COMPILER "-sw")
  elseif(CMAKE_CXX_COMPILER_ID STREQUAL "XL")
    set(_boost_COMPILER "-xlc")
  elseif (MINGW)
    _Boost_COMPILER_DUMPVERSION(_boost_COMPILER_VERSION)
    set(_boost_COMPILER "-mgw${_boost_COMPILER_VERSION}")
  elseif (UNIX)
    if (CMAKE_COMPILER_IS_GNUCXX)
      _Boost_COMPILER_DUMPVERSION(_boost_COMPILER_VERSION)
      # Determine which version of GCC we have.
      if(APPLE)
        set(_boost_COMPILER "-xgcc${_boost_COMPILER_VERSION}")
      else()
        set(_boost_COMPILER "-gcc${_boost_COMPILER_VERSION}")
      endif()
    endif ()
  else()
    # TODO at least Boost_DEBUG here?
    set(_boost_COMPILER "")
  endif()
  set(${_ret} ${_boost_COMPILER} PARENT_SCOPE)
endfunction()

_Boost_GUESS_COMPILER_PREFIX(_cms_suffix_cxx)

set (CMS_TOOLSET_SUFFIX_CXX "${_cms_suffix_cxx}" CACHE STRING
     "The suffix string which is put after the names of the C++ libraries")
mark_as_advanced (CMS_TOOLSET_SUFFIX_CXX)
