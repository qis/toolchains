# Toolchains
Custom [vcpkg](https://github.com/Microsoft/vcpkg) toolchains.

```sh
cd C:/Workspace || cd /opt
git clone --depth 1 --filter=blob:none git@github.com:Microsoft/vcpkg
cmake -E rename vcpkg/scripts/toolchains vcpkg/scripts/toolchains.orig
git clone git@github.com:qis/toolchains vcpkg/scripts/toolchains
```

Patch vcpkg to disable static library post-build architecture checks.

```diff
--- i/toolsrc/src/vcpkg/postbuildlint.cpp
+++ w/toolsrc/src/vcpkg/postbuildlint.cpp
@@ -429,7 +429,7 @@ namespace vcpkg::PostBuildLint
     static LintStatus check_lib_architecture(const std::string& expected_architecture,
                                              const std::vector<fs::path>& files)
     {
-#if defined(_WIN32)
+#if defined(_WIN32) && 0
         std::vector<FileAndArch> binaries_with_invalid_architecture;

         for (const fs::path& file : files)
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
set VCPKG_ROOT=C:\Workspace\vcpkg
set VCPKG_DEFAULT_TRIPLET=x64-windows-static
set PATH=%PATH%;%VCPKG_ROOT%
```

Build Vcpkg.

```cmd
bootstrap-vcpkg -disableMetrics -win64
```

Build LLVM.

```sh
cd "%VCPKG_ROOT%\scripts\toolchains" && make
```

<details>
<summary>Modify the <code>triplets/x64-windows-static.cmake</code> triplet file.</summary>

Example for targeting CPUs with AVX2 support.

```cmake
set(VCPKG_TARGET_ARCHITECTURE x64)
set(VCPKG_CRT_LINKAGE static)
set(VCPKG_LIBRARY_LINKAGE static)

set(VCPKG_C_FLAGS "/arch:AVX2")
set(VCPKG_CXX_FLAGS "/arch:AVX2")
```

</details>

## Linux
Set up environment variables.

```sh
export VCPKG_ROOT="/opt/vcpkg"
export VCPKG_DEFAULT_TRIPLET="x64-linux"
export PATH="${PATH}:${VCPKG_ROOT}"
```

Build Vcpkg.

```sh
bootstrap-vcpkg.sh -disableMetrics -useSystemBinaries
rm -rf /opt/vcpkg/toolsrc/build.rel
```

Build LLVM.

```sh
cd "${VCPKG_ROOT}/scripts/toolchains" && make
```

<details>
<summary>Modify the <code>triplets/x64-linux.cmake</code> triplet file.</summary>

Example for targeting CPUs with AVX2 support.

```cmake
set(VCPKG_TARGET_ARCHITECTURE x64)
set(VCPKG_CRT_LINKAGE dynamic)
set(VCPKG_LIBRARY_LINKAGE static)

set(VCPKG_C_FLAGS "-mavx2")
set(VCPKG_CXX_FLAGS "-mavx2")

set(VCPKG_CMAKE_SYSTEM_NAME Linux)
```

</details>

## Ports
Install ports.

```sh
# Development
vcpkg install benchmark gtest

# Encryption
vcpkg install openssl

# Compression
vcpkg install bzip2 liblzma libzip[bzip2,openssl] zlib zstd

# Utility
vcpkg install date fmt libssh2 nlohmann-json pugixml ragel spdlog utf8proc

# Images
vcpkg install giflib libjpeg-turbo libpng tiff

# Fonts
vcpkg install freetype

# Documents
vcpkg install podofo

# Boost
vcpkg install boost
```

<!--
```
git clone git@github.com:qis/backward vcpkg/ports/backward && ^
git clone git@github.com:qis/bcrypt vcpkg/ports/bcrypt && ^
git clone git@github.com:qis/compat vcpkg/ports/compat && ^
git clone git@github.com:qis/ice vcpkg/ports/ice && ^
git clone git@github.com:qis/sql vcpkg/ports/sql && ^
git clone git@github.com:xnetsystems/pdf vcpkg/ports/pdf && ^
git clone git:libraries/http vcpkg/ports/http

vcpkg install benchmark gtest openssl bzip2 liblzma libzip[bzip2,openssl] zlib zstd && ^
vcpkg install date fmt libssh2 nlohmann-json pugixml ragel spdlog utf8proc && ^
vcpkg install giflib libjpeg-turbo libpng tiff freetype podofo boost && ^
vcpkg install bcrypt compat ice pdf sql http

vcpkg install benchmark gtest openssl bzip2 liblzma libzip[bzip2,openssl] zlib zstd && \
vcpkg install date fmt libssh2 nlohmann-json pugixml ragel spdlog utf8proc && \
vcpkg install giflib libjpeg-turbo libpng tiff freetype podofo boost && \
vcpkg install backward bcrypt compat ice pdf sql http
```
-->

## Resources
See [qis/example](https://github.com/qis/example) for a C++ application example using this setup.
