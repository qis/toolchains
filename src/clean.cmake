foreach(directory .git debuginfo-tests libc libclc llgo parallel-libs)
  file(REMOVE_RECURSE ${CMAKE_CURRENT_LIST_DIR}/llvm/${directory})
endforeach()

foreach(directory clang clang-tools-extra compiler-rt libcxx libcxxabi lld lldb llvm)
  file(REMOVE_RECURSE ${CMAKE_CURRENT_LIST_DIR}/llvm/${directory}/test)
endforeach()

file(GLOB files LIST_DIRECTORIES OFF ${CMAKE_CURRENT_LIST_DIR}/llvm/*)
foreach(file ${files})
  file(REMOVE ${file})
endforeach()
