# Remove unused projects.
foreach(directory .git debuginfo-tests libc libclc llgo parallel-libs)
  file(REMOVE_RECURSE ${CMAKE_CURRENT_LIST_DIR}/llvm/${directory})
endforeach()

# Remove unused tests.
foreach(directory clang clang-tools-extra compiler-rt libcxx libcxxabi lld lldb llvm)
  file(REMOVE_RECURSE ${CMAKE_CURRENT_LIST_DIR}/llvm/${directory}/test)
  file(REMOVE_RECURSE ${CMAKE_CURRENT_LIST_DIR}/llvm/${directory}/unittests)
endforeach()

# Remove unused files.
file(GLOB files LIST_DIRECTORIES OFF ${CMAKE_CURRENT_LIST_DIR}/llvm/*)
foreach(file ${files})
  file(REMOVE ${file})
endforeach()

# Patch libcxx.
file(READ "${CMAKE_CURRENT_LIST_DIR}/llvm/libcxx/src/CMakeLists.txt" LIBCXX_SRC_CMAKELISTS_TXT)

string(REPLACE
  " message(FATAL_ERROR \"Could not find ParallelSTL\")"
  " #message(FATAL_ERROR \"Could not find ParallelSTL\")"
  LIBCXX_SRC_CMAKELISTS_TXT "${LIBCXX_SRC_CMAKELISTS_TXT}")

string(REPLACE
  " target_link_libraries(\${name} PUBLIC pstl::ParallelSTL)"
  " #target_link_libraries(\${name} PUBLIC pstl::ParallelSTL)"
  LIBCXX_SRC_CMAKELISTS_TXT "${LIBCXX_SRC_CMAKELISTS_TXT}")

file(WRITE "${CMAKE_CURRENT_LIST_DIR}/llvm/libcxx/src/CMakeLists.txt" "${LIBCXX_SRC_CMAKELISTS_TXT}")
