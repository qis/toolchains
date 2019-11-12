include_guard(GLOBAL)

set(CMAKE_C_STANDARD 11 CACHE STRING "")
set(CMAKE_C_STANDARD_REQUIRED ON CACHE STRING "")
set(CMAKE_C_EXTENSIONS OFF CACHE STRING "")

set(CMAKE_CXX_STANDARD 20 CACHE STRING "")
set(CMAKE_CXX_STANDARD_REQUIRED ON CACHE STRING "")
set(CMAKE_CXX_EXTENSIONS OFF CACHE STRING "")

if(NOT VCPKG_CRT_LINKAGE)
  include(${CMAKE_CURRENT_LIST_DIR}/../../triplets/${VCPKG_TARGET_TRIPLET}.cmake)
endif()

if(CMAKE_BUILD_TYPE STREQUAL Release)
  set(CMAKE_C_COMPILER "${CMAKE_CURRENT_LIST_DIR}/llvm/bin/clang-cl.exe" CACHE STRING "" FORCE)
  set(CMAKE_CXX_COMPILER "${CMAKE_CURRENT_LIST_DIR}/llvm/bin/clang-cl.exe" CACHE STRING "" FORCE)
  set(CMAKE_LINKER "${CMAKE_CURRENT_LIST_DIR}/llvm/bin/lld-link.exe" CACHE STRING "" FORCE)
  set(CMAKE_RC_COMPILER "rc.exe" CACHE STRING "" FORCE)
endif()

if(VCPKG_CRT_LINKAGE STREQUAL "dynamic")
  if(CMAKE_BUILD_TYPE STREQUAL Release)
    set(VCPKG_CRT_LINKAGE "static")
    set(CMAKE_MSVC_RUNTIME_LIBRARY "MultiThreaded$<$<CONFIG:Debug>:Debug>" CACHE STRING "" FORCE)
    set(MSVC_CRT_FLAGS "/MT")
  else()
    set(CMAKE_MSVC_RUNTIME_LIBRARY "MultiThreaded$<$<CONFIG:Debug>:Debug>DLL" CACHE STRING "" FORCE)
    set(MSVC_CRT_FLAGS "/MD")
  endif()
elseif(VCPKG_CRT_LINKAGE STREQUAL "static")
  set(CMAKE_MSVC_RUNTIME_LIBRARY "MultiThreaded$<$<CONFIG:Debug>:Debug>" CACHE STRING "" FORCE)
  set(MSVC_CRT_FLAGS "/MT")
else()
  message(FATAL_ERROR "Invalid setting for VCPKG_CRT_LINKAGE: \"${VCPKG_CRT_LINKAGE}\".")
endif()

set(MSVC_CPP_FLAGS "/Zc:strictStrings /Zc:char8_t /utf-8 /wd26812 /wd28251")
set(MSVC_CXX_FLAGS "/EHsc /GR /FI\"${CMAKE_CURRENT_LIST_DIR}/src/vs.hpp\"")

if(CMAKE_BUILD_TYPE STREQUAL Release)
  set(MSVC_CPP_FLAGS "${MSVC_CPP_FLAGS} /clang:-fasm /clang:-fopenmp-simd /clang:-flto=full")
  set(MSVC_CXX_FLAGS "${MSVC_CXX_FLAGS} /clang:-fwhole-program-vtables /clang:-fvirtual-function-elimination")
  set(MSVC_CXX_FLAGS "${MSVC_CXX_FLAGS} /clang:-fcoroutines-ts")
else()
  set(MSVC_CXX_FLAGS "${MSVC_CXX_FLAGS} /d2FH4 /await")
endif()

set(CMAKE_C_FLAGS "/nologo ${MSVC_CPP_FLAGS} ${VCPKG_C_FLAGS}" CACHE STRING "")
set(CMAKE_CXX_FLAGS "/nologo ${MSVC_CPP_FLAGS} ${MSVC_CXX_FLAGS} ${VCPKG_CXX_FLAGS}" CACHE STRING "")

if(CMAKE_BINARY_DIR MATCHES "^$ENV{VCPKG_ROOT}")
  set(CMAKE_C_FLAGS_DEBUG "/O1 /Oi /GS- /Z7 ${VCPKG_C_FLAGS_DEBUG} ${MSVC_CRT_FLAGS}d" CACHE STRING "")
  set(CMAKE_CXX_FLAGS_DEBUG "/O1 /Oi /GS- /Z7 ${VCPKG_CXX_FLAGS_DEBUG} ${MSVC_CRT_FLAGS}d" CACHE STRING "")
