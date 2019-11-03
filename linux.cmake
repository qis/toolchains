include_guard(GLOBAL)

if(CMAKE_HOST_SYSTEM_NAME STREQUAL "Linux")
  set(CMAKE_CROSSCOMPILING OFF CACHE BOOL "")
endif()
set(CMAKE_SYSTEM_NAME Linux CACHE STRING "")
if(VCPKG_TARGET_ARCHITECTURE STREQUAL "x64")
  set(CMAKE_SYSTEM_PROCESSOR x86_64 CACHE STRING "")
endif()

set(CMAKE_C_STANDARD 11 CACHE STRING "")
set(CMAKE_C_STANDARD_REQUIRED ON CACHE STRING "")
set(CMAKE_C_EXTENSIONS OFF CACHE STRING "")

set(CMAKE_CXX_STANDARD 20 CACHE STRING "")
set(CMAKE_CXX_STANDARD_REQUIRED ON CACHE STRING "")
set(CMAKE_CXX_EXTENSIONS OFF CACHE STRING "")

set(CMAKE_AR "${CMAKE_CURRENT_LIST_DIR}/llvm/bin/llvm-ar" CACHE STRING "")
set(CMAKE_NM "${CMAKE_CURRENT_LIST_DIR}/llvm/bin/llvm-nm" CACHE STRING "")
set(CMAKE_RANLIB "${CMAKE_CURRENT_LIST_DIR}/llvm/bin/llvm-ranlib" CACHE STRING "")
set(CMAKE_C_COMPILER "${CMAKE_CURRENT_LIST_DIR}/llvm/bin/clang" CACHE STRING "")
set(CMAKE_CXX_COMPILER "${CMAKE_CURRENT_LIST_DIR}/llvm/bin/clang++" CACHE STRING "")

if(NOT VCPKG_CRT_LINKAGE)
  include(${CMAKE_CURRENT_LIST_DIR}/../../triplets/${VCPKG_TARGET_TRIPLET}.cmake)
endif()

set(LLVM_CPP_FLAGS "-fasm -fopenmp-simd -fomit-frame-pointer -fmerge-all-constants -fdiagnostics-absolute-paths -fPIC")
set(LLVM_CXX_FLAGS "-fcoroutines-ts -isystem ${CMAKE_CURRENT_LIST_DIR}/llvm/include")
set(LLVM_OPT_FLAGS "-fwhole-program-vtables -fvirtual-function-elimination")

set(CMAKE_C_FLAGS "${LLVM_CPP_FLAGS} ${VCPKG_C_FLAGS}" CACHE STRING "")
set(CMAKE_CXX_FLAGS "${LLVM_CPP_FLAGS} ${LLVM_CXX_FLAGS} ${VCPKG_CXX_FLAGS}" CACHE STRING "")

set(CMAKE_C_FLAGS_DEBUG "-O0 -g ${VCPKG_C_FLAGS_DEBUG}" CACHE STRING "")
set(CMAKE_CXX_FLAGS_DEBUG "-O0 -g ${VCPKG_CXX_FLAGS_DEBUG}" CACHE STRING "")

set(CMAKE_C_FLAGS_RELEASE "-Os -flto=full ${VCPKG_C_FLAGS_RELEASE}" CACHE STRING "")
set(CMAKE_CXX_FLAGS_RELEASE "-Os -flto=full ${LLVM_OPT_FLAGS} ${VCPKG_C_FLAGS_RELEASE}" CACHE STRING "")

set(CMAKE_C_FLAGS_INIT "" CACHE STRING "")
set(CMAKE_CXX_FLAGS_INIT "" CACHE STRING "")

set(CMAKE_C_FLAGS_DEBUG_INIT "" CACHE STRING "")
set(CMAKE_CXX_FLAGS_DEBUG_INIT "" CACHE STRING "")

set(CMAKE_C_FLAGS_RELEASE_INIT "" CACHE STRING "")
set(CMAKE_CXX_FLAGS_RELEASE_INIT "" CACHE STRING "")

set(CMAKE_STATIC_LINKER_FLAGS "" CACHE STRING "")
set(CMAKE_SHARED_LINKER_FLAGS "-pthread -lc++abi" CACHE STRING "")
set(CMAKE_EXE_LINKER_FLAGS "-pthread -lc++abi -ltbb" CACHE STRING "")

set(CMAKE_STATIC_LINKER_FLAGS_DEBUG "" CACHE STRING "")
set(CMAKE_SHARED_LINKER_FLAGS_DEBUG "" CACHE STRING "")
set(CMAKE_EXE_LINKER_FLAGS_DEBUG "" CACHE STRING "")

set(CMAKE_STATIC_LINKER_FLAGS_RELEASE "" CACHE STRING "")
set(CMAKE_SHARED_LINKER_FLAGS_RELEASE "-Xlinker -plugin-opt=O3 -flto=full -Wl,-s" CACHE STRING "")
set(CMAKE_EXE_LINKER_FLAGS_RELEASE "-Xlinker -plugin-opt=O3 -flto=full -Wl,-s" CACHE STRING "")

list(PREPEND CMAKE_PROGRAM_PATH "${CMAKE_CURRENT_LIST_DIR}/llvm/bin")

add_definitions(-D_DEFAULT_SOURCE=1)  
