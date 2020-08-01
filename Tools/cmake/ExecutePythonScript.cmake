cmake_minimum_required (VERSION 3.16.6)
find_package (CMakeSupports 0.0.7 REQUIRED)
find_package (Python3 REQUIRED)

set (_index 1)
while (_index LESS CMAKE_ARGC)
  set (_arg "${CMAKE_ARGV${_index}}")
  math (EXPR _index "${_index} + 1")
  if (_arg STREQUAL "--")
    break ()
  endif ()
endwhile ()

set (_args)
while (_index LESS CMAKE_ARGC)
  list (APPEND _args "${CMAKE_ARGV${_index}}")
  math (EXPR _index "${_index} + 1")
endwhile ()


list (PREPEND ENV{PYTHONPATH} ${CMS_PYLIB_DIR})
execute_process (COMMAND ${Python3_EXECUTABLE} ${_args})
