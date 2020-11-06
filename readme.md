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

Install [NASM](https://www.nasm.us/pub/nasm/releasebuilds/2.15.05/win64/nasm-2.15.05-installer-x64.exe)

```
☐ RDOFF
☐ Manual
☐ VS8 integration
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
C:\Program Files\NASM
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
sudo apt install -y binutils-dev gcc g++ gdb make nasm ninja-build manpages-dev pkg-config
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

Set system LLVM C and C++ compiler.

```sh
for i in clang clang++; do sudo update-alternatives --remove-all $i; done
sudo update-alternatives --install /usr/bin/clang   clang   /opt/llvm/bin/clang   100
sudo update-alternatives --install /usr/bin/clang++ clang++ /opt/llvm/bin/clang++ 100
```

Set system C and C++ compiler.

```sh
for i in c++ cc; do sudo update-alternatives --remove-all $i; done
sudo update-alternatives --install /usr/bin/cc  cc  /usr/bin/clang   100
sudo update-alternatives --install /usr/bin/c++ c++ /usr/bin/clang++ 100
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

### Ubuntu
Build vcpkg.

```sh
/opt/vcpkg/bootstrap-vcpkg.sh -disableMetrics -useSystemBinaries && rm -rf /opt/vcpkg/toolsrc/build.rel
```

## Ports
Create a ports overlays.

```cmd
cd C:/Workspace || cd /opt

git clone git@github.com:xnetsystems/boost boost
git clone git@github.com:xnetsystems/bcrypt ports/bcrypt
git clone git@github.com:xnetsystems/compat ports/compat
git clone git@github.com:xnetsystems/dtz ports/dtz
git clone git@github.com:xnetsystems/ice ports/ice
git clone git@github.com:xnetsystems/sql ports/sql
git clone git@github.com:xnetsystems/tbb ports/tbb
git clone git@github.com:xnetsystems/http ports/http
git clone git@github.com:xnetsystems/pdf ports/pdf

cmake -P boost/create.cmake
```

Install ports in `cmd.exe`.

```cmd
vcpkg install --editable benchmark doctest gtest openssl ^
  brotli bzip2 liblzma libzip zlib zstd libjpeg-turbo libpng ^
  boost date fmt libssh2 nlohmann-json pugixml tbb utf8proc ^
  bcrypt compat dtz http ice pdf sql
```

Install ports in `wsl.exe`.

```sh
vcpkg install --editable benchmark doctest gtest openssl \
  brotli bzip2 liblzma libzip zlib zstd libjpeg-turbo libpng \
  boost date fmt libssh2 nlohmann-json pugixml tbb utf8proc \
  bcrypt compat dtz http ice pdf sql
```

Clean `buildtrees` directory and remove `packages` directories.

```cmd
cd C:/Workspace || cd /opt
cmake -P vcpkg/triplets/toolchains/clean.cmake
```

<!--
Find required system packages for CPack.

```sh
sudo apt install apt-file
sudo apt-file update

ldd <executable>
apt-file search <shared-library>
apt info <package> 2>/dev/null | grep Version
```
-->
