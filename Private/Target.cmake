# Copyright (c) 2014-2020 Flokart World, Inc.
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

function (CMS_DEFINE_TARGET_SCOPE _name)
  CMS_ASSERT_IDENTIFIER(${_name})
  CMS_GET_PROPERTY(_parentType Type)

  if (NOT _parentType STREQUAL "None"
      AND NOT _parentType STREQUAL "Module"
      AND NOT _parentType STREQUAL "EmbeddedPackage")
    message (FATAL_ERROR "Target definition is not allowed here.")
  endif ()

  CMS_DEFINE_NAMESPACE(${_name})

  CMS_INHERIT_PROPERTY(CompileDefinitions)
  CMS_INHERIT_PROPERTY(CompileFeatures)
  CMS_INHERIT_PROPERTY(CompileOptions)
  CMS_INHERIT_PROPERTY(IncludeDirectories)
  CMS_INHERIT_PROPERTY(LinkDirectories)
  CMS_INHERIT_PROPERTY(LinkLibraries)
  CMS_INHERIT_PROPERTY(LinkOptions)
  CMS_INHERIT_PROPERTY(PrecompileHeaders)
endfunction ()

function (CMS_DEFINE_TARGET _name)
  CMS_DEFINE_TARGET_SCOPE(${_name})

  CMS_DEFINE_PROPERTY(AutoMOC)
  CMS_DEFINE_PROPERTY(Dependencies)
  CMS_DEFINE_PROPERTY(GeneratedFiles)
  CMS_DEFINE_PROPERTY(LinkFlags)
  CMS_DEFINE_PROPERTY(LinkerLanguage)
  CMS_DEFINE_PROPERTY(OutputName)
  CMS_DEFINE_PROPERTY(OutputExtension)
  CMS_DEFINE_PROPERTY(OutputSuffixDebug)
  CMS_DEFINE_PROPERTY(OutputSuffixVersion)
  CMS_DEFINE_PROPERTY(SourceFiles)
  CMS_DEFINE_PROPERTY(StaticLibraryOptions)

  CMS_INHERIT_PROPERTY(PublicHeaders)
  CMS_INHERIT_PROPERTY(PublicHeaderDirectories)
  CMS_INHERIT_PROPERTY(RequiredPackages)
  CMS_INHERIT_PROPERTY(SourceGroups)
  CMS_INHERIT_PROPERTY(Version)

  if (MSVC AND CMS_MSVC_WARNING_STYLE STREQUAL "NEW")
    CMS_INHERIT_PROPERTY(MSVCFloatingPoint)
    CMS_INHERIT_PROPERTY(MSVCPermissive)
    CMS_INHERIT_PROPERTY(MSVCWarningLevel)
  endif ()

  CMS_GET_PROPERTY(_requiredPackages RequiredPackages)
  CMS_GET_PROPERTY(_groups SourceGroups)

  foreach (_package IN LISTS _requiredPackages)
    CMS_ASSERT_IDENTIFIER(${_package})
    set (_name RequiredComponents[${_package}])

    CMS_DEFINE_PROPERTY(${_name})
    CMS_INHERIT_PROPERTY(${_name})
  endforeach ()

  foreach (_group IN LISTS _groups)
    set (_name "SourceGroup[${_group}]")

    CMS_DEFINE_PROPERTY(${_name})
    CMS_INHERIT_PROPERTY(${_name})
  endforeach ()
endfunction ()

function (CMS_DEFINE_SOURCE_FILE_PROPERTIES _fullPath)
  set (_prefix "SourceFile[${_fullPath}]::")
  CMS_DEFINE_PROPERTY("${_prefix}CompileDefinitions")
  CMS_DEFINE_PROPERTY("${_prefix}CompileOptions")

  # We don't define MSVCWarningLevel, MSVCPermissive and MSVCFloatingPoint
  # here since they must be consistent across precompile headers and source
  # files. Unless something to separate option space is provided by CMake,
  # we leave it as a restriction.
endfunction ()

function (CMS_ESCAPE_KEYWORDS _ret _keywords)
  string (JOIN "|" _joined ${_keywords})
  set (_values)
  while (ARGN)
    list (GET ARGN 0 _arg)
    list (REMOVE_AT ARGN 0)
    string (REGEX REPLACE "^(${_joined})$" [[$<1:\1>]] _arg "${_arg}")
    list (APPEND _values "${_arg}")
  endwhile ()
  CMS_RETURN(_ret [[${_values}]])
endfunction ()

