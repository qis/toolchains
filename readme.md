# Toolchains
Custom [vcpkg](https://github.com/Microsoft/vcpkg) toolchains.

```sh
cd C:/Workspace || cd /opt
git clone git@github.com:Microsoft/vcpkg
cmake -E remove_directory vcpkg/scripts/toolchains
git clone git@github.com:qis/toolchains vcpkg/scripts/toolchains
curl https://raw.githubusercontent.com/qis/vcpkg-patches/master/date/CMakeLists.txt -o vcpkg/ports/date/CMakeLists.txt
```

Alternatively, create a symlink to the windows vcpkg directory in WSL.<br/>
**NOTE**: Do not execute `vcpkg` on Windows and in WSL at the same time.

```sh
ln -s /mnt/c/Workspace/vcpkg /opt/vcpkg
```

## Windows
Set up environment variables.

```cmd
set PATH=%PATH%;C:\Workspace\vcpkg
set VCPKG_DEFAULT_TRIPLET=x64-windows
```

Build Vcpkg.

```cmd
bootstrap-vcpkg -disableMetrics -win64
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

if(PORT STREQUAL "harfbuzz")
  set(VCPKG_C_FLAGS "${VCPKG_C_FLAGS} /DHB_NO_MT=1")
  set(VCPKG_CXX_FLAGS "${VCPKG_CXX_FLAGS} /DHB_NO_MT=1")
endif()

if(PORT STREQUAL "pugixml")
  set(VCPKG_CXX_FLAGS "${VCPKG_CXX_FLAGS} /DPUGIXML_NO_EXCEPTIONS=1")
endif()
```

Use [/d2FH4](https://devblogs.microsoft.com/cppblog/making-cpp-exception-handling-smaller-x64/)
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
rm -rf vcpkg/toolsrc/build.rel
```

<details>
<summary>Modify the <code>triplets/x64-linux.cmake</code> triplet file.</summary>
Example for targeting specific CPUs and disabling exceptions and RTTI.

```cmake
set(VCPKG_TARGET_ARCHITECTURE x64)
set(VCPKG_CRT_LINKAGE dynamic)
set(VCPKG_LIBRARY_LINKAGE static)

set(VCPKG_C_FLAGS "-march=broadwell -mavx2")
set(VCPKG_CXX_FLAGS "-march=broadwell -mavx2 -fno-exceptions -fno-rtti")

if(PORT STREQUAL "ragel")
  set(VCPKG_C_FLAGS "-march=broadwell -mavx2")
  set(VCPKG_CXX_FLAGS "-march=broadwell -mavx2")
endif()

if(PORT STREQUAL "harfbuzz")
  set(VCPKG_C_FLAGS "${VCPKG_C_FLAGS} -DHB_NO_MT=1")
  set(VCPKG_CXX_FLAGS "${VCPKG_CXX_FLAGS} -DHB_NO_MT=1")
endif()

if(PORT STREQUAL "pugixml")
  set(VCPKG_CXX_FLAGS "${VCPKG_CXX_FLAGS} -DPUGIXML_NO_EXCEPTIONS=1")
endif()

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
vcpkg install cpr curl[core,openssl] date fmt libssh2 nlohmann-json pugixml ragel utf8proc

# Images
vcpkg install giflib libjpeg-turbo libpng tiff

# Graphics
# apt install libx11-dev mesa-common-dev
vcpkg install angle freetype harfbuzz[ucdn] podofo
```

<!--
### Windows
```cmd
rem General
git clone git@github.com:xnetsystems/backward vcpkg/ports/backward && ^
git clone git@github.com:xnetsystems/bcrypt vcpkg/ports/bcrypt && ^
git clone git@github.com:xnetsystems/compat vcpkg/ports/compat && ^
git clone git@github.com:xnetsystems/ice vcpkg/ports/ice && ^
git clone git@github.com:xnetsystems/pdf vcpkg/ports/pdf && ^
git clone git@github.com:xnetsystems/sql vcpkg/ports/sql && ^
git clone git:libraries/http vcpkg/ports/http

vcpkg install ^
  benchmark gtest ^
  openssl ^
  bzip2 liblzma libzip[bzip2,openssl] zlib ^
  cpr curl[core,openssl] date fmt libssh2 nlohmann-json pugixml ragel utf8proc ^
  giflib libjpeg-turbo libpng tiff ^
  angle freetype harfbuzz[ucdn] podofo ^
  bcrypt compat ice pdf sql http

rem Minimal
vcpkg install benchmark gtest bzip2 liblzma libzip[core,bzip2] zlib fmt pugixml ragel utf8proc ^
  giflib libjpeg-turbo libpng tiff angle freetype harfbuzz[ucdn]
```

### Linux
```sh
# General
git clone git@github.com:xnetsystems/backward vcpkg/ports/backward && \
git clone git@github.com:xnetsystems/bcrypt vcpkg/ports/bcrypt && \
git clone git@github.com:xnetsystems/compat vcpkg/ports/compat && \
git clone git@github.com:xnetsystems/ice vcpkg/ports/ice && \
git clone git@github.com:xnetsystems/pdf vcpkg/ports/pdf && \
git clone git@github.com:xnetsystems/sql vcpkg/ports/sql && \
git clone git:libraries/http vcpkg/ports/http

vcpkg install \
  benchmark gtest \
  openssl \
  bzip2 liblzma libzip[bzip2,openssl] zlib \
  cpr curl[core,openssl] date fmt libssh2 nlohmann-json pugixml ragel utf8proc \
  giflib libjpeg-turbo libpng tiff \
  angle freetype harfbuzz[ucdn] podofo \
  backward bcrypt compat ice pdf sql http

# Minimal
vcpkg install benchmark gtest bzip2 liblzma libzip[core,bzip2] zlib fmt pugixml ragel utf8proc \
  giflib libjpeg-turbo libpng tiff angle freetype harfbuzz[ucdn]
```
-->

## Usage
CMake 3.14.0 snippets for all libraries.

<details>
<summary>benchmark</summary>

```cmake
find_package(benchmark CONFIG REQUIRED)
target_link_libraries(${PROJECT_NAME} PUBLIC benchmark::benchmark)

# int main(int argc, char* argv[]) {
#   benchmark::Initialize(&argc, argv);
#   if (benchmark::ReportUnrecognizedArguments(argc, argv)) {
#     return EXIT_FAILURE;
#   }
#   benchmark::RunSpecifiedBenchmarks();
# }
```

</details>

<details>
<summary>gtest</summary>

```cmake
enable_testing()
find_package(GTest MODULE REQUIRED)
target_link_libraries(${PROJECT_NAME} PUBLIC GTest::GTest)

# Discover tests dynamically.
gtest_discover_tests(${PROJECT_NAME} WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR})

# Parse sources for tests (required for VS integration).
gtest_add_tests(TARGET ${PROJECT_NAME} SOURCES ${sources} WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR})

