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

## Compiler
Skip this step if you decide to use [release](https://github.com/qis/toolchains/releases) binaries.

Build LLVM in `cmd.exe`.

```cmd
cd C:\Workspace\vcpkg\triplets\toolchains && make
```

Build LLVM in `wsl.exe`.

```sh
cd /opt/vcpkg/triplets/toolchains && make
```

## Ports
Install ports.

```sh
# Development
vcpkg install benchmark catch2

# Encryption
vcpkg install openssl

# Compression
vcpkg install bzip2 liblzma libzip lz4 zlib zstd

# Utility
vcpkg install date fmt libssh2 pugixml spdlog utf8proc

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

## Templates
Project templates that support this setup.

* [qis/application](https://github.com/qis/application)
* [qis/library](https://github.com/qis/library)
* [qis/test](https://github.com/qis/test)
* [qis/xaml](https://github.com/qis/xaml)

## CMake
CMake script that demonstrates how to use this setup.

```cmake
cmake_minimum_required(VERSION 3.17 FATAL_ERROR)
set(CMAKE_TOOLCHAIN_FILE "$ENV{VCPKG_ROOT}/triplets/toolchains/res/toolchain.cmake")
project(application VERSION 0.1.0 LANGUAGES CXX)

file(GLOB sources CONFIGURE_DEPENDS src/application/*.[hc]pp)

add_library(objects OBJECT ${sources})
target_compile_definitions(objects PUBLIC NOMINMAX WIN32_LEAN_AND_MEAN)
target_compile_features(objects PUBLIC cxx_std_20)

# =============================================================================
# benchmark
# =============================================================================
option(DISABLE_BENCHMARK "Disable benchmark" OFF)
if(NOT DISABLE_BENCHMARK)
  file(GLOB_RECURSE benchmark_sources src/benchmark/*.[hc]pp)
  add_executable(benchmark EXCLUDE_FROM_ALL ${benchmark_sources} src/main.manifest)
  target_link_libraries(benchmark PUBLIC objects)

  find_package(benchmark CONFIG REQUIRED)
  target_link_libraries(benchmark PUBLIC benchmark::benchmark_main)
endif()

# =============================================================================
# tests
# =============================================================================
option(DISABLE_TESTS "Disable tests" OFF)
if(NOT DISABLE_TESTS)
  file(GLOB_RECURSE tests_sources src/tests/*.[hc]pp)
  add_executable(tests EXCLUDE_FROM_ALL ${tests_sources} src/main.manifest)
  target_link_libraries(tests PUBLIC objects)

  find_package(Catch2 CONFIG REQUIRED)
  target_link_libraries(tests PUBLIC Catch2::Catch2)

  include(CTest)
  include(Catch)
  catch_discover_tests(tests)
endif()

# =============================================================================
# openssl
# =============================================================================
find_package(OpenSSL REQUIRED)
target_link_libraries(objects PUBLIC OpenSSL::Crypto OpenSSL::SSL)

if(WIN32)
  target_link_libraries(objects PUBLIC crypt32 ws2_32)
endif()

# =============================================================================
# bzip2
# =============================================================================
find_package(BZip2 REQUIRED)
target_link_libraries(objects PUBLIC BZip2::BZip2)

# =============================================================================
# liblzma
# =============================================================================
find_path(LZMA_INCLUDE_DIR lzma.h)
get_filename_component(LZMA_ROOT_DIR ${LZMA_INCLUDE_DIR} DIRECTORY)

find_library(LZMA_LIBRARY_DEBUG NAMES lzma lzmad
  NAMES_PER_DIR NO_CMAKE_PATH PATHS ${LZMA_ROOT_DIR}/debug/lib)

find_library(LZMA_LIBRARY_RELEASE NAMES lzma
  NAMES_PER_DIR NO_CMAKE_PATH PATHS ${LZMA_ROOT_DIR}/lib)

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(LZMA DEFAULT_MSG
  LZMA_INCLUDE_DIR LZMA_LIBRARY_DEBUG LZMA_LIBRARY_RELEASE)

add_library(lzma::lzma UNKNOWN IMPORTED)
set_target_properties(lzma::lzma PROPERTIES
  INTERFACE_INCLUDE_DIRECTORIES "${LZMA_INCLUDE_DIR}"
  IMPORTED_LINK_INTERFACE_LANGUAGES "C"
  IMPORTED_CONFIGURATIONS "DEBUG;RELEASE"
  MAP_IMPORTED_CONFIG_MINSIZEREL Release
  MAP_IMPORTED_CONFIG_RELWITHDEBINFO Release
  IMPORTED_LOCATION_DEBUG "${LZMA_LIBRARY_DEBUG}"
  IMPORTED_LOCATION_RELEASE "${LZMA_LIBRARY_RELEASE}")

target_link_libraries(${PROJECT_NAME} PUBLIC lzma::lzma)

# =============================================================================
# libzip
# =============================================================================
find_path(ZIP_INCLUDE_DIR zip.h)
get_filename_component(ZIP_ROOT_DIR ${ZIP_INCLUDE_DIR} DIRECTORY)

find_library(ZIP_LIBRARY_DEBUG NAMES zip
  NAMES_PER_DIR NO_CMAKE_PATH PATHS ${ZIP_ROOT_DIR}/debug/lib)

find_library(ZIP_LIBRARY_RELEASE NAMES zip
  NAMES_PER_DIR NO_CMAKE_PATH PATHS ${ZIP_ROOT_DIR}/lib)

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(ZIP DEFAULT_MSG
  ZIP_INCLUDE_DIR ZIP_LIBRARY_DEBUG ZIP_LIBRARY_RELEASE)

add_library(zip::zip UNKNOWN IMPORTED)
set_target_properties(zip::zip PROPERTIES
  INTERFACE_INCLUDE_DIRECTORIES "${ZIP_INCLUDE_DIR}"
  IMPORTED_LINK_INTERFACE_LANGUAGES "C"
  IMPORTED_CONFIGURATIONS "DEBUG;RELEASE"
  MAP_IMPORTED_CONFIG_MINSIZEREL Release
  MAP_IMPORTED_CONFIG_RELWITHDEBINFO Release
  IMPORTED_LOCATION_DEBUG "${ZIP_LIBRARY_DEBUG}"
  IMPORTED_LOCATION_RELEASE "${ZIP_LIBRARY_RELEASE}")

target_link_libraries(${PROJECT_NAME} PUBLIC zip::zip)

# =============================================================================
# lz4
# =============================================================================
find_package(lz4 CONFIG REQUIRED)
target_link_libraries(objects PUBLIC lz4::lz4)

# =============================================================================
# zlib
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
target_link_libraries(objects PUBLIC date::date date::tz)

find_package(Threads REQUIRED)
target_link_libraries(objects PUBLIC Threads::Threads)

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
# utf8proc
# =============================================================================
find_path(UTF8PROC_INCLUDE_DIR utf8proc.h)
get_filename_component(UTF8PROC_ROOT_DIR ${UTF8PROC_INCLUDE_DIR} DIRECTORY)

find_library(UTF8PROC_LIBRARY_DEBUG NAMES utf8proc utf8proc_static
  NAMES_PER_DIR NO_CMAKE_PATH PATHS ${UTF8PROC_ROOT_DIR}/debug/lib)

find_library(UTF8PROC_LIBRARY_RELEASE NAMES utf8proc utf8proc_static
  NAMES_PER_DIR NO_CMAKE_PATH PATHS ${UTF8PROC_ROOT_DIR}/lib)

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(UTF8PROC DEFAULT_MSG
  UTF8PROC_INCLUDE_DIR UTF8PROC_LIBRARY_DEBUG UTF8PROC_LIBRARY_RELEASE)

add_library(utf8proc::utf8proc UNKNOWN IMPORTED)
set_target_properties(utf8proc::utf8proc PROPERTIES
  INTERFACE_INCLUDE_DIRECTORIES "${UTF8PROC_INCLUDE_DIR}"
  IMPORTED_LINK_INTERFACE_LANGUAGES "C"
  IMPORTED_CONFIGURATIONS "DEBUG;RELEASE"
  MAP_IMPORTED_CONFIG_MINSIZEREL Release
  MAP_IMPORTED_CONFIG_RELWITHDEBINFO Release
  IMPORTED_LOCATION_DEBUG "${UTF8PROC_LIBRARY_DEBUG}"
  IMPORTED_LOCATION_RELEASE "${UTF8PROC_LIBRARY_RELEASE}")

get_filename_component(UTF8PROC_LIBRARY_NAME_DEBUG ${UTF8PROC_LIBRARY_DEBUG} NAME_WE)
if(UTF8PROC_LIBRARY_NAME_DEBUG STREQUAL "utf8proc_static")
  set_property(TARGET utf8proc::utf8proc APPEND PROPERTY
    INTERFACE_COMPILE_DEFINITIONS "$<$<CONFIG:Debug>:UTF8PROC_STATIC=1>")
endif()

get_filename_component(UTF8PROC_LIBRARY_NAME_RELEASE ${UTF8PROC_LIBRARY_RELEASE} NAME_WE)
if(UTF8PROC_LIBRARY_NAME_RELEASE STREQUAL "utf8proc_static")
  set_property(TARGET utf8proc::utf8proc APPEND PROPERTY
    INTERFACE_COMPILE_DEFINITIONS "$<$<CONFIG:Release>:UTF8PROC_STATIC=1>")
endif()

target_link_libraries(${PROJECT_NAME} PUBLIC utf8proc::utf8proc)

# =============================================================================
# giflib
# =============================================================================
find_package(GIF REQUIRED)
target_link_libraries(objects PUBLIC GIF::GIF)

# =============================================================================
# libjpeg
# =============================================================================
find_package(JPEG REQUIRED)
target_link_libraries(objects PUBLIC JPEG::JPEG)

# =============================================================================
# libjpeg-turbo
# =============================================================================
find_path(TURBOJPEG_INCLUDE_DIR turbojpeg.h)
get_filename_component(TURBOJPEG_ROOT_DIR ${TURBOJPEG_INCLUDE_DIR} DIRECTORY)

find_library(TURBOJPEG_LIBRARY_DEBUG NAMES turbojpeg turbojpegd
  NAMES_PER_DIR NO_CMAKE_PATH PATHS ${TURBOJPEG_ROOT_DIR}/debug/lib)

find_library(TURBOJPEG_LIBRARY_RELEASE NAMES turbojpeg
  NAMES_PER_DIR NO_CMAKE_PATH PATHS ${TURBOJPEG_ROOT_DIR}/lib)

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(TURBOJPEG DEFAULT_MSG
  TURBOJPEG_INCLUDE_DIR TURBOJPEG_LIBRARY_DEBUG TURBOJPEG_LIBRARY_RELEASE)

add_library(turbojpeg::turbojpeg UNKNOWN IMPORTED)
set_target_properties(turbojpeg::turbojpeg PROPERTIES
  INTERFACE_INCLUDE_DIRECTORIES "${TURBOJPEG_INCLUDE_DIR}"
  IMPORTED_LINK_INTERFACE_LANGUAGES "C"
  IMPORTED_CONFIGURATIONS "DEBUG;RELEASE"
  MAP_IMPORTED_CONFIG_MINSIZEREL Release
  MAP_IMPORTED_CONFIG_RELWITHDEBINFO Release
  IMPORTED_LOCATION_DEBUG "${TURBOJPEG_LIBRARY_DEBUG}"
  IMPORTED_LOCATION_RELEASE "${TURBOJPEG_LIBRARY_RELEASE}")

target_link_libraries(${PROJECT_NAME} PUBLIC turbojpeg::turbojpeg)

# =============================================================================
# libpng
# =============================================================================
find_package(PNG REQUIRED)
target_link_libraries(objects PUBLIC PNG::PNG)

# =============================================================================
# tiff
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
find_package(Boost 1.73.0 CONFIG REQUIRED COMPONENTS headers filesystem)
target_link_libraries(objects PUBLIC Boost::headers Boost::filesystem)
target_compile_definitions(objects PUBLIC
  BOOST_ASIO_HAS_CO_AWAIT
  BOOST_ASIO_DISABLE_CONCEPTS
  BOOST_ASIO_SEPARATE_COMPILATION
  BOOST_BEAST_SEPARATE_COMPILATION
  BOOST_BEAST_USE_STD_STRING_VIEW
  BOOST_JSON_STANDALONE)

# =============================================================================
# tbb
# =============================================================================
find_package(TBB CONFIG REQUIRED)
target_link_libraries(objects PUBLIC TBB::tbb TBB::tbbmalloc)

# =============================================================================

add_executable(${PROJECT_NAME} src/main.cpp src/main.manifest)
target_link_libraries(${PROJECT_NAME} PRIVATE objects)

install(TARGETS ${PROJECT_NAME} RUNTIME DESTINATION bin)

if(WIN32 AND NOT CMAKE_BUILD_TYPE MATCHES Debug AND VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
  install(FILES
    $<TARGET_FILE_DIR:${PROJECT_NAME}>/libcrypto-1_1-x64.dll
    $<TARGET_FILE_DIR:${PROJECT_NAME}>/libssl-1_1-x64.dll
    $<TARGET_FILE_DIR:${PROJECT_NAME}>/bz2.dll
    $<TARGET_FILE_DIR:${PROJECT_NAME}>/lzma.dll
    $<TARGET_FILE_DIR:${PROJECT_NAME}>/zip.dll
    $<TARGET_FILE_DIR:${PROJECT_NAME}>/lz4.dll
    $<TARGET_FILE_DIR:${PROJECT_NAME}>/zlib1.dll
    $<TARGET_FILE_DIR:${PROJECT_NAME}>/zstd.dll
    $<TARGET_FILE_DIR:${PROJECT_NAME}>/tz.dll
    $<TARGET_FILE_DIR:${PROJECT_NAME}>/fmt.dll
    $<TARGET_FILE_DIR:${PROJECT_NAME}>/pugixml.dll
    $<TARGET_FILE_DIR:${PROJECT_NAME}>/utf8proc.dll
    $<TARGET_FILE_DIR:${PROJECT_NAME}>/jpeg62.dll
    $<TARGET_FILE_DIR:${PROJECT_NAME}>/turbojpeg.dll
    $<TARGET_FILE_DIR:${PROJECT_NAME}>/libpng16.dll
    $<TARGET_FILE_DIR:${PROJECT_NAME}>/tiff.dll
    $<TARGET_FILE_DIR:${PROJECT_NAME}>/freetype.dll
    $<TARGET_FILE_DIR:${PROJECT_NAME}>/harfbuzz.dll
    $<TARGET_FILE_DIR:${PROJECT_NAME}>/boost_filesystem.dll
    $<TARGET_FILE_DIR:${PROJECT_NAME}>/tbb.dll
    DESTINATION bin)
endif()
```

<!--
## Exceptions
Some ports require macro definitions to disable exceptions.

* `fmt` requires `FMT_EXCEPTIONS=0`
* `pugixml` requires `PUGIXML_NO_EXCEPTIONS`
* `spdlog` requires `SPDLOG_NO_EXCEPTIONS`

<details>
<summary>Modify the <code>triplets/x64-windows-msvc-debug.cmake</code> triplet file.</summary>
&nbsp;

```cmake
set(VCPKG_TARGET_ARCHITECTURE x64)
set(VCPKG_CRT_LINKAGE dynamic)
set(VCPKG_LIBRARY_LINKAGE dynamic)

set(VCPKG_CHAINLOAD_TOOLCHAIN_FILE "C:/Workspace/vcpkg/triplets/toolchains/windows.cmake")
set(VCPKG_LOAD_VCVARS_ENV ON)

set(VCPKG_C_FLAGS "/arch:AVX2 /W3 /wd26812 /wd28251 /wd4275")
set(VCPKG_CXX_FLAGS "${VCPKG_C_FLAGS} /EHs-c- /GR- -D_HAS_EXCEPTIONS=0")

set(VCPKG_CXX_FLAGS "${VCPKG_CXX_FLAGS} -DFMT_EXCEPTIONS=0")
```

</details>

<details>
<summary>Modify the <code>triplets/x64-windows-msvc-release.cmake</code> triplet file.</summary>
&nbsp;

```cmake
set(VCPKG_TARGET_ARCHITECTURE x64)
set(VCPKG_CRT_LINKAGE static)
set(VCPKG_LIBRARY_LINKAGE static)

set(VCPKG_CHAINLOAD_TOOLCHAIN_FILE "C:/Workspace/vcpkg/triplets/toolchains/windows.cmake")
set(VCPKG_LOAD_VCVARS_ENV ON)

set(VCPKG_C_FLAGS "/arch:AVX2 /W3 /wd26812 /wd28251 /wd4275")
set(VCPKG_CXX_FLAGS "${VCPKG_C_FLAGS} /EHs-c- /GR- -D_HAS_EXCEPTIONS=0")

set(VCPKG_CXX_FLAGS "${VCPKG_CXX_FLAGS} -DFMT_EXCEPTIONS=0")
```

</details>
-->
