# - this module looks for Cygwin
#

#=============================================================================
# Copyright 2001-2009 Kitware, Inc.
# Copyright 2014 Flokart World, Inc.
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

if (WIN32)
  set (_CYGWIN_PARENT "HKEY_LOCAL_MACHINE\\SOFTWARE")
  unset (_CYGWIN_HINTS)

  foreach (_dir
           "C:/Cygwin"
           "[${_CYGWIN_PARENT}\\Cygwin\\setup;rootdir]"
           "[${_CYGWIN_PARENT}\\Cygnus Solutions\\Cygwin\\mounts v2\\/;native]")

    get_filename_component (_CYGWIN_HINT "${_dir}" ABSOLUTE)
    list (APPEND _CYGWIN_HINTS "${_CYGWIN_HINT}")
  endforeach ()

  find_path (CYGWIN_INSTALL_PATH cygwin.bat ${_CYGWIN_HINTS})
  mark_as_advanced (CYGWIN_INSTALL_PATH)
endif ()