# int main(int argc, char* argv[]) {
#   testing::InitGoogleTest(&argc, argv);
#   return RUN_ALL_TESTS();
# }
```

</details>

<details>
<summary>openssl</summary>

```cmake
if(WIN32)
  target_link_libraries(${PROJECT_NAME} PUBLIC ws2_32)
endif()

#find_package(OpenSSL REQUIRED)
#target_link_libraries(${PROJECT_NAME} PUBLIC OpenSSL::Crypto OpenSSL::SSL)

find_path(OPENSSL_INCLUDE_DIR openssl/crypto.h
  PATHS ${_VCPKG_ROOT_DIR}/installed/${VCPKG_TARGET_TRIPLET}/include NO_DEFAULT_PATH)
find_library(OPENSSL_CRYPTO_LIBRARY_DEBUG NAMES crypto libeay32
  PATHS ${_VCPKG_ROOT_DIR}/installed/${VCPKG_TARGET_TRIPLET}/debug/lib NO_DEFAULT_PATH)
find_library(OPENSSL_CRYPTO_LIBRARY_RELEASE NAMES crypto libeay32
  PATHS ${_VCPKG_ROOT_DIR}/installed/${VCPKG_TARGET_TRIPLET}/lib NO_DEFAULT_PATH)
find_library(OPENSSL_SSL_LIBRARY_DEBUG NAMES ssl ssleay32
  PATHS ${_VCPKG_ROOT_DIR}/installed/${VCPKG_TARGET_TRIPLET}/debug/lib NO_DEFAULT_PATH)
find_library(OPENSSL_SSL_LIBRARY_RELEASE NAMES ssl ssleay32
  PATHS ${_VCPKG_ROOT_DIR}/installed/${VCPKG_TARGET_TRIPLET}/lib NO_DEFAULT_PATH)
if(NOT OPENSSL_INCLUDE_DIR OR
   NOT OPENSSL_CRYPTO_LIBRARY_DEBUG OR NOT OPENSSL_CRYPTO_LIBRARY_RELEASE OR
   NOT OPENSSL_SSL_LIBRARY_DEBUG OR NOT OPENSSL_SSL_LIBRARY_RELEASE)
  message(FATAL_ERROR "Could not find library: openssl")
endif()
target_include_directories(${PROJECT_NAME} PUBLIC ${OPENSSL_INCLUDE_DIR})
target_link_libraries(${PROJECT_NAME} PUBLIC
  debug ${OPENSSL_CRYPTO_LIBRARY_DEBUG} debug ${OPENSSL_SSL_LIBRARY_DEBUG}
  optimized ${OPENSSL_CRYPTO_LIBRARY_RELEASE} optimized ${OPENSSL_SSL_LIBRARY_RELEASE}
  general $<$<PLATFORM_ID:Linux>:dl>)
```

</details>

<details>
<summary>bzip2</summary>

```cmake
find_package(BZip2 REQUIRED)
target_link_libraries(${PROJECT_NAME} PUBLIC BZip2::BZip2)
```

</details>

<details>
<summary>liblzma</summary>

```cmake
#find_package(LibLZMA REQUIRED)
#target_link_libraries(${PROJECT_NAME} PUBLIC LibLZMA::LibLZMA)

