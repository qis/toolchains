# Toolchains
Custom [vcpkg](https://github.com/microsoft/vcpkg) toolchains.

## Requirements
* Working system compiler (Visual Studio 2019 on Windows; GCC on Linux).
* CMake 3.17.0 or newer.
* Ninja 1.10.0 or newer.
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
git clone git@github.com:microsoft/vcpkg C:/Workspace/vcpkg
git clone git@github.com:qis/toolchains C:/Workspace/vcpkg/triplets/toolchains
```

## Setup
Set Windows environment variables.

```cmd
set VSCMD_SKIP_SENDTELEMETRY=1
set VCPKG_KEEP_ENV_VARS=VSCMD_SKIP_SENDTELEMETRY
set VCPKG_DEFAULT_TRIPLET=x64-windows-msvc
set VCPKG_DOWNLOADS=C:\Workspace\downloads
set VCPKG_ROOT=C:\Workspace\vcpkg
```

Set Linux environment variables.

```sh
export VCPKG_DEFAULT_TRIPLET="x64-linux-llvm"
export VCPKG_DOWNLOADS="/opt/downloads"
export VCPKG_ROOT="/opt/vcpkg"
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
Overwrite existing vcpkg triplet files or create new ones.

<details>
<summary>Modify the <code>triplets/x64-windows-msvc.cmake</code> triplet file.</summary>
&nbsp;

```cmake
set(VCPKG_TARGET_ARCHITECTURE x64)
set(VCPKG_CRT_LINKAGE dynamic)
set(VCPKG_LIBRARY_LINKAGE static)

set(VCPKG_CHAINLOAD_TOOLCHAIN_FILE "C:/Workspace/vcpkg/triplets/toolchains/windows.cmake")
set(VCPKG_LOAD_VCVARS_ENV ON)

set(VCPKG_C_FLAGS "/arch:AVX2 /W3 /wd26812 /wd28251 /wd4275")
set(VCPKG_CXX_FLAGS "${VCPKG_C_FLAGS}")
```

**NOTE**: `VCPKG_CRT_LINKAGE` can be `static`.

</details>

<details>
<summary>Modify the <code>triplets/x64-windows-llvm.cmake</code> triplet file (optional).</summary>
&nbsp;

```cmake
set(VCPKG_TARGET_ARCHITECTURE x64)
set(VCPKG_CRT_LINKAGE dynamic)
set(VCPKG_LIBRARY_LINKAGE static)

set(VCPKG_CHAINLOAD_TOOLCHAIN_FILE "C:/Workspace/vcpkg/triplets/toolchains/windows-llvm.cmake")
set(VCPKG_POLICY_SKIP_ARCHITECTURE_CHECK enabled)
set(VCPKG_POLICY_SKIP_DUMPBIN_CHECKS enabled)
set(VCPKG_LOAD_VCVARS_ENV ON)

set(VCPKG_C_FLAGS "/arch:AVX2 /W3 -Wno-unused-variable")
set(VCPKG_CXX_FLAGS "${VCPKG_C_FLAGS}")
```

**NOTE**: `VCPKG_CRT_LINKAGE` can be `static`.

</details>

<details>
<summary>Modify the <code>triplets/x64-linux-llvm.cmake</code> triplet file.</summary>
&nbsp;

```cmake
set(VCPKG_TARGET_ARCHITECTURE x64)
set(VCPKG_CRT_LINKAGE dynamic)
set(VCPKG_LIBRARY_LINKAGE static)

set(VCPKG_CMAKE_SYSTEM_NAME Linux)
set(VCPKG_CHAINLOAD_TOOLCHAIN_FILE "/opt/vcpkg/triplets/toolchains/linux.cmake")

set(VCPKG_LINKER_FLAGS "-ldl")  # remove on musl-based systems
```

**NOTE**: `VCPKG_CRT_LINKAGE` can be `static`.

</details>

## Compiler
Install [LLVM](https://releases.llvm.org/download.html) and add it to the `Path` system environment variable.

Install [LLVM](https://releases.llvm.org/download.html) in WSL.

```sh
sudo rm -rf /opt/llvm; sudo mkdir -p /opt/llvm
wget https://github.com/llvm/llvm-project/releases/download/llvmorg-10.0.0/clang+llvm-10.0.0-x86_64-linux-gnu-ubuntu-18.04.tar.xz
sudo tar xf clang+llvm-10.0.0-x86_64-linux-gnu-ubuntu-18.04.tar.xz -C /opt/llvm --strip-components 1
echo "/opt/llvm/lib" | sudo tee /etc/ld.so.conf.d/llvm.conf
sudo ldconfig
```

Switch the default C and C++ compiler to LLVM.

```sh
sudo update-alternatives --install /usr/bin/cc cc /opt/llvm/bin/clang 100
sudo update-alternatives --install /usr/bin/c++ c++ /opt/llvm/bin/clang++ 100
```

<!--
Build LLVM in `cmd.exe` (optional).

```cmd
cd C:\Workspace\vcpkg\triplets\toolchains && make
```

Build LLVM in `wsl.exe`.

```sh
cd /opt/vcpkg/triplets/toolchains && make
```
-->

## Ports
Install ports.

```sh
# Development
vcpkg install benchmark gtest

# Encryption
vcpkg install openssl

# Compression
vcpkg install bzip2 liblzma libzip zlib zstd

# Utility
vcpkg install bfgroup-lyra date fmt libssh2 pugixml spdlog utf8proc

# Images
vcpkg install giflib libjpeg-turbo libpng tiff

# Fonts
vcpkg install freetype harfbuzz
```

## Overlay
Create a ports overlay for [boost](https://www.boost.org/) and [tbb](https://software.intel.com/en-us/tbb).

```cmd
git clone git@github.com:qis/boost C:/Workspace/ports
cmake -DVCPKG_ROOT=C:/Workspace/vcpkg -P C:/Workspace/ports/create.cmake
git clone git@github.com:qis/tbb C:/Workspace/ports/tbb
```

Install ports in `cmd.exe`.

```cmd
vcpkg install --overlay-ports=C:/Workspace/ports boost tbb
```

Install ports in `wsl.exe`.

```sh
vcpkg install --overlay-ports=/opt/ports boost tbb
```

<!--
## Exceptions
Some ports require macro definitions to disable exceptions.

* `gtest` incorrectly sets `_HAS_EXCEPTIONS=1` and requires `GTEST_HAS_EXCEPTIONS=0` during compilation
* `fmt` requires `FMT_EXCEPTIONS=0`
* `pugixml` requires `PUGIXML_NO_EXCEPTIONS`
* `spdlog` requires `SPDLOG_NO_EXCEPTIONS`

The following repositories show how this setup can be used in a production environment.

* [qis/test](https://github.com/qis/test)
* [qis/example](https://github.com/qis/example)
* [qis/library](https://github.com/qis/library)
* [qis/server](https://github.com/qis/server)
-->
