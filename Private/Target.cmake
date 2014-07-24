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
#    3. This notice may not be removed or altered from any source distribution.

function (CMS_DEFINE_TARGET _name)
  CMS_GET_PROPERTY(_parentType Type)

  if (NOT _parentType STREQUAL "None"
      AND NOT _parentType STREQUAL "Module"
      AND NOT _parentType STREQUAL "EmbeddedPackage")
    message (FATAL_ERROR "Target definition is not allowed here.")
  endif ()

  CMS_DEFINE_NAMESPACE(${_name})
  CMS_DEFINE_PROPERTY(GeneratedFiles)
  CMS_DEFINE_PROPERTY(LinkFlags)
  CMS_DEFINE_PROPERTY(LinkerLanguage)
  CMS_DEFINE_PROPERTY(OutputName)
  CMS_DEFINE_PROPERTY(OutputSuffixDebug)
  CMS_DEFINE_PROPERTY(OutputSuffixVersion)
  CMS_DEFINE_PROPERTY(SourceFiles)

  CMS_INHERIT_PROPERTY(CompileOptions)
  CMS_INHERIT_PROPERTY(CompileDefinitions)
  CMS_INHERIT_PROPERTY(IncludeDirectories)
  CMS_INHERIT_PROPERTY(LinkDirectories)
  CMS_INHERIT_PROPERTY(LinkLibraries)
  CMS_INHERIT_PROPERTY(PublicHeaders)
  CMS_INHERIT_PROPERTY(PublicHeaderDirectories)
  CMS_INHERIT_PROPERTY(RequiredPackages)
  CMS_INHERIT_PROPERTY(SourceGroups)
  CMS_INHERIT_PROPERTY(Version)

  CMS_GET_PROPERTY(_groups SourceGroups)

  foreach (_group IN LISTS _groups)
    set (_name "SourceGroup[${_group}]")

    CMS_DEFINE_PROPERTY(${_name})
    CMS_INHERIT_PROPERTY(${_name})
  endforeach ()

  get_property (_defaultOptions GLOBAL PROPERTY CMS::DefaultCompilerOptions)

  if (_defaultOptions)
    CMS_APPEND_TO_PROPERTY(CompileOptions PRIVATE ${_defaultOptions})
  endif ()
endfunction ()

function (CMS_DEFINE_SOURCE_FILE_PROPERTIES _fullPath)
  set (_prefix "SourceFile[${_fullPath}]::")
  CMS_DEFINE_PROPERTY("${_prefix}CompileDefinitions")
  CMS_DEFINE_PROPERTY("${_prefix}CompileOptions")
endfunction ()

function (CMS_APPEND_TO_SOURCE_FILE_PROPERTY _file _name)
  get_filename_component (_fullPath "${_file}" ABSOLUTE)
  CMS_APPEND_TO_PROPERTY("SourceFile[${_fullPath}]::${_name}" ${ARGN})
endfunction ()

function (CMS_SOURCE_FILES_DISABLE_MSVC_WARNINGS)

  # TODO : Delete them.
  CMS_GET_PROPERTY(_type Type)
  if (_type STREQUAL "None")
    CMS_SOURCE_FILES_DISABLE_MSVC_WARNINGS_OLD(${ARGN})
    CMS_OBJMAP_PROMOTE_TO_PARENT_SCOPE(CMS_SOURCE_FLAGS)
    return ()
  endif ()

  set (_files "")

  while (ARGN)
    list (GET ARGN 0 _arg)
    list (REMOVE_AT ARGN 0)

    if (_arg STREQUAL "WARNINGS")
      break ()
    else ()
      list (APPEND _files "${_arg}")
    endif ()
  endwhile ()

  if (_files)
    CMS_OPTIONS_DISABLE_MSVC_WARNINGS(_options ${ARGN})

    foreach (_file IN LISTS _files)
      CMS_APPEND_TO_SOURCE_FILE_PROPERTY("${_file}" CompileOptions ${_options})
    endforeach ()
  else ()
    message (FATAL_ERROR "No files are specified.")
  endif ()
endfunction ()

function (CMS_ADD_SOURCE_FILES)

  # TODO : Delete them.
  CMS_GET_PROPERTY(_type Type)
  if (_type STREQUAL "None")
    CMS_ADD_SOURCE_FILES_OLD(${ARGN})
    CMS_PROMOTE_TO_PARENT_SCOPE(CMS_SOURCE_FILES)
    CMS_OBJMAP_PROMOTE_TO_PARENT_SCOPE(CMS_SOURCE_GROUPS)
    return ()
  endif ()

  if (ARGN)
    set (_files "")
    list (GET ARGN -1 _last)

    if (_last STREQUAL "NO_GROUP")
      list (REMOVE_AT ARGN -1)
      set (_group false)
    else ()
      set (_group true)
    endif ()

    foreach (_file IN LISTS ARGN)
      get_filename_component (_ext "${_file}" EXT)
      get_filename_component (_fullPath "${_file}" ABSOLUTE)

      if (_group)
        if (_ext MATCHES "^\\.(asm|c|cc|cpp|cxx|m|mm|S)$")
          set (_category "Source Files")
        elseif (_ext MATCHES "^\\.(h|hh|hpp|hxx|inl)(\\.in)?$")
          set (_category "Header Files")
        else ()
          set (_category "")
        endif ()

        if (_category)
          CMS_GROUP_FILE("${_category}" "${_file}" "${_fullPath}")
        endif ()
      endif ()

      CMS_DEFINE_SOURCE_FILE_PROPERTIES("${_fullPath}")
      list (APPEND _files "${_fullPath}")
    endforeach ()

    CMS_APPEND_TO_PROPERTY(SourceFiles "${_files}")
  else ()
    message (FATAL_ERROR "No files are specified.")
  endif ()