find_path(LZMA_INCLUDE_DIR lzma.h
  PATHS ${_VCPKG_ROOT_DIR}/installed/${VCPKG_TARGET_TRIPLET}/include NO_DEFAULT_PATH)
find_library(LZMA_LIBRARY_DEBUG NAMES lzma
  PATHS ${_VCPKG_ROOT_DIR}/installed/${VCPKG_TARGET_TRIPLET}/debug/lib NO_DEFAULT_PATH)
find_library(LZMA_LIBRARY_RELEASE NAMES lzma
  PATHS ${_VCPKG_ROOT_DIR}/installed/${VCPKG_TARGET_TRIPLET}/lib NO_DEFAULT_PATH)
if(NOT LZMA_INCLUDE_DIR OR NOT LZMA_LIBRARY_DEBUG OR NOT LZMA_LIBRARY_RELEASE)
  message(FATAL_ERROR "Could not find library: liblzma")
endif()
target_include_directories(${PROJECT_NAME} PUBLIC ${LZMA_INCLUDE_DIR})
target_link_libraries(${PROJECT_NAME} PUBLIC debug ${LZMA_LIBRARY_DEBUG} optimized ${LZMA_LIBRARY_RELEASE})
```

</details>

<details>
<summary>libzip[bzip2,openssl]</summary>

```cmake
find_package(BZip2 REQUIRED)
target_link_libraries(${PROJECT_NAME} PUBLIC BZip2::BZip2)

#find_package(OpenSSL REQUIRED)
#target_link_libraries(${PROJECT_NAME} PUBLIC OpenSSL::Crypto)

find_path(OPENSSL_INCLUDE_DIR openssl/crypto.h
  PATHS ${_VCPKG_ROOT_DIR}/installed/${VCPKG_TARGET_TRIPLET}/include NO_DEFAULT_PATH)
find_library(OPENSSL_CRYPTO_LIBRARY_DEBUG NAMES crypto libeay32
  PATHS ${_VCPKG_ROOT_DIR}/installed/${VCPKG_TARGET_TRIPLET}/debug/lib NO_DEFAULT_PATH)
find_library(OPENSSL_CRYPTO_LIBRARY_RELEASE NAMES crypto libeay32
  PATHS ${_VCPKG_ROOT_DIR}/installed/${VCPKG_TARGET_TRIPLET}/lib NO_DEFAULT_PATH)
if(NOT OPENSSL_INCLUDE_DIR OR NOT OPENSSL_CRYPTO_LIBRARY_DEBUG OR NOT OPENSSL_CRYPTO_LIBRARY_RELEASE)
  message(FATAL_ERROR "Could not find library: openssl")
endif()
target_include_directories(${PROJECT_NAME} PUBLIC ${OPENSSL_INCLUDE_DIR})
target_link_libraries(${PROJECT_NAME} PUBLIC
  debug ${OPENSSL_CRYPTO_LIBRARY_DEBUG}
  optimized ${OPENSSL_CRYPTO_LIBRARY_RELEASE}
  general $<$<PLATFORM_ID:Linux>:dl>)

find_path(ZIP_INCLUDE_DIR zip.h
  PATHS ${_VCPKG_ROOT_DIR}/installed/${VCPKG_TARGET_TRIPLET}/include NO_DEFAULT_PATH)
find_library(ZIP_LIBRARY_DEBUG NAMES zip
  PATHS ${_VCPKG_ROOT_DIR}/installed/${VCPKG_TARGET_TRIPLET}/debug/lib NO_DEFAULT_PATH)
find_library(ZIP_LIBRARY_RELEASE NAMES zip
  PATHS ${_VCPKG_ROOT_DIR}/installed/${VCPKG_TARGET_TRIPLET}/lib NO_DEFAULT_PATH)
if(NOT ZIP_INCLUDE_DIR OR NOT ZIP_LIBRARY_DEBUG OR NOT ZIP_LIBRARY_RELEASE)
  message(FATAL_ERROR "Could not find library: libzip")
endif()
target_include_directories(${PROJECT_NAME} PUBLIC ${ZIP_INCLUDE_DIR})
target_link_libraries(${PROJECT_NAME} PUBLIC debug ${ZIP_LIBRARY_DEBUG} optimized ${ZIP_LIBRARY_RELEASE})

find_package(ZLIB REQUIRED)
target_link_libraries(${PROJECT_NAME} PUBLIC ZLIB::ZLIB)
```

</details>

<details>
<summary>zlib</summary>

```cmake
find_package(ZLIB REQUIRED)
target_link_libraries(${PROJECT_NAME} PUBLIC ZLIB::ZLIB)
```

</details>

<details>
<summary>cpr</summary>

```cmake
if(WIN32)
  target_link_libraries(${PROJECT_NAME} PUBLIC ws2_32)
endif()

