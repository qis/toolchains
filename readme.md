# Toolchains
Custom [vcpkg](https://github.com/microsoft/vcpkg) toolchains.

## Requirements
* Working system compiler (Visual Studio 2019 on Windows; GCC on Linux).
* CMake 3.16.0 or newer.
* Ninja 1.8.2 or newer.
* Git 2.17.1 or newer.

## Download
Download vcpkg with toolset patches and this toolchain.

```sh
cd C:/Workspace || cd /opt
git clone git@github.com:microsoft/vcpkg
cmake -E rename vcpkg/scripts/toolchains vcpkg/scripts/toolchains.orig
git clone git@github.com:qis/toolchains vcpkg/scripts/toolchains
```

Create downloads directory in `cmd.exe`.

```cmd
md C:\Workspace\downloads
```

## Setup
Set Windows environment variables in `rundll32.exe sysdm.cpl,EditEnvironmentVariables`.

```cmd
set VCPKG_ROOT=C:\Workspace\vcpkg
set VCPKG_DOWNLOADS=C:\Workspace\downloads
set VCPKG_DEFAULT_TRIPLET=x64-windows
```

Set Linux environment variables in `~/.bashrc`.

```sh
export VCPKG_ROOT=/opt/vcpkg
export VCPKG_DOWNLOADS=/opt/downloads
export VCPKG_DEFAULT_TRIPLET=x64-linux
```

Create symbolic links in `bash.exe`.

```sh
ln -s /mnt/c/Workspace/vcpkg /opt/vcpkg
ln -s /mnt/c/Workspace/downloads /opt/downloads
```

**NOTE**: Do not use `vcpkg install` or `vcpkg upgrade` in `bash.exe` and `cmd.exe` at the same time.

## Vcpkg
Build vcpkg in `cmd.exe`.

```cmd
C:\Workspace\vcpkg\bootstrap-vcpkg.bat -disableMetrics -win64
```

Build vcpkg in `bash.exe`.

```sh
/opt/vcpkg/bootstrap-vcpkg.sh -disableMetrics -useSystemBinaries && rm -rf /opt/vcpkg/toolsrc/build.rel
```

## Triplets

<details>
<summary>Modify the <code>triplets/x64-windows.cmake</code> triplet file.</summary>
&nbsp;

```cmake
set(VCPKG_TARGET_ARCHITECTURE x64)
set(VCPKG_LIBRARY_LINKAGE dynamic)
set(VCPKG_CRT_LINKAGE dynamic)

set(VCPKG_C_FLAGS "/arch:AVX2 /W3 /wd26812 /wd28251")
set(VCPKG_CXX_FLAGS "${VCPKG_C_FLAGS}")
set(VCPKG_LINKER_FLAGS "/ignore:4099")
```

</details>

<details>
<summary>Modify the <code>triplets/x64-windows-static.cmake</code> triplet file.</summary>
&nbsp;

```cmake
set(VCPKG_TARGET_ARCHITECTURE x64)
set(VCPKG_LIBRARY_LINKAGE static)
set(VCPKG_CRT_LINKAGE static)

set(VCPKG_C_FLAGS "/arch:AVX2 /W3 /wd26812 /wd28251")
set(VCPKG_CXX_FLAGS "${VCPKG_C_FLAGS}")
set(VCPKG_LINKER_FLAGS "/ignore:4099")
```

</details>

## Compiler
Build LLVM in `bash.exe`.

```sh
make -C /opt/vcpkg/scripts/toolchains
```

## Ports
Install ports.

```sh
# Development
vcpkg install benchmark gtest

# Encryption
vcpkg install openssl

# Compression
vcpkg install bzip2 liblzma zlib zstd

# Utility
vcpkg install fmt pugixml spdlog utf8proc

# Images
vcpkg install giflib libjpeg-turbo libpng tiff
```

## Exceptions
Some ports require macro definitions to disable exceptions.

* `gtest` incorrectly sets `_HAS_EXCEPTIONS=1` and requires `GTEST_HAS_EXCEPTIONS=0` during compilation
* `fmt` requires `FMT_EXCEPTIONS=0`
* `pugixml` requires `PUGIXML_NO_EXCEPTIONS`
* `spdlog` requires `SPDLOG_NO_EXCEPTIONS`

## Resources
See [qis/example](https://github.com/qis/example) for a C++ application example using this setup.