function (CMS_APPEND_TO_SOURCE_FILE_PROPERTY _file _name)
  get_filename_component (_fullPath "${_file}" ABSOLUTE)
  CMS_APPEND_TO_PROPERTY("SourceFile[${_fullPath}]::${_name}" ${ARGN})
endfunction ()

function (CMS_SOURCE_FILES_DISABLE_MSVC_WARNINGS)
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

function (CMS_ADD_COMMAND _cmd)
  string (REPLACE ";" "$<SEMICOLON>" _cmd "${_cmd}")
  set (_keywords COMMAND
                 DEPENDS
                 BYPRODUCTS
                 WORKING_DIRECTORY
                 COMMENT
                 JOB_POOL
                 VERBATIM
                 USES_TERMINAL
                 COMMAND_EXPAND_LISTS
                 SOURCES)
  CMS_ESCAPE_KEYWORDS(_commandLine "${_keywords}" "${_cmd}" ${ARGN})
  CMS_APPEND_TO_PROPERTY(Commands COMMAND "${_commandLine}")
endfunction ()

function (CMS_ENSURE_PACKAGES)
  CMS_GET_PROPERTY(_packages RequiredPackages)
  set (_foreignPackages "")

  while (_packages)
    list (GET _packages 0 _package)
    list (REMOVE_AT _packages 0)

    CMS_GET_PACKAGE_DOMAIN(_domain "${_package}")

    if (_domain STREQUAL "LOCAL")
      CMS_QUALIFY_NAMESPACE(_qname "${_package}")
      CMS_GET_QNAME_PROPERTY(_deps "${_qname}::RequiredPackages")
      list (APPEND _packages ${_deps})
      list (REMOVE_DUPLICATES _packages)

      foreach (_package IN LISTS _deps)
        set (_key RequiredComponents[${_package}])
        CMS_GET_QNAME_PROPERTY(_components ${_qname}::${_key})
        CMS_ADD_REQUIRED_COMPONENTS(${_package} ${_components})
      endforeach ()
    elseif (_domain STREQUAL "FOREIGN")
      list (APPEND _foreignPackages ${_package})
    else ()
      message (FATAL_ERROR "Unrecognized domain: ${_domain} (${_package})")
    endif ()
  endwhile ()

  list (REMOVE_DUPLICATES _foreignPackages)

  foreach (_package IN LISTS _foreignPackages)
    CMS_REPLAY_PACKAGE_ARGS(_params ${_package} REQUIRED)
    CMS_LOAD_PACKAGE(${_package} ${_params})
  endforeach ()
endfunction ()

function (CMS_PREPARE_TARGET_SCOPE)
  CMS_GET_PROPERTY(_linkDirectories LinkDirectories)

  if (_linkDirectories)
    link_directories (${_linkDirectories})
  endif ()

  CMS_ENSURE_PACKAGES()
endfunction ()

function (CMS_PREPARE_TARGET _sources)
  CMS_PREPARE_TARGET_SCOPE()

  CMS_GET_PROPERTY(_publicHeaders PublicHeaders)
  CMS_GET_PROPERTY(_sourceFiles SourceFiles)

  CMS_RETURN(_sources \${_publicHeaders} \${_sourceFiles})
endfunction ()

function (CMS_SUBMIT_DEPENDENCIES _name)
  CMS_ASSERT_IDENTIFIER(${_name})

  CMS_GET_PROPERTY(_dependencies Dependencies)

  if (_dependencies)
    add_dependencies (${_name} ${_dependencies})
  endif ()
endfunction ()

function (_CMS_FALLBACK_VALUE_EXPR _ret _specified _default)
  set (_value "$<IF:$<STREQUAL:${_specified},>,${_default},${_specified}>")
  CMS_RETURN(_ret [[${_value}]])
endfunction ()

