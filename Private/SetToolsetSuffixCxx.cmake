# The function was copied from FindBoost.cmake
#=============================================================================
# Copyright 2006-2009 Kitware, Inc.
# Copyright 2006-2008 Andreas Schneider <mail@cynapses.org>
# Copyright 2007      Wengo
# Copyright 2007      Mike Jackson
# Copyright 2008      Andreas Pakulat <apaku@gmx.de>
# Copyright 2008-2012 Philip Lowman <philip@yhbt.com>
# Copyright 2014      Flokart World, Inc.
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

function(_Boost_GUESS_COMPILER_PREFIX _ret)
  if("${CMAKE_CXX_COMPILER_ID}" STREQUAL "Intel"
      OR "${CMAKE_CXX_COMPILER}" MATCHES "icl"
      OR "${CMAKE_CXX_COMPILER}" MATCHES "icpc")
    if(WIN32)
      set (_boost_COMPILER "-iw")
    else()
      set (_boost_COMPILER "-il")
    endif()
  elseif (MSVC11)
    set(_boost_COMPILER "-vc110")
  elseif (MSVC10)
    set(_boost_COMPILER "-vc100")
  elseif (MSVC90)
    set(_boost_COMPILER "-vc90")
  elseif (MSVC80)
    set(_boost_COMPILER "-vc80")
  elseif (MSVC71)
    set(_boost_COMPILER "-vc71")
  elseif (MSVC70) # Good luck!
    set(_boost_COMPILER "-vc7") # yes, this is correct
  elseif (MSVC60) # Good luck!
    set(_boost_COMPILER "-vc6") # yes, this is correct
  elseif (BORLAND)
    set(_boost_COMPILER "-bcb")
  elseif("${CMAKE_CXX_COMPILER_ID}" STREQUAL "SunPro")
    set(_boost_COMPILER "-sw")
  elseif (MINGW)
    if(${Boost_MAJOR_VERSION}.${Boost_MINOR_VERSION} VERSION_LESS 1.34)
        set(_boost_COMPILER "-mgw") # no GCC version encoding prior to 1.34
    else()
      _Boost_COMPILER_DUMPVERSION(_boost_COMPILER_VERSION)
      set(_boost_COMPILER "-mgw${_boost_COMPILER_VERSION}")
    endif()
  elseif (UNIX)
    if (CMAKE_COMPILER_IS_GNUCXX)
      if(${Boost_MAJOR_VERSION}.${Boost_MINOR_VERSION} VERSION_LESS 1.34)
        set(_boost_COMPILER "-gcc") # no GCC version encoding prior to 1.34
      else()
        _Boost_COMPILER_DUMPVERSION(_boost_COMPILER_VERSION)
        # Determine which version of GCC we have.
        if(APPLE)
          if(Boost_MINOR_VERSION)
            if(${Boost_MINOR_VERSION} GREATER 35)
              # In Boost 1.36.0 and newer, the mangled compiler name used
              # on Mac OS X/Darwin is "xgcc".
              set(_boost_COMPILER "-xgcc${_boost_COMPILER_VERSION}")
            else()
              # In Boost <= 1.35.0, there is no mangled compiler name for
              # the Mac OS X/Darwin version of GCC.
              set(_boost_COMPILER "")
            endif()
          else()
            # We don't know the Boost version, so assume it's
            # pre-1.36.0.
            set(_boost_COMPILER "")
          endif()
        else()
          set(_boost_COMPILER "-gcc${_boost_COMPILER_VERSION}")
        endif()
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
