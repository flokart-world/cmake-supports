# Copyright (c) 2020 Flokart World, Inc.
# All rights reserved.
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

import argparse
import json
import os
import shutil


def main(args):
  is_existing = os.path.isfile(os.path.join(args.directory, 'CMakeCache.txt'))

  if is_existing:
    build_dir = args.directory
  else:
    build_dir = '.'

  vscode_dir = os.path.join(build_dir, '.vscode')
  settings_json = os.path.join(vscode_dir, 'settings.json')

  if os.path.isfile(settings_json):
    is_existing = True
    with open(settings_json) as reading:
      current_settings = json.load(reading)
  else:
    os.makedirs(vscode_dir)
    current_settings = {}

  src_dir = current_settings.get('cmake.sourceDirectory', args.directory)
  base_settings_json = os.path.join(src_dir, '.vscode', 'settings.json')

  if os.path.isfile(base_settings_json):
    with open(base_settings_json) as reading:
      settings = json.load(reading)
  else:
    settings = {}

  current_config = current_settings.get('cmake.configureSettings', {})
  config = settings.get('cmake.configureSettings', {})

  settings.update(current_settings)
  settings['cmake.cmakePath'] = args.cmake_path
  settings['cmake.generator'] = 'Ninja'

  config.update(current_config)
  config['CMAKE_MAKE_PROGRAM'] = args.ninja_path

  settings['cmake.configureSettings'] = config

  if not is_existing:
    settings['cmake.configureOnOpen'] = True
    settings['cmake.buildDirectory'] = '${workspaceFolder}'
    settings['cmake.sourceDirectory'] = os.path.abspath(src_dir)

  dummy_cmake_list = os.path.join(build_dir, 'CMakeLists.txt')
  if not os.path.isfile(dummy_cmake_list):
    # Workaround.
    # https://github.com/microsoft/vscode-cmake-tools/issues/1386
    with open(dummy_cmake_list, 'w') as writing:
      writing.write(
          'message (ERROR "This is a dummy script. Do not load it.")\n')

  with open(settings_json, 'w') as writing:
    json.dump(settings, writing, indent=4)

  with open(os.path.join(vscode_dir, 'c_cpp_properties.json'), 'w') as writing:
    json.dump({
      'version': 4,
      'configurations': [{
        'name': 'CMake',
        'configurationProvider': 'ms-vscode.cmake-tools'
      }]
    }, writing, indent=4)

  for filename in ['cmake-variants.json',
                   'cmake-variants.yaml',
                   'cmake-kits.json']:
    src = os.path.join(src_dir, '.vscode', filename)
    if os.path.isfile(src):
      shutil.copyfile(src, os.path.join(vscode_dir, filename))


parser = argparse.ArgumentParser(description='Workspace generator for VSCode.')
parser.add_argument('--cmake-path', help='Path to CMake command',
    required=True)
parser.add_argument('--ninja-path', help='Path to Ninja command',
    required=True)
parser.add_argument('directory', nargs='?',
    help='Source or existing build directory',
    default='.')
main(parser.parse_args())
