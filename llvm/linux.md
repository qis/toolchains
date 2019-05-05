# LLVM
How to instal a custom LLVM toolchain.

As of 2019-04-30 `libcxx` and `libcxxabi` are broken and have to be patched.

```diff
diff --git i/lib/CMakeLists.txt w/lib/CMakeLists.txt
index 0564ee6..53b6b02 100644
--- i/lib/CMakeLists.txt
+++ w/lib/CMakeLists.txt
@@ -168,8 +168,8 @@ if (LIBCXX_ENABLE_SHARED)
     elseif (LIBCXXABI_STATICALLY_LINK_UNWINDER_IN_SHARED_LIBRARY AND (TARGET unwind_static OR HAVE_LIBUNWIND))
       # libunwind is already included in libc++abi
     else()
-      target_link_libraries(cxx_shared PRIVATE unwind)
-      list(APPEND LIBCXX_INTERFACE_LIBRARIES unwind) # For the linker script
+      target_link_libraries(cxx_shared PRIVATE unwind_static)
+      list(APPEND LIBCXX_INTERFACE_LIBRARIES unwind_static) # For the linker script
     endif()
   endif()
 
```

```diff
diff --git i/src/CMakeLists.txt w/src/CMakeLists.txt
index afc13c8..d4f3708 100644
--- i/src/CMakeLists.txt
+++ w/src/CMakeLists.txt
@@ -66,14 +66,14 @@ if (LIBCXXABI_USE_LLVM_UNWINDER)
   elseif (LIBCXXABI_STATICALLY_LINK_UNWINDER_IN_SHARED_LIBRARY AND (TARGET unwind_static OR HAVE_LIBUNWIND))
     list(APPEND LIBCXXABI_SHARED_LIBRARIES unwind_static)
   else()
-    list(APPEND LIBCXXABI_SHARED_LIBRARIES unwind)
+    list(APPEND LIBCXXABI_SHARED_LIBRARIES unwind_static)
   endif()
   if (NOT LIBCXXABI_STATICALLY_LINK_UNWINDER_IN_STATIC_LIBRARY AND (TARGET unwind_shared OR HAVE_LIBUNWIND))
     list(APPEND LIBCXXABI_STATIC_LIBRARIES unwind_shared)
   elseif (LIBCXXABI_STATICALLY_LINK_UNWINDER_IN_STATIC_LIBRARY AND (TARGET unwind_static OR HAVE_LIBUNWIND))
       # We handle this by directly merging libunwind objects into libc++abi.
   else()
-    list(APPEND LIBCXXABI_STATIC_LIBRARIES unwind)
+    list(APPEND LIBCXXABI_STATIC_LIBRARIES unwind_static)
   endif()
 else()
   add_library_flags_if(LIBCXXABI_HAS_GCC_S_LIB gcc_s)
```

