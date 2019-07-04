# LLVM
How to instal a custom LLVM toolchain.

As of 2019-07-04 `libcxx` and `libcxxabi` are broken and have to be patched.

```diff
diff --git i/libcxx/src/CMakeLists.txt w/libcxx/src/CMakeLists.txt
index 2a8ff2c2d..50ee2fa1b 100644
--- i/libcxx/src/CMakeLists.txt
+++ w/libcxx/src/CMakeLists.txt
@@ -252,8 +252,8 @@ if (LIBCXX_ENABLE_SHARED)
     elseif (LIBCXXABI_STATICALLY_LINK_UNWINDER_IN_SHARED_LIBRARY AND (TARGET unwind_static OR HAVE_LIBUNWIND))
       # libunwind is already included in libc++abi
     else()
-      target_link_libraries(cxx_shared PRIVATE unwind)
-      list(APPEND LIBCXX_INTERFACE_LIBRARIES unwind) # For the linker script
+      target_link_libraries(cxx_shared PRIVATE unwind_static)
+      list(APPEND LIBCXX_INTERFACE_LIBRARIES unwind_static) # For the linker script
     endif()
   endif()

diff --git i/libcxxabi/src/CMakeLists.txt w/libcxxabi/src/CMakeLists.txt
index 45d4d0253..2b17c8b6d 100644
--- i/libcxxabi/src/CMakeLists.txt
+++ w/libcxxabi/src/CMakeLists.txt
@@ -74,14 +74,14 @@ if (LIBCXXABI_USE_LLVM_UNWINDER)
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

It is also viable to patch TBB to create libraries without a version number.

```diff
diff --git i/build/Makefile.tbb w/build/Makefile.tbb
index 63ee6eb..ea965cf 100644
--- i/build/Makefile.tbb
+++ w/build/Makefile.tbb
@@ -102,10 +102,6 @@ $(TBB.DLL): BUILDING_LIBRARY = $(TBB.DLL)
 $(TBB.DLL): $(TBB.OBJ) $(TBB.RES) tbbvars.sh $(TBB_NO_VERSION.DLL)
        $(LIB_LINK_CMD) $(LIB_OUTPUT_KEY)$(TBB.DLL) $(TBB.OBJ) $(TBB.RES) $(LIB_LINK_LIBS) $(LIB_LINK_FLAGS)
 
-ifneq (,$(TBB_NO_VERSION.DLL))
-$(TBB_NO_VERSION.DLL):
-       echo "INPUT ($(TBB.DLL))" > $(TBB_NO_VERSION.DLL)
-endif
 
 #clean:
 #      $(RM) *.$(OBJ) *.$(DLL) *.res *.map *.ilk *.pdb *.exp *.manifest *.tmp *.d core core.*[0-9][0-9] *.ver
