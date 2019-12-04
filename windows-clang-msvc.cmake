include_guard(GLOBAL)
get_filename_component(VCPKG_ROOT ${CMAKE_CURRENT_LIST_DIR}/../.. ABSOLUTE CACHE)

set(CMAKE_C_STANDARD 11 CACHE STRING "")
set(CMAKE_C_STANDARD_REQUIRED ON CACHE STRING "")
set(CMAKE_C_EXTENSIONS OFF CACHE STRING "")

set(CMAKE_CXX_STANDARD 20 CACHE STRING "")
set(CMAKE_CXX_STANDARD_REQUIRED ON CACHE STRING "")
set(CMAKE_CXX_EXTENSIONS OFF CACHE STRING "")

set(CMAKE_AR "${CMAKE_CURRENT_LIST_DIR}/llvm/bin/llvm-ar.exe" CACHE STRING "")
set(CMAKE_RANLIB "${CMAKE_CURRENT_LIST_DIR}/llvm/bin/llvm-ranlib.exe" CACHE STRING "")
set(CMAKE_C_COMPILER "${CMAKE_CURRENT_LIST_DIR}/llvm/bin/clang.exe" CACHE STRING "")
set(CMAKE_CXX_COMPILER "${CMAKE_CURRENT_LIST_DIR}/llvm/bin/clang++.exe" CACHE STRING "")
set(CMAKE_RC_COMPILER "rc.exe" CACHE STRING "")

if(NOT VCPKG_CRT_LINKAGE)
  include(${VCPKG_ROOT}/triplets/${VCPKG_TARGET_TRIPLET}.cmake)
endif()

if(NOT VCPKG_CRT_LINKAGE STREQUAL "static")
  message(FATAL_ERROR "Invalid setting for VCPKG_CRT_LINKAGE: \"${VCPKG_CRT_LINKAGE}\".")
endif()

set(CMAKE_MSVC_RUNTIME_LIBRARY "" CACHE STRING "")

set(LLVM_CPP_FLAGS "-mavx2 -fasm -fopenmp-simd -ffast-math -fomit-frame-pointer -fmerge-all-constants")
set(LLVM_CPP_FLAGS "${LLVM_CPP_FLAGS} -fdiagnostics-absolute-paths -fms-compatibility-version=19.23")
set(LLVM_CXX_FLAGS "-fcoroutines-ts")

set(LLVM_CPP_FLAGS_DEBUG "-Xclang --dependent-lib=libcmtd -D_MT -D_DEBUG -g -Xclang -gcodeview")
set(LLVM_CXX_FLAGS_DEBUG "-Xclang --dependent-lib=libcpmtd")

set(LLVM_CPP_FLAGS_RELEASE "-Xclang --dependent-lib=libcmt -D_MT -DNDEBUG -flto=full")
set(LLVM_CXX_FLAGS_RELEASE "-Xclang --dependent-lib=libcpmt -fwhole-program-vtables -fvirtual-function-elimination")

set(CMAKE_C_FLAGS "${LLVM_CPP_FLAGS} ${VCPKG_C_FLAGS}" CACHE STRING "")
set(CMAKE_CXX_FLAGS "${LLVM_CPP_FLAGS} ${LLVM_CXX_FLAGS} ${VCPKG_CXX_FLAGS}" CACHE STRING "")

if(CMAKE_BINARY_DIR MATCHES "^${VCPKG_ROOT}")
  set(CMAKE_C_FLAGS_DEBUG "-Os ${LLVM_CPP_FLAGS_DEBUG} ${VCPKG_C_FLAGS_DEBUG}" CACHE STRING "")
  set(CMAKE_CXX_FLAGS_DEBUG "-Os ${LLVM_CPP_FLAGS_DEBUG} ${LLVM_CXX_FLAGS_DEBUG} ${VCPKG_CXX_FLAGS_DEBUG}" CACHE STRING "")
