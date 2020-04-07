MAKEFLAGS += --no-print-directory

TRIPLE	!= gcc -dumpmachine | grep musl >/dev/null && echo "x86_64-linux-musl" || echo "x86_64-linux-gnu"
MUSL	!= echo $(TRIPLE) | grep musl >/dev/null && echo "ON" || echo "OFF"
DATE	!= date +%F

all: llvm

# =================================================================================================
# llvm
# =================================================================================================

src:
	git clone --depth 1 https://github.com/llvm/llvm-project src

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
	  -B build/llvm src/llvm
	@ninja -C build/llvm \
	  install-LTO \
	  install-lld-stripped \
	  install-lldb-stripped \
	  install-clang-stripped \
	  install-clang-format-stripped \
	  install-clang-resource-headers \
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
	rm -f llvm/bin/clang
	rm -f llvm/bin/clang-cl
	rm -f llvm/bin/clang-cpp
	rm -f llvm/bin/lld-link
	rm -f llvm/bin/wasm-ld
	rm -f llvm/lib/libLTO.so
	mv llvm/bin/clang-11 llvm/bin/clang
	mv llvm/lib/libLTO.so.11git llvm/lib/libLTO.so

llvm: llvm/bin/clang restore

# =================================================================================================
# package
# =================================================================================================

package: clean package-toolchain restore

package-toolchain:
	rm -f toolchain.7z
	7z a -mx=9 -myx=9 -ms=2g toolchains-$(DATE).7z \
	  llvm \
	  config.cmake \
	  linux.cmake \
	  makefile \
	  readme.md \
	  windows.cmake

# =================================================================================================
# clean
# =================================================================================================

clean:
	rm -f llvm/bin/clang++
	rm -f llvm/bin/ld.lld
	rm -f llvm/bin/ld64.lld
	rm -f llvm/bin/llvm-ranlib
	rm -f llvm/bin/llvm-strip

# =================================================================================================
# restore
# =================================================================================================

restore: clean
	ln -s clang llvm/bin/clang++
	ln -s lld llvm/bin/ld.lld
	ln -s lld llvm/bin/ld64.lld
	ln -s llvm-ar llvm/bin/llvm-ranlib
	ln -s llvm-objcopy llvm/bin/llvm-strip
	find llvm -type d -exec chmod 0755 '{}' ';' -or -type f -exec chmod 0644 '{}' ';'
	find llvm/bin -type f -and -not -iname '*.dll' -exec chmod 0755 '{}' ';'

.PHONY: all llvm package clean restore
