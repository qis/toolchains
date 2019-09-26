# Toolchains
Custom [vcpkg](https://github.com/Microsoft/vcpkg) toolchains.

<!--
```sh
cd C:/Workspace || cd /opt
git clone git@github.com:Microsoft/vcpkg
cmake -E remove_directory vcpkg/scripts/toolchains
git clone git@github.com:qis/toolchains vcpkg/scripts/toolchains
```
-->

```sh
cd C:/Workspace || cd /opt
git clone --depth 1 git@github.com:Microsoft/vcpkg
cmake -E remove_directory vcpkg/scripts/toolchains
git clone git@github.com:qis/toolchains vcpkg/scripts/toolchains
```

Download Strawberry Perl in WSL.

```sh
wget --continue --directory-prefix=/mnt/c/Workspace/vcpkg/downloads \
  "$(grep strawberryperl.com /mnt/c/Workspace/vcpkg/scripts/cmake/vcpkg_find_acquire_program.cmake | cut -d\" -f2)"
```

You can create a symlink from `/mnt/c/Workspace/vcpkg` to `/opt/vcpkg` to improve compilation times, but you
won't be able to use `vcpkg upgrade` or install ports in Windows and WSL at the same time.

## Windows
Set up environment variables.

```cmd
set PATH=%PATH%;C:\Workspace\vcpkg
set VCPKG_DEFAULT_TRIPLET=x64-windows
```

Build Vcpkg.

```cmd
bootstrap-vcpkg -disableMetrics -win64
vcpkg integrate install
```

<details>
<summary>Modify the <code>triplets/x64-windows.cmake</code> triplet file.</summary>
Example for targeting specific CPUs and disabling exceptions and RTTI.

```cmake
set(VCPKG_TARGET_ARCHITECTURE x64)
set(VCPKG_CRT_LINKAGE dynamic)
set(VCPKG_LIBRARY_LINKAGE static)

set(VCPKG_C_FLAGS "/arch:AVX2 /favor:INTEL64")
set(VCPKG_CXX_FLAGS "/arch:AVX2 /favor:INTEL64 /EHs-c- /GR- /D_HAS_EXCEPTIONS=0")

if(PORT STREQUAL "ragel")
  set(VCPKG_C_FLAGS "/arch:AVX2 /favor:INTEL64")
  set(VCPKG_CXX_FLAGS "/arch:AVX2 /favor:INTEL64")
endif()

if(PORT STREQUAL "fmt")
  set(VCPKG_CXX_FLAGS "${VCPKG_CXX_FLAGS} /DFMT_EXCEPTIONS=0")
endif()

if(PORT STREQUAL "harfbuzz")
  set(VCPKG_C_FLAGS "${VCPKG_C_FLAGS} /DHB_NO_MT=1")
  set(VCPKG_CXX_FLAGS "${VCPKG_CXX_FLAGS} /DHB_NO_MT=1")
endif()

if(PORT STREQUAL "pugixml")
  set(VCPKG_CXX_FLAGS "${VCPKG_CXX_FLAGS} /DPUGIXML_NO_EXCEPTIONS=1")
endif()

if(PORT STREQUAL "tbb")
  set(VCPKG_CXX_FLAGS "${VCPKG_CXX_FLAGS} /DTBB_USE_EXCEPTIONS=0")
endif()
```

NOTE: Use [/d2FH4](https://devblogs.microsoft.com/cppblog/making-cpp-exception-handling-smaller-x64/)
for faster exception handling.
</details>

## Linux
Set up environment variables.

```sh
export PATH="${PATH}:/opt/vcpkg"
export VCPKG_DEFAULT_TRIPLET="x64-linux"
```

Build Vcpkg.

```sh
CC=gcc CXX=g++ bootstrap-vcpkg.sh -disableMetrics -useSystemBinaries
rm -rf /opt/vcpkg/toolsrc/build.rel
```

<details>
<summary>Modify the <code>triplets/x64-linux.cmake</code> triplet file.</summary>
Example for targeting specific CPUs and disabling exceptions and RTTI.

```cmake
set(VCPKG_TARGET_ARCHITECTURE x64)
set(VCPKG_CRT_LINKAGE dynamic)
set(VCPKG_LIBRARY_LINKAGE static)

set(VCPKG_C_FLAGS "-march=broadwell -mavx2")
set(VCPKG_CXX_FLAGS "-march=broadwell -mavx2")

set(VCPKG_CMAKE_SYSTEM_NAME Linux)
```
</details>

[Instal a custom LLVM toolchain.](llvm/linux.md)

## Ports
Install ports.

```sh
# Development
vcpkg install benchmark gtest

# Encryption
vcpkg install openssl

# Compression
vcpkg install bzip2 liblzma libzip[bzip2,openssl] zlib

# Utility
vcpkg install date fmt libssh2 nlohmann-json pugixml ragel reproc spdlog tbb utf8proc

# Images
vcpkg install giflib libjpeg-turbo libpng tiff

# Fonts
vcpkg install freetype harfbuzz[ucdn]

# Boost
vcpkg install boost
```

<!--
### Windows
```cmd
git clone git@github.com:xnetsystems/backward vcpkg/ports/backward && ^
git clone git@github.com:xnetsystems/bcrypt vcpkg/ports/bcrypt && ^
git clone git@github.com:xnetsystems/compat vcpkg/ports/compat && ^
git clone git@github.com:xnetsystems/ice vcpkg/ports/ice && ^
git clone git@github.com:xnetsystems/pdf vcpkg/ports/pdf && ^
git clone git@github.com:xnetsystems/sql vcpkg/ports/sql && ^
git clone git:libraries/http vcpkg/ports/http

vcpkg install benchmark gtest ^
  openssl bzip2 liblzma libzip[bzip2,openssl] zlib ^
  date fmt libssh2 nlohmann-json pugixml ragel reproc spdlog tbb utf8proc ^
  giflib libjpeg-turbo libpng tiff ^
  freetype harfbuzz[ucdn] ^
  bcrypt compat ice pdf sql http ^
  boost
```

### Linux
```sh
git clone git@github.com:xnetsystems/backward vcpkg/ports/backward && \
git clone git@github.com:xnetsystems/bcrypt vcpkg/ports/bcrypt && \
git clone git@github.com:xnetsystems/compat vcpkg/ports/compat && \
git clone git@github.com:xnetsystems/ice vcpkg/ports/ice && \
git clone git@github.com:xnetsystems/pdf vcpkg/ports/pdf && \
git clone git@github.com:xnetsystems/sql vcpkg/ports/sql && \
git clone git:libraries/http vcpkg/ports/http

vcpkg install benchmark gtest \
  openssl bzip2 liblzma libzip[bzip2,openssl] zlib \
  date fmt libssh2 nlohmann-json pugixml ragel reproc spdlog utf8proc \
  giflib libjpeg-turbo libpng tiff \
  freetype harfbuzz[ucdn] \
  backward bcrypt compat ice pdf sql http \
  boost
```

### Vulkan
```cmd
vcpkg install benchmark gtest ^
  fmt ragel reproc spdlog tbb utf8proc ^
  giflib libjpeg-turbo libpng tiff ^
  freetype harfbuzz[ucdn] ^
  volk
```
-->

## Usage
See [vcpkg-test](https://github.com/qis/vcpkg-test) for usage examples.

## Resources
This repository demonstrates how to set up and use a custom build environment to build
optimized applications and libraries.

* [qis/toolchains](https://github.com/qis/toolchains) Custom vcpkg toolchains.
* [qis/application](https://github.com/qis/application) CMake template for a C++ application.
* [qis/library](https://github.com/qis/library) CMake template for a C++ library.
* [qis/server](https://github.com/qis/server) CMake template for a C++ server.