function (CMS_SUBMIT_TARGET_SCOPE _name _compileTime _linkTime)
  CMS_ASSERT_IDENTIFIER(${_name})
  CMS_ASSERT_IDENTIFIER(${_compileTime})
  CMS_ASSERT_IDENTIFIER(${_linkTime})

  CMS_GET_PROPERTY(_compileDefinitions CompileDefinitions)
  CMS_GET_PROPERTY(_compileFeatures CompileFeatures)
  CMS_GET_PROPERTY(_compileOptions CompileOptions)
  CMS_GET_PROPERTY(_exportName ExportName)
  CMS_GET_PROPERTY(_includeDirectories IncludeDirectories)
  CMS_GET_PROPERTY(_linkLibraries LinkLibraries)
  CMS_GET_PROPERTY(_linkOptions LinkOptions)
  CMS_GET_PROPERTY(_precompileHeaders PrecompileHeaders)

  CMS_DEFAULT_COMPILE_OPTIONS(_defaultCompileOptions)

  if (_compileDefinitions)
    CMS_COMPLETE_SCOPED_PROPERTY(_values ${_compileTime}
                                 ${_compileDefinitions})
    if (_values)
      target_compile_definitions (${_name} ${_values})
    endif ()
  endif ()

  if (_compileFeatures)
    CMS_COMPLETE_SCOPED_PROPERTY(_values ${_compileTime}
                                 ${_compileFeatures})
    if (_values)
      target_compile_features (${_name} ${_values})
    endif ()
  endif ()

  if (NOT _compileTime STREQUAL "INTERFACE")
    if (_defaultCompileOptions)
      target_compile_options (${_name} PRIVATE ${_defaultCompileOptions})
    endif ()

    if (MSVC AND CMS_MSVC_WARNING_STYLE STREQUAL "NEW")
      CMS_GET_PROPERTY(_targetFloatingPoint "MSVCFloatingPoint")
      CMS_GET_PROPERTY(_targetPermissive "MSVCPermissive")
      CMS_GET_PROPERTY(_targetWarningLevel "MSVCWarningLevel")

      set (_defaultFloatingPoint fast)
      set (_defaultPermissive false)
      set (_defaultWarningLevel 4)

      if (_findVersion VERSION_LESS 0.0.7)
        set (_defaultPermissive true)
      endif ()

      foreach (_property IN ITEMS FloatingPoint Permissive WarningLevel)
        _CMS_FALLBACK_VALUE_EXPR(_actual${_property} "${_target${_property}}"
                                                     "${_default${_property}}")
      endforeach ()

      set (_optFloatingPoint
           "/fp:${_actualFloatingPoint}")
      set (_optPermissive
           "$<$<NOT:$<BOOL:${_actualPermissive}>>:/permissive->")
      set (_optWarningLevel
           "/W${_actualWarningLevel}")

      set (_values)
      foreach (_property IN ITEMS FloatingPoint Permissive WarningLevel)
        list (APPEND _values "$<${_isCOrCxx}:${_opt${_property}}>")
      endforeach ()

      target_compile_options (${_name} PRIVATE ${_values})
    endif ()
  endif ()

  if (_compileOptions)
    CMS_COMPLETE_SCOPED_PROPERTY(_values ${_compileTime}
                                 ${_compileOptions})
    if (_values)
      target_compile_options (${_name} ${_values})
    endif ()
  endif ()

  if (_includeDirectories)
    CMS_COMPLETE_SCOPED_PROPERTY(_values ${_compileTime}
                                 ${_includeDirectories})
    if (_values)
      target_include_directories (${_name} ${_values})
    endif ()
  endif ()

  if (_linkLibraries)
    CMS_COMPLETE_SCOPED_PROPERTY(_values ${_linkTime} ${_linkLibraries})

    if (_values)
      target_link_libraries (${_name} ${_values})
    endif ()
  endif ()

  if (_linkOptions)
    CMS_COMPLETE_SCOPED_PROPERTY(_values ${_linkTime} ${_linkOptions})

    if (_values)
      target_link_options (${_name} ${_values})
    endif ()
  endif ()

  if (_precompileHeaders AND CMS_ENABLE_PRECOMPILE_HEADERS)
    CMS_COMPLETE_SCOPED_PROPERTY(_values PRIVATE ${_precompileHeaders})

    if (_values)
      target_precompile_headers (${_name} ${_values})
    endif ()
  endif ()

  if (_exportName)
    install (TARGETS "${_name}"
             EXPORT "${_exportName}"
             ARCHIVE DESTINATION lib
             LIBRARY DESTINATION lib
             RUNTIME DESTINATION bin)

    CMS_ADD_TO_PARENT_PROPERTY(ProvidedTargets ${_name})
  endif ()
endfunction ()

