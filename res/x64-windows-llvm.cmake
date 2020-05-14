set(VCPKG_TARGET_ARCHITECTURE x64)
set(VCPKG_CRT_LINKAGE dynamic)
set(VCPKG_LIBRARY_LINKAGE static)

set(VCPKG_CHAINLOAD_TOOLCHAIN_FILE "C:/Workspace/vcpkg/triplets/toolchains/windows-llvm.cmake")
set(VCPKG_POLICY_SKIP_ARCHITECTURE_CHECK enabled)
set(VCPKG_POLICY_SKIP_DUMPBIN_CHECKS enabled)
set(VCPKG_LOAD_VCVARS_ENV ON)

set(VCPKG_C_FLAGS "/arch:AVX2 /W3 -Wno-unused-variable")
set(VCPKG_CXX_FLAGS "${VCPKG_C_FLAGS} /EHsc /GR")

if(PORT STREQUAL harfbuzz)
  set(VCPKG_CXX_FLAGS "${VCPKG_CXX_FLAGS} /wd4172")
endif()

if(PORT STREQUAL libssh2)
  set(VCPKG_LIBRARY_LINKAGE static)
endif()
