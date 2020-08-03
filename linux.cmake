include_guard(GLOBAL)
include("${CMAKE_CURRENT_LIST_DIR}/config.cmake")

# Set system.
set(CMAKE_CROSSCOMPILING OFF CACHE BOOL "")
set(CMAKE_SYSTEM_PROCESSOR x86_64 CACHE STRING "")
set(CMAKE_SYSTEM_NAME Linux CACHE STRING "")

# Set compiler flags.
set(WARN_FLAGS "-Wall -Wextra -Wpedantic -Wrange-loop-analysis")
set(WARN_FLAGS "${WARN_FLAGS} -Wno-unused-variable -Wno-unused-parameter -Wno-nullability-completeness")

set(CMAKE_C_FLAGS_INIT "-fasm -fPIC -fdiagnostics-absolute-paths ${WARN_FLAGS} ${VCPKG_C_FLAGS}")
set(CMAKE_C_FLAGS_DEBUG_INIT "${VCPKG_C_FLAGS_DEBUG}")
set(CMAKE_C_FLAGS_RELEASE_INIT "${VCPKG_C_FLAGS_RELEASE} -flto")
set(CMAKE_C_FLAGS_MINSIZEREL_INIT "${VCPKG_C_FLAGS_RELEASE} -flto")
set(CMAKE_C_FLAGS_RELWITHDEBINFO_INIT "${VCPKG_C_FLAGS_RELEASE} -flto")

set(CMAKE_CXX_FLAGS_INIT "-fasm -fPIC -fdiagnostics-absolute-paths ${WARN_FLAGS} ${VCPKG_CXX_FLAGS}")
set(CMAKE_CXX_FLAGS_DEBUG_INIT "${VCPKG_CXX_FLAGS_DEBUG}")
set(CMAKE_CXX_FLAGS_RELEASE_INIT "${VCPKG_CXX_FLAGS_RELEASE} -flto -fvirtual-function-elimination -fwhole-program-vtables")
set(CMAKE_CXX_FLAGS_MINSIZEREL_INIT "${VCPKG_CXX_FLAGS_RELEASE} -flto -fvirtual-function-elimination -fwhole-program-vtables")
set(CMAKE_CXX_FLAGS_RELWITHDEBINFO_INIT "${VCPKG_CXX_FLAGS_RELEASE} -flto -fvirtual-function-elimination -fwhole-program-vtables")

# Set linker flags.
foreach(LINKER SHARED_LINKER MODULE_LINKER EXE_LINKER)
  set(CMAKE_${LINKER}_FLAGS_INIT "-pthread ${VCPKG_LINKER_FLAGS} -ldl")
  set(CMAKE_${LINKER}_FLAGS_RELEASE_INIT "-Wl,-s")
  set(CMAKE_${LINKER}_FLAGS_MINSIZEREL_INIT "-Wl,-s")
  if(VCPKG_CRT_LINKAGE STREQUAL "static")
    set(CMAKE_${LINKER}_FLAGS_INIT "-static ${CMAKE_${LINKER}_FLAGS_INIT}")
  endif()
endforeach()