else()
  set(CMAKE_C_FLAGS_DEBUG "/Od /Oi- /Ob0 /Gy- /GS /RTC1 /ZI ${VCPKG_C_FLAGS_DEBUG} ${MSVC_CRT_FLAGS}d" CACHE STRING "")
  set(CMAKE_CXX_FLAGS_DEBUG "/Od /Oi- /Ob0 /Gy- /GS /RTC1 /ZI ${VCPKG_CXX_FLAGS_DEBUG} ${MSVC_CRT_FLAGS}d" CACHE STRING "")
endif()

set(CMAKE_C_FLAGS_RELEASE "/O1 /Oi /GS- /GF /Z7 ${VCPKG_C_FLAGS_RELEASE} ${MSVC_CRT_FLAGS} /DNDEBUG" CACHE STRING "")
set(CMAKE_CXX_FLAGS_RELEASE "/O1 /Oi /GS- /GF /Z7 ${VCPKG_CXX_FLAGS_RELEASE} ${MSVC_CRT_FLAGS} /DNDEBUG" CACHE STRING "")

set(CMAKE_C_FLAGS_INIT "" CACHE STRING "")
set(CMAKE_CXX_FLAGS_INIT "" CACHE STRING "")

set(CMAKE_C_FLAGS_DEBUG_INIT "" CACHE STRING "")
set(CMAKE_CXX_FLAGS_DEBUG_INIT "" CACHE STRING "")

set(CMAKE_C_FLAGS_RELEASE_INIT "" CACHE STRING "")
set(CMAKE_CXX_FLAGS_RELEASE_INIT "" CACHE STRING "")

set(CMAKE_STATIC_LINKER_FLAGS "/nologo" CACHE STRING "")
set(CMAKE_SHARED_LINKER_FLAGS "/nologo ${VCPKG_LINKER_FLAGS}" CACHE STRING "")
set(CMAKE_EXE_LINKER_FLAGS "/nologo ${VCPKG_LINKER_FLAGS}" CACHE STRING "")

if(CMAKE_BINARY_DIR MATCHES "^$ENV{VCPKG_ROOT}")
  set(CMAKE_STATIC_LINKER_FLAGS_DEBUG "" CACHE STRING "")
  set(CMAKE_SHARED_LINKER_FLAGS_DEBUG "/DEBUG:FASTLINK /OPT:REF /OPT:ICF" CACHE STRING "")
  set(CMAKE_EXE_LINKER_FLAGS_DEBUG "/DEBUG:FASTLINK /OPT:REF /OPT:ICF" CACHE STRING "")
else()
  set(CMAKE_STATIC_LINKER_FLAGS_DEBUG "" CACHE STRING "")
  set(CMAKE_SHARED_LINKER_FLAGS_DEBUG "/DEBUG:FASTLINK /INCREMENTAL /EDITANDCONTINUE" CACHE STRING "")
  set(CMAKE_EXE_LINKER_FLAGS_DEBUG "/DEBUG:FASTLINK /INCREMENTAL /EDITANDCONTINUE" CACHE STRING "")
endif()

set(CMAKE_STATIC_LINKER_FLAGS_RELEASE "" CACHE STRING "")
set(CMAKE_SHARED_LINKER_FLAGS_RELEASE "/DEBUG:FULL /OPT:REF /OPT:ICF" CACHE STRING "")
set(CMAKE_EXE_LINKER_FLAGS_RELEASE "/DEBUG:FULL /OPT:REF /OPT:ICF" CACHE STRING "")

set(CMAKE_RC_FLAGS "/nologo -c65001" CACHE STRING "")

add_definitions(/D_WIN64 /D_WINDOWS /D_WIN32_WINNT=0x0A00 /DWINVER=0x0A00)
add_definitions(/D_CRT_STDIO_ISO_WIDE_SPECIFIERS /D_CRT_NONSTDC_NO_DEPRECATE)
add_definitions(/D_CRT_SECURE_NO_DEPRECATE /D_CRT_SECURE_NO_WARNINGS)
add_definitions(/D_ATL_SECURE_NO_DEPRECATE /D_SCL_SECURE_NO_WARNINGS)

set(SILENCE_VS_WARNINGS "${CMAKE_C_COMPILER};${CMAKE_CXX_COMPILER}")
