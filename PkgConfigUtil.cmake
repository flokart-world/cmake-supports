# Copyright (c) 2014 BPS Co., Ltd.
# All rights reserved.

include (FindPackageHandleStandardArgs)
find_package(PkgConfig REQUIRED)

macro (FIND_PC_PACKAGE _varname _libname)
  PKG_CHECK_MODULES(_pc_${_varname} ${_libname})

  if (${_pc_${_varname}_FOUND})
    set (${_varname}_INCLUDE_DIRS ${_pc_${_varname}_INCLUDE_DIRS})
    set (${_varname}_LIBRARY_DIRS ${_pc_${_varname}_LIBRARY_DIRS})
    set (${_varname}_FOUND true)
  endif ()
endmacro ()