else()
  set(CMAKE_C_FLAGS_DEBUG "-O0 ${LLVM_CPP_FLAGS_DEBUG} ${VCPKG_C_FLAGS_DEBUG}" CACHE STRING "")
  set(CMAKE_CXX_FLAGS_DEBUG "-O0 ${LLVM_CPP_FLAGS_DEBUG} ${LLVM_CXX_FLAGS_DEBUG} ${VCPKG_CXX_FLAGS_DEBUG}" CACHE STRING "")
endif()

set(CMAKE_C_FLAGS_RELEASE "-Os ${LLVM_CPP_FLAGS_RELEASE} ${VCPKG_C_FLAGS_RELEASE}" CACHE STRING "")
set(CMAKE_CXX_FLAGS_RELEASE "-Os ${LLVM_CPP_FLAGS_RELEASE} ${LLVM_CXX_FLAGS_RELEASE} ${VCPKG_CXX_FLAGS_RELEASE}" CACHE STRING "")

set(CMAKE_C_FLAGS_INIT "" CACHE STRING "")
set(CMAKE_CXX_FLAGS_INIT "" CACHE STRING "")

set(CMAKE_C_FLAGS_DEBUG_INIT "" CACHE STRING "")
set(CMAKE_CXX_FLAGS_DEBUG_INIT "" CACHE STRING "")

set(CMAKE_C_FLAGS_RELEASE_INIT "" CACHE STRING "")
set(CMAKE_CXX_FLAGS_RELEASE_INIT "" CACHE STRING "")

set(CMAKE_STATIC_LINKER_FLAGS "" CACHE STRING "")
set(CMAKE_SHARED_LINKER_FLAGS "${VCPKG_LINKER_FLAGS} -Wl,/DEBUG:FULL" CACHE STRING "")
set(CMAKE_EXE_LINKER_FLAGS "${VCPKG_LINKER_FLAGS} -Wl,/DEBUG:FULL" CACHE STRING "")

if(NOT CMAKE_BINARY_DIR MATCHES "^${VCPKG_ROOT}")
  set(CMAKE_STATIC_LINKER_FLAGS_DEBUG "" CACHE STRING "")
  set(CMAKE_SHARED_LINKER_FLAGS_DEBUG "-Wl,/OPT:REF,/OPT:ICF" CACHE STRING "")
  set(CMAKE_EXE_LINKER_FLAGS_DEBUG "-Wl,/OPT:REF,/OPT:ICF" CACHE STRING "")
else()
  set(CMAKE_STATIC_LINKER_FLAGS_DEBUG "" CACHE STRING "")
  set(CMAKE_SHARED_LINKER_FLAGS_DEBUG "-Wl,/INCREMENTAL" CACHE STRING "")
  set(CMAKE_EXE_LINKER_FLAGS_DEBUG "-Wl,/INCREMENTAL" CACHE STRING "")
endif()

set(CMAKE_STATIC_LINKER_FLAGS_RELEASE "" CACHE STRING "")
set(CMAKE_SHARED_LINKER_FLAGS_RELEASE "-flto=full -Wl,/OPT:REF,/OPT:ICF" CACHE STRING "")
set(CMAKE_EXE_LINKER_FLAGS_RELEASE "-flto=full -Wl,/OPT:REF,/OPT:ICF" CACHE STRING "")

set(CMAKE_RC_FLAGS "/nologo -c65001" CACHE STRING "")

add_definitions(-D_WIN64 -D_WINDOWS -D_WIN32_WINNT=0x0A00 -DWINVER=0x0A00)
add_definitions(-D_CRT_SECURE_NO_DEPRECATE -D_CRT_SECURE_NO_WARNINGS -D_CRT_NONSTDC_NO_DEPRECATE)
add_definitions(-D_ATL_SECURE_NO_DEPRECATE -D_SCL_SECURE_NO_WARNINGS)

set(SILENCE_VS_WARNINGS "${CMAKE_C_COMPILER};${CMAKE_CXX_COMPILER}")
