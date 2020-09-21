if(NOT DEFINED VCPKG_TARGET_TRIPLET)
  set(VCPKG_TARGET_TRIPLET "x64-linux-ipo" CACHE STRING "")
endif()

include("${CMAKE_CURRENT_LIST_DIR}/config.cmake")

if(DEFINED CMAKE_CXX_CLANG_TIDY AND NOT CMAKE_BUILD_TYPE STREQUAL "Debug")
  unset(CMAKE_CXX_CLANG_TIDY CACHE)
endif()

# Set system.
set(CMAKE_CROSSCOMPILING OFF CACHE BOOL "")
set(CMAKE_SYSTEM_PROCESSOR x86_64 CACHE STRING "")
set(CMAKE_SYSTEM_NAME Linux CACHE STRING "")

# Set compiler.
set(CMAKE_C_COMPILER "cc" CACHE STRING "" FORCE)
set(CMAKE_CXX_COMPILER "c++" CACHE STRING "" FORCE)
set(CMAKE_RANLIB "ranlib" CACHE STRING "" FORCE)
set(CMAKE_AR "ar" CACHE STRING "" FORCE)
set(CMAKE_NM "nm" CACHE STRING "" FORCE)

# Set compiler flags.
set(WARN_FLAGS "-Wall -Wextra -Wpedantic -Wrange-loop-analysis")
set(WARN_FLAGS "${WARN_FLAGS} -Wno-unused-variable -Wno-unused-parameter")
set(WARN_FLAGS "${WARN_FLAGS} -Wno-gnu-zero-variadic-macro-arguments")

set(CMAKE_C_FLAGS_INIT "-fasm -fPIC -fdiagnostics-absolute-paths ${WARN_FLAGS} ${VCPKG_C_FLAGS}")
set(CMAKE_C_FLAGS_DEBUG_INIT "${VCPKG_C_FLAGS_DEBUG}")
set(CMAKE_C_FLAGS_RELEASE_INIT "${VCPKG_C_FLAGS_RELEASE} -flto=full")
set(CMAKE_C_FLAGS_MINSIZEREL_INIT "${VCPKG_C_FLAGS_RELEASE} -flto=full")
set(CMAKE_C_FLAGS_RELWITHDEBINFO_INIT "${VCPKG_C_FLAGS_RELEASE}")

set(CMAKE_CXX_FLAGS_INIT "-stdlib=libc++ -fasm -fPIC -fdiagnostics-absolute-paths ${WARN_FLAGS} ${VCPKG_CXX_FLAGS}")
set(CMAKE_CXX_FLAGS_DEBUG_INIT "${VCPKG_CXX_FLAGS_DEBUG}")
set(CMAKE_CXX_FLAGS_RELEASE_INIT "${VCPKG_CXX_FLAGS_RELEASE} -flto=full -fvirtual-function-elimination -fwhole-program-vtables")
set(CMAKE_CXX_FLAGS_MINSIZEREL_INIT "${VCPKG_CXX_FLAGS_RELEASE} -flto=full -fvirtual-function-elimination -fwhole-program-vtables")
set(CMAKE_CXX_FLAGS_RELWITHDEBINFO_INIT "${VCPKG_CXX_FLAGS_RELEASE}")

# Set linker flags.
foreach(LINKER SHARED_LINKER MODULE_LINKER EXE_LINKER)
  set(CMAKE_${LINKER}_FLAGS_INIT "-pthread ${VCPKG_LINKER_FLAGS} -fuse-ld=lld -ldl")
  set(CMAKE_${LINKER}_FLAGS_RELEASE_INIT "-Wl,-s")
  set(CMAKE_${LINKER}_FLAGS_MINSIZEREL_INIT "-Xlinker -plugin-opt=O3 -Wl,-s")
  if(VCPKG_CRT_LINKAGE STREQUAL "static")
    set(CMAKE_${LINKER}_FLAGS_INIT "-static ${CMAKE_${LINKER}_FLAGS_INIT}")
  endif()
endforeach()
