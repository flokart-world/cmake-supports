# - Try to find the LibXml2 xml processing library
# Once done this will define
#
#  LIBXML2_FOUND - System has LibXml2
#  LIBXML2_INCLUDE_DIRS - The LibXml2 include directories
#  LIBXML2_LIBRARY_DIRS - The LibXml2 library directories
#  LIBXML2_LIBRARIES - The libraries needed to use LibXml2
#  LIBXML2_DEFINITIONS - Compiler switches required for using LibXml2
#  LIBXML2_XMLLINT_EXECUTABLE - The XML checking tool xmllint coming with LibXml2
#  LIBXML2_VERSION_STRING - the version of LibXml2 found (since CMake 2.8.8)

#=============================================================================
# Copyright 2006-2009 Kitware, Inc.
# Copyright 2006 Alexander Neundorf <neundorf@kde.org>
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

CMS_ASSIGN_PACKAGE(LIBXML2 libxml-2.0)
PKG_CHECK_MODULES(PC_LIBXML QUIET libxml-2.0)

set (LIBXML2_DEFINITIONS "${PC_LIBXML_CFLAGS_OTHER}")

find_path (LIBXML2_INCLUDE_DIR NAMES libxml/xpath.h
           HINTS
           "${PC_LIBXML_INCLUDEDIR}"
           "${PC_LIBXML_INCLUDE_DIRS}"
           PATH_SUFFIXES libxml2)

find_library (LIBXML2_LIBRARIES NAMES xml2 libxml2
              HINTS
              "${PC_LIBXML_LIBDIR}"
              "${PC_LIBXML_LIBRARY_DIRS}")

find_program(LIBXML2_XMLLINT_EXECUTABLE xmllint)
# for backwards compat. with KDE 4.0.x:
set(XMLLINT_EXECUTABLE "${LIBXML2_XMLLINT_EXECUTABLE}")

if(PC_LIBXML_VERSION)
    set(LIBXML2_VERSION_STRING ${PC_LIBXML_VERSION})
elseif(LIBXML2_INCLUDE_DIR AND EXISTS "${LIBXML2_INCLUDE_DIR}/libxml/xmlversion.h")
    file(STRINGS "${LIBXML2_INCLUDE_DIR}/libxml/xmlversion.h" libxml2_version_str
         REGEX "^#define[\t ]+LIBXML_DOTTED_VERSION[\t ]+\".*\"")

    string(REGEX REPLACE "^#define[\t ]+LIBXML_DOTTED_VERSION[\t ]+\"([^\"]*)\".*" "\\1"
           LIBXML2_VERSION_STRING "${libxml2_version_str}")
    unset(libxml2_version_str)
endif()

set (LIBXML2_LIBRARY_DIR "${PC_LIBXML_LIBDIR}" CACHE PATH "")
list (APPEND LIBXML2_LIBRARIES ${PC_LIBXML_LIBRARIES})

# handle the QUIETLY and REQUIRED arguments and set LIBXML2_FOUND to TRUE if
# all listed variables are TRUE
include(FindPackageHandleStandardArgs)
FIND_PACKAGE_HANDLE_STANDARD_ARGS(LibXml2
                                  REQUIRED_VARS
                                  LIBXML2_LIBRARIES
                                  LIBXML2_INCLUDE_DIR
                                  LIBXML2_LIBRARY_DIR
                                  VERSION_VAR LIBXML2_VERSION_STRING)

mark_as_advanced(LIBXML2_INCLUDE_DIR
                 LIBXML2_LIBRARY_DIR
                 LIBXML2_LIBRARIES
                 LIBXML2_XMLLINT_EXECUTABLE)

set (LIBXML2_INCLUDE_DIRS "${PC_LIBXML_INCLUDE_DIRS}")
set (LIBXML2_LIBRARY_DIRS "${PC_LIBXML_LIBRARY_DIRS}")

CMS_REPLACE_MODULE_DIRS(LIBXML2
                        "${PC_LIBXML_INCLUDEDIR}"
                        "${PC_LIBXML_LIBDIR}")
CMS_PROMOTE_MODULE_DIRS(LIBXML2)
