# Copyright (c) 2014 Flokart World, Inc.
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

function (CMS_ADD_DEFINITIONS)
  if (ARGN)
    list (APPEND CMS_DEFINITIONS "${ARGN}")
    CMS_PROMOTE_TO_PARENT_SCOPE(CMS_DEFINITIONS)
  else ()
    message (FATAL_ERROR "No definitions are specified.")
  endif ()
endfunction ()

function (CMS_DISABLE_MSVC_WARNINGS)
  if (ARGN)
    list (APPEND CMS_DISABLED_MSVC_WARNINGS "${ARGN}")
    CMS_PROMOTE_TO_PARENT_SCOPE(CMS_DISABLED_MSVC_WARNINGS)
  else ()
    message (FATAL_ERROR "No warnings are specified.")
  endif ()
endfunction ()

macro (CMS_PROJECT_VERSION _version)
  set (CMS_CURRENT_VERSION "${_version}")
endmacro ()

macro (CMS_PROJECT_DESCRIPTION _text)
  set (CMS_PACKAGE_DESCRIPTION "${_text}")
endmacro ()

macro (_CMS_PROMOTE_LIBRARY_HEADERS)
  CMS_PROMOTE_TO_PARENT_SCOPE(CMS_CURRENT_PUBLIC_DIR)
  CMS_PROMOTE_TO_PARENT_SCOPE(CMS_ADDITIONAL_FILES)
  CMS_OBJMAP_PROMOTE_TO_PARENT_SCOPE(CMS_HEADER_GROUPS)
endmacro ()

function (CMS_ADD_INCLUDE_SUBDIRECTORY _directory)
  set (CMS_IS_INCLUDE_DIR true)
  add_subdirectory ("${_directory}")
  _CMS_PROMOTE_LIBRARY_HEADERS()
endfunction ()

function (CMS_IMPORT_LIBRARY_INCLUDE_DIR _directory)
  set (CMS_IS_INCLUDE_DIR true)
  add_subdirectory ("${_directory}" "${CMAKE_CURRENT_BINARY_DIR}/include")
  _CMS_PROMOTE_LIBRARY_HEADERS()
endfunction ()

function (_CMS_INSTALL_LIBRARY_HEADERS)
  if (ARGN)
    foreach (_file IN LISTS ARGN)
      get_filename_component (_fullpath "${_file}" ABSOLUTE)
      get_filename_component (_directory "${_file}" DIRECTORY)
      list (APPEND CMS_ADDITIONAL_FILES "${_fullpath}")
      install (FILES "${_fullpath}" DESTINATION "include/${_directory}")
    endforeach ()

    CMS_SGM_ADD_FILES(CMS_HEADER_GROUPS "Header Files" "${ARGN}")

    _CMS_PROMOTE_LIBRARY_HEADERS()
  else ()
    message ("No file specified.")
  endif ()
endfunction ()

macro (CMS_LIBRARY_HEADERS)
  if (CMS_CURRENT_PUBLIC_DIR)
    message (FATAL_ERROR
             "CMS_LIBRARY_HEADERS can be called only once per project.")
  else ()
    _CMS_INSTALL_LIBRARY_HEADERS(${ARGN})
    set(CMS_CURRENT_PUBLIC_DIR "${CMAKE_CURRENT_SOURCE_DIR}")

    if (CMS_IS_INCLUDE_DIR)
      _CMS_PROMOTE_LIBRARY_HEADERS()
    endif ()
  endif ()
endmacro ()

macro (CMS_ADD_LIBRARY_HEADERS)
  message (WARNING "CMS_ADD_LIBRARY_HEADERS is obsolete. Use CMS_LIBRARY_HEADERS instead.")
  CMS_LIBRARY_HEADERS(${ARGN})
endmacro ()

