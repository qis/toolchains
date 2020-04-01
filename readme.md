# Toolchains
Custom [vcpkg](https://github.com/microsoft/vcpkg) toolchains.

## Requirements
* Working system compiler (Visual Studio 2019 on Windows; GCC on Linux).
* CMake 3.17.0 or newer.
* Ninja 1.8.2 or newer.
* Git 2.17.1 or newer.

## Directories
Create directories in `cmd.exe`.

```cmd
md C:\Workspace
md C:\Workspace\downloads
```

Create symlinks in `wsl.exe`.

```sh
sudo ln -s /mnt/c/Workspace/vcpkg /opt/vcpkg
sudo ln -s /mnt/c/Workspace/downloads /opt/downloads
```

## Download
Download vcpkg with toolset patches and this toolchain.

```cmd
cd C:\Workspace
git clone git@github.com:microsoft/vcpkg
git clone git@github.com:qis/toolchains vcpkg/triplets/toolchains
```

## Setup
Set Windows environment variables.

```cmd
set VCPKG_ROOT=C:\Workspace\vcpkg
set VCPKG_DOWNLOADS=C:\Workspace\downloads
set VCPKG_DEFAULT_TRIPLET=x64-windows
```

Set Linux environment variables.

```sh
export VCPKG_ROOT=/opt/vcpkg
export VCPKG_DOWNLOADS=/opt/downloads
export VCPKG_DEFAULT_TRIPLET=x64-linux
```

## Vcpkg
Build vcpkg in `cmd.exe`.

```cmd
C:\Workspace\vcpkg\bootstrap-vcpkg.bat -disableMetrics -win64
```

Build vcpkg in `wsl.exe`.

```sh
/opt/vcpkg/bootstrap-vcpkg.sh -disableMetrics -useSystemBinaries && rm -rf /opt/vcpkg/toolsrc/build.rel
```

## Triplets

<details>
<summary>Modify the <code>triplets/x64-windows.cmake</code> triplet file.</summary>
&nbsp;

```cmake
set(VCPKG_TARGET_ARCHITECTURE x64)
set(VCPKG_CRT_LINKAGE dynamic)
set(VCPKG_LIBRARY_LINKAGE dynamic)

set(VCPKG_CHAINLOAD_TOOLCHAIN_FILE "C:/Workspace/vcpkg/triplets/toolchains/windows.cmake")
set(VCPKG_LOAD_VCVARS_ENV ON)

set(VCPKG_C_FLAGS "/arch:AVX2 /W3 /wd26812 /wd28251 /wd4275")
set(VCPKG_CXX_FLAGS "${VCPKG_C_FLAGS}")
```

</details>

<details>
<summary>Modify the <code>triplets/x64-windows-static.cmake</code> triplet file.</summary>
&nbsp;

```cmake
set(VCPKG_TARGET_ARCHITECTURE x64)
set(VCPKG_CRT_LINKAGE static)
set(VCPKG_LIBRARY_LINKAGE static)

set(VCPKG_CHAINLOAD_TOOLCHAIN_FILE "C:/Workspace/vcpkg/triplets/toolchains/windows.cmake")
set(VCPKG_LOAD_VCVARS_ENV ON)

set(VCPKG_C_FLAGS "/arch:AVX2 /W3 /wd26812 /wd28251 /wd4275")
set(VCPKG_CXX_FLAGS "${VCPKG_C_FLAGS}")
```

</details>

<details>
<summary>Modify the <code>triplets/x64-linux.cmake</code> triplet file.</summary>
&nbsp;

```cmake
set(VCPKG_TARGET_ARCHITECTURE x64)
set(VCPKG_CRT_LINKAGE dynamic)
set(VCPKG_LIBRARY_LINKAGE static)

set(VCPKG_CMAKE_SYSTEM_NAME Linux)
set(VCPKG_CHAINLOAD_TOOLCHAIN_FILE "/opt/vcpkg/triplets/toolchains/linux.cmake")
```

**NOTE**: `VCPKG_CRT_LINKAGE` can be `static` on musl-based Linux distributions.

</details>

## Compiler
Build LLVM in `wsl.exe`.

```sh
make -C /opt/vcpkg/triplets/toolchains
```

## Ports
Install ports.

```sh
# Development
vcpkg install benchmark gtest

# Encryption
vcpkg install openssl libssh2

# Compression
vcpkg install bzip2 liblzma zlib zstd

# Utility
vcpkg install date fmt bfgroup-lyra pugixml spdlog tbb utf8proc

# Images
vcpkg install giflib libjpeg-turbo libpng tiff

# Fonts
vcpkg install freetype harfbuzz

# Boost
vcpkg install boost
```

<!--
## Exceptions
Some ports require macro definitions to disable exceptions.

* `gtest` incorrectly sets `_HAS_EXCEPTIONS=1` and requires `GTEST_HAS_EXCEPTIONS=0` during compilation
* `fmt` requires `FMT_EXCEPTIONS=0`
* `pugixml` requires `PUGIXML_NO_EXCEPTIONS`
* `spdlog` requires `SPDLOG_NO_EXCEPTIONS`

## Resources
The following repositories show how this setup can be used in a production environment.

* [qis/test](https://github.com/qis/test)
* [qis/example](https://github.com/qis/example)
* [qis/library](https://github.com/qis/library)
* [qis/server](https://github.com/qis/server)
-->