```sh
# Set environment variables.
export PATH="${PATH}:/opt/llvm/bin"

# Download LLVM source code.
git clone --depth 1 https://github.com/llvm-project/llvm-project-submodule llvm
for i in clang clang-tools-extra compiler-rt libcxx libcxxabi libunwind lld llvm openmp pstl; do
  sh -c "cd llvm && git submodule update --init --depth 1 -- $i"
done
ls llvm/{clang,clang-tools-extra,compiler-rt,libcxx,libcxxabi,libunwind,lld,llvm,openmp,pstl}

# Download TBB source code.
git clone -b tbb_2019 --depth 1 https://github.com/01org/tbb tbb

# Unregister old toolchain.
sudo update-alternatives --remove-all cc
sudo update-alternatives --remove-all c++
sudo rm -f /etc/ld.so.conf.d/llvm.conf
sudo ldconfig

# Uninstall old toolchain.
rm -rf /opt/stage /opt/llvm

# Stage LLVM.
rm -rf llvm/stage
cmake -GNinja -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX="/opt/stage" \
  -DLLVM_ENABLE_PROJECTS="clang;libcxx;libcxxabi;compiler-rt;libunwind;lld" \
  -DLLVM_TARGETS_TO_BUILD="X86" \
  -DLLVM_ENABLE_ASSERTIONS=OFF \
  -DLLVM_ENABLE_WARNINGS=OFF \
  -DLLVM_ENABLE_PEDANTIC=OFF \
  -DLLVM_INCLUDE_EXAMPLES=OFF \
  -DLLVM_INCLUDE_TESTS=OFF \
  -DLLVM_INCLUDE_DOCS=OFF \
  -DCLANG_DEFAULT_STD_C="c99" \
  -DCLANG_DEFAULT_STD_CXX="cxx17" \
  -DCLANG_DEFAULT_CXX_STDLIB="libc++" \
  -DCLANG_DEFAULT_RTLIB="compiler-rt" \
  -DCLANG_DEFAULT_LINKER="lld" \
  -DLIBUNWIND_ENABLE_SHARED=OFF \
  -DLIBUNWIND_ENABLE_STATIC=ON \
  -DLIBCXXABI_USE_COMPILER_RT=ON \
  -DLIBCXXABI_USE_LLVM_UNWINDER=ON \
  -DLIBCXXABI_ENABLE_SHARED=OFF \
  -DLIBCXXABI_ENABLE_STATIC=ON \
  -DLIBCXXABI_ENABLE_STATIC_UNWINDER=ON \
  -DLIBCXXABI_ENABLE_ASSERTIONS=OFF \
  -DLIBCXXABI_ENABLE_EXCEPTIONS=ON \
  -DLIBCXX_ENABLE_SHARED=ON \
  -DLIBCXX_ENABLE_STATIC=OFF \
  -DLIBCXX_ENABLE_STATIC_ABI_LIBRARY=ON \
  -DLIBCXX_ENABLE_ASSERTIONS=OFF \
  -DLIBCXX_ENABLE_EXCEPTIONS=ON \
  -DLIBCXX_ENABLE_FILESYSTEM=ON \
  -DLIBCXX_ENABLE_EXPERIMENTAL_LIBRARY=ON \
  -DLIBCXX_INSTALL_EXPERIMENTAL_LIBRARY=ON \
  -DLIBCXX_INCLUDE_BENCHMARKS=OFF \
  -B llvm/stage llvm/llvm
cmake --build llvm/stage --target install

# Install LLVM.
rm -rf llvm/build
PATH="/opt/stage/bin:$PATH" \
LD_LIBRARY_PATH="/opt/stage/lib:/opt/stage/lib/clang/9.0.0/lib/linux:$LD_LIBRARY_PATH" \
cmake -GNinja -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX="/opt/llvm" \
  -DCMAKE_AR="/opt/stage/bin/llvm-ar" \
  -DCMAKE_RANLIB="/opt/stage/bin/llvm-ranlib" \
  -DCMAKE_C_COMPILER="/opt/stage/bin/clang" \
  -DCMAKE_CXX_COMPILER="/opt/stage/bin/clang++" \
  -DCMAKE_EXE_LINKER_FLAGS_RELEASE="-Wl,-S" \
  -DCMAKE_SHARED_LINKER_FLAGS_RELEASE="-Wl,-S" \
  -DLLVM_ENABLE_PROJECTS="clang;clang-tools-extra;libcxx;libcxxabi;compiler-rt;libunwind;lld" \
  -DLLVM_TARGETS_TO_BUILD="X86;WebAssembly" \
  -DLLVM_EXPERIMENTAL_TARGETS_TO_BUILD="WebAssembly" \
  -DLLVM_ENABLE_ASSERTIONS=OFF \
  -DLLVM_ENABLE_WARNINGS=OFF \
  -DLLVM_ENABLE_PEDANTIC=OFF \
  -DLLVM_ENABLE_LTO=Thin \
  -DLLVM_ENABLE_LLD=ON \
  -DLLVM_INCLUDE_EXAMPLES=OFF \
  -DLLVM_INCLUDE_TESTS=OFF \
  -DLLVM_INCLUDE_DOCS=OFF \
  -DCLANG_DEFAULT_STD_C="c99" \
  -DCLANG_DEFAULT_STD_CXX="cxx17" \
  -DCLANG_DEFAULT_CXX_STDLIB="libc++" \
  -DCLANG_DEFAULT_RTLIB="compiler-rt" \
  -DCLANG_DEFAULT_LINKER="lld" \
  -DLIBUNWIND_ENABLE_SHARED=OFF \
  -DLIBUNWIND_ENABLE_STATIC=ON \
  -DLIBCXXABI_USE_COMPILER_RT=ON \
  -DLIBCXXABI_USE_LLVM_UNWINDER=ON \
  -DLIBCXXABI_ENABLE_SHARED=OFF \
  -DLIBCXXABI_ENABLE_STATIC=ON \
  -DLIBCXXABI_ENABLE_ASSERTIONS=OFF \
  -DLIBCXXABI_ENABLE_EXCEPTIONS=ON \
  -DLIBCXX_ENABLE_SHARED=ON \
  -DLIBCXX_ENABLE_STATIC=OFF \
  -DLIBCXX_ENABLE_STATIC_ABI_LIBRARY=ON \
  -DLIBCXX_ENABLE_ASSERTIONS=OFF \
  -DLIBCXX_ENABLE_EXCEPTIONS=ON \
  -DLIBCXX_ENABLE_FILESYSTEM=ON \
  -DLIBCXX_ENABLE_EXPERIMENTAL_LIBRARY=ON \
  -DLIBCXX_INSTALL_EXPERIMENTAL_LIBRARY=ON \
  -DLIBCXX_INCLUDE_BENCHMARKS=OFF \
  -DLIBCXX_USE_COMPILER_RT=ON \
  -B llvm/build llvm/llvm
PATH="/opt/stage/bin:$PATH" \
LD_LIBRARY_PATH="/opt/stage/lib:/opt/stage/lib/clang/9.0.0/lib/linux:$LD_LIBRARY_PATH" \
cmake --build llvm/build --target install
for i in libcxx libcxxabi compiler-rt libunwind lld; do
  cp llvm/$i/LICENSE.TXT /opt/llvm/share/$i.license
done

# Install OpenMP.
rm -rf llvm/build-openmp
PATH="/opt/llvm/bin:$PATH" \
LD_LIBRARY_PATH="/opt/llvm/lib:/opt/llvm/lib/clang/9.0.0/lib/linux:$LD_LIBRARY_PATH" \
cmake -GNinja -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX="/opt/llvm" \
  -DCMAKE_AR="/opt/llvm/bin/llvm-ar" \
  -DCMAKE_RANLIB="/opt/llvm/bin/llvm-ranlib" \
  -DCMAKE_C_COMPILER="/opt/llvm/bin/clang" \
  -DCMAKE_CXX_COMPILER="/opt/llvm/bin/clang++" \
  -DCMAKE_EXE_LINKER_FLAGS_RELEASE="-Wl,-S" \
  -DCMAKE_SHARED_LINKER_FLAGS_RELEASE="-Wl,-S" \
  -B llvm/build-openmp llvm/openmp
PATH="/opt/llvm/bin:$PATH" \
LD_LIBRARY_PATH="/opt/llvm/lib:/opt/llvm/lib/clang/9.0.0/lib/linux:$LD_LIBRARY_PATH" \
cmake --build llvm/build-openmp --target install
cp llvm/openmp/LICENSE.txt /opt/llvm/share/openmp.license

# Install PSTL headers.
cp -R llvm/pstl/include/pstl /opt/llvm/include/c++/v1/
cp -R llvm/pstl/test/support/stdlib /opt/llvm/include/c++/v1/pstl/
cp llvm/pstl/LICENSE.txt /opt/llvm/share/pstl.license

# Install TBB.
pushd tbb
rm -rf build/*_release
PATH="/opt/llvm/bin:$PATH" \
LD_LIBRARY_PATH="/opt/llvm/lib:/opt/llvm/lib/clang/9.0.0/lib/linux:$LD_LIBRARY_PATH" \
AR="llvm-ar" RANLIB="llvm-ranlib" CC="clang" CXX="clang++" LDFLAGS="-fuse-ld=ld -Wl,-S" \
make compiler=clang arch=intel64 stdver=c++17 cfg=release
chmod 0644 build/*_release/lib*.so*
cp -R build/*_release/lib*.so* /opt/llvm/lib/
cp -R include/tbb /opt/llvm/include/c++/v1/
cp LICENSE /opt/llvm/share/tbb.license
popd

# Create distribution.
pushd llvm/llvm
tar czf /opt/llvm-9.0.0-$(git rev-parse --short HEAD).tar.gz -C /opt llvm
popd

# Register toolchain.
sudo update-alternatives --install /usr/bin/cc cc /opt/llvm/bin/clang 100
sudo update-alternatives --install /usr/bin/c++ c++ /opt/llvm/bin/clang++ 100
sudo tee /etc/ld.so.conf.d/llvm.conf <<'EOF'
/opt/llvm/lib
/opt/llvm/lib/clang/9.0.0/lib/linux
EOF
sudo ldconfig
```
