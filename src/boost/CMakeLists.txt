cmake_minimum_required(VERSION 3.16)
project(boost LANGUAGES C CXX)

set(config "${CMAKE_CURRENT_BINARY_DIR}/config.jam")
if(WIN32)
  file(WRITE ${config} "using msvc : ")
else()
  file(WRITE ${config} "using clang-linux : ")
endif()
file(APPEND ${config} "${CMAKE_CXX_COMPILER_VERSION} : \"${CMAKE_CXX_COMPILER}\" :\n")
file(APPEND ${config} "\n")

function(append name value)
  string(REPLACE "\"" "\\\"" quoted_value "${value}")
  file(APPEND ${config} "${name}\"${quoted_value}\"\n")
endfunction()

append("<cflags>" "${CMAKE_C_FLAGS}")
append("<variant>debug:<cflags>" "${CMAKE_C_FLAGS_DEBUG}")
append("<variant>release:<cflags>" "${CMAKE_C_FLAGS_RELEASE}")
file(APPEND ${config} "\n")

append("<cxxstd>" "2a")
append("<cxxstd-dialect>" "iso")
append("<cxxflags>" "${CMAKE_CXX_FLAGS}")
append("<variant>debug:<cxxflags>" "${CMAKE_CXX_FLAGS_DEBUG}")
append("<variant>release:<cxxflags>" "${CMAKE_CXX_FLAGS_RELEASE}")
file(APPEND ${config} "\n")

append("<linkflags>" "${CMAKE_STATIC_LINKER_FLAGS}")
append("<variant>debug:<linkflags>" "${CMAKE_STATIC_LINKER_FLAGS_DEBUG}")
append("<variant>release:<linkflags>" "${CMAKE_STATIC_LINKER_FLAGS_RELEASE}")
file(APPEND ${config} "\n")

get_property(COMPILE_DEFINITIONS DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR} PROPERTY COMPILE_DEFINITIONS)
foreach(define ${COMPILE_DEFINITIONS})
  file(APPEND ${config} "<define>${define}\n")
endforeach()

file(APPEND ${config} "\n;\n")

if(CMAKE_BUILD_TYPE STREQUAL Debug)
  set(VARIANT debug)
else()
  set(VARIANT release)
endif()

if(LIBRARY_LINKAGE STREQUAL static)
  set(LINK static)
else()
  set(LINK shared)
endif()

if(CRT_LINKAGE STREQUAL static)
  set(RUNTIME_LINK static)
else()
  set(RUNTIME_LINK shared)
endif()

execute_process(COMMAND ${B2}
  --without-graph_parallel
  --project-config=${config}
  --prefix=${CMAKE_INSTALL_PREFIX}
  --build-dir=${CMAKE_CURRENT_BINARY_DIR}/build
  architecture=x86 address-model=64
  link=${LINK} runtime-link=${RUNTIME_LINK}
  variant=${VARIANT} threading=multi install
  OUTPUT_FILE ${CMAKE_CURRENT_BINARY_DIR}/build-out.log
  ERROR_FILE ${CMAKE_CURRENT_BINARY_DIR}/build-err.log
  WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR})

install(FILES LICENSE_1_0.txt DESTINATION share/boost RENAME copyright)
