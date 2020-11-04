# Toolchains
Custom [vcpkg](https://github.com/microsoft/vcpkg) toolchains.

## Windows

<details>
<summary><b>Requirements</b></summary>

Install [Git](https://git-scm.com/downloads).

```
Select Components
☐ Windows Explorer integration
☐ Associate .git* configuration files with the default text editor
☐ Associate .sh files to be run with Bash

Choosing the default editor used by Git
Use Visual Studio Code as Git's default editor

Adjusting the name of the initial branch in new repositories
◉ Override the default branch name for new repositories
Specify the name "git init" should use for the initial branch: master

Configuring the line ending conversions
◉ Checkout as-is, commit as-is

Configuring the terminal emulator to use Git Bash
◉ Use Windows' default console window

Choose the default behavior of `git pull`
◉ Rebase

Choose a credential helper
◉ None
```

Install [LLVM](https://github.com/llvm/llvm-project/releases/download/llvmorg-11.0.0/LLVM-11.0.0-win64.exe).

```
Install Options
◉ Add LLVM to the system PATN for all users
```

Install [Visual Studio Preview](https://visualstudio.microsoft.com/vs/preview/).

```
Workloads
☑ Desktop development with C++
☑ Linux development with C++
☑ Node.js development

Installation Details
+ Desktop development with C++
  ☐ Test Adapter for Boost.Test
  ☐ Test Adapter for Google Test
  ☐ Live Share
+ Node.js development
  ☐ Web Deploy
```

Install Visual Studio extensions.

- [Hide Suggestion And Outlining Margins][hi]
- [Trailing Whitespace Visualizer][ws]

[hi]: https://marketplace.visualstudio.com/items?itemName=MussiKara.HideSuggestionAndOutliningMargins
[ws]: https://marketplace.visualstudio.com/items?itemName=MadsKristensen.TrailingWhitespaceVisualizer

Add the following directories to the `Path` system environment variable.

```
C:\Program Files (x86)\Microsoft Visual Studio\2019\Preview\Common7\IDE\CommonExtensions\Microsoft\CMake\Ninja
C:\Program Files (x86)\Microsoft Visual Studio\2019\Preview\Common7\IDE\CommonExtensions\Microsoft\CMake\CMake\bin
C:\Program Files (x86)\Microsoft Visual Studio\2019\Preview\Msbuild\Microsoft\VisualStudio\NodeJs
```

Set system environment variables.

```cmd
set VCPKG_ROOT=C:\Workspace\vcpkg
set VCPKG_FEATURE_FLAGS=-binarycaching
set VCPKG_DEFAULT_TRIPLET=x64-windows-xnet
set VCPKG_DOWNLOADS=C:\Workspace\downloads
set VCPKG_OVERLAY_PORTS=C:\Workspace\boost\ports;C:\Workspace\ports
set VCPKG_KEEP_ENV_VARS=VSCMD_SKIP_SENDTELEMETRY
set VSCMD_SKIP_SENDTELEMETRY=1
```

</details>

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

## Ubuntu

<details>
<summary><b>Requirements</b></summary>

Install basic development packages.

```sh
sudo apt install -y binutils-dev gcc-10 g++-10 gdb make nasm ninja-build manpages-dev pkg-config
```

Install [CMake](https://cmake.org/).

```sh
sudo rm -rf /opt/cmake; sudo mkdir -p /opt/cmake
wget https://github.com/Kitware/CMake/releases/download/v3.18.4/cmake-3.18.4-Linux-x86_64.tar.gz
sudo tar xf cmake-3.18.4-Linux-x86_64.tar.gz -C /opt/cmake --strip-components=1
rm -f cmake-3.18.4-Linux-x86_64.tar.gz

sudo tee /etc/profile.d/cmake.sh >/dev/null <<'EOF'
export PATH="/opt/cmake/bin:${PATH}"
EOF

sudo chmod 0755 /etc/profile.d/cmake.sh
. /etc/profile.d/cmake.sh
```

Install [Node](https://nodejs.org/).

```sh
sudo rm -rf /opt/node; sudo mkdir -p /opt/node
wget https://nodejs.org/dist/v12.16.3/node-v12.16.3-linux-x64.tar.xz
sudo tar xf node-v12.16.3-linux-x64.tar.xz -C /opt/node --strip-components=1
rm -f node-v12.16.3-linux-x64.tar.xz

sudo tee /etc/profile.d/node.sh >/dev/null <<'EOF'
export PATH="/opt/node/bin:${PATH}"
EOF

sudo chmod 0755 /etc/profile.d/node.sh
. /etc/profile.d/node.sh
```

Install [LLVM](https://llvm.org/).

```sh
sudo rm -rf /opt/llvm; sudo mkdir -p /opt/llvm
wget https://github.com/llvm/llvm-project/releases/download/llvmorg-11.0.0/clang+llvm-11.0.0-x86_64-linux-gnu-ubuntu-20.04.tar.xz
sudo tar xf clang+llvm-11.0.0-x86_64-linux-gnu-ubuntu-20.04.tar.xz -C /opt/llvm --strip-components=1
rm -f clang+llvm-11.0.0-x86_64-linux-gnu-ubuntu-20.04.tar.xz

sudo tee /etc/profile.d/llvm.sh >/dev/null <<'EOF'
export PATH="/opt/llvm/bin:${PATH}"
EOF

sudo chmod 0755 /etc/profile.d/llvm.sh
. /etc/profile.d/llvm.sh

sudo tee /etc/ld.so.conf.d/llvm.conf >/dev/null <<'EOF'
/opt/llvm/lib
EOF

sudo ldconfig
```

Set system compiler.

```sh
for i in c++ cc g++ gcc clang{,++}; do sudo update-alternatives --remove-all $i; done
sudo update-alternatives --install /usr/bin/clang   clang   /opt/llvm/bin/clang   100
sudo update-alternatives --install /usr/bin/clang++ clang++ /opt/llvm/bin/clang++ 100
sudo update-alternatives --install /usr/bin/cc      cc      /usr/bin/clang        100
sudo update-alternatives --install /usr/bin/c++     c++     /usr/bin/clang++      100
```

Set system `clang-format` tool.

```sh
sudo update-alternatives --install /usr/bin/clang-format clang-format /opt/llvm/bin/clang-format 100
```

Set system environment variables.

```sh
sudo tee /etc/profile.d/vcpkg.sh >/dev/null <<'EOF'
export PATH="/opt/vcpkg:${PATH}"
export VCPKG_ROOT="/opt/vcpkg"
export VCPKG_FEATURE_FLAGS="-binarycaching"
export VCPKG_DEFAULT_TRIPLET="x64-linux-xnet"
export VCPKG_DOWNLOADS="/opt/downloads"
export VCPKG_OVERLAY_PORTS="/opt/boost/ports:/opt/ports"
EOF

sudo chmod 0755 /etc/profile.d/vcpkg.sh
. /etc/profile.d/vcpkg.sh
```

</details>

Delete binary cache.

```sh
rm -rf ~/.cache/vcpkg ~/.vcpkg/archives
```

Create symlinks (WSL).

```sh
for i in boost ports vcpkg downloads; do
  sudo ln -s /mnt/c/Workspace/$i /opt/$i
done
```

Create directories (VM).

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
Build vcpkg.

```cmd
C:\Workspace\vcpkg\bootstrap-vcpkg.bat -disableMetrics -win64
```

Create the `x64-windows-xnet.cmake` triplet in `C:\Workspace\vcpkg\triplets`.

```cmake
set(VCPKG_LOAD_VCVARS_ENV ON)
set(VCPKG_TARGET_ARCHITECTURE x64)
set(VCPKG_LIBRARY_LINKAGE static)
set(VCPKG_CRT_LINKAGE dynamic)

set(VCPKG_C_FLAGS "/DWINVER=0x0A00 /D_WIN32_WINNT=0x0A00")
set(VCPKG_CXX_FLAGS "${VCPKG_C_FLAGS}")

set(VCPKG_C_FLAGS_DEBUG "/sdl /RTC1")
set(VCPKG_CXX_FLAGS_DEBUG "${VCPKG_C_FLAGS_DEBUG}")

set(VCPKG_C_FLAGS_RELEASE "/GS- /analyze-")
set(VCPKG_CXX_FLAGS_RELEASE "${VCPKG_C_FLAGS_RELEASE}")

set(VCPKG_LINKER_FLAGS_DEBUG "/OPT:REF /OPT:ICF /DEBUG:FULL /INCREMENTAL:NO")
```

### Ubuntu
Build vcpkg.

```sh
/opt/vcpkg/bootstrap-vcpkg.sh -disableMetrics -useSystemBinaries && rm -rf /opt/vcpkg/toolsrc/build.rel
```

Create the `x64-linux-xnet.cmake` triplet in `/opt/vcpkg/triplets`.

```cmake
set(VCPKG_CMAKE_SYSTEM_NAME Linux)
set(VCPKG_TARGET_ARCHITECTURE x64)
set(VCPKG_LIBRARY_LINKAGE static)
set(VCPKG_CRT_LINKAGE dynamic)

set(VCPKG_C_FLAGS "-fasm -pthread -D_DEFAULT_SOURCE=1")
set(VCPKG_CXX_FLAGS "-fcoroutines ${VCPKG_C_FLAGS}")

set(VCPKG_LINKER_FLAGS "-Wl,--as-needed")
set(VCPKG_LINKER_FLAGS_RELEASE "-Wl,-s")
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
# Development
vcpkg install --editable benchmark doctest gtest

# Utility
vcpkg install --editable date fmt libssh2 pugixml tbb utf8proc

# Compression
vcpkg install --editable brotli bzip2 liblzma libzip zlib zstd

# Encryption
vcpkg install --editable openssl

# Boost
vcpkg install --editable boost
```

## Templates
Project templates that support this setup.

* [qis/application](https://github.com/qis/application)
* [qis/library](https://github.com/qis/library)

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
