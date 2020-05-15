include_guard(GLOBAL)

# Set C standard.
set(CMAKE_C_STANDARD 11 CACHE STRING "")
set(CMAKE_C_STANDARD_REQUIRED ON CACHE STRING "")
set(CMAKE_C_EXTENSIONS ON CACHE STRING "")

# Set C++ standard.
set(CMAKE_CXX_STANDARD 20 CACHE STRING "")
set(CMAKE_CXX_STANDARD_REQUIRED ON CACHE STRING "")
set(CMAKE_CXX_EXTENSIONS OFF CACHE STRING "")

# Determine vcpkg root directory.
if(NOT DEFINED VCPKG_ROOT)
  if(DEFINED ENV{VCPKG_ROOT})
    set(VCPKG_ROOT "$ENV{VCPKG_ROOT}" CACHE STRING "")
  else()
    get_filename_component(VCPKG_ROOT "${CMAKE_CURRENT_LIST_DIR}/../.." ABSOLUTE CACHE)
  endif()
endif()

# Determine vcpkg target triplet.
if(NOT VCPKG_TARGET_TRIPLET)
  if(DEFINED ENV{VCPKG_DEFAULT_TRIPLET})
    set(VCPKG_TARGET_TRIPLET "$ENV{VCPKG_DEFAULT_TRIPLET}" CACHE STRING "")
  else()
    if(WIN32)
      set(VCPKG_TARGET_TRIPLET "x64-windows" CACHE STRING "")
    else()
      set(VCPKG_TARGET_TRIPLET "x64-linux" CACHE STRING "")
    endif()
  endif()
endif()

# Include vcpkg triplet.
if(NOT VCPKG_CRT_LINKAGE)
  include("${VCPKG_ROOT}/triplets/${VCPKG_TARGET_TRIPLET}.cmake")
endif()

# Prefer LLVM executables.
if(EXISTS ${CMAKE_CURRENT_LIST_DIR}/llvm/bin)
  list(INSERT CMAKE_PROGRAM_PATH 0 ${CMAKE_CURRENT_LIST_DIR}/llvm/bin)
endif()

# Modules
list(INSERT CMAKE_MODULE_PATH 0 ${CMAKE_CURRENT_LIST_DIR}/cmake)
