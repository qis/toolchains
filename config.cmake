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
  get_filename_component(VCPKG_ROOT "${CMAKE_CURRENT_LIST_DIR}/../.." ABSOLUTE CACHE)
endif()

# Determine vcpkg target triplet.
if(NOT DEFINED VCPKG_TARGET_TRIPLET)
  if(WIN32)
    set(VCPKG_TARGET_TRIPLET "x64-windows-ipo" CACHE STRING "")
  else()
    set(VCPKG_TARGET_TRIPLET "x64-linux-ipo" CACHE STRING "")
  endif()
endif()

# Fix build type case.
if(CMAKE_BUILD_TYPE MATCHES "^[Dd][Ee][Bb][Uu][Gg]$")
  set(CMAKE_BUILD_TYPE "Debug" CACHE STRING "" FORCE)
elseif(CMAKE_BUILD_TYPE MATCHES "^[Rr][Ee][Ll][Ee][Aa][Ss][Ee]$")
  set(CMAKE_BUILD_TYPE "Release" CACHE STRING "" FORCE)
elseif(CMAKE_BUILD_TYPE MATCHES "^[Mm][Ii][Nn][Ss][Ii][Zz][Ee][Rr][Ee][Ll]$")
  set(CMAKE_BUILD_TYPE "MinSizeRel" CACHE STRING "" FORCE)
elseif(CMAKE_BUILD_TYPE MATCHES "^[Rr][Ee][Ll][Ww][Ii][Tt][Hh][Dd][Ee][Bb][Ii][Nn][Ff][Oo]$")
  set(CMAKE_BUILD_TYPE "RelWithDebInfo" CACHE STRING "" FORCE)
endif()

# Include vcpkg triplet.
if(NOT DEFINED VCPKG_CRT_LINKAGE)
  include("${VCPKG_ROOT}/triplets/${VCPKG_TARGET_TRIPLET}.cmake")
endif()

# Include vcpkg toolchain.
if(NOT DEFINED VCPKG_TOOLCHAIN)
  include("${VCPKG_ROOT}/scripts/buildsystems/vcpkg.cmake")
endif()

# Set modules path.
list(INSERT CMAKE_MODULE_PATH 0 ${CMAKE_CURRENT_LIST_DIR}/cmake)
