# Get vcpkg root directory.
if(NOT VCPKG_ROOT)
  if(DEFINED ENV{VCPKG_ROOT})
    set(VCPKG_ROOT "$ENV{VCPKG_ROOT}" CACHE STRING "")
  else()
    get_filename_component(VCPKG_ROOT "${CMAKE_CURRENT_LIST_DIR}/../.." ABSOLUTE CACHE)
  endif()
endif()

# Get vcpkg triplet.
if(NOT VCPKG_TARGET_TRIPLET)
  if(DEFINED ENV{VCPKG_DEFAULT_TRIPLET})
    set(VCPKG_TARGET_TRIPLET "$ENV{VCPKG_DEFAULT_TRIPLET}" CACHE STRING "")
  else()
    message(FATAL_ERROR "Missing setting for VCPKG_TARGET_TRIPLET. $ENV{VCPKG_DEFAULT_TRIPLET}")
  endif()
endif()

# Load vcpkg triplet.
if(NOT VCPKG_CRT_LINKAGE)
  include("${VCPKG_ROOT}/triplets/${VCPKG_TARGET_TRIPLET}.cmake")
endif()

# Set boost variables.
if(EXISTS ${CMAKE_CURRENT_LIST_DIR}/include/boost)
  set(Boost_INCLUDE_DIR ${CMAKE_CURRENT_LIST_DIR}/include)
endif()
