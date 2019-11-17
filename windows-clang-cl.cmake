include_guard(GLOBAL)
get_filename_component(VCPKG_ROOT ${CMAKE_CURRENT_LIST_DIR}/../.. ABSOLUTE CACHE)

set(CMAKE_C_STANDARD 11 CACHE STRING "")
set(CMAKE_C_STANDARD_REQUIRED ON CACHE STRING "")
set(CMAKE_C_EXTENSIONS OFF CACHE STRING "")

set(CMAKE_CXX_STANDARD 20 CACHE STRING "")
set(CMAKE_CXX_STANDARD_REQUIRED ON CACHE STRING "")
set(CMAKE_CXX_EXTENSIONS OFF CACHE STRING "")

set(CMAKE_C_COMPILER "${CMAKE_CURRENT_LIST_DIR}/llvm/bin/clang-cl.exe" CACHE STRING "" FORCE)
set(CMAKE_CXX_COMPILER "${CMAKE_CURRENT_LIST_DIR}/llvm/bin/clang-cl.exe" CACHE STRING "" FORCE)
set(CMAKE_LINKER "${CMAKE_CURRENT_LIST_DIR}/llvm/bin/lld-link.exe" CACHE STRING "" FORCE)
set(CMAKE_RC_COMPILER "rc.exe" CACHE STRING "" FORCE)

if(NOT VCPKG_CRT_LINKAGE)
  include(${VCPKG_ROOT}/triplets/${VCPKG_TARGET_TRIPLET}.cmake)
endif()

if(VCPKG_CRT_LINKAGE STREQUAL "dynamic")
  set(CMAKE_MSVC_RUNTIME_LIBRARY "MultiThreaded$<$<CONFIG:Debug>:Debug>DLL" CACHE STRING "")
  set(LLVM_CRT_FLAG "/MD")
elseif(VCPKG_CRT_LINKAGE STREQUAL "static")
  set(CMAKE_MSVC_RUNTIME_LIBRARY "MultiThreaded$<$<CONFIG:Debug>:Debug>" CACHE STRING "")
  set(LLVM_CRT_FLAG "/MT")
else()
  message(FATAL_ERROR "Invalid setting for VCPKG_CRT_LINKAGE: \"${VCPKG_CRT_LINKAGE}\".")
endif()

set(LLVM_CPP_FLAGS "/Zc:strictStrings /Zc:char8_t /utf-8 /wd26812 /wd28251")
set(LLVM_CPP_FLAGS "${LLVM_CPP_FLAGS} /clang:-fasm /clang:-fopenmp-simd /clang:-flto=full")

set(LLVM_CXX_FLAGS "/EHsc /GR /FI\"${CMAKE_CURRENT_LIST_DIR}/src/vs.hpp\"")
set(LLVM_CXX_FLAGS "${LLVM_CXX_FLAGS} /clang:-fwhole-program-vtables /clang:-fvirtual-function-elimination")
set(LLVM_CXX_FLAGS "${LLVM_CXX_FLAGS} /clang:-fcoroutines-ts")

set(CMAKE_C_FLAGS "${LLVM_CPP_FLAGS} ${VCPKG_C_FLAGS}" CACHE STRING "")
set(CMAKE_CXX_FLAGS "${LLVM_CPP_FLAGS} ${LLVM_CXX_FLAGS} ${VCPKG_CXX_FLAGS}" CACHE STRING "")

if(CMAKE_BINARY_DIR MATCHES "^${VCPKG_ROOT}")
  set(CMAKE_C_FLAGS_DEBUG "/O1 /Oi /GS- /Z7 ${VCPKG_C_FLAGS_DEBUG} ${LLVM_CRT_FLAG}d" CACHE STRING "")
  set(CMAKE_CXX_FLAGS_DEBUG "/O1 /Oi /GS- /Z7 ${VCPKG_CXX_FLAGS_DEBUG} ${LLVM_CRT_FLAG}d" CACHE STRING "")