#find_package(OpenSSL REQUIRED)
#target_link_libraries(${PROJECT_NAME} PUBLIC OpenSSL::SSL OpenSSL::Crypto)

find_path(OPENSSL_INCLUDE_DIR openssl/crypto.h
  PATHS ${_VCPKG_ROOT_DIR}/installed/${VCPKG_TARGET_TRIPLET}/include NO_DEFAULT_PATH)
find_library(OPENSSL_CRYPTO_LIBRARY_DEBUG NAMES crypto libeay32
  PATHS ${_VCPKG_ROOT_DIR}/installed/${VCPKG_TARGET_TRIPLET}/debug/lib NO_DEFAULT_PATH)
find_library(OPENSSL_CRYPTO_LIBRARY_RELEASE NAMES crypto libeay32
  PATHS ${_VCPKG_ROOT_DIR}/installed/${VCPKG_TARGET_TRIPLET}/lib NO_DEFAULT_PATH)
find_library(OPENSSL_SSL_LIBRARY_DEBUG NAMES ssl ssleay32
  PATHS ${_VCPKG_ROOT_DIR}/installed/${VCPKG_TARGET_TRIPLET}/debug/lib NO_DEFAULT_PATH)
find_library(OPENSSL_SSL_LIBRARY_RELEASE NAMES ssl ssleay32
  PATHS ${_VCPKG_ROOT_DIR}/installed/${VCPKG_TARGET_TRIPLET}/lib NO_DEFAULT_PATH)
if(NOT OPENSSL_INCLUDE_DIR OR
   NOT OPENSSL_CRYPTO_LIBRARY_DEBUG OR NOT OPENSSL_CRYPTO_LIBRARY_RELEASE OR
   NOT OPENSSL_SSL_LIBRARY_DEBUG OR NOT OPENSSL_SSL_LIBRARY_RELEASE)
  message(FATAL_ERROR "Could not find library: openssl")
endif()
target_include_directories(${PROJECT_NAME} PUBLIC ${OPENSSL_INCLUDE_DIR})
target_link_libraries(${PROJECT_NAME} PUBLIC
  debug ${OPENSSL_CRYPTO_LIBRARY_DEBUG} debug ${OPENSSL_SSL_LIBRARY_DEBUG}
  optimized ${OPENSSL_CRYPTO_LIBRARY_RELEASE} optimized ${OPENSSL_SSL_LIBRARY_RELEASE}
  general $<$<PLATFORM_ID:Linux>:dl>)

#find_package(CURL REQUIRED)
#target_link_libraries(${PROJECT_NAME} PUBLIC CURL::libcurl)

find_path(CURL_INCLUDE_DIR curl/curl.h
  PATHS ${_VCPKG_ROOT_DIR}/installed/${VCPKG_TARGET_TRIPLET}/include NO_DEFAULT_PATH)
find_library(CURL_LIBRARY_DEBUG NAMES curl curl-d libcurl libcurl-d
  PATHS ${_VCPKG_ROOT_DIR}/installed/${VCPKG_TARGET_TRIPLET}/debug/lib NO_DEFAULT_PATH)
find_library(CURL_LIBRARY_RELEASE NAMES curl libcurl
  PATHS ${_VCPKG_ROOT_DIR}/installed/${VCPKG_TARGET_TRIPLET}/lib NO_DEFAULT_PATH)
if(NOT CURL_INCLUDE_DIR OR NOT CURL_LIBRARY_DEBUG OR NOT CURL_LIBRARY_RELEASE)
  message(FATAL_ERROR "Could not find library: curl")
endif()
target_include_directories(${PROJECT_NAME} PUBLIC ${CURL_INCLUDE_DIR})
target_link_libraries(${PROJECT_NAME} PUBLIC debug ${CURL_LIBRARY_DEBUG} optimized ${CURL_LIBRARY_RELEASE})

find_path(CPR_INCLUDE_DIR cpr/cpr.h
  PATHS ${_VCPKG_ROOT_DIR}/installed/${VCPKG_TARGET_TRIPLET}/include NO_DEFAULT_PATH)
find_library(CPR_LIBRARY_DEBUG NAMES cpr
  PATHS ${_VCPKG_ROOT_DIR}/installed/${VCPKG_TARGET_TRIPLET}/debug/lib NO_DEFAULT_PATH)
find_library(CPR_LIBRARY_RELEASE NAMES cpr
  PATHS ${_VCPKG_ROOT_DIR}/installed/${VCPKG_TARGET_TRIPLET}/lib NO_DEFAULT_PATH)
if(NOT CPR_INCLUDE_DIR OR NOT CPR_LIBRARY_DEBUG OR NOT CPR_LIBRARY_RELEASE)
  message(FATAL_ERROR "Could not find library: cpr")
endif()
target_include_directories(${PROJECT_NAME} PUBLIC ${CPR_INCLUDE_DIR})
target_link_libraries(${PROJECT_NAME} PUBLIC debug ${CPR_LIBRARY_DEBUG} optimized ${CPR_LIBRARY_RELEASE})

