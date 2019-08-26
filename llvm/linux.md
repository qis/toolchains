# LLVM
Check out LLVM and TBB source code.

```cmd
rem Enter workspace.
cd C:\Workspace

rem Check out LLVM source code.
git clone --depth 1 https://github.com/llvm/llvm-project llvm

rem Check out TBB source code.
git clone -b tbb_2019 --depth 1 https://github.com/01org/tbb tbb
```

Install LLVM.

```sh
# Install dependencies.
sudo apt install build-essential binutils-dev libedit-dev libelf-dev libffi-dev nasm python

# Unregister old toolchain.
sudo update-alternatives --remove-all cc
sudo update-alternatives --remove-all c++
sudo rm -f /etc/ld.so.conf.d/llvm.conf
sudo ldconfig

# Uninstall old toolchain.
rm -rf /opt/llvm

# Enter workspace.
cd /mnt/c/Workspace

# Stage LLVM.
rm -rf llvm-stage
LDFLAGS="-Wl,-S" \
cmake -GNinja -DCMAKE_BUILD_TYPE=MinSizeRel -DCMAKE_INSTALL_PREFIX="/opt/llvm" \
  -DLLVM_ENABLE_PROJECTS="lld;clang;clang-tools-extra;compiler-rt;libunwind;libcxxabi;libcxx" \
  -DLLVM_TARGETS_TO_BUILD="X86" \
  -DLLVM_ENABLE_UNWIND_TABLES=OFF \
  -DLLVM_ENABLE_WARNINGS=OFF \
  -DLLVM_INCLUDE_BENCHMARKS=OFF \
  -DLLVM_INCLUDE_EXAMPLES=OFF \
  -DLLVM_INCLUDE_TESTS=OFF \
  -DLLVM_INCLUDE_DOCS=OFF \
  -DLLVM_INSTALL_TOOLCHAIN_ONLY=ON \
  -DCLANG_DEFAULT_STD_C="c99" \
  -DCLANG_DEFAULT_STD_CXX="cxx2a" \
  -DCLANG_DEFAULT_CXX_STDLIB="libc++" \
  -DCLANG_DEFAULT_UNWINDLIB="libunwind" \
  -DCLANG_DEFAULT_RTLIB="compiler-rt" \
  -DCLANG_DEFAULT_LINKER="lld" \
  -DCOMPILER_RT_BUILD_LIBFUZZER=OFF \
  -DCOMPILER_RT_BUILD_PROFILE=OFF \
  -DCOMPILER_RT_BUILD_SANITIZERS=OFF \
  -DCOMPILER_RT_BUILD_XRAY=OFF \
  -DCOMPILER_RT_INCLUDE_TESTS=OFF \
  -DLIBUNWIND_ENABLE_SHARED=ON \
  -DLIBUNWIND_ENABLE_STATIC=OFF \
  -DLIBUNWIND_USE_COMPILER_RT=ON \
  -DLIBCXXABI_ENABLE_SHARED=ON \
  -DLIBCXXABI_ENABLE_STATIC=OFF \
  -DLIBCXXABI_USE_COMPILER_RT=ON \
  -DLIBCXXABI_USE_LLVM_UNWINDER=ON \
  -DLIBCXX_ENABLE_SHARED=ON \
  -DLIBCXX_ENABLE_STATIC=OFF \
  -DLIBCXX_INCLUDE_BENCHMARKS=OFF \
  -DLIBCXX_USE_COMPILER_RT=ON \
  -B llvm-stage llvm/llvm
cmake --build llvm-stage -t \
  install-{clang,clang-format,clang-resource-headers,lld,llvm-{ar,nm,objcopy,objdump,ranlib,rc},LTO}-stripped \
  install-{compiler-rt,compiler-rt-headers,unwind,cxxabi,cxx}-stripped tools/llvm-config/install/strip \
  utils/FileCheck/install/strip

# Register toolchain.
sudo update-alternatives --install /usr/bin/cc cc /opt/llvm/bin/clang 100
sudo update-alternatives --install /usr/bin/c++ c++ /opt/llvm/bin/clang++ 100
sudo tee /etc/ld.so.conf.d/llvm.conf <<'EOF'
/opt/llvm/lib
/opt/llvm/lib/clang/10.0.0/lib/linux
EOF
sudo ldconfig

# Add toolchain to path.
export PATH="/opt/llvm/bin:$PATH"

# Install TBB.
pushd tbb
rm -rf build/*_{debug,release}
CC="clang -flto=thin" CXX="clang++ -flto=thin" AR="llvm-ar" RANLIB="llvm-ranlib" LDFLAGS="-Wl,-S -rtlib=compiler-rt" \
make compiler=clang arch=intel64 stdver=c++2a stdlib=libc++ cfg=debug,release
cp -R include/tbb /opt/llvm/include/
cp -R build/*_release/libtbb*.so* /opt/llvm/lib/
cp -R build/*_debug/libtbb*.so* /opt/llvm/lib/
chmod 0644 /opt/llvm/lib/libtbb*.so*
cmake -DINSTALL_DIR=/opt/llvm/lib/cmake/TBB -DSYSTEM_NAME=Linux \
  -DTBB_VERSION_FILE=/opt/llvm/include/tbb/tbb_stddef.h \
  -DINC_REL_PATH=../../../include/ \
  -DLIB_REL_PATH=../.. \
  -P cmake/tbb_config_installer.cmake
popd

# Install OpenMP.
rm -rf llvm-openmp
CC="clang" CXX="clang++" AR="llvm-ar" RANLIB="llvm-ranlib" CPPFLAGS="-flto=thin" LDFLAGS="-Wl,-S -rtlib=compiler-rt" \
cmake -GNinja -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX="/opt/llvm" \
  -DOPENMP_LLVM_TOOLS_DIR=llvm-stage/bin \
  -B llvm-openmp llvm/openmp
cmake --build llvm-openmp -t install/strip

# Reinstall LLVM.
rm -rf llvm-build
CC="clang" CXX="clang++" AR="llvm-ar" RANLIB="llvm-ranlib" CPPFLAGS="-flto=thin" LDFLAGS="-Wl,-S -rtlib=compiler-rt" \
cmake -GNinja -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX="/opt/llvm" \
  -DLLVM_ENABLE_PROJECTS="lld;clang;clang-tools-extra;compiler-rt;libunwind;libcxxabi;libcxx;pstl" \
  -DLLVM_TARGETS_TO_BUILD="X86" \
  -DLLVM_ENABLE_UNWIND_TABLES=OFF \
  -DLLVM_ENABLE_WARNINGS=OFF \
  -DLLVM_INCLUDE_BENCHMARKS=OFF \
  -DLLVM_INCLUDE_EXAMPLES=OFF \
  -DLLVM_INCLUDE_TESTS=OFF \
  -DLLVM_INCLUDE_DOCS=OFF \
  -DLLVM_ENABLE_LTO=Thin \
  -DLLVM_INSTALL_TOOLCHAIN_ONLY=ON \
  -DCLANG_DEFAULT_STD_C="c99" \
  -DCLANG_DEFAULT_STD_CXX="cxx2a" \
  -DCLANG_DEFAULT_CXX_STDLIB="libc++" \
  -DCLANG_DEFAULT_UNWINDLIB="libunwind" \
  -DCLANG_DEFAULT_RTLIB="compiler-rt" \
  -DCLANG_DEFAULT_LINKER="lld" \
  -DCOMPILER_RT_BUILD_LIBFUZZER=OFF \
  -DCOMPILER_RT_BUILD_PROFILE=OFF \
  -DCOMPILER_RT_BUILD_SANITIZERS=OFF \
  -DCOMPILER_RT_BUILD_XRAY=OFF \
  -DCOMPILER_RT_INCLUDE_TESTS=OFF \
  -DLIBUNWIND_ENABLE_SHARED=ON \
  -DLIBUNWIND_ENABLE_STATIC=OFF \
  -DLIBUNWIND_USE_COMPILER_RT=ON \
  -DLIBCXXABI_ENABLE_SHARED=ON \
  -DLIBCXXABI_ENABLE_STATIC=OFF \
  -DLIBCXXABI_USE_COMPILER_RT=ON \
  -DLIBCXXABI_USE_LLVM_UNWINDER=ON \
  -DLIBCXX_ENABLE_SHARED=ON \
  -DLIBCXX_ENABLE_STATIC=OFF \
  -DLIBCXX_ENABLE_PARALLEL_ALGORITHMS=ON \
  -DLIBCXX_INCLUDE_BENCHMARKS=OFF \
  -DLIBCXX_USE_COMPILER_RT=ON \
  -DPSTL_PARALLEL_BACKEND="tbb" \
  -B llvm-build llvm/llvm
cmake --build llvm-build -t install-{unwind,cxxabi}-stripped \
  install-cxx-headers projects/libcxx/install/strip install-pstl

# Move OpenMP and ParallelSTL headers to the default C++ include path.
mv /opt/llvm/include/{pstl,tbb,__pstl*,omp*} /opt/llvm/include/c++/v1/

# Update registered toolchain.
sudo ldconfig
```

Remove build directories and create archive.

```sh
# Remove build directories.
rm -rf llvm-{stage,build,openmp} tbb/build/*_{debug,release}

# Create archive.
tar czf llvm-10.0.0-$(git --git-dir=llvm/.git rev-parse --short HEAD).tar.gz -C /opt llvm
```