diff --git i/build/Makefile.tbbmalloc w/build/Makefile.tbbmalloc
index 421e95c..5037bfa 100644
--- i/build/Makefile.tbbmalloc
+++ w/build/Makefile.tbbmalloc
@@ -98,15 +98,6 @@ $(MALLOCPROXY.DLL): $(PROXY.OBJ) $(MALLOCPROXY_NO_VERSION.DLL) $(MALLOC.DLL) $(M
        $(LIB_LINK_CMD) $(LIB_OUTPUT_KEY)$(MALLOCPROXY.DLL) $(PROXY.OBJ) $(MALLOC.RES) $(LIB_LINK_LIBS) $(LINK_MALLOC.LIB) $(PROXY_LINK_FLAGS)
 endif
 
-ifneq (,$(MALLOC_NO_VERSION.DLL))
-$(MALLOC_NO_VERSION.DLL):
-       echo "INPUT ($(MALLOC.DLL))" > $(MALLOC_NO_VERSION.DLL)
-endif
-
-ifneq (,$(MALLOCPROXY_NO_VERSION.DLL))
-$(MALLOCPROXY_NO_VERSION.DLL):
-       echo "INPUT ($(MALLOCPROXY.DLL))" > $(MALLOCPROXY_NO_VERSION.DLL)
-endif
 
 malloc: $(MALLOC.DLL) $(MALLOCPROXY.DLL)

diff --git i/build/linux.inc w/build/linux.inc
index 4d59aaa..e94f18d 100644
--- i/build/linux.inc
+++ w/build/linux.inc
@@ -111,20 +111,20 @@ endif
 TBB.LST = $(tbb_root)/src/tbb/$(def_prefix)-tbb-export.lst
 TBB.DEF = $(TBB.LST:.lst=.def)
 
-TBB.DLL = $(TBB_NO_VERSION.DLL).$(SONAME_SUFFIX)
+TBB.DLL = $(TBB_NO_VERSION.DLL)
 TBB.LIB = $(TBB.DLL)
 TBB_NO_VERSION.DLL=libtbb$(CPF_SUFFIX)$(DEBUG_SUFFIX).$(DLL)
 LINK_TBB.LIB = $(TBB_NO_VERSION.DLL)
 
 MALLOC_NO_VERSION.DLL = libtbbmalloc$(DEBUG_SUFFIX).$(MALLOC_DLL)
 MALLOC.DEF = $(MALLOC_ROOT)/$(def_prefix)-tbbmalloc-export.def
-MALLOC.DLL = $(MALLOC_NO_VERSION.DLL).$(SONAME_SUFFIX)
+MALLOC.DLL = $(MALLOC_NO_VERSION.DLL)
 MALLOC.LIB = $(MALLOC_NO_VERSION.DLL)
 LINK_MALLOC.LIB = $(MALLOC_NO_VERSION.DLL)
 
 MALLOCPROXY_NO_VERSION.DLL = libtbbmalloc_proxy$(DEBUG_SUFFIX).$(DLL)
 MALLOCPROXY.DEF = $(MALLOC_ROOT)/$(def_prefix)-proxy-export.def
-MALLOCPROXY.DLL = $(MALLOCPROXY_NO_VERSION.DLL).$(SONAME_SUFFIX)
+MALLOCPROXY.DLL = $(MALLOCPROXY_NO_VERSION.DLL)
 MALLOCPROXY.LIB = $(MALLOCPROXY_NO_VERSION.DLL)
 LINK_MALLOCPROXY.LIB = $(MALLOCPROXY.LIB)
 
```

```sh
# Set environment variables.
export PATH="${PATH}:/opt/llvm/bin"

# Download LLVM source code.
git clone --depth 1 https://github.com/llvm/llvm-project llvm

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
rm -rf llvm-stage
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
  -B llvm-stage llvm/llvm
/usr/bin/time cmake --build llvm-stage --target install

# Install LLVM.
rm -rf llvm-release
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
  -DLLVM_TARGETS_TO_BUILD="X86" \
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
  -B llvm-release llvm/llvm
PATH="/opt/stage/bin:$PATH" \
LD_LIBRARY_PATH="/opt/stage/lib:/opt/stage/lib/clang/9.0.0/lib/linux:$LD_LIBRARY_PATH" \
cmake --build llvm-release --target install
for i in libcxx libcxxabi compiler-rt libunwind lld; do
  cp llvm/$i/LICENSE.TXT /opt/llvm/share/$i.license
done

# Install OpenMP.
rm -rf llvm-openmp
PATH="/opt/llvm/bin:$PATH" \
LD_LIBRARY_PATH="/opt/llvm/lib:/opt/llvm/lib/clang/9.0.0/lib/linux:$LD_LIBRARY_PATH" \
cmake -GNinja -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX="/opt/llvm" \
  -DCMAKE_AR="/opt/llvm/bin/llvm-ar" \
  -DCMAKE_RANLIB="/opt/llvm/bin/llvm-ranlib" \
  -DCMAKE_C_COMPILER="/opt/llvm/bin/clang" \
  -DCMAKE_CXX_COMPILER="/opt/llvm/bin/clang++" \
  -DCMAKE_EXE_LINKER_FLAGS_RELEASE="-Wl,-S" \
  -DCMAKE_SHARED_LINKER_FLAGS_RELEASE="-Wl,-S" \
  -B llvm-openmp llvm/openmp
PATH="/opt/llvm/bin:$PATH" \
LD_LIBRARY_PATH="/opt/llvm/lib:/opt/llvm/lib/clang/9.0.0/lib/linux:$LD_LIBRARY_PATH" \
cmake --build llvm-openmp --target install
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
cp -R build/*_release/libtbb*.so* /opt/llvm/lib/
cp -R include/tbb /opt/llvm/include/c++/v1/
cp LICENSE /opt/llvm/share/tbb.license
chmod 0644 /opt/llvm/lib/libtbb*.so*
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