function (CMS_INSTALL_LIBRARY_PACKAGE)
  CMS_CHECK_PREFIX()

  if (ARGN)
    list (GET ARGN 0 _name)
  else ()
    set (_name "${PROJECT_NAME}")
  endif ()

  if (NOT CMS_CURRENT_VERSION)
    message (WARNING "Version is not set.")
  endif ()

  if (NOT CMS_PACKAGE_DESCRIPTION)
    message (WARNING "Package description is not set.")
  endif ()

  CMS_ASSIGN_PACKAGE(${CMS_CURRENT_PREFIX} "${_name}")
  set (_var CMS_DOTPC_${_name})
  set (_filename "${_name}.pc.in")

  find_file (${_var} ${_filename} PATHS "${CMAKE_CURRENT_SOURCE_DIR}"
             NO_DEFAULT_PATH)
  mark_as_advanced (${_var})

  if (${_var})
    set (_input "${${_var}}")
  else ()
    message (STATUS "${_filename} not found. Using default.")
    set (_input "${CMS_PRIVATE_DIR}/DefaultLibraryPackage.pc.in")
  endif ()

  unset (CMS_REQUIRED_PACKAGES)

  foreach (_prefix IN LISTS CMS_IMPORTED_PREFIXES)
    set (_package ${${_prefix}_PACKAGE})

    if (_package)
      if (CMS_REQUIRED_PACKAGES)
        set (CMS_REQUIRED_PACKAGES "${CMS_REQUIRED_PACKAGES}, ${_package}")
      else ()
        set (CMS_REQUIRED_PACKAGES "${_package}")
      endif ()
    endif ()
  endforeach ()

  set (_dotpc "${PROJECT_BINARY_DIR}/${_name}.pc")
  set (CMS_CURRENT_PACKAGE "${_name}")
  configure_file (${_input} "${_dotpc}" @ONLY)
  install (FILES "${_dotpc}" DESTINATION "${CMS_DOTPC_DIR}")

  CMS_ASSIGN_PACKAGE(${CMS_CURRENT_PREFIX} "${_name}")
  CMS_PROMOTE_TO_PARENT_SCOPE(CMS_CURRENT_PACKAGE)
endfunction ()

function (CMS_INSTALL_MODULE _name)
  CMS_CHECK_PREFIX()

  if (NOT CMS_CURRENT_VERSION)
    message (FATAL_ERROR "Set the project version.")
  endif ()

  if (NOT CMS_CURRENT_PACKAGE)
    message (FATAL_ERROR "Install the current package first.")
  endif ()

  set (CMS_CURRENT_MODULE "${_name}")

  set (_var CMS_MODULE_${_name})
  set (_filename "Find${_name}.cmake")

  find_file (${_var} ${_filename}.in ${_filename}
             PATHS "${CMAKE_CURRENT_SOURCE_DIR}"
                   "${CMAKE_CURRENT_SOURCE_DIR}/cmake"
             NO_DEFAULT_PATH)
  mark_as_advanced (${_var})

  if (${_var})
    set (_input "${${_var}}")
    get_filename_component (_ext "${_input}" EXT)

    if (_ext STREQUAL ".cmake.in")
      set (_configure true)
    else ()
      set (_module "${_input}")
    endif ()
  else ()
    message (STATUS "${_filename}(.in)? not found. Using default.")
    set (_input "${CMS_PRIVATE_DIR}/DefaultModule.cmake.in")
    set (_configure true)
  endif ()

  if (_configure)
    set (_module "${PROJECT_BINARY_DIR}/${_filename}")
    configure_file (${_input} "${_module}" @ONLY)
  endif ()

  install (FILES "${_module}" DESTINATION "${CMS_MODULE_DIR}")
  set (CMS_CURRENT_MODULE "${CMS_CURRENT_MODULE}" PARENT_SCOPE)
endfunction ()