endfunction ()

function (CMS_ADD_GENERATED_FILES)

  # TODO : Delete them.
  CMS_GET_PROPERTY(_type Type)
  if (_type STREQUAL "None")
    CMS_ADD_GENERATED_FILES_OLD("${ARGN}")
    CMS_PROMOTE_TO_PARENT_SCOPE(CMS_GENERATED_FILES)
    return ()
  endif ()

  if (ARGN)
    set (_files "")

    foreach (_file IN LISTS ARGN)
      get_filename_component (_fullPath "${_file}" ABSOLUTE)
      CMS_GROUP_FILE("Generated Files" "" "${_fullPath}")

      CMS_DEFINE_SOURCE_FILE_PROPERTIES("${_fullPath}")
      list (APPEND _files "${_fullPath}")
    endforeach ()

    CMS_APPEND_TO_PROPERTY(GeneratedFiles "${_files}")
    CMS_APPEND_TO_PROPERTY(SourceFiles "${_files}")
  else ()
    message (FATAL_ERROR "No files are specified.")
  endif ()
endfunction ()

function (CMS_PREPARE_TARGET _sources)
  CMS_GET_PROPERTY(_linkDirectories LinkDirectories)
  CMS_GET_PROPERTY(_publicHeaders PublicHeaders)
  CMS_GET_PROPERTY(_sourceFiles SourceFiles)
  CMS_GET_PROPERTY(_requiredPackages RequiredPackages)

  if (_linkDirectories)
    link_directories (${_linkDirectories})
  endif ()

  CMS_ENSURE_PACKAGES(${_requiredPackages})
  CMS_RETURN(_sources \${_sourceFiles} \${_publicHeaders})
endfunction ()

function (CMS_SUBMIT_TARGET _name)
  CMS_GET_PROPERTY(_compileOptions CompileOptions)
  CMS_GET_PROPERTY(_compileDefinitions CompileDefinitions)
  CMS_GET_PROPERTY(_exportName ExportName)
  CMS_GET_PROPERTY(_generatedFiles GeneratedFiles)
  CMS_GET_PROPERTY(_includeDirectories IncludeDirectories)
  CMS_GET_PROPERTY(_linkFlags LinkFlags)
  CMS_GET_PROPERTY(_linkLibraries LinkLibraries)
  CMS_GET_PROPERTY(_linkerLanguage LinkerLanguage)
  CMS_GET_PROPERTY(_outputName OutputName)
  CMS_GET_PROPERTY(_outputSuffixDebug OutputSuffixDebug)
  CMS_GET_PROPERTY(_outputSuffixVersion OutputSuffixVersion)
  CMS_GET_PROPERTY(_publicHeaderDirectories PublicHeaderDirectories)
  CMS_GET_PROPERTY(_sourceFiles SourceFiles)
  CMS_GET_PROPERTY(_sourceGroups SourceGroups)

  list (REMOVE_DUPLICATES _publicHeaderDirectories)

  set_target_properties (${_name}
      PROPERTIES
      LINKER_LANGUAGE "${_linkerLanguage}"
      LINK_FLAGS "${_linkFlags}"
      OUTPUT_NAME
      "${_outputName}${_outputSuffixVersion}"
      OUTPUT_NAME_DEBUG
      "${_outputName}${_outputSuffixDebug}${_outputSuffixVersion}")

  if (_publicHeaderDirectories)
    list (APPEND _includeDirectories PUBLIC)

    foreach (_dir IN LISTS _publicHeaderDirectories)
      list (APPEND _includeDirectories "$<BUILD_INTERFACE:${_dir}>")
    endforeach ()

    list (APPEND _includeDirectories
          INTERFACE $<INSTALL_INTERFACE:include>)
  endif ()

  if (_includeDirectories)
    target_include_directories (${_name} ${_includeDirectories})
  endif ()

  if (_compileOptions)
    target_compile_options (${_name} ${_compileOptions})
  endif ()

  if (_compileDefinitions)
    target_compile_definitions (${_name} ${_compileDefinitions})
  endif ()

  if (_linkLibraries)
    target_link_libraries (${_name} ${_linkLibraries})
  endif ()

  if (_generatedFiles)
    set_source_files_properties ("${_generatedFiles}" PROPERTIES
                                 GENERATED true)
  endif ()

  if (_sourceFiles)
    foreach (_source IN LISTS _sourceFiles)
      set (_prefix "SourceFile[${_source}]::")

      CMS_GET_PROPERTY(_definitions "${_prefix}CompileDefinitions")
      CMS_GET_PROPERTY(_options "${_prefix}CompileOptions")

      set_source_files_properties ("${_source}" PROPERTIES
                                   COMPILE_DEFINITIONS "${_definitions}"
                                   COMPILE_FLAGS "${_options}")
    endforeach ()
  endif ()

  if (_sourceGroups)
    foreach (_sourceGroup IN LISTS _sourceGroups)
      CMS_GET_PROPERTY(_files "SourceGroup[${_sourceGroup}]")
      source_group ("${_sourceGroup}" FILES "${_files}")
    endforeach ()
  endif ()

  CMS_PROPAGATE_PROPERTY(ProvidedPackages)
  CMS_PROPAGATE_PROPERTY(ProvidedTargets)
  CMS_PROPAGATE_PROPERTY(RequiredPackages)
  CMS_PROPAGATE_PROPERTY(RequiredVariables)

  if (_exportName)
    install (TARGETS "${_name}"
             EXPORT "${_exportName}"
             ARCHIVE DESTINATION lib
             LIBRARY DESTINATION lib
             RUNTIME DESTINATION bin)

    CMS_APPEND_TO_PARENT_PROPERTY(ProvidedTargets ${_name})
  endif ()
endfunction ()