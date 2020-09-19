# Toolchains
Custom [vcpkg](https://github.com/microsoft/vcpkg) toolchains.

## Configuration
Configure the system.

### Windows
Install [Visual Studio](https://visualstudio.microsoft.com/downloads/).

```
Workloads
+ ☑ Desktop development with C++
```

Install [CMake](https://github.com/Kitware/CMake/releases/download/v3.18.0/cmake-3.18.0-win64-x64.msi).

```
Install Options
  ◉ Do not add CMake to the system PATH
```

Install [Git](https://git-scm.com/downloads) with specific settings.

```
Select Destination Location
  C:\Program Files\Git

Select Components
  ☐ Windows Explorer integration
  ☑ Git LFS (Large File Support)
  ☐ Associate .git* configuration files with the default text editor
  ☐ Associate .sh files to be run with Bash

Select Start Menu Folder
  ☑ Don't create a Start Menu folder

Choosing the default editor used by Git
  [Select other editor as Git's default editor]
  Location of editor: C:\Program Files (x86)\Vim\vim81\gvim.exe
  [Test Custom Editor]

Adjusting your PATH environment
  ◉ Use Git from Git Bash only

Choosing HTTPS transport backend
  ◉ Use the OpenSSL library

Configuring the line ending conversions
  ◉ Checkout as-is, commit as-is

Configuring the terminal emulator to use with Git Bash
  ◉ Use Windows' default console window

Configuring file system caching
  ☑ Enable file system caching
  ☑ Enable Git Credential Manager
  ☑ Enable symbolic links
```

Install [Ninja](https://github.com/ninja-build/ninja/releases).

```
C:\Program Files\Ninja\ninja.exe
```

Configure system environment variable `Path`.

```
C:\Program Files (x86)\Microsoft Visual Studio\2019\Professional\VC\Tools\Llvm\x64\bin
C:\Program Files\CMake\bin
C:\Program Files\Git\cmd
C:\Program Files\Ninja
C:\Workspace\vcpkg
```

Set system environment variables.

```cmd
set VCPKG_ROOT=C:\Workspace\vcpkg
set VCPKG_FEATURE_FLAGS=-binarycaching
set VCPKG_DEFAULT_TRIPLET=x64-windows-ipo
set VCPKG_DOWNLOADS=C:\Workspace\downloads
set VCPKG_OVERLAY_PORTS=C:\Workspace\boost\ports;C:\Workspace\ports
set VCPKG_KEEP_ENV_VARS=VSCMD_SKIP_SENDTELEMETRY
set VSCMD_SKIP_SENDTELEMETRY=1
```

Delete binary cache.

```cmd
rd /q /s "%LocalAppData%\vcpkg\archives"
```

Create directories.

```cmd
md C:\Workspace
md C:\Workspace\boost
md C:\Workspace\ports
md C:\Workspace\vcpkg
md C:\Workspace\downloads
```

### WSL & Linux
Install basic development packages.

```sh
sudo apt install -y binutils-dev linux-headers-generic libc6-dev manpages-dev
sudo apt install -y -o APT::Install-Suggests=0 -o APT::Install-Recommends=0 \
  autoconf automake bison flex libtool make nasm ninja-build patch \
  perl pkgconf python3 python3-pip sqlite3 zip
```

Install CMake.

```sh
sudo rm -rf /opt/cmake; sudo mkdir -p /opt/cmake
wget https://github.com/Kitware/CMake/releases/download/v3.18.0/cmake-3.18.0-Linux-x86_64.tar.gz
sudo tar xf cmake-3.18.0-Linux-x86_64.tar.gz -C /opt/cmake --strip-components=1
sudo tee /etc/profile.d/cmake.sh >/dev/null <<'EOF'
export PATH="/opt/cmake/bin:${PATH}"
EOF
sudo chmod 0755 /etc/profile.d/cmake.sh
rm -f cmake-3.18.0-Linux-x86_64.tar.gz
```

Install [GCC](https://gcc.gnu.org/).

```sh
sudo apt install -y gcc-10 g++-10 gdb
```

Set default GCC compiler.

```sh
sudo update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-10 100
sudo update-alternatives --install /usr/bin/g++ g++ /usr/bin/g++-10 100
```

Install [LLVM](https://llvm.org/).

```sh
sudo apt install -y -o APT::Install-Suggests=0 -o APT::Install-Recommends=0 \
  llvm-10-{runtime,tools} {lld,lldb,clang,clang-format,clang-tidy}-10 libc++{,abi}-10-dev
```

Set default LLVM compiler.

```sh
sudo update-alternatives --install /usr/bin/clang   clang   /usr/bin/clang-10   100
sudo update-alternatives --install /usr/bin/clang++ clang++ /usr/bin/clang++-10 100
```

Set default system compiler.

```sh
sudo update-alternatives --remove-all cc
sudo update-alternatives --remove-all c++
sudo update-alternatives --install /usr/bin/cc  cc  /usr/bin/clang   100
sudo update-alternatives --install /usr/bin/c++ c++ /usr/bin/clang++ 100
```

Install code formatting tools.

```sh
sudo apt install -y -o APT::Install-Suggests=0 -o APT::Install-Recommends=0 \
  clang-format-10 clang-tidy-10
```

Set default code formatting tools.

```sh
sudo update-alternatives --install /usr/bin/clang-format clang-format /usr/bin/clang-format-10 100
sudo update-alternatives --install /usr/bin/clang-tidy   clang-tidy   /usr/bin/clang-tidy-10   100
```

Set system environment variables.

```sh
sudo tee /etc/profile.d/vcpkg.sh >/dev/null <<'EOF'
export PATH="/opt/vcpkg:${PATH}"
export VCPKG_ROOT="/opt/vcpkg"
export VCPKG_FEATURE_FLAGS="-binarycaching"
export VCPKG_DEFAULT_TRIPLET="x64-linux-ipo"
export VCPKG_DOWNLOADS="/opt/downloads"
export VCPKG_OVERLAY_PORTS="/opt/boost/ports:/opt/ports"
EOF
sudo chmod 0755 /etc/profile.d/vcpkg.sh
```

Delete binary cache.

```sh
rm -rf ~/.cache/vcpkg ~/.vcpkg/archives; rmdir ~/.cache
```

### WSL
Create symlinks.

```sh
for i in boost ports vcpkg downloads; do
  sudo ln -s /mnt/c/Workspace/$i /opt/$i
done
```

### Linux
Create directories.

```sh
for i in boost ports vcpkg downloads; do
  sudo mkdir /opt/$i; sudo chown $(id -un):$(id -gn) /opt/$i
done
```

## Install
Download vcpkg and toolchains.

```sh
cd C:/Workspace || cd /opt
git clone git@github.com:microsoft/vcpkg vcpkg
git clone git@github.com:qis/toolchains vcpkg/triplets/toolchains
cmake -P vcpkg/triplets/toolchains/triplets/install.cmake
```

### Windows
Build and install vcpkg.

```cmd
C:\Workspace\vcpkg\bootstrap-vcpkg.bat -disableMetrics -win64
```

### WSL & Linux
Build and install vcpkg.

```sh
/opt/vcpkg/bootstrap-vcpkg.sh -disableMetrics -useSystemBinaries && rm -rf /opt/vcpkg/toolsrc/build.rel
```

## Ports
Create a ports overlay for [boost](https://www.boost.org/).

```cmd
cd C:/Workspace || cd /opt
git clone git@github.com:qis/boost boost
cmake -P boost/create.cmake
```

Create a ports overlay for [tbb](https://software.intel.com/en-us/tbb).

```cmd
cd C:/Workspace || cd /opt
git clone git@github.com:qis/tbb ports/tbb
```

Install ports.

```sh
# Encryption
vcpkg install --editable openssl

# Compression
vcpkg install --editable brotli bzip2 liblzma libzip lz4 zlib zstd

# Utility
vcpkg install --editable date fmt libssh2 pugixml spdlog tbb utf8proc

# Images
vcpkg install --editable giflib libjpeg-turbo libpng tiff

# Fonts
vcpkg install --editable freetype harfbuzz

# Boost
vcpkg install --editable boost

# Benchmark
vcpkg install --editable benchmark

# Test
vcpkg install --editable gtest
```

## Templates
Project templates that support this setup.

* [qis/application](https://github.com/qis/application)
* [qis/library](https://github.com/qis/library)
* [qis/test](https://github.com/qis/test)
* [qis/xaml](https://github.com/qis/xaml)

## CMake
CMake script that demonstrates how to use this setup.

```cmake
cmake_minimum_required(VERSION 3.16 FATAL_ERROR)
project(application VERSION 0.1.0 LANGUAGES CXX)

file(GLOB_RECURSE sources CONFIGURE_DEPENDS src/${PROJECT_NAME}/*.[hc]pp)

add_library(objects OBJECT ${sources})
target_compile_definitions(objects PUBLIC NOMINMAX WIN32_LEAN_AND_MEAN)
target_compile_features(objects PUBLIC cxx_std_20)

# =============================================================================
# openssl (cmake/FindOpenSSL.cmake)
# =============================================================================
find_package(OpenSSL REQUIRED)
target_link_libraries(objects PUBLIC OpenSSL::Crypto OpenSSL::SSL)

# =============================================================================
# brotli
# =============================================================================
find_package(unofficial-brotli CONFIG REQUIRED)
target_link_libraries(objects PUBLIC
  unofficial::brotli::brotlicommon
  unofficial::brotli::brotlidec
  unofficial::brotli::brotlienc)

# =============================================================================
# bzip2 (cmake/FindBZip2.cmake)
# =============================================================================
find_package(BZip2 REQUIRED)
target_link_libraries(objects PUBLIC BZip2::BZip2)

# =============================================================================
# liblzma
# =============================================================================
find_package(LibLZMA CONFIG REQUIRED)
target_link_libraries(objects PUBLIC LibLZMA::LibLZMA)

# =============================================================================
# libzip (cmake/FindZIP.cmake)
# =============================================================================
find_package(libzip CONFIG REQUIRED)
target_link_libraries(objects PRIVATE zip)

# =============================================================================
# lz4
# =============================================================================
find_package(lz4 CONFIG REQUIRED)
target_link_libraries(objects PUBLIC lz4::lz4)

# =============================================================================
# zlib (cmake/FindZLIB.cmake)
# =============================================================================
find_package(ZLIB REQUIRED)
target_link_libraries(objects PUBLIC ZLIB::ZLIB)

# =============================================================================
# zstd
# =============================================================================
find_package(zstd CONFIG REQUIRED)
target_link_libraries(objects PUBLIC libzstd)

# =============================================================================
# date
# =============================================================================
find_package(date CONFIG REQUIRED)
target_link_libraries(objects PUBLIC date::date date::date-tz)

# =============================================================================
# fmt
# =============================================================================
find_package(fmt CONFIG REQUIRED)
target_link_libraries(objects PUBLIC fmt::fmt)

# =============================================================================
# fmt (header-only)
# =============================================================================
#find_package(fmt CONFIG REQUIRED)
#target_link_libraries(objects PUBLIC fmt::fmt-header-only)

# =============================================================================
# libssh2
# =============================================================================
find_package(Libssh2 CONFIG REQUIRED)
target_link_libraries(objects PUBLIC Libssh2::libssh2)

# =============================================================================
# pugixml
# =============================================================================
find_package(pugixml CONFIG REQUIRED)
target_link_libraries(objects PUBLIC pugixml)

# =============================================================================
# spdlog
# =============================================================================
find_package(spdlog CONFIG REQUIRED)
target_link_libraries(objects PUBLIC spdlog::spdlog)

# =============================================================================
# spdlog (header-only)
# =============================================================================
#find_package(spdlog CONFIG REQUIRED)
#target_link_libraries(objects PUBLIC spdlog::spdlog_header_only)

# =============================================================================
# tbb
# =============================================================================
find_package(TBB CONFIG REQUIRED)
target_link_libraries(objects PUBLIC TBB::tbb TBB::tbbmalloc)

# =============================================================================
# utf8proc (cmake/FindUtf8Proc.cmake)
# =============================================================================
find_package(Utf8Proc REQUIRED)
target_link_libraries(objects PUBLIC utf8proc::utf8proc)

# =============================================================================
# giflib (cmake/FindGIF.cmake)
# =============================================================================
find_package(GIF REQUIRED)
target_link_libraries(objects PUBLIC GIF::GIF)

# =============================================================================
# libjpeg (cmake/FindJPEG.cmake)
# =============================================================================
find_package(JPEG REQUIRED)
target_link_libraries(objects PUBLIC JPEG::JPEG)

# =============================================================================
# libjpeg-turbo (cmake/FindJPEGTURBO.cmake)
# =============================================================================
find_package(JPEGTURBO REQUIRED)
target_link_libraries(objects PUBLIC JPEGTURBO::JPEGTURBO)

# =============================================================================
# libpng (cmake/FindPNG.cmake)
# =============================================================================
find_package(PNG REQUIRED)
target_link_libraries(objects PUBLIC PNG::PNG)

# =============================================================================
# tiff (cmake/FindTIFF.cmake)
# =============================================================================
find_package(TIFF REQUIRED)
target_link_libraries(objects PUBLIC TIFF::TIFF)

# =============================================================================
# freetype
# =============================================================================
find_package(freetype CONFIG REQUIRED)
target_link_libraries(objects PUBLIC freetype)

# =============================================================================
# harfbuzz
# =============================================================================
find_package(harfbuzz CONFIG REQUIRED)
target_link_libraries(objects PUBLIC harfbuzz::harfbuzz)

# =============================================================================
# boost
# =============================================================================
find_package(Boost REQUIRED COMPONENTS headers filesystem)
target_link_libraries(objects PUBLIC Boost::headers Boost::filesystem)
target_compile_definitions(objects PUBLIC
  BOOST_ASIO_HAS_CO_AWAIT
  BOOST_ASIO_DISABLE_CONCEPTS
  BOOST_ASIO_SEPARATE_COMPILATION
  BOOST_BEAST_SEPARATE_COMPILATION
  BOOST_BEAST_USE_STD_STRING_VIEW
  BOOST_JSON_STANDALONE)

# =============================================================================
# threads
# =============================================================================
find_package(Threads REQUIRED)
target_link_libraries(objects PUBLIC Threads::Threads)

# =============================================================================
# executable
# =============================================================================
add_executable(${PROJECT_NAME} src/main.cpp src/main.manifest src/main.rc)
target_link_libraries(${PROJECT_NAME} PRIVATE objects)

# =============================================================================
# benchmark
# =============================================================================
find_package(benchmark CONFIG)
if(benchmark_FOUND)
  file(GLOB_RECURSE benchmarks_sources src/benchmarks/*.[hc]pp)
  add_executable(benchmarks EXCLUDE_FROM_ALL ${benchmarks_sources} src/main.manifest)
  target_link_libraries(benchmarks PRIVATE objects benchmark::benchmark_main)
endif()

# =============================================================================
# test
# =============================================================================
find_package(GTest CONFIG)
if(GTest_FOUND)
  file(GLOB_RECURSE tests_sources src/tests/*.[hc]pp)
  add_executable(tests EXCLUDE_FROM_ALL ${tests_sources} src/main.manifest)
  target_link_libraries(tests PRIVATE objects GTest::gtest GTest::gtest_main)

  include(GoogleTest)
  gtest_discover_tests(tests)
endif()

install(TARGETS ${PROJECT_NAME} RUNTIME DESTINATION bin)

if(WIN32 AND VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
  install(FILES
    $<TARGET_FILE_DIR:${PROJECT_NAME}>/fmt.dll
    $<TARGET_FILE_DIR:${PROJECT_NAME}>/tz.dll
    DESTINATION bin)
endif()
```

## Tests
Select ports are tested with [qis/vcpkg-test](https://github.com/qis/vcpkg-test).

<!--
## Exceptions
Some ports require macro definitions to disable exceptions.

* `fmt` requires `FMT_EXCEPTIONS=0`
* `pugixml` requires `PUGIXML_NO_EXCEPTIONS`
* `spdlog` requires `SPDLOG_NO_EXCEPTIONS`

<details>
<summary>Modify the <code>triplets/x64-windows-debug.cmake</code> triplet file.</summary>
&nbsp;

```cmake
set(VCPKG_TARGET_ARCHITECTURE x64)
set(VCPKG_LIBRARY_LINKAGE static)
set(VCPKG_CRT_LINKAGE dynamic)

set(VCPKG_LOAD_VCVARS_ENV ON)
set(VCPKG_CHAINLOAD_TOOLCHAIN_FILE "C:/Workspace/vcpkg/triplets/toolchains/windows.cmake")

set(VCPKG_C_FLAGS "/arch:AVX2")
set(VCPKG_CXX_FLAGS "${VCPKG_C_FLAGS} /EHs-c- /GR- -D_HAS_EXCEPTIONS=0")
set(VCPKG_CXX_FLAGS "${VCPKG_CXX_FLAGS} -DFMT_EXCEPTIONS=0")
```

</details>

<details>
<summary>Modify the <code>triplets/x64-windows-release.cmake</code> triplet file.</summary>
&nbsp;

```cmake
set(VCPKG_TARGET_ARCHITECTURE x64)
set(VCPKG_LIBRARY_LINKAGE static)
set(VCPKG_CRT_LINKAGE dynamic)

set(VCPKG_LOAD_VCVARS_ENV ON)
set(VCPKG_CHAINLOAD_TOOLCHAIN_FILE "C:/Workspace/vcpkg/triplets/toolchains/windows.cmake")

set(VCPKG_C_FLAGS "/arch:AVX2")
set(VCPKG_CXX_FLAGS "${VCPKG_C_FLAGS} /EHs-c- /GR- -D_HAS_EXCEPTIONS=0")
set(VCPKG_CXX_FLAGS "${VCPKG_CXX_FLAGS} -DFMT_EXCEPTIONS=0")
```

</details>

Find required packages.

```sh
sudo apt install apt-file
sudo apt-file update

ldd <executable>
apt-file search <shared-library>
apt info <package> 2>/dev/null | grep Version
```
-->
