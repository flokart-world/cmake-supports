# Copyright (c) 2016 Flokart World, Inc.
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

import os
import re
import subprocess

class ReadELF:
  def __init__(self, cmd):
    self.cmd = cmd
    self.rule = re.compile('\(NEEDED\)[ \t]*Shared library: \[([^\n]+)\]')

  def dependencies(self, filename):
    out = subprocess.check_output([self.cmd, '-d', filename])
    return self.rule.findall(out)

class DependencyMap:
  def __init__(self):
    self._references = set()
    self._locations = dict()
    self._getname = re.compile(r'^lib(.*)\.so(\.[0-9]+)*$')

  def references(self):
    return self._references

  def add_reference(self, refname):
    if refname in self._references:
      return False
    else:
      self._references.add(refname)
      return True

  def location(self, refname):
    return self._locations[refname] if refname in self._locations else None

  def locations(self):
    return self._locations.values()

  def is_solib(self, filename):
    return self._getname.match(os.path.basename(filename))

  def basename(self, filename):
    return self._getname.sub(r'\1', os.path.basename(filename))

  def basenames(self):
    return [self.basename(refname) for refname in self._references]

  def is_resolved(self, refname):
    return self.basename(refname) in self._locations

  def resolve(self, refname, fullpath):
    libname = self.basename(refname)

    if libname in self._locations:
      return False
    else:
      self._locations[libname] = fullpath
      return True

  def realname(self, fullpath):
    return os.path.basename(os.path.realpath(fullpath))

  def add_library(self, fullpath):
    refname = self.realname(fullpath)
    self.add_reference(refname)
    return self.resolve(refname, os.path.realpath(fullpath))

class DependencyGraph:
  def __init__(self):
    self._map = DependencyMap()
    self._forward_deps = dict()
    self._reverse_deps = dict()

  def add_node(self, refname):
    self._forward_deps[refname] = set()
    self._reverse_deps[refname] = set()

  def add_libraries(self, readso, libraries):
    search_paths = set([os.path.dirname(path) for path in libraries])
    unevaluated = set()

    for lib in libraries:
      # supposed to ignore non-shared or system libraries.
      if self._map.is_solib(lib) and os.path.exists(lib):
        refname = self._map.realname(lib)
        if self._map.add_reference(refname):
          self.add_node(refname)
        if self._map.add_library(lib):
          unevaluated.add(os.path.realpath(lib))

    while unevaluated:
      lib = unevaluated.pop()
      libname = os.path.basename(lib) # lib has to be realpath.

      for dep in readso.dependencies(lib):
        if self._map.add_reference(dep):
          self.add_node(dep)

        self._forward_deps[libname].add(dep)
        self._reverse_deps[dep].add(libname)

        if not self._map.is_resolved(dep):
          for path in search_paths:
            fullpath = os.path.join(path, dep)

            if os.path.exists(fullpath):
              self._map.resolve(dep, fullpath)
              unevaluated.add(os.path.realpath(fullpath))
              break

  def is_resolved(self, refname):
    return self._map.is_resolved(refname)

  def references(self):
    return self._map.references()

  def sorted_references(self):
    retval = []

    forward_deps = self._forward_deps
    reverse_deps = self._reverse_deps

    stack = []
    unresolved = forward_deps.keys()

    while unresolved or stack:
      if stack:
        libname = stack[-1]

        if forward_deps[libname]:
          dep = forward_deps[libname].pop()
          reverse_deps[dep].remove(libname)
          libname = dep

          unresolved.remove(libname)

        else:
          for referrer in reverse_deps[libname]:
            forward_deps[referrer].remove(libname)

          retval.append(stack.pop())
          continue

      else:
        libname = unresolved.pop()

      stack.append(libname)

    return retval

  def basename(self, refname):
    return self._map.basename(refname)

  def basenames(self):
    return self._map.basenames()

  def sorted_basenames(self):
    return [self._map.basename(refname) for refname in self.sorted_references()]

  def libraries(self):
    return self._map.locations()

  def sorted_libraries(self):
    return [self._map.location(refname) for refname in self.sorted_references()
                                       if self._map.is_resolved(refname)]
