set(VCPKG_LOAD_VCVARS_ENV ON)
set(VCPKG_TARGET_ARCHITECTURE x64)
set(VCPKG_LIBRARY_LINKAGE static)
set(VCPKG_CRT_LINKAGE static)

set(VCPKG_CHAINLOAD_TOOLCHAIN_FILE "C:/Workspace/vcpkg/triplets/toolchains/windows.cmake")

if(PORT STREQUAL pdf)
  set(VCPKG_LIBRARY_LINKAGE dynamic)
endif()