function (CMS_SUBMIT_TARGET _name)
  CMS_SUBMIT_DEPENDENCIES(${_name})

  CMS_GET_PROPERTY(_autoMoc AutoMOC)
  CMS_GET_PROPERTY(_dependencies Dependencies)
  CMS_GET_PROPERTY(_generatedFiles GeneratedFiles)
  CMS_GET_PROPERTY(_linkFlags LinkFlags)
  CMS_GET_PROPERTY(_linkerLanguage LinkerLanguage)
  CMS_GET_PROPERTY(_outputName OutputName)
  CMS_GET_PROPERTY(_outputExt OutputExtension)
  CMS_GET_PROPERTY(_outputSuffixDebug OutputSuffixDebug)
  CMS_GET_PROPERTY(_outputSuffixVersion OutputSuffixVersion)
  CMS_GET_PROPERTY(_publicHeaderDirectories PublicHeaderDirectories)
  CMS_GET_PROPERTY(_sourceFiles SourceFiles)
  CMS_GET_PROPERTY(_sourceGroups SourceGroups)
  CMS_GET_PROPERTY(_staticLibraryOptions StaticLibraryOptions)

  set (_compileTime PUBLIC)
  set (_linkTime PRIVATE)
  set (_isCOrCxx "$<COMPILE_LANGUAGE:C,CXX>")
  get_directory_property (_findVersion CMS::FindVersion)

  list (REMOVE_DUPLICATES _publicHeaderDirectories)

  if (_linkFlags AND _findVersion VERSION_GREATER_EQUAL 0.0.7)
    message (WARNING "LinkFlags property is deprecated."
                     " Use CMS_ADD_LINK_OPTIONS function instead.")
  endif ()

  if (_sourceFiles) # elsewise it is an interface library.
    set_target_properties (${_name}
        PROPERTIES LINK_FLAGS "${_linkFlags}"
                   STATIC_LIBRARY_OPTIONS "${_staticLibraryOptions}")

    if (_outputName)
      set_target_properties (${_name}
          PROPERTIES
          OUTPUT_NAME
          "${_outputName}${_outputSuffixVersion}"
          OUTPUT_NAME_DEBUG
          "${_outputName}${_outputSuffixDebug}${_outputSuffixVersion}")
    endif ()

    if (_outputExt)
      set_target_properties (${_name} PROPERTIES SUFFIX ${_outputExt})
    endif ()

    if (_linkerLanguage)
      set_target_properties (${_name}
                             PROPERTIES LINKER_LANGUAGE "${_linkerLanguage}")
    endif ()

    if (_autoMoc)
      set_target_properties (${_name} PROPERTIES AUTOMOC ON)
    endif ()

    get_target_property (_targetType ${_name} TYPE)

    if (_targetType STREQUAL "EXECUTABLE")
      set (_compileTime PRIVATE)
    endif ()

    if (_targetType MATCHES "_LIBRARY$")
      set (_linkTime PUBLIC)
    endif ()
  else ()
    set (_compileTime INTERFACE)
    set (_linkTime INTERFACE)
  endif ()

  CMS_SUBMIT_TARGET_SCOPE(${_name} ${_compileTime} ${_linkTime})

  if (_publicHeaderDirectories)
    foreach (_dir IN LISTS _publicHeaderDirectories)
      target_include_directories (${_name} ${_compileTime}
                                  "$<BUILD_INTERFACE:${_dir}>")
    endforeach ()

    target_include_directories (${_name} ${_compileTime}
                                $<INSTALL_INTERFACE:include>)
  endif ()

  if (_generatedFiles)
    set_source_files_properties (${_generatedFiles} PROPERTIES
                                 GENERATED true)
  endif ()

  if (_sourceFiles)
    foreach (_source IN LISTS _sourceFiles)
      set (_prefix "SourceFile[${_source}]::")

      CMS_GET_PROPERTY(_values "${_prefix}CompileDefinitions")

      if (_values)
        set_source_files_properties (${_source} PROPERTIES
                                     COMPILE_DEFINITIONS "${_values}")
      endif ()

      CMS_GET_PROPERTY(_values "${_prefix}CompileOptions")

      if (_values)
        # The trailing semi-colon is workaround against the issue below:
        #   https://gitlab.kitware.com/cmake/cmake/issues/20456
        set_source_files_properties (${_source} PROPERTIES
                                     COMPILE_OPTIONS "${_values};")
      endif ()
    endforeach ()
  endif ()

  if (_sourceGroups)
    foreach (_sourceGroup IN LISTS _sourceGroups)
      CMS_GET_PROPERTY(_files "SourceGroup[${_sourceGroup}]")
      source_group ("${_sourceGroup}" FILES ${_files})
    endforeach ()
  endif ()
endfunction ()

string (JOIN " " _msg "Whether to enable precompiled headers."
                      "Using precompiled headers improve compilation speed,"
                      "but may drop some missing includes.")
set (CMS_ENABLE_PRECOMPILE_HEADERS true CACHE BOOL ${_msg})
mark_as_advanced (CMS_ENABLE_PRECOMPILE_HEADERS)