macro (CMS_APPLY_DEPENDENCIES)
  if (${CMS_CURRENT_PREFIX}_INCLUDE_DIRS)
    include_directories (${${CMS_CURRENT_PREFIX}_INCLUDE_DIRS})
  endif ()

  if (${CMS_CURRENT_PREFIX}_LIBRARY_DIRS)
    link_directories (${${CMS_CURRENT_PREFIX}_LIBRARY_DIRS})
  endif ()
endmacro ()

macro (CMS_BEGIN_TARGET _name)
  set (CMS_CURRENT_TARGET_NAME "${_name}")
  unset (CMS_SOURCE_FILES)
endmacro ()

macro (CMS_CHECK_TARGET)
  if (NOT CMS_CURRENT_TARGET_NAME)
    message (FATAL_ERROR "Target definition has not begun.")
  endif ()
endmacro ()

macro (CMS_SOURCE_FILES_COMPILE_DEFINITIONS)
  CMS_CHECK_TARGET()
  CMS_SFPM_ADD_VALUES(CMS_SOURCE_DEFINITIONS DEFINITIONS "definitions" ${ARGN})
endmacro ()

macro (CMS_SOURCE_FILES_COMPILE_FLAGS)
  CMS_CHECK_TARGET()
  CMS_SFPM_ADD_VALUES(CMS_SOURCE_FLAGS FLAGS "flags" ${ARGN})
endmacro ()

function (CMS_SOURCE_FILES_DISABLE_MSVC_WARNINGS)
  CMS_CHECK_TARGET()

  if (ARGN)
    unset (_files)
    unset (_flags)

    while (ARGN)
      list (GET ARGN 0 _arg)
      list (REMOVE_AT ARGN 0)

      if (_arg STREQUAL "WARNINGS")
        break()
      else ()
        list (APPEND _files "${_arg}")
      endif ()
    endwhile ()

    if (ARGN)
      foreach (_number IN LISTS ARGN)
        list (APPEND _flags "/wd${_number}")
      endforeach ()

      CMS_SOURCE_FILES_COMPILE_FLAGS("${_files}" FLAGS "${_flags}")
      CMS_OBJMAP_PROMOTE_TO_PARENT_SCOPE(CMS_SOURCE_FLAGS)
    else ()
      message (FATAL_ERROR "No warnings specified.")
    endif ()
  else ()
    message (FATAL_ERROR "No files specified.")
  endif ()
endfunction ()

macro (CMS_BEGIN_LIBRARY_C _name)
  CMS_CHECK_PREFIX()
  set (CMS_CURRENT_LIBRARY_LANG C)

  if (NOT _name)
    set (_name "${CMAKE_PROJECT_NAME}")
  endif ()

  CMS_BEGIN_TARGET("${_name}")

  set (CMS_CURRENT_LIBRARY_NAME "${_name}")
  unset (_name)
endmacro ()

macro (CMS_BEGIN_LIBRARY_CXX _name)
  CMS_CHECK_PREFIX()
  set (CMS_CURRENT_LIBRARY_LANG CXX)

  if (NOT _name)
    set (_name "${CMAKE_PROJECT_NAME}")
  endif ()

  CMS_BEGIN_TARGET("${_name}")

  string (REGEX REPLACE "^lib" "" _newname "${_name}")
  set (CMS_CURRENT_LIBRARY_NAME "${_newname}${CMS_TOOLSET_SUFFIX_CXX}")
  unset (_name)

  if (CMS_CURRENT_VERSION)
    string (REGEX REPLACE "^((\\d+)(\\.\\d+)?)" "\\1"
            CMS_CURRENT_LIBRARY_SUFFIX "${CMS_CURRENT_VERSION}")
    string (REPLACE "." "_"
            CMS_CURRENT_LIBRARY_SUFFIX "${CMS_CURRENT_LIBRARY_SUFFIX}")
    set (CMS_CURRENT_LIBRARY_SUFFIX "-${CMS_CURRENT_LIBRARY_SUFFIX}")
  else ()
    unset (CMS_CURRENT_LIBRARY_SUFFIX)
  endif ()

  if (WIN32)
    set (CMS_CURRENT_LIBRARY_NAME "${CMS_CURRENT_LIBRARY_NAME}-mt")
  endif ()
