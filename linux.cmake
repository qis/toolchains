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

  set(CLANG_FLAGS "-pthread -fasm -fPIC -D_DEFAULT_SOURCE=1")
  set(CLANG_FLAGS "${CLANG_FLAGS} -fdiagnostics-absolute-paths -fcolor-diagnostics")

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

  add_definitions(-D_PSTL_PAR_BACKEND_TBB=1)
  include_directories(BEFORE SYSTEM /opt/llvm/include/c++/v1/pstl/stdlib)
  link_libraries(tbb tbbmalloc)

  function(vcpkg_find_library name header)
    if(NOT TARGET ${name})
      find_path(${name}_INCLUDE_DIR ${header} PATHS
        ${_VCPKG_ROOT_DIR}/installed/${VCPKG_TARGET_TRIPLET}/include NO_DEFAULT_PATH)
      if(NOT ${name}_INCLUDE_DIR)
        message(FATAL_ERROR "Could not find library: ${name} (${header})")
      endif()
      if(ARGN)
        foreach(arg IN LISTS ARGN)
          if(NOT ${name}_LIBRARY_DEBUG)
            find_library(${name}_LIBRARY_DEBUG NAMES ${arg} PATHS
              ${_VCPKG_ROOT_DIR}/installed/${VCPKG_TARGET_TRIPLET}/debug/lib NO_DEFAULT_PATH)
          endif()
          if(NOT ${name}_LIBRARY_RELEASE)
            find_library(${name}_LIBRARY_RELEASE NAMES ${arg} PATHS
              ${_VCPKG_ROOT_DIR}/installed/${VCPKG_TARGET_TRIPLET}/lib NO_DEFAULT_PATH)
          endif()
        endforeach()
        if(NOT ${name}_LIBRARY_DEBUG OR NOT ${name}_LIBRARY_RELEASE)
          message(FATAL_ERROR "Could not find library: ${name}")
        endif()
        add_library(${name} STATIC IMPORTED)
        set_target_properties(${name} PROPERTIES IMPORTED_LOCATION_DEBUG "${${name}_LIBRARY_DEBUG}")
        set_target_properties(${name} PROPERTIES IMPORTED_LOCATION_RELEASE "${${name}_LIBRARY_RELEASE}")
        message(STATUS "Found ${name}: ${${name}_LIBRARY_DEBUG} (Debug)")
        message(STATUS "Found ${name}: ${${name}_LIBRARY_RELEASE} (Release)")
      else()
        add_library(${name} INTERFACE)
      endif()
      set_target_properties(${name} PROPERTIES INTERFACE_INCLUDE_DIRECTORIES "${${name}_INCLUDE_DIR}")
    endif()
  endfunction()
endif()
