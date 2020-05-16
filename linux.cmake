include_guard(GLOBAL)
include("${CMAKE_CURRENT_LIST_DIR}/config.cmake")

# Set system.
set(CMAKE_CROSSCOMPILING OFF CACHE BOOL "")
set(CMAKE_SYSTEM_PROCESSOR x86_64 CACHE STRING "")
set(CMAKE_SYSTEM_NAME Linux CACHE STRING "")

# Set compiler.
set(CMAKE_C_COMPILER "${CMAKE_CURRENT_LIST_DIR}/llvm/bin/clang" CACHE STRING "")
set(CMAKE_CXX_COMPILER "${CMAKE_CURRENT_LIST_DIR}/llvm/bin/clang++" CACHE STRING "")
set(CMAKE_RANLIB "${CMAKE_CURRENT_LIST_DIR}/llvm/bin/llvm-ranlib" CACHE STRING "")
set(CMAKE_AR "${CMAKE_CURRENT_LIST_DIR}/llvm/bin/llvm-ar" CACHE STRING "")
set(CMAKE_NM "${CMAKE_CURRENT_LIST_DIR}/llvm/bin/llvm-nm" CACHE STRING "")

# Set compiler flags.
set(CLANG_C_FLAGS "-fasm -fPIC -fdiagnostics-absolute-paths -D_DEFAULT_SOURCE=1 -Wall -Wextra -Wpedantic")
set(CLANG_C_FLAGS "${CLANG_C_FLAGS} -Wno-unused-variable -Wno-unused-parameter -Wrange-loop-analysis")
set(CLANG_C_FLAGS_RELEASE "-flto=full")

set(CLANG_CXX_FLAGS "${CLANG_C_FLAGS} -fcoroutines-ts -stdlib=libc++")
set(CLANG_CXX_FLAGS_RELEASE "${CLANG_C_FLAGS_RELEASE} -fwhole-program-vtables")

set(CMAKE_C_FLAGS_INIT "${CLANG_C_FLAGS} ${VCPKG_C_FLAGS}")
set(CMAKE_C_FLAGS_DEBUG_INIT "${VCPKG_C_FLAGS_DEBUG}")
set(CMAKE_C_FLAGS_RELEASE_INIT "${CLANG_C_FLAGS_RELEASE} ${VCPKG_C_FLAGS_RELEASE}")
set(CMAKE_C_FLAGS_MINSIZEREL_INIT "${CLANG_C_FLAGS_RELEASE}")
set(CMAKE_C_FLAGS_RELWITHDEBINFO_INIT "${CLANG_C_FLAGS_RELEASE}")

set(CMAKE_CXX_FLAGS_INIT "${CLANG_CXX_FLAGS} ${VCPKG_CXX_FLAGS}")
set(CMAKE_CXX_FLAGS_DEBUG_INIT "${VCPKG_CXX_FLAGS_DEBUG}")
set(CMAKE_CXX_FLAGS_RELEASE_INIT "${CLANG_CXX_FLAGS_RELEASE} ${VCPKG_CXX_FLAGS_RELEASE}")
set(CMAKE_CXX_FLAGS_MINSIZEREL_INIT "${CLANG_CXX_FLAGS_RELEASE}")
set(CMAKE_CXX_FLAGS_RELWITHDEBINFO_INIT "${CLANG_CXX_FLAGS_RELEASE}")

# Set linker flags.
foreach(LINKER SHARED_LINKER MODULE_LINKER EXE_LINKER)
  set(CMAKE_${LINKER}_FLAGS_INIT "-pthread ${VCPKG_LINKER_FLAGS}")
  set(CMAKE_${LINKER}_FLAGS_RELEASE_INIT "-Wl,-s")
  set(CMAKE_${LINKER}_FLAGS_MINSIZEREL_INIT "-Xlinker -plugin-opt=O3 -Wl,-s")
  if(VCPKG_CRT_LINKAGE STREQUAL "static")
    set(CMAKE_${LINKER}_FLAGS_INIT "-static ${CMAKE_${LINKER}_FLAGS_INIT}")
  endif()
endforeach()