find_package(ZLIB REQUIRED)
target_link_libraries(${PROJECT_NAME} PUBLIC ZLIB::ZLIB)
```

</details>

<details>
<summary>curl[core,openssl]</summary>

```cmake
#find_package(OpenSSL REQUIRED)
#target_link_libraries(${PROJECT_NAME} PUBLIC OpenSSL::SSL OpenSSL::Crypto)

find_path(OPENSSL_INCLUDE_DIR openssl/ssl.h
  PATHS ${_VCPKG_ROOT_DIR}/installed/${VCPKG_TARGET_TRIPLET}/include NO_DEFAULT_PATH)
find_library(OPENSSL_CRYPTO_LIBRARY_DEBUG NAMES crypto libeay32
  PATHS ${_VCPKG_ROOT_DIR}/installed/${VCPKG_TARGET_TRIPLET}/debug/lib NO_DEFAULT_PATH)
find_library(OPENSSL_CRYPTO_LIBRARY_RELEASE NAMES crypto libeay32
  PATHS ${_VCPKG_ROOT_DIR}/installed/${VCPKG_TARGET_TRIPLET}/lib NO_DEFAULT_PATH)
find_library(OPENSSL_SSL_LIBRARY_DEBUG NAMES ssl ssleay32
  PATHS ${_VCPKG_ROOT_DIR}/installed/${VCPKG_TARGET_TRIPLET}/debug/lib NO_DEFAULT_PATH)
find_library(OPENSSL_SSL_LIBRARY_RELEASE NAMES ssl ssleay32
  PATHS ${_VCPKG_ROOT_DIR}/installed/${VCPKG_TARGET_TRIPLET}/lib NO_DEFAULT_PATH)
if(NOT OPENSSL_INCLUDE_DIR OR
   NOT OPENSSL_CRYPTO_LIBRARY_DEBUG OR NOT OPENSSL_CRYPTO_LIBRARY_RELEASE OR
   NOT OPENSSL_SSL_LIBRARY_DEBUG OR NOT OPENSSL_SSL_LIBRARY_RELEASE)
  message(FATAL_ERROR "Could not find library: openssl")
endif()
target_include_directories(${PROJECT_NAME} PUBLIC ${OPENSSL_INCLUDE_DIR})
target_link_libraries(${PROJECT_NAME} PUBLIC
  debug ${OPENSSL_CRYPTO_LIBRARY_DEBUG} debug ${OPENSSL_SSL_LIBRARY_DEBUG}
  optimized ${OPENSSL_CRYPTO_LIBRARY_RELEASE} optimized ${OPENSSL_SSL_LIBRARY_RELEASE}
  general $<$<PLATFORM_ID:Linux>:dl>)

#find_package(CURL REQUIRED)
#target_link_libraries(${PROJECT_NAME} PUBLIC CURL::libcurl)

find_path(CURL_INCLUDE_DIR curl/curl.h
  PATHS ${_VCPKG_ROOT_DIR}/installed/${VCPKG_TARGET_TRIPLET}/include NO_DEFAULT_PATH)
find_library(CURL_LIBRARY_DEBUG NAMES curl curl-d libcurl libcurl-d
  PATHS ${_VCPKG_ROOT_DIR}/installed/${VCPKG_TARGET_TRIPLET}/debug/lib NO_DEFAULT_PATH)
find_library(CURL_LIBRARY_RELEASE NAMES curl libcurl
  PATHS ${_VCPKG_ROOT_DIR}/installed/${VCPKG_TARGET_TRIPLET}/lib NO_DEFAULT_PATH)
if(NOT CURL_INCLUDE_DIR OR NOT CURL_LIBRARY_DEBUG OR NOT CURL_LIBRARY_RELEASE)
  message(FATAL_ERROR "Could not find library: curl")
endif()
target_include_directories(${PROJECT_NAME} PUBLIC ${CURL_INCLUDE_DIR})
target_link_libraries(${PROJECT_NAME} PUBLIC debug ${CURL_LIBRARY_DEBUG} optimized ${CURL_LIBRARY_RELEASE})

find_package(ZLIB REQUIRED)
target_link_libraries(${PROJECT_NAME} PUBLIC ZLIB::ZLIB)
```

</details>

<details>
<summary>date</summary>

```cmake
find_package(unofficial-date CONFIG REQUIRED)
target_link_libraries(${PROJECT_NAME} PUBLIC unofficial::date::date unofficial::date::tz)
```

</details>

<details>
<summary>fmt</summary>

```cmake
find_package(fmt CONFIG REQUIRED)
target_link_libraries(${PROJECT_NAME} PUBLIC fmt::fmt)
```

</details>

<details>
<summary>nlohmann-json</summary>

```cmake
find_package(nlohmann_json CONFIG REQUIRED)
target_link_libraries(${PROJECT_NAME} PUBLIC nlohmann_json::nlohmann_json)
```

</details>

<details>
<summary>ragel</summary>

```cmake
find_program(RAGEL NAMES ragel DOC "Ragel executable.")
if(NOT RAGEL)
  message(FATAL_ERROR "Could not find program: ragel")