endmacro ()

macro (CMS_CHECK_LIBRARY)
  if (NOT CMS_CURRENT_LIBRARY_NAME)
    message (FATAL_ERROR "Library definition has not begun.")
  endif ()
endmacro ()

function (CMS_ADD_SOURCE_FILES)
  if (ARGN)
    foreach (_file IN LISTS ARGN)
      get_filename_component (_fullpath "${_file}" ABSOLUTE)
      list (APPEND CMS_SOURCE_FILES "${_fullpath}")
    endforeach ()

    CMS_PROMOTE_TO_PARENT_SCOPE(CMS_SOURCE_FILES)

    CMS_SGM_ADD_FILES(CMS_SOURCE_GROUPS "Source Files" "${ARGN}")
    CMS_OBJMAP_PROMOTE_TO_PARENT_SCOPE(CMS_SOURCE_GROUPS)
  else ()
    message (FATAL_ERROR "No source files are specified.")
  endif ()
endfunction ()

macro (_CMS_END_TARGET)
  unset (CMS_SOURCE_FILES)
  unset (CMS_CURRENT_TARGET_NAME)
endmacro ()

macro (_CMS_END_LIBRARY_C)
  set_target_properties ("${CMS_CURRENT_TARGET_NAME}"
                         PROPERTIES LINKER_LANGUAGE C
                         OUTPUT_NAME
                         "${CMS_CURRENT_LIBRARY_NAME}"
                         OUTPUT_NAME_DEBUG
                         "${CMS_CURRENT_LIBRARY_NAME}d")
endmacro ()

macro (_CMS_END_LIBRARY_CXX)
  set_target_properties ("${CMS_CURRENT_TARGET_NAME}"
      PROPERTIES LINKER_LANGUAGE CXX
      OUTPUT_NAME
      "lib${CMS_CURRENT_LIBRARY_NAME}${CMS_CURRENT_LIBRARY_SUFFIX}"
      OUTPUT_NAME_DEBUG
      "lib${CMS_CURRENT_LIBRARY_NAME}-gd${CMS_CURRENT_LIBRARY_SUFFIX}")
endmacro ()

function (_CMS_FLUSH_SOURCE_SPECIFIC_SETTINGS)
  if (MSVC AND CMS_DISABLED_MSVC_WARNINGS)
    # All /wd flags must be specified for each file if modified.
    CMS_SOURCE_FILES_DISABLE_MSVC_WARNINGS("${CMS_SOURCE_FLAGS_KEYS}"
                                           WARNINGS
                                           "${CMS_DISABLED_MSVC_WARNINGS}")
  endif ()

  CMS_SFFM_WRITE(CMS_SOURCE_FLAGS COMPILE_FLAGS)
  CMS_SFDM_WRITE(CMS_SOURCE_DEFINITIONS COMPILE_DEFINITIONS)
endfunction ()

function (_CMS_FLUSH_DISABLED_MSVC_WARNINGS)
  unset (_flags)

  foreach (_number IN LISTS CMS_DISABLED_MSVC_WARNINGS)
    list (APPEND _flags "/wd${_number}")
  endforeach ()

  target_compile_options ("${CMS_CURRENT_TARGET_NAME}" PUBLIC ${_flags})
endfunction ()

