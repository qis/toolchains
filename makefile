MAKEFLAGS += --no-print-directory

TRIPLE	!= gcc -dumpmachine | grep musl >/dev/null && echo "x86_64-linux-musl" || echo "x86_64-linux-gnu"
MUSL	!= echo $(TRIPLE) | grep musl >/dev/null && echo "ON" || echo "OFF"

all: llvm

# =================================================================================================
# llvm
# =================================================================================================

src:
	git clone --config core.autocrlf=false --depth 1 \
	  -b release/10.x https://github.com/llvm/llvm-project src

llvm/bin/clang: src
	@cmake -GNinja -Wno-dev \
	  -DCMAKE_BUILD_TYPE=Release \
	  -DCMAKE_INSTALL_PREFIX="$(CURDIR)/llvm" \
	  -DCMAKE_BUILD_WITH_INSTALL_RPATH=ON \
	  -DLLVM_ENABLE_PROJECTS="clang;clang-tools-extra;lld;lldb;polly;openmp;compiler-rt;libunwind;libcxxabi;libcxx" \
	  -DLLVM_DEFAULT_TARGET_TRIPLE="$(TRIPLE)" \
	  -DLLVM_TARGETS_TO_BUILD="X86" \
	  -DLLVM_ENABLE_BACKTRACES=OFF \
	  -DLLVM_ENABLE_UNWIND_TABLES=OFF \
	  -DLLVM_ENABLE_WARNINGS=OFF \
	  -DLLVM_INCLUDE_BENCHMARKS=OFF \
	  -DLLVM_INCLUDE_EXAMPLES=OFF \
	  -DLLVM_INCLUDE_TESTS=OFF \
	  -DLLVM_INCLUDE_DOCS=OFF \
	  -DCLANG_ENABLE_ARCMT=OFF \
	  -DCLANG_ENABLE_STATIC_ANALYZER=OFF \
	  -DCLANG_DEFAULT_STD_C="c11" \
	  -DCLANG_DEFAULT_STD_CXX="cxx20" \
	  -DCLANG_DEFAULT_CXX_STDLIB="libc++" \
	  -DCLANG_DEFAULT_UNWINDLIB="none" \
	  -DCLANG_DEFAULT_RTLIB="compiler-rt" \
	  -DCLANG_DEFAULT_LINKER="lld" \
	  -DCLANG_PLUGIN_SUPPORT=OFF \
	  -DOPENMP_ENABLE_LIBOMPTARGET=OFF \
	  -DCOMPILER_RT_BUILD_SANITIZERS=OFF \
	  -DCOMPILER_RT_BUILD_LIBFUZZER=OFF \
	  -DCOMPILER_RT_BUILD_PROFILE=OFF \
	  -DCOMPILER_RT_BUILD_XRAY=OFF \
	  -DCOMPILER_RT_INCLUDE_TESTS=OFF \
	  -DLIBUNWIND_ENABLE_SHARED=OFF \
	  -DLIBUNWIND_ENABLE_STATIC=ON \
	  -DLIBUNWIND_USE_COMPILER_RT=ON \
	  -DLIBCXXABI_ENABLE_SHARED=OFF \
	  -DLIBCXXABI_ENABLE_STATIC=ON \
	  -DLIBCXXABI_ENABLE_STATIC_UNWINDER=ON \
	  -DLIBCXXABI_USE_COMPILER_RT=ON \
	  -DLIBCXXABI_USE_LLVM_UNWINDER=ON \
	  -DLIBCXX_ENABLE_SHARED=OFF \
	  -DLIBCXX_ENABLE_STATIC=ON \
	  -DLIBCXX_ENABLE_STATIC_ABI_LIBRARY=ON \
	  -DLIBCXX_HAS_MUSL_LIBC=$(MUSL) \
	  -DLIBCXX_USE_COMPILER_RT=ON \
	  -DLIBCXX_INCLUDE_BENCHMARKS=OFF \
	  -B build/linux src/llvm
	@ninja -C build/linux \
	  install-LTO-stripped \
	  install-lld-stripped \
	  install-lldb-stripped \
	  install-clang-stripped \
	  install-clang-tidy-stripped \
	  install-clang-format-stripped \
	  install-clang-resource-headers \
	  install-libclang-stripped \
	  install-libclang-headers \
	  install-llvm-ar-stripped \
	  install-llvm-nm-stripped \
	  install-llvm-objdump-stripped \
	  install-llvm-ranlib-stripped \
	  install-llvm-strip-stripped \
	  install-compiler-rt-stripped \
	  install-compiler-rt-headers-stripped \
	  install-unwind-stripped \
	  install-cxxabi-stripped \
	  install-cxx-stripped
	cmake -E remove llvm/bin/clang
	cmake -E remove llvm/bin/clang-cl
	cmake -E remove llvm/bin/clang-cpp
	cmake -E remove llvm/bin/lld-link
	cmake -E remove llvm/bin/wasm-ld
	cmake -E remove llvm/lib/libLTO.so
	cmake -E remove llvm/lib/libclang.so
	cmake -E rename llvm/lib/libLTO.so.10 llvm/lib/libLTO.so
	cmake -E rename llvm/lib/libclang.so.10 llvm/lib/libclang.so
	cmake -E rename llvm/bin/clang-10 llvm/bin/clang

llvm: llvm/bin/clang restore

# =================================================================================================
# package
# =================================================================================================

package: clean
	@echo Generating llvm.7z ...
	@cmake -E remove -f llvm.7z
	@7z a -mx=9 -myx=9 -ms=2g llvm.7z llvm

# =================================================================================================
# clean
# =================================================================================================

clean: clean-linux clean-windows

clean-linux:
	cmake -E remove -f llvm/bin/clang++
	cmake -E remove -f llvm/bin/ld.lld
	cmake -E remove -f llvm/bin/ld64.lld
	cmake -E remove -f llvm/bin/llvm-ranlib
	cmake -E remove -f llvm/bin/llvm-strip

clean-windows:
	cmake -E remove -f llvm/bin/clang++.exe
	cmake -E remove -f llvm/bin/clang-cl.exe
	cmake -E remove -f llvm/bin/ld.lld.exe
	cmake -E remove -f llvm/bin/ld64.lld.exe
	cmake -E remove -f llvm/bin/lld-link.exe
	cmake -E remove -f llvm/bin/llvm-ranlib.exe
	cmake -E remove -f llvm/bin/llvm-strip.exe

# =================================================================================================
# restore
# =================================================================================================

restore: clean-linux
	cmake -E create_symlink clang llvm/bin/clang++
	cmake -E create_symlink lld llvm/bin/ld.lld
	cmake -E create_symlink lld llvm/bin/ld64.lld
	cmake -E create_symlink llvm-ar llvm/bin/llvm-ranlib
	cmake -E create_symlink llvm-objcopy llvm/bin/llvm-strip
	find llvm -type d -exec chmod 0755 '{}' ';' -or -type f -exec chmod 0644 '{}' ';'
	find llvm/bin -type f -and -not -iname '*.dll' -exec chmod 0755 '{}' ';'
	cmake -P res/install.cmake

.PHONY: all llvm package clean restore
