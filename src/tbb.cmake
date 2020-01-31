include(config.cmake)

set(OPT_FLAGS "-Os -DNDEBUG -fPIC")
foreach(FLAG ${LLVM_ARCHITECTURE})
  string(APPEND OPT_FLAGS " ${FLAG}")
endforeach()
string(APPEND OPT_FLAGS " -D_LIBCPP_CONFIG_SITE -D_LIBCPP_HAS_MERGED_TYPEINFO_NAMES_DEFAULT=0")
string(APPEND OPT_FLAGS " -Werror -Wno-deprecated-volatile")

set(ENV{CC} "../../llvm/bin/clang -std=c11 ${VCPKG_C_FLAGS} ${OPT_FLAGS}")
set(ENV{CXX} "../../llvm/bin/clang++ -std=c++2a ${VCPKG_CXX_FLAGS} ${OPT_FLAGS}")

file(REMOVE_RECURSE build/tbb)
file(MAKE_DIRECTORY build/tbb)

execute_process(COMMAND make -C build/tbb -f ../../src/tbb/build/Makefile.tbb
  tbb_root=../../src/tbb tbb_build_dir=. extra_inc=big_iron.inc compiler=clang
  arch=intel64 stdver=c++2a stdlib=libc++ cfg=release)

execute_process(COMMAND make -C build/tbb -f ../../src/tbb/build/Makefile.tbbmalloc
  tbb_root=../../src/tbb tbb_build_dir=. extra_inc=big_iron.inc compiler=clang
  arch=intel64 stdver=c++2a stdlib=libc++ cfg=release malloc)
