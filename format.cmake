find_program(clang_format NAMES clang-format)
if(NOT clang_format)
  message(FATAL_ERROR "error: could not find program: clang-format")
endif()

if(CMAKE_ARGC LESS 4)
  message(FATAL_ERROR "usage: cmake -P format.cmake include src")
endif()

set(sources)

math(EXPR ARGC "${CMAKE_ARGC} - 1")
foreach(N RANGE 3 ${ARGC})
  set(directory ${CMAKE_ARGV${N}})

  if(NOT IS_DIRECTORY ${directory})
    message(FATAL_ERROR "error: not a directory: \"${directory}\"")
  endif()

  file(GLOB_RECURSE directory_sources
    ${directory}/*.h
    ${directory}/*.c
    ${directory}/*.hpp
    ${directory}/*.cpp)

  list(APPEND sources ${directory_sources})
endforeach()

foreach(file_absolute ${sources})
  file(RELATIVE_PATH file_relative ${CMAKE_CURRENT_SOURCE_DIR} ${file_absolute})
  file(TIMESTAMP "${file_relative}" file_timestamp_original UTC)
  execute_process(COMMAND "${clang_format}" -i ${file_relative})
  file(TIMESTAMP "${file_relative}" file_timestamp_modified UTC)
  if(NOT file_timestamp_original STREQUAL file_timestamp_modified)
    message(STATUS "${file_relative}")
  endif()
endforeach()
