set(VCPKG_CMAKE_SYSTEM_NAME Linux)
set(VCPKG_TARGET_ARCHITECTURE x64)
set(VCPKG_LIBRARY_LINKAGE static)
set(VCPKG_CRT_LINKAGE dynamic)

set(VCPKG_CHAINLOAD_TOOLCHAIN_FILE "/opt/vcpkg/triplets/toolchains/linux.cmake")

if(PORT STREQUAL pdf)
  set(VCPKG_LIBRARY_LINKAGE dynamic)
endif()