macro (_CMS_FLUSH_TARGET_SETTINGS)
  if (CMS_DEFINITIONS)
    target_compile_definitions ("${CMS_CURRENT_TARGET_NAME}" PUBLIC
                                ${CMS_DEFINITIONS})
  endif ()

  if (MSVC)
    if (NOT CMS_DISABLE_MSVC_DEFAULT_OPTIONS)
      target_compile_options ("${CMS_CURRENT_TARGET_NAME}" PUBLIC
          $<$<CONFIG:MinSizeRel>:/Os>)
      target_compile_options ("${CMS_CURRENT_TARGET_NAME}" PUBLIC
          $<$<OR:$<CONFIG:Release>,$<CONFIG:RelWithDebInfo>>:/Oi /Ot>)
      target_compile_options ("${CMS_CURRENT_TARGET_NAME}" PUBLIC
          $<$<OR:$<CONFIG:MinSizeRel>,$<CONFIG:Release>>:/Oy>)
      target_compile_options ("${CMS_CURRENT_TARGET_NAME}" PUBLIC
          $<$<NOT:$<CONFIG:Debug>>:/GL /GS->)
      target_compile_options ("${CMS_CURRENT_TARGET_NAME}" PUBLIC
          /W4 /fp:fast)
      set_target_properties ("${CMS_CURRENT_TARGET_NAME}" PROPERTIES
                             LINK_FLAGS
                             "/LTCG"
                             LINK_FLAGS_DEBUG
                             "/LTCG-")
    endif ()

    _CMS_FLUSH_DISABLED_MSVC_WARNINGS()
  endif ()

  _CMS_FLUSH_SOURCE_SPECIFIC_SETTINGS()
  CMS_SGM_WRITE(CMS_HEADER_GROUPS)
  CMS_SGM_WRITE(CMS_SOURCE_GROUPS)
  CMS_MAP_CLEAR(CMS_SOURCE_GROUPS)
  CMS_MAP_CLEAR(CMS_SOURCE_FLAGS)
  CMS_MAP_CLEAR(CMS_SOURCE_DEFINITIONS)
endmacro ()

macro (CMS_END_LIBRARY)
  CMS_CHECK_PREFIX()
  CMS_CHECK_LIBRARY()

  CMS_RESOLVE_DEPENDENCIES()

  if (CMS_CURRENT_PUBLIC_DIR)
    set (${CMS_CURRENT_PREFIX}_INCLUDE_DIR
         "${CMS_CURRENT_PUBLIC_DIR}" CACHE PATH "" FORCE)
    mark_as_advanced (${CMS_CURRENT_PREFIX}_INCLUDE_DIR)
    set (${CMS_CURRENT_PREFIX}_INCLUDE_DIRS
         "${${CMS_CURRENT_PREFIX}_INCLUDE_DIRS}"
         "${CMS_CURRENT_PUBLIC_DIR}"
         CACHE INTERNAL "" FORCE)
  else ()
    message (FATAL_ERROR "No library headers added.")
  endif ()

  CMS_APPLY_DEPENDENCIES()

  add_library ("${CMS_CURRENT_TARGET_NAME}"
               ${CMS_SOURCE_FILES}
               ${CMS_ADDITIONAL_FILES})

  _CMS_FLUSH_TARGET_SETTINGS()

  if (CMS_CURRENT_LIBRARY_LANG STREQUAL "C")
    _CMS_END_LIBRARY_C()
  elseif (CMS_CURRENT_LIBRARY_LANG STREQUAL "CXX")
    _CMS_END_LIBRARY_CXX()
  endif ()

  install (TARGETS "${CMS_CURRENT_TARGET_NAME}" DESTINATION lib)
  unset (CMS_CURRENT_LIBRARY_NAME)
  _CMS_END_TARGET()
endmacro ()

# Each project shouldn't inherit the parent's settings.

CMS_MAP_CLEAR(CMS_HEADER_GROUPS)
unset (CMS_PACKAGE_DESCRIPTION)
unset (CMS_CURRENT_VERSION)
unset (CMS_DISABLED_MSVC_WARNINGS)
unset (CMS_DEFINITIONS)
unset (CMS_CURRENT_PUBLIC_DIR)
unset (CMS_CURRENT_INCLUDE_DIRS)