else()
  set(CMAKE_C_FLAGS_DEBUG "/Od /Oi- /Ob0 /Gy- /GS /RTC1 /Z7 ${VCPKG_C_FLAGS_DEBUG} ${LLVM_CRT_FLAG}d" CACHE STRING "")
  set(CMAKE_CXX_FLAGS_DEBUG "/Od /Oi- /Ob0 /Gy- /GS /RTC1 /Z7 ${VCPKG_CXX_FLAGS_DEBUG} ${LLVM_CRT_FLAG}d" CACHE STRING "")
endif()

set(CMAKE_C_FLAGS_RELEASE "/O1 /Oi /GS- /GF /Z7 ${VCPKG_C_FLAGS_RELEASE} ${LLVM_CRT_FLAG} /DNDEBUG" CACHE STRING "")
set(CMAKE_CXX_FLAGS_RELEASE "/O1 /Oi /GS- /GF /Z7 ${VCPKG_CXX_FLAGS_RELEASE} ${LLVM_CRT_FLAG} /DNDEBUG" CACHE STRING "")

set(CMAKE_C_FLAGS_INIT "" CACHE STRING "")
set(CMAKE_CXX_FLAGS_INIT "" CACHE STRING "")

set(CMAKE_C_FLAGS_DEBUG_INIT "" CACHE STRING "")
set(CMAKE_CXX_FLAGS_DEBUG_INIT "" CACHE STRING "")

set(CMAKE_C_FLAGS_RELEASE_INIT "" CACHE STRING "")
set(CMAKE_CXX_FLAGS_RELEASE_INIT "" CACHE STRING "")

set(CMAKE_STATIC_LINKER_FLAGS "" CACHE STRING "")
set(CMAKE_SHARED_LINKER_FLAGS "${VCPKG_LINKER_FLAGS} /DEBUG:FULL" CACHE STRING "")
set(CMAKE_EXE_LINKER_FLAGS "${VCPKG_LINKER_FLAGS} /DEBUG:FULL" CACHE STRING "")

if(CMAKE_BINARY_DIR MATCHES "^${VCPKG_ROOT}")
  set(CMAKE_STATIC_LINKER_FLAGS_DEBUG "" CACHE STRING "")
  set(CMAKE_SHARED_LINKER_FLAGS_DEBUG "/OPT:REF /OPT:ICF" CACHE STRING "")
  set(CMAKE_EXE_LINKER_FLAGS_DEBUG "/OPT:REF /OPT:ICF" CACHE STRING "")
else()
  set(CMAKE_STATIC_LINKER_FLAGS_DEBUG "" CACHE STRING "")
  set(CMAKE_SHARED_LINKER_FLAGS_DEBUG "/INCREMENTAL" CACHE STRING "")
  set(CMAKE_EXE_LINKER_FLAGS_DEBUG "/INCREMENTAL" CACHE STRING "")
endif()

set(CMAKE_STATIC_LINKER_FLAGS_RELEASE "" CACHE STRING "")
set(CMAKE_SHARED_LINKER_FLAGS_RELEASE "/OPT:REF /OPT:ICF" CACHE STRING "")
set(CMAKE_EXE_LINKER_FLAGS_RELEASE "/OPT:REF /OPT:ICF" CACHE STRING "")

set(CMAKE_RC_FLAGS "/nologo -c65001" CACHE STRING "")

add_definitions(/D_WIN64 /D_WINDOWS /D_WIN32_WINNT=0x0A00 /DWINVER=0x0A00)
add_definitions(/D_CRT_STDIO_ISO_WIDE_SPECIFIERS /D_CRT_NONSTDC_NO_DEPRECATE)
add_definitions(/D_CRT_SECURE_NO_DEPRECATE /D_CRT_SECURE_NO_WARNINGS)
add_definitions(/D_ATL_SECURE_NO_DEPRECATE /D_SCL_SECURE_NO_WARNINGS)

set(SILENCE_VS_WARNINGS "${CMAKE_C_COMPILER};${CMAKE_CXX_COMPILER}")
