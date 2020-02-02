MAKEFLAGS += --no-print-directory

all: llvm

# =================================================================================================
# llvm
# =================================================================================================

src/llvm:
	@cmake -E echo "Downloading llvm ..."
	@git clone --depth 1 https://github.com/llvm/llvm-project src/llvm
	@cmake -E echo "Patching llvm ..."
	@cmake -P src/llvm.cmake

llvm/bin/clang: src/llvm
	@cmake -GNinja -Wno-dev \
	  -DCMAKE_BUILD_TYPE=Release \
	  -DCMAKE_INSTALL_PREFIX="$(CURDIR)/llvm" \
	  -DLLVM_ENABLE_PROJECTS="clang;clang-tools-extra;lld;lldb;polly;openmp;compiler-rt;libunwind;libcxxabi;libcxx" \
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
	  -DCLANG_DEFAULT_STD_CXX="cxx2a" \
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
	  -DLIBCXX_USE_COMPILER_RT=ON \
	  -DLIBCXX_INCLUDE_BENCHMARKS=OFF \
	  -DLIBCXX_ENABLE_PARALLEL_ALGORITHMS=ON \
	  -B build/llvm src/llvm/llvm
	@cmake --build build/llvm -t \
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
	@cmake -E remove -f "llvm/bin/clang"
	@cmake -E remove -f "llvm/bin/clang-cl"
	@cmake -E remove -f "llvm/bin/clang-cpp"
	@cmake -E remove -f "llvm/bin/lld-link"
	@cmake -E remove -f "llvm/bin/wasm-ld"
	@cmake -E remove -f "llvm/lib/libLTO.so"
	@cmake -E rename "llvm/bin/clang-11" "llvm/bin/clang"
	@cmake -E rename "llvm/lib/libLTO.so.11git" "llvm/lib/libLTO.so"

llvm: llvm/bin/clang restore llvm/include/pstl
	@cmake -E copy src/llvm/clang/LICENSE.TXT llvm/share/clang/license.txt
	@cmake -E copy src/llvm/clang-tools-extra/LICENSE.TXT llvm/share/clang-tools-extra/license.txt
	@cmake -E copy src/llvm/openmp/LICENSE.TXT llvm/share/openmp/license.txt
	@cmake -E copy src/llvm/polly/LICENSE.TXT llvm/share/polly/license.txt
	@cmake -E copy src/llvm/llvm/LICENSE.TXT llvm/share/llvm/license.txt
	@cmake -E copy src/llvm/lld/LICENSE.TXT llvm/share/lld/license.txt
	@cmake -E copy src/llvm/lldb/LICENSE.TXT llvm/share/lldb/license.txt
	@cmake -E copy src/llvm/compiler-rt/LICENSE.TXT llvm/share/compiler-rt/license.txt
	@cmake -E copy src/llvm/libunwind/LICENSE.TXT llvm/share/libunwind/license.txt
	@cmake -E copy src/llvm/libcxxabi/LICENSE.TXT llvm/share/libcxxabi/license.txt
	@cmake -E copy src/llvm/libcxx/LICENSE.TXT llvm/share/libcxx/license.txt
	@cmake -E copy src/llvm/pstl/LICENSE.TXT llvm/share/pstl/license.txt
	@cmake -E copy src/tbb/LICENSE llvm/share/tbb/license.txt

# =================================================================================================
# tbb
# =================================================================================================

src/tbb.tar.gz:
	@cmake -E echo "Downloading tbb ..."
	@curl -L https://github.com/intel/tbb/archive/2019_U9.tar.gz -o src/tbb.tar.gz

src/tbb: src/tbb.tar.gz
	@cmake -E echo "Extracting tbb ..."
	@cmake -E make_directory src/tbb
	@tar xf src/tbb.tar.gz -C src/tbb --strip-components 1
	@cmake -E echo "Patching tbb ..."
	@cd src/tbb && git --work-tree=. --git-dir=.git apply ../tbb.patch --ignore-whitespace --whitespace=nowarn

llvm/include/tbb/version_string.ver: src/tbb
	@cd src/tbb/include && find tbb -name '*.h' -exec cmake -E copy "{}" "$(CURDIR)/llvm/include/{}" ";"
	@echo '#define __TBB_VERSION_STRINGS(N) "2019"' > llvm/include/tbb/version_string.ver

llvm/lib/libtbb.a: llvm/include/tbb/version_string.ver
	@cmake -P src/tbb.cmake
	@cmake -E copy build/tbb/libtbb.a llvm/lib/libtbb.a
	@cmake -E copy build/tbb/libtbbmalloc.a llvm/lib/libtbbmalloc.a
	@cmake -E copy src/TBBConfig.cmake llvm/lib/cmake/TBB/TBBConfig.cmake
	@cmake -E copy src/TBBConfigVersion.cmake llvm/lib/cmake/TBB/TBBConfigVersion.cmake
	@find llvm/include/tbb llvm/lib/libtbb*.a llvm/lib/cmake/TBB \
	  -type d -exec chmod 0755 '{}' ';' -or -type f -exec chmod 0644 '{}' ';'

# =================================================================================================
# pstl
# =================================================================================================

llvm/include/pstl: llvm/lib/libtbb.a
	@cmake -GNinja -Wno-dev \
	  -DCMAKE_BUILD_TYPE=Release \
	  -DCMAKE_INSTALL_PREFIX="$(CURDIR)/llvm" \
	  -DCMAKE_TOOLCHAIN_FILE="$(CURDIR)/linux.cmake" \
	  -DVCPKG_TARGET_TRIPLET="x64-linux" \
	  -DPSTL_PARALLEL_BACKEND="tbb" \
	  -B build/pstl src/llvm/pstl
	@cmake --build build/pstl --target install

# =================================================================================================
# package
# =================================================================================================

package: clean
	@cmake -E remove -f toolchain.7z
	@cd .. && 7z a -mx=9 -myx=9 -ms=2g toolchains/toolchains.7z \
	  toolchains/llvm \
	  toolchains/config.cmake \
	  toolchains/linux.cmake \
	  toolchains/make.cmd \
	  toolchains/makefile \
	  toolchains/readme.md \
	  toolchains/windows.cmake

# =================================================================================================
# clean
# =================================================================================================

clean:
	@cmake -E remove -f "llvm/bin/clang++"
	@cmake -E remove -f "llvm/bin/ld.lld"
	@cmake -E remove -f "llvm/bin/ld64.lld"
	@cmake -E remove -f "llvm/bin/llvm-ranlib"
	@cmake -E remove -f "llvm/bin/llvm-strip"

# =================================================================================================
# restore
# =================================================================================================

restore: clean
	@ln -s clang llvm/bin/clang++
	@ln -s lld llvm/bin/ld.lld
	@ln -s lld llvm/bin/ld64.lld
	@ln -s llvm-ar llvm/bin/llvm-ranlib
	@ln -s llvm-objcopy llvm/bin/llvm-strip
	find llvm -type d -exec chmod 0755 '{}' ';' -or -type f -exec chmod 0644 '{}' ';'
	find llvm/bin -type f -and -not -iname '*.dll' -exec chmod 0755 '{}' ';'

.PHONY: all llvm package clean restore