endif()

find_program(CLANG_FORMAT NAMES clang-format DOC "Clang-Format executable." HINTS "$ENV{ProgramFiles\(x86\)}")
if(NOT CLANG_FORMAT)
  message(FATAL_ERROR "Could not find program: clang-format")
endif()

add_custom_command(
  OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/src/main.hpp
  MAIN_DEPENDENCY ${CMAKE_CURRENT_SOURCE_DIR}/src/main.hpp.rl
  COMMAND ${RAGEL} -C -o "${CMAKE_CURRENT_BINARY_DIR}/src/main.hpp" "${CMAKE_CURRENT_SOURCE_DIR}/src/main.hpp.rl"
  COMMAND ${CLANG_FORMAT} -i "${CMAKE_CURRENT_BINARY_DIR}/src/main.hpp")

target_sources(${PROJECT_NAME} PRIVATE ${CMAKE_CURRENT_BINARY_DIR}/src/main.hpp)
```

</details>

<details>
<summary>utf8proc</summary>

```cmake
find_path(UTF8PROC_INCLUDE_DIR utf8proc.h
  PATHS ${_VCPKG_ROOT_DIR}/installed/${VCPKG_TARGET_TRIPLET}/include NO_DEFAULT_PATH)
find_library(UTF8PROC_LIBRARY_DEBUG NAMES utf8proc
  PATHS ${_VCPKG_ROOT_DIR}/installed/${VCPKG_TARGET_TRIPLET}/debug/lib NO_DEFAULT_PATH)
find_library(UTF8PROC_LIBRARY_RELEASE NAMES utf8proc
  PATHS ${_VCPKG_ROOT_DIR}/installed/${VCPKG_TARGET_TRIPLET}/lib NO_DEFAULT_PATH)
if(NOT UTF8PROC_INCLUDE_DIR OR NOT UTF8PROC_LIBRARY_DEBUG OR NOT UTF8PROC_LIBRARY_RELEASE)
  message(FATAL_ERROR "Could not find library: utf8proc")
endif()
target_include_directories(${PROJECT_NAME} PUBLIC ${UTF8PROC_INCLUDE_DIR})
target_link_libraries(${PROJECT_NAME} PUBLIC debug ${UTF8PROC_LIBRARY_DEBUG} optimized ${UTF8PROC_LIBRARY_RELEASE})
```

</details>

<details>
<summary>giflib</summary>

```cmake
#find_package(GIF REQUIRED)
#target_link_libraries(${PROJECT_NAME} PUBLIC GIF::GIF)

find_path(GIF_INCLUDE_DIR gif_lib.h
  PATHS ${_VCPKG_ROOT_DIR}/installed/${VCPKG_TARGET_TRIPLET}/include NO_DEFAULT_PATH)
find_library(GIF_LIBRARY_DEBUG NAMES gif
  PATHS ${_VCPKG_ROOT_DIR}/installed/${VCPKG_TARGET_TRIPLET}/debug/lib NO_DEFAULT_PATH)
find_library(GIF_LIBRARY_RELEASE NAMES gif
  PATHS ${_VCPKG_ROOT_DIR}/installed/${VCPKG_TARGET_TRIPLET}/lib NO_DEFAULT_PATH)
if(NOT GIF_INCLUDE_DIR OR NOT GIF_LIBRARY_DEBUG OR NOT GIF_LIBRARY_RELEASE)
  message(FATAL_ERROR "Could not find library: giflib")
endif()
target_include_directories(${PROJECT_NAME} PUBLIC ${GIF_INCLUDE_DIR})
target_link_libraries(${PROJECT_NAME} PUBLIC debug ${GIF_LIBRARY_DEBUG} optimized ${GIF_LIBRARY_RELEASE})
```

</details>

<details>
<summary>libjpeg-turbo</summary>

<br/>

Interface: `jpeg`

```cmake
find_package(JPEG REQUIRED)
target_link_libraries(${PROJECT_NAME} PUBLIC JPEG::JPEG)
```

Interface: `jpeg-turbo`

```cmake
find_path(TURBOJPEG_INCLUDE_DIR turbojpeg.h
  PATHS ${_VCPKG_ROOT_DIR}/installed/${VCPKG_TARGET_TRIPLET}/include NO_DEFAULT_PATH)
find_library(TURBOJPEG_LIBRARY_DEBUG NAMES turbojpeg turbojpegd
  PATHS ${_VCPKG_ROOT_DIR}/installed/${VCPKG_TARGET_TRIPLET}/debug/lib NO_DEFAULT_PATH)
find_library(TURBOJPEG_LIBRARY_RELEASE NAMES turbojpeg
  PATHS ${_VCPKG_ROOT_DIR}/installed/${VCPKG_TARGET_TRIPLET}/lib NO_DEFAULT_PATH)
