set(VCPKG_TARGET_ARCHITECTURE x64)
set(VCPKG_CRT_LINKAGE dynamic)
set(VCPKG_LIBRARY_LINKAGE static)

set(VCPKG_CHAINLOAD_TOOLCHAIN_FILE "C:/Workspace/vcpkg/triplets/toolchains/windows.cmake")
set(VCPKG_LOAD_VCVARS_ENV ON)

set(VCPKG_C_FLAGS "/arch:AVX2 /W3 /wd26812 /wd28251 /wd4275")
set(VCPKG_CXX_FLAGS "${VCPKG_C_FLAGS} /EHsc /GR")

if(PORT STREQUAL harfbuzz)
  set(VCPKG_CXX_FLAGS "${VCPKG_CXX_FLAGS} /wd4172")
endif()

if(PORT STREQUAL libssh2)
  set(VCPKG_LIBRARY_LINKAGE static)
endif()
