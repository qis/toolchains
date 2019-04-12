# Toolchains
Custom [vcpkg](https://github.com/Microsoft/vcpkg) toolchains.

```sh
cd C:/Workspace || cd /opt
git clone git@github.com:Microsoft/vcpkg
cmake -E remove_directory vcpkg/scripts/toolchains
git clone git@github.com:qis/toolchains vcpkg/scripts/toolchains
curl https://raw.githubusercontent.com/qis/vcpkg-date/master/portfile.cmake -o vcpkg/ports/date/portfile.cmake
curl https://raw.githubusercontent.com/qis/vcpkg-date/master/fix-date.patch -o vcpkg/ports/date/fix-date.patch
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

## Linux
Set up environment variables.

```sh
export PATH="${PATH}:/opt/vcpkg"
```

Build Vcpkg.

```sh
CC=gcc CXX=g++ bootstrap-vcpkg.sh -disableMetrics -useSystemBinaries
rm -rf vcpkg/toolsrc/build.rel
```

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
vcpkg install cpr curl[core,openssl] date fmt nlohmann-json ragel utf8proc

# Images
vcpkg install giflib libjpeg-turbo libpng tiff

# Graphics
# apt install libx11-dev mesa-common-dev
vcpkg install angle freetype harfbuzz[ucdn] podofo
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

vcpkg install ^
  benchmark gtest ^
  openssl ^
  bzip2 liblzma libzip[bzip2,openssl] zlib ^
  cpr curl[core,openssl] date fmt nlohmann-json ragel utf8proc ^
  giflib libjpeg-turbo libpng tiff ^
  angle freetype harfbuzz[ucdn] podofo ^
  bcrypt compat ice pdf sql http
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

vcpkg install \
  benchmark gtest \
  openssl \
  bzip2 liblzma libzip[bzip2,openssl] zlib \
  cpr curl[core,openssl] date fmt nlohmann-json ragel utf8proc \
  giflib libjpeg-turbo libpng tiff \
  angle freetype harfbuzz[ucdn] podofo \
  backward bcrypt compat ice pdf sql http
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

find_package(OpenSSL REQUIRED)
target_link_libraries(${PROJECT_NAME} PUBLIC OpenSSL::Crypto OpenSSL::SSL)
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
find_package(LibLZMA REQUIRED)
if(CMAKE_VERSION VERSION_GREATER_EQUAL "3.14.0")
  target_link_libraries(${PROJECT_NAME} PUBLIC LibLZMA::LibLZMA)
else()
  target_include_directories(${PROJECT_NAME} PUBLIC ${LIBLZMA_INCLUDE_DIRS})
  target_link_libraries(${PROJECT_NAME} PUBLIC ${LIBLZMA_LIBRARIES})
endif()
```

</details>

<details>
<summary>libzip[bzip2,openssl]</summary>

```cmake
if(WIN32)
  target_link_libraries(${PROJECT_NAME} PUBLIC ws2_32)
endif()

find_package(BZip2 REQUIRED)
target_link_libraries(${PROJECT_NAME} PUBLIC BZip2::BZip2)

find_package(OpenSSL REQUIRED)
target_link_libraries(${PROJECT_NAME} PUBLIC OpenSSL::Crypto)

find_path(ZIP_INCLUDE_DIR zip.h)
find_library(ZIP_LIBRARY NAMES zip)
if(NOT ZIP_INCLUDE_DIR OR NOT ZIP_LIBRARY)
  message(FATAL_ERROR "Could not find library: zip")
endif()
target_include_directories(${PROJECT_NAME} PUBLIC ${ZIP_INCLUDE_DIR})
target_link_libraries(${PROJECT_NAME} PUBLIC ${ZIP_LIBRARY})

find_package(ZLIB REQUIRED)
target_link_libraries(${PROJECT_NAME} PUBLIC ZLIB::ZLIB
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

find_package(OpenSSL REQUIRED)
target_link_libraries(${PROJECT_NAME} PUBLIC OpenSSL::SSL OpenSSL::Crypto)

find_path(CPR_INCLUDE_DIR cpr/cpr.h)
find_library(CPR_LIBRARY NAMES cpr)
if(NOT CPR_INCLUDE_DIR OR NOT CPR_LIBRARY)
  message(FATAL_ERROR "Could not find library: cpr")
endif()
target_include_directories(${PROJECT_NAME} PUBLIC ${CPR_INCLUDE_DIR})
target_link_libraries(${PROJECT_NAME} PUBLIC ${CPR_LIBRARY})

find_package(CURL REQUIRED)
target_link_libraries(${PROJECT_NAME} PUBLIC CURL::libcurl)

find_package(ZLIB REQUIRED)
target_link_libraries(${PROJECT_NAME} PUBLIC ZLIB::ZLIB)
```

</details>

<details>
<summary>curl[core,openssl]</summary>

```cmake
if(WIN32)
  target_link_libraries(${PROJECT_NAME} PUBLIC ws2_32)
endif()

find_package(OpenSSL REQUIRED)
target_link_libraries(${PROJECT_NAME} PUBLIC OpenSSL::SSL OpenSSL::Crypto)

find_package(CURL REQUIRED)
target_link_libraries(${PROJECT_NAME} PUBLIC CURL::libcurl)

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
find_path(UTF8PROC_INCLUDE_DIR utf8proc.h)
find_library(UTF8PROC_LIBRARY NAMES utf8proc)
if(NOT UTF8PROC_INCLUDE_DIR OR NOT UTF8PROC_LIBRARY)
  message(FATAL_ERROR "Could not find library: utf8proc")
endif()
target_include_directories(${PROJECT_NAME} PUBLIC ${UTF8PROC_INCLUDE_DIR})
target_link_libraries(${PROJECT_NAME} PUBLIC ${UTF8PROC_LIBRARY})
```

</details>

<details>
<summary>giflib</summary>

```cmake
find_package(GIF REQUIRED)
if(CMAKE_VERSION VERSION_GREATER_EQUAL "3.14.0")
  target_link_libraries(${PROJECT_NAME} PUBLIC GIF::GIF)
else()
  target_include_directories(${PROJECT_NAME} PUBLIC ${GIF_INCLUDE_DIR})
  target_link_libraries(${PROJECT_NAME} PUBLIC ${GIF_LIBRARIES})
endif()
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
find_path(TURBOJPEG_INCLUDE_DIR turbojpeg.h)
find_library(TURBOJPEG_LIBRARY NAMES turbojpeg turbojpegd NAMES_PER_DIR)
if(NOT TURBOJPEG_INCLUDE_DIR OR NOT TURBOJPEG_LIBRARY)
  message(FATAL_ERROR "Could not find library: libjpeg-turbo")
endif()
target_include_directories(${PROJECT_NAME} PUBLIC ${TURBOJPEG_INCLUDE_DIR})
target_link_libraries(${PROJECT_NAME} PUBLIC ${TURBOJPEG_LIBRARY})
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
find_package(LibLZMA REQUIRED)
if(CMAKE_VERSION VERSION_GREATER_EQUAL "3.14.0")
  target_link_libraries(${PROJECT_NAME} PUBLIC LibLZMA::LibLZMA)
else()
  target_include_directories(${PROJECT_NAME} PUBLIC ${LIBLZMA_INCLUDE_DIRS})
  target_link_libraries(${PROJECT_NAME} PUBLIC ${LIBLZMA_LIBRARIES})
endif()

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
  if(CMAKE_VERSION VERSION_GREATER_EQUAL "3.14.0")
    target_link_libraries(${PROJECT_NAME} PUBLIC X11::X11 dl)
  else()
    target_include_directories(${PROJECT_NAME} PUBLIC ${X11_INCLUDE_DIR})
    target_link_libraries(${PROJECT_NAME} PUBLIC ${X11_LIBRARIES} dl)
  endif()
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
if(WIN32)
  target_link_libraries(${PROJECT_NAME} PUBLIC ws2_32)
else()
  find_package(OpenSSL REQUIRED)
  target_link_libraries(${PROJECT_NAME} PUBLIC OpenSSL::Crypto)
endif()

find_package(BZip2 REQUIRED)
target_link_libraries(${PROJECT_NAME} PUBLIC BZip2::BZip2)

find_package(LibLZMA REQUIRED)
if(CMAKE_VERSION VERSION_GREATER_EQUAL "3.14.0")
  target_link_libraries(${PROJECT_NAME} PUBLIC LibLZMA::LibLZMA)
else()
  target_include_directories(${PROJECT_NAME} PUBLIC ${LIBLZMA_INCLUDE_DIRS})
  target_link_libraries(${PROJECT_NAME} PUBLIC ${LIBLZMA_LIBRARIES})
endif()

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

find_path(PODOFO_INCLUDE_DIR podofo/podofo.h)
find_library(PODOFO_LIBRARY NAMES podofo)
if(NOT PODOFO_INCLUDE_DIR OR NOT PODOFO_LIBRARY)
  message(FATAL_ERROR "Could not find library: podofo")
endif()
target_include_directories(${PROJECT_NAME} PUBLIC ${PODOFO_INCLUDE_DIR})
target_link_libraries(${PROJECT_NAME} PUBLIC ${PODOFO_LIBRARY})
```

</details>

## Test
Verify that all ports and usage snippets are working properly using
the [vcpkg-test](https://github.com/qis/vcpkg-test) project.

```sh
git clone git@github.com:qis/vcpkg-test
cd vcpkg-test && make ports test
```