if(NOT TURBOJPEG_INCLUDE_DIR OR NOT TURBOJPEG_LIBRARY_DEBUG OR NOT TURBOJPEG_LIBRARY_RELEASE)
  message(FATAL_ERROR "Could not find library: libjpeg-turbo")
endif()
target_include_directories(${PROJECT_NAME} PUBLIC ${TURBOJPEG_INCLUDE_DIR})
target_link_libraries(${PROJECT_NAME} PUBLIC debug ${TURBOJPEG_LIBRARY_DEBUG} optimized ${TURBOJPEG_LIBRARY_RELEASE})
```

</details>

<details>
<summary>libpng</summary>

```cmake
find_package(PNG REQUIRED)
target_link_libraries(${PROJECT_NAME} PUBLIC PNG::PNG)

find_package(ZLIB REQUIRED)
target_link_libraries(${PROJECT_NAME} PUBLIC ZLIB::ZLIB)
```

</details>

<details>
<summary>tiff</summary>

```cmake
#find_package(LibLZMA REQUIRED)
#target_link_libraries(${PROJECT_NAME} PUBLIC LibLZMA::LibLZMA)

find_path(LZMA_INCLUDE_DIR lzma.h
  PATHS ${_VCPKG_ROOT_DIR}/installed/${VCPKG_TARGET_TRIPLET}/include NO_DEFAULT_PATH)
find_library(LZMA_LIBRARY_DEBUG NAMES lzma
  PATHS ${_VCPKG_ROOT_DIR}/installed/${VCPKG_TARGET_TRIPLET}/debug/lib NO_DEFAULT_PATH)
find_library(LZMA_LIBRARY_RELEASE NAMES lzma
  PATHS ${_VCPKG_ROOT_DIR}/installed/${VCPKG_TARGET_TRIPLET}/lib NO_DEFAULT_PATH)
if(NOT LZMA_INCLUDE_DIR OR NOT LZMA_LIBRARY_DEBUG OR NOT LZMA_LIBRARY_RELEASE)
  message(FATAL_ERROR "Could not find library: liblzma")
endif()
target_include_directories(${PROJECT_NAME} PUBLIC ${LZMA_INCLUDE_DIR})
target_link_libraries(${PROJECT_NAME} PUBLIC debug ${LZMA_LIBRARY_DEBUG} optimized ${LZMA_LIBRARY_RELEASE})

find_package(JPEG REQUIRED)
target_link_libraries(${PROJECT_NAME} PUBLIC JPEG::JPEG)

find_package(TIFF REQUIRED)
target_link_libraries(${PROJECT_NAME} PUBLIC TIFF::TIFF)

find_package(ZLIB REQUIRED)
target_link_libraries(${PROJECT_NAME} PUBLIC ZLIB::ZLIB)
```

</details>

<details>
<summary>angle</summary>

```cmake
if(CMAKE_SYSTEM_NAME STREQUAL "Linux")
  find_package(X11 REQUIRED)
  target_link_libraries(${PROJECT_NAME} PUBLIC X11::X11 dl)
endif()

find_package(unofficial-angle CONFIG REQUIRED)
target_link_libraries(${PROJECT_NAME} PUBLIC unofficial::angle::libEGL unofficial::angle::libGLESv2)
```

</details>

<details>
<summary>freetype</summary>

```cmake
find_package(BZip2 REQUIRED)
target_link_libraries(${PROJECT_NAME} PUBLIC BZip2::BZip2)

find_package(Freetype REQUIRED)
target_link_libraries(${PROJECT_NAME} PUBLIC Freetype::Freetype)

find_package(PNG REQUIRED)
target_link_libraries(${PROJECT_NAME} PUBLIC PNG::PNG)

find_package(ZLIB REQUIRED)
target_link_libraries(${PROJECT_NAME} PUBLIC ZLIB::ZLIB)
```

</details>

<details>
<summary>harfbuzz[ucdn]</summary>

```cmake
find_package(BZip2 REQUIRED)
target_link_libraries(${PROJECT_NAME} PUBLIC BZip2::BZip2)

find_package(Freetype REQUIRED)
target_link_libraries(${PROJECT_NAME} PUBLIC Freetype::Freetype)

find_package(harfbuzz CONFIG REQUIRED)
target_link_libraries(${PROJECT_NAME} PUBLIC harfbuzz::harfbuzz)

find_package(PNG REQUIRED)
target_link_libraries(${PROJECT_NAME} PUBLIC PNG::PNG)

