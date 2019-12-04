# Remove unused projects.
foreach(directory .git debuginfo-tests libc libclc llgo parallel-libs)
  file(REMOVE_RECURSE ${CMAKE_CURRENT_LIST_DIR}/llvm/${directory})
endforeach()

# Remove unused tests.
foreach(directory clang clang-tools-extra compiler-rt libcxx libcxxabi lldb)
  file(REMOVE_RECURSE ${CMAKE_CURRENT_LIST_DIR}/llvm/${directory}/test)
endforeach()

# Replace tests.
file(REMOVE_RECURSE ${CMAKE_CURRENT_LIST_DIR}/llvm/lld/test)
file(REMOVE_RECURSE ${CMAKE_CURRENT_LIST_DIR}/llvm/llvm/test)
file(REMOVE_RECURSE ${CMAKE_CURRENT_LIST_DIR}/llvm/llvm/unittests)

file(MAKE_DIRECTORY ${CMAKE_CURRENT_LIST_DIR}/llvm/lld/test)
file(MAKE_DIRECTORY ${CMAKE_CURRENT_LIST_DIR}/llvm/llvm/test)
file(MAKE_DIRECTORY ${CMAKE_CURRENT_LIST_DIR}/llvm/llvm/unittests)

file(WRITE ${CMAKE_CURRENT_LIST_DIR}/llvm/lld/test/CMakeLists.txt "")
file(WRITE ${CMAKE_CURRENT_LIST_DIR}/llvm/llvm/test/CMakeLists.txt "")
file(WRITE ${CMAKE_CURRENT_LIST_DIR}/llvm/llvm/unittests/CMakeLists.txt "")

# Remove unused files.
file(GLOB files LIST_DIRECTORIES OFF ${CMAKE_CURRENT_LIST_DIR}/llvm/*)
foreach(file ${files})
  file(REMOVE ${file})
endforeach()

# Patch libcxx.
file(READ "${CMAKE_CURRENT_LIST_DIR}/llvm/libcxx/CMakeLists.txt" LIBCXX_CMAKELISTS_TXT)

string(REPLACE
  "/FI\\\"\${site_config_path}\\\""
  "-include\${site_config_path}"
  LIBCXX_CMAKELISTS_TXT "${LIBCXX_CMAKELISTS_TXT}")

file(WRITE "${CMAKE_CURRENT_LIST_DIR}/llvm/libcxx/CMakeLists.txt" "${LIBCXX_CMAKELISTS_TXT}")
