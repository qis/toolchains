ifeq ($(OS),Windows_NT)
all: llvm/bin/clang.exe
else
all: llvm/include/pstl
endif

# =================================================================================================
# llvm
# =================================================================================================

ifeq ($(OS),Windows_NT)

src/llvm:
	@if exist src/llvm.7z ( 7z x src/llvm.7z -osrc ) else \
	  ( git clone --depth 1 --filter=blob:none https://github.com/llvm/llvm-project src/llvm )
	@cmake -P src/clean.cmake

build/msvc/CMakeCache.txt: src/llvm
	@cmake -GNinja -DCMAKE_BUILD_TYPE=MinSizeRel -Wno-dev \
	  -DCMAKE_INSTALL_PREFIX="$(CURDIR)/llvm" \
	  -DLLVM_ENABLE_PROJECTS="clang;clang-tools-extra;polly;lld" \
	  -DLLVM_TARGETS_TO_BUILD="X86" \
	  -DLLVM_ENABLE_BACKTRACES=OFF \
	  -DLLVM_ENABLE_UNWIND_TABLES=OFF \
	  -DLLVM_ENABLE_WARNINGS=OFF \
	  -DLLVM_ENABLE_RTTI=OFF \
	  -DLLVM_INCLUDE_BENCHMARKS=OFF \
	  -DLLVM_INCLUDE_EXAMPLES=OFF \
	  -DLLVM_INCLUDE_TESTS=OFF \
	  -DLLVM_INCLUDE_DOCS=OFF \
	  -DCLANG_ENABLE_ARCMT=OFF \
	  -DCLANG_ENABLE_STATIC_ANALYZER=OFF \
	  -DCLANG_DEFAULT_STD_C="c99" \
	  -DCLANG_DEFAULT_STD_CXX="cxx2a" \
	  -DCLANG_DEFAULT_LINKER="lld" \
	  -DCLANG_PLUGIN_SUPPORT=OFF \
	  -B build/msvc src/llvm/llvm

llvm/bin/clang.exe: build/msvc/CMakeCache.txt
	@cmake --build build/msvc -t \
	  install-clang-stripped \
	  install-clang-format-stripped \
	  install-clang-resource-headers \
	  install-llvm-ar-stripped \
	  install-lld-stripped \
	  install-LTO-stripped
	@cmake -E remove -f "llvm/bin/ld.lld.exe"
	@cmake -E remove -f "llvm/bin/ld64.lld.exe"
	@cmake -E remove -f "llvm/bin/lld-link.exe"
	@cmake -E remove -f "llvm/bin/wasm-ld.exe"
	@cmake -E remove -f "llvm/bin/clang++.exe"
	@cmake -E remove -f "llvm/bin/clang-cl.exe"
	@cmake -E remove -f "llvm/bin/clang-cpp.exe"
	@cmake -E remove -f "llvm/bin/llvm-ranlib.exe"
	@cmd /c mklink "llvm\bin\clang++.exe" "clang.exe"
	@cmd /c mklink "llvm\bin\clang-cl.exe" "clang.exe"
	@cmd /c mklink "llvm\bin\llvm-ranlib.exe" "llvm-ar.exe"
	@cmd /c mklink "llvm\bin\lld-link.exe" "lld.exe"

else

src/llvm:
	@if [ -f src/llvm.7z ]; then 7z x src/llvm.7z -osrc; else \
	  git clone --depth 1 --filter=blob:none https://github.com/llvm/llvm-project src/llvm; \
	fi
	@cmake -P src/clean.cmake

build/llvm/CMakeCache.txt: src/llvm
	@cmake -GNinja -DCMAKE_BUILD_TYPE=MinSizeRel -Wno-dev \
	  -DCMAKE_INSTALL_PREFIX="$(CURDIR)/llvm" \
	  -DLLVM_ENABLE_PROJECTS="lld;lldb;polly;clang;clang-tools-extra;compiler-rt;libunwind;libcxxabi;libcxx;openmp" \
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
	  -DCLANG_DEFAULT_STD_C="c99" \
	  -DCLANG_DEFAULT_STD_CXX="cxx2a" \
	  -DCLANG_DEFAULT_CXX_STDLIB="libc++" \
	  -DCLANG_DEFAULT_UNWINDLIB="libunwind" \
	  -DCLANG_DEFAULT_RTLIB="compiler-rt" \
	  -DCLANG_DEFAULT_LINKER="lld" \
	  -DCLANG_PLUGIN_SUPPORT=OFF \
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
	  -DLIBCXX_ENABLE_PARALLEL_ALGORITHMS=OFF \
	  -DLIBCXX_INCLUDE_BENCHMARKS=OFF \
	  -DOPENMP_ENABLE_LIBOMPTARGET=OFF \
	  -B build/llvm src/llvm/llvm

llvm/bin/clang: build/llvm/CMakeCache.txt
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
	  install-cxx-stripped \
	  llvm-config

endif

# =================================================================================================
# tbb
# =================================================================================================

src/tbb.tar.gz:
	@curl -L https://github.com/intel/tbb/archive/2019_U9.tar.gz -o src/tbb.tar.gz

src/tbb: src/tbb.tar.gz
	@mkdir -p src/tbb
	@tar xf src/tbb.tar.gz -C src/tbb --strip-components 1
	@patch -p1 < src/tbb.patch

llvm/lib/cmake/TBB/TBBConfig.cmake: llvm/bin/clang src/tbb
	@rm -rf src/tbb/build/*_debug src/tbb/build/*_release
	@cd src/tbb && \
	  CC="$(CURDIR)/llvm/bin/clang -fasm -fomit-frame-pointer -fmerge-all-constants" \
	  CXX="$(CURDIR)/llvm/bin/clang++ -fasm -fomit-frame-pointer -fmerge-all-constants -Werror -Wno-deprecated-volatile" \
	  make extra_inc=big_iron.inc compiler=clang arch=intel64 stdver=c++2a stdlib=libc++ tbb tbbmalloc
	@mkdir -p llvm/include llvm/lib/cmake/TBB
	@cp -R src/tbb/include/tbb llvm/include/
	@cp -R src/tbb/build/*_release/libtbb*.a llvm/lib/
	@cp -R src/TBBConfig.cmake src/TBBConfigVersion.cmake llvm/lib/cmake/TBB/
	@find llvm/include/tbb llvm/lib/libtbb*.a llvm/lib/cmake/TBB \
	  -type d -exec chmod 0755 '{}' ';' -or -type f -exec chmod 0644 '{}' ';'

# =================================================================================================
# pstl
# =================================================================================================

build/pstl/CMakeCache.txt: llvm/lib/cmake/TBB/TBBConfig.cmake
	@cmake -GNinja -DCMAKE_BUILD_TYPE=MinSizeRel -Wno-dev \
	  -DCMAKE_PREFIX_PATH="$(CURDIR)/llvm" \
	  -DCMAKE_INSTALL_PREFIX="$(CURDIR)/llvm" \
	  -DCMAKE_C_COMPILER="$(CURDIR)/llvm/bin/clang" \
	  -DCMAKE_CXX_COMPILER="$(CURDIR)/llvm/bin/clang++" \
	  -DCMAKE_C_FLAGS="-std=c11 -fasm -fomit-frame-pointer -fmerge-all-constants" \
	  -DCMAKE_CXX_FLAGS="-std=c++2a -fasm -fomit-frame-pointer -fmerge-all-constants" \
	  -DCMAKE_SHARED_LINKER_FLAGS="-pthread -lc++abi -ldl" \
	  -DCMAKE_EXE_LINKER_FLAGS="-pthread -lc++abi -ldl" \
	  -DLLVM_ENABLE_PROJECTS="libunwind;libcxxabi;libcxx;pstl" \
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
	  -DLIBCXX_ENABLE_PARALLEL_ALGORITHMS=ON \
	  -DLIBCXX_INCLUDE_BENCHMARKS=OFF \
	  -DLIBCXX_USE_COMPILER_RT=ON \
	  -DPSTL_PARALLEL_BACKEND="tbb" \
	  -B build/pstl src/llvm/llvm

llvm/include/pstl: build/pstl/CMakeCache.txt
	@cmake --build build/pstl -t install-unwind-stripped
	@cmake --build build/pstl -t install-cxxabi-stripped
	@cmake --build build/pstl -t install-cxx-stripped
	@cmake --build build/pstl -t install-pstl

# =================================================================================================
# test
# =================================================================================================

test: llvm/include/pstl
	@llvm/bin/clang++ -std=c++2a -Os -flto=full -fwhole-program-vtables -fvirtual-function-elimination \
	  -fasm -fopenmp-simd -fomit-frame-pointer -fmerge-all-constants -fdiagnostics-absolute-paths -fPIC \
	  -isystem llvm/include src/test-filesystem.cpp -o build/test-filesystem \
	  -Xlinker -plugin-opt=O3 -Wl,-S -pthread -lc++abi -ltbb
	@llvm/bin/llvm-strip build/test-filesystem
	@build/test-filesystem
	@llvm/bin/clang++ -std=c++2a -Os -flto=full -fwhole-program-vtables -fvirtual-function-elimination \
	  -fasm -fopenmp-simd -fomit-frame-pointer -fmerge-all-constants -fdiagnostics-absolute-paths -fPIC \
	  -isystem llvm/include src/test-pstl.cpp -o build/test-pstl \
	  -Xlinker -plugin-opt=O3 -Wl,-S -pthread -lc++abi -ltbb
	@llvm/bin/llvm-strip build/test-pstl
	@build/test-pstl
	@llvm/bin/clang++ -std=c++2a -Os -flto=full -fwhole-program-vtables -fvirtual-function-elimination \
	  -fasm -fopenmp-simd -fomit-frame-pointer -fmerge-all-constants -fdiagnostics-absolute-paths -fPIC \
	  -isystem llvm/include src/test-re.cpp -o build/test-re \
	  -Xlinker -plugin-opt=O3 -Wl,-S -pthread -lc++abi -ltbb
	@llvm/bin/llvm-strip build/test-re
	@build/test-re

# =================================================================================================
# clean
# =================================================================================================

clean:
	cmake -E remove_directory build
	cmake -E remove_directory src/tbb
	cmake -E remove_directory src/llvm

.PHONY: all test clean