find_package(ZLIB REQUIRED)
target_link_libraries(${PROJECT_NAME} PUBLIC ZLIB::ZLIB)
```

</details>

<details>
<summary>podofo</summary>

```cmake
if(NOT WIN32)
  #find_package(OpenSSL REQUIRED)
  #target_link_libraries(${PROJECT_NAME} PUBLIC OpenSSL::Crypto)

  find_path(OPENSSL_INCLUDE_DIR openssl/crypto.h
    PATHS ${_VCPKG_ROOT_DIR}/installed/${VCPKG_TARGET_TRIPLET}/include NO_DEFAULT_PATH)
  find_library(OPENSSL_CRYPTO_LIBRARY_DEBUG NAMES crypto libeay32
    PATHS ${_VCPKG_ROOT_DIR}/installed/${VCPKG_TARGET_TRIPLET}/debug/lib NO_DEFAULT_PATH)
  find_library(OPENSSL_CRYPTO_LIBRARY_RELEASE NAMES crypto libeay32
    PATHS ${_VCPKG_ROOT_DIR}/installed/${VCPKG_TARGET_TRIPLET}/lib NO_DEFAULT_PATH)
  if(NOT OPENSSL_INCLUDE_DIR OR NOT OPENSSL_CRYPTO_LIBRARY_DEBUG OR NOT OPENSSL_CRYPTO_LIBRARY_RELEASE)
    message(FATAL_ERROR "Could not find library: openssl")
  endif()
  target_include_directories(${PROJECT_NAME} PUBLIC ${OPENSSL_INCLUDE_DIR})
  target_link_libraries(${PROJECT_NAME} PUBLIC
    debug ${OPENSSL_CRYPTO_LIBRARY_DEBUG}
    optimized ${OPENSSL_CRYPTO_LIBRARY_RELEASE}
    general $<$<PLATFORM_ID:Linux>:dl>)
endif()

find_package(BZip2 REQUIRED)
target_link_libraries(${PROJECT_NAME} PUBLIC BZip2::BZip2)

#find_package(LibLZMA REQUIRED)
#target_link_libraries(${PROJECT_NAME} PUBLIC LibLZMA::LibLZMA)

find_path(LZMA_INCLUDE_DIR lzma.h
  PATHS ${_VCPKG_ROOT_DIR}/installed/${VCPKG_TARGET_TRIPLET}/include NO_DEFAULT_PATH)
find_library(LZMA_LIBRARY_DEBUG NAMES lzma
  PATHS ${_VCPKG_ROOT_DIR}/installed/${VCPKG_TARGET_TRIPLET}/debug/lib NO_DEFAULT_PATH)
find_library(LZMA_LIBRARY_RELEASE NAMES lzma
  PATHS ${_VCPKG_ROOT_DIR}/installed/${VCPKG_TARGET_TRIPLET}/lib NO_DEFAULT_PATH)
if(NOT LZMA_INCLUDE_DIR OR NOT LZMA_LIBRARY_DEBUG OR NOT LZMA_LIBRARY_RELEASE)
  message(FATAL_ERROR "Could not find library: liblzma")
endif()
target_include_directories(${PROJECT_NAME} PUBLIC ${LZMA_INCLUDE_DIR})
target_link_libraries(${PROJECT_NAME} PUBLIC debug ${LZMA_LIBRARY_DEBUG} optimized ${LZMA_LIBRARY_RELEASE})

find_package(Freetype REQUIRED)
target_link_libraries(${PROJECT_NAME} PUBLIC Freetype::Freetype)

find_package(JPEG REQUIRED)
target_link_libraries(${PROJECT_NAME} PUBLIC JPEG::JPEG)

find_package(PNG REQUIRED)
target_link_libraries(${PROJECT_NAME} PUBLIC PNG::PNG)

find_package(TIFF REQUIRED)
target_link_libraries(${PROJECT_NAME} PUBLIC TIFF::TIFF)

find_package(ZLIB REQUIRED)
target_link_libraries(${PROJECT_NAME} PUBLIC ZLIB::ZLIB)

find_path(PODOFO_INCLUDE_DIR podofo/podofo.h
  PATHS ${_VCPKG_ROOT_DIR}/installed/${VCPKG_TARGET_TRIPLET}/include NO_DEFAULT_PATH)
find_library(PODOFO_LIBRARY_DEBUG NAMES podofo
  PATHS ${_VCPKG_ROOT_DIR}/installed/${VCPKG_TARGET_TRIPLET}/debug/lib NO_DEFAULT_PATH)
find_library(PODOFO_LIBRARY_RELEASE NAMES podofo
  PATHS ${_VCPKG_ROOT_DIR}/installed/${VCPKG_TARGET_TRIPLET}/lib NO_DEFAULT_PATH)
if(NOT PODOFO_INCLUDE_DIR OR NOT PODOFO_LIBRARY_DEBUG OR NOT PODOFO_LIBRARY_RELEASE)
  message(FATAL_ERROR "Could not find library: podofo")
endif()
target_include_directories(${PROJECT_NAME} PUBLIC ${PODOFO_INCLUDE_DIR})
target_link_libraries(${PROJECT_NAME} PUBLIC debug ${PODOFO_LIBRARY_DEBUG} optimized ${PODOFO_LIBRARY_RELEASE})
```

</details>

## Test
Verify that all ports and usage snippets are working properly using
the [vcpkg-test](https://github.com/qis/vcpkg-test) project.

```sh
git clone git@github.com:qis/vcpkg-test
cd vcpkg-test && make ports test
```
