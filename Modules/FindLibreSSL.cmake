# Copyright (c) 2016 BPS Co., Ltd.
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
#    3. This notice may not be removed or altered from any source
#    distribution.

PKG_CHECK_MODULES(PC_LIBRESSL QUIET libressl)

find_path (LibreSSL_INCLUDE_DIR NAMES tls.h
           HINTS
           "${PC_LIBRESSL_INCLUDEDIR}"
           "${PC_LIBRESSL_INCLUDE_DIRS}")

set (LibreSSL_LIBRARY_DIR "${PC_LIBRESSL_LIBDIR}"
     CACHE PATH "LibreSSL library directory")
set (_hints "${PC_LIBRESSL_LIBDIR}"
            "${PC_LIBRESSL_LIBRARY_DIRS}")

set (LibreSSL_LIBRARIES "")
set (_extraNamesCRYPTO crypto-38)

foreach (_name crypto tls ssl)
    string (TOUPPER ${_name} _suffix)

    set (_names "${_name}")
    if (_extraNames${_suffix})
        list (APPEND _names "${_extraNames${_suffix}}")
    endif ()

    find_library (LibreSSL_LIBRARY_${_suffix} NAMES ${_names}
                                              HINTS ${_hints})
    list (APPEND LibreSSL_LIBRARIES ${LibreSSL_LIBRARY_${_suffix}})
endforeach ()

set (LibreSSL_INCLUDE_DIRS "${LibreSSL_INCLUDE_DIR}")
set (LibreSSL_VERSION_STRING "${PC_LIBRESSL_VERSION}")

include (FindPackageHandleStandardArgs)
FIND_PACKAGE_HANDLE_STANDARD_ARGS(LibreSSL
                                  REQUIRED_VARS
                                  LibreSSL_LIBRARY_CRYPTO
                                  LibreSSL_LIBRARY_SSL
                                  LibreSSL_LIBRARY_TLS
                                  LibreSSL_INCLUDE_DIR
                                  LibreSSL_LIBRARY_DIR
                                  VERSION_VAR
                                  LibreSSL_VERSION_STRING)

mark_as_advanced (LibreSSL_LIBRARY_CRYPTO
                  LibreSSL_LIBRARY_SSL
                  LibreSSL_LIBRARY_TLS
                  LibreSSL_INCLUDE_DIR
                  LibreSSL_LIBRARY_DIR)
