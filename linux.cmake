if(CMAKE_HOST_SYSTEM_NAME STREQUAL "Linux")
  set(CMAKE_CROSSCOMPILING OFF CACHE BOOL "")
endif()
set(CMAKE_SYSTEM_NAME Linux CACHE STRING "")

get_property(_CMAKE_IN_TRY_COMPILE GLOBAL PROPERTY IN_TRY_COMPILE)
if(NOT _CMAKE_IN_TRY_COMPILE)
  if(NOT VCPKG_CRT_LINKAGE)
    include(${CMAKE_CURRENT_LIST_DIR}/../../triplets/${VCPKG_TARGET_TRIPLET}.cmake)
  endif()

  if(VCPKG_CRT_LINKAGE STREQUAL "static")
    set(CMAKE_SHARED_LINKER_FLAGS "${CMAKE_SHARED_LINKER_FLAGS} -pthread -static" CACHE STRING "")
    set(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} -pthread -static" CACHE STRING "")
  elseif(NOT VCPKG_CRT_LINKAGE STREQUAL "dynamic")
    message(FATAL_ERROR "Invalid setting for VCPKG_CRT_LINKAGE: \"${VCPKG_CRT_LINKAGE}\". It must be \"static\" or \"dynamic\"")
  endif()

  set(CMAKE_CXX_STANDARD 20 CACHE STRING "")
  set(CMAKE_CXX_STANDARD_REQUIRED ON CACHE STRING "")
  set(CMAKE_CXX_EXTENSIONS OFF CACHE STRING "")

  set(CMAKE_AR "llvm-ar" CACHE STRING "")
  set(CMAKE_RANLIB "llvm-ranlib" CACHE STRING "")

  set(CMAKE_C_COMPILER "clang" CACHE STRING "")
  set(CMAKE_CXX_COMPILER "clang++" CACHE STRING "")

  set(CLANG_FLAGS "-pthread -fasm -fPIC -D_DEFAULT_SOURCE=1 -fdiagnostics-absolute-paths -fcolor-diagnostics" CACHE STRING "")

  set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} ${VCPKG_C_FLAGS} ${CLANG_FLAGS}" CACHE STRING "")
  set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} ${VCPKG_CXX_FLAGS} ${CLANG_FLAGS} -fcoroutines-ts" CACHE STRING "")

  set(CMAKE_C_FLAGS_DEBUG "-g -O0 -DDEBUG ${CMAKE_C_FLAGS_DEBUG} ${VCPKG_C_FLAGS_DEBUG}" CACHE STRING "")
  set(CMAKE_CXX_FLAGS_DEBUG "-g -O0 -DDEBUG ${CMAKE_CXX_FLAGS_DEBUG} ${VCPKG_CXX_FLAGS_DEBUG}" CACHE STRING "")

  set(CMAKE_C_FLAGS_RELEASE "-Oz -flto=thin -DNDEBUG ${CMAKE_C_FLAGS_RELEASE} ${VCPKG_C_FLAGS_RELEASE}" CACHE STRING "")
  set(CMAKE_CXX_FLAGS_RELEASE "-Oz -flto=thin -DNDEBUG ${CMAKE_CXX_FLAGS_RELEASE} ${VCPKG_CXX_FLAGS_RELEASE}" CACHE STRING "")

  set(CMAKE_SHARED_LINKER_FLAGS_RELEASE "-O3 -Wl,-S -Wl,--thinlto-cache-dir=lto" CACHE STRING "")
  set(CMAKE_EXE_LINKER_FLAGS_RELEASE "-O3 -Wl,-S -Wl,--thinlto-cache-dir=lto" CACHE STRING "")

  set(CMAKE_SHARED_LINKER_FLAGS "${CMAKE_SHARED_LINKER_FLAGS} ${VCPKG_LINKER_FLAGS} -pthread" CACHE STRING "")
  set(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} ${VCPKG_LINKER_FLAGS} -pthread" CACHE STRING "")
endif()
