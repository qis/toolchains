cmake_minimum_required(VERSION 3.16 FATAL_ERROR)
project(tbb VERSION 2020.1 LANGUAGES CXX)

if(WIN32)
  enable_language(ASM_MASM)
endif()

file(WRITE ${CMAKE_CURRENT_BINARY_DIR}/version_string.ver
  "#define __TBB_VERSION_STRINGS(N) \"${PROJECT_VERSION}\"\n")

# =================================================================================================
# tbb
# =================================================================================================

add_library(tbb
  src/tbb/concurrent_hash_map.cpp
  src/tbb/concurrent_queue.cpp
  src/tbb/concurrent_vector.cpp
  src/tbb/dynamic_link.cpp
  src/tbb/itt_notify.cpp
  src/tbb/cache_aligned_allocator.cpp
  src/tbb/pipeline.cpp
  src/tbb/queuing_mutex.cpp
  src/tbb/queuing_rw_mutex.cpp
  src/tbb/reader_writer_lock.cpp
  src/tbb/spin_rw_mutex.cpp
  src/tbb/x86_rtm_rw_mutex.cpp
  src/tbb/spin_mutex.cpp
  src/tbb/critical_section.cpp
  src/tbb/mutex.cpp
  src/tbb/recursive_mutex.cpp
  src/tbb/condition_variable.cpp
  src/tbb/tbb_thread.cpp
  src/tbb/concurrent_monitor.cpp
  src/tbb/semaphore.cpp
  src/tbb/private_server.cpp
  src/rml/client/rml_tbb.cpp
  src/tbb/tbb_misc.cpp
  src/tbb/tbb_misc_ex.cpp
  src/tbb/task.cpp
  src/tbb/task_group_context.cpp
  src/tbb/governor.cpp
  src/tbb/market.cpp
  src/tbb/arena.cpp
  src/tbb/scheduler.cpp
  src/tbb/observer_proxy.cpp
  src/tbb/tbb_statistics.cpp
  src/tbb/tbb_main.cpp
  src/old/concurrent_vector_v2.cpp
  src/old/concurrent_queue_v2.cpp
  src/old/spin_rw_mutex_v2.cpp
  src/old/task_v2.cpp)

target_compile_definitions(tbb PRIVATE __TBB_BUILD=1 PUBLIC __TBB_NO_IMPLICIT_LINKAGE=1)
target_include_directories(tbb PRIVATE ${CMAKE_CURRENT_BINARY_DIR} src src/rml/include)
target_include_directories(tbb PUBLIC
  $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include>
  $<INSTALL_INTERFACE:include>)

if(WIN32)
  if(CMAKE_SIZEOF_VOID_P STREQUAL 4)
    target_sources(tbb PRIVATE
      src/tbb/ia32-masm/atomic_support.asm
      src/tbb/ia32-masm/lock_byte.asm
      src/tbb/ia32-masm/itsx.asm)
  else()
    target_sources(tbb PRIVATE
      src/tbb/intel64-masm/atomic_support.asm
      src/tbb/intel64-masm/intel64_misc.asm
      src/tbb/intel64-masm/itsx.asm)
  endif()
else()
  set(THREADS_PREFER_PTHREAD_FLAG ON)
  find_package(Threads REQUIRED)
  target_link_libraries(tbb PRIVATE Threads::Threads)
endif()

# =================================================================================================
# tbbmalloc
# =================================================================================================

add_library(tbbmalloc
  src/tbbmalloc/backend.cpp
  src/tbbmalloc/large_objects.cpp
  src/tbbmalloc/backref.cpp
  src/tbbmalloc/tbbmalloc.cpp
  src/tbb/itt_notify.cpp
  src/tbbmalloc/frontend.cpp)

target_include_directories(tbbmalloc PRIVATE ${CMAKE_CURRENT_BINARY_DIR} src src/rml/include src/tbbmalloc)
target_compile_definitions(tbbmalloc PRIVATE __TBBMALLOC_BUILD=1 PUBLIC __TBBMALLOC_NO_IMPLICIT_LINKAGE=1)
target_link_libraries(tbbmalloc PUBLIC tbb)

if(WIN32)
  if(CMAKE_SIZEOF_VOID_P STREQUAL 4)
    target_sources(tbbmalloc PRIVATE
      src/tbb/ia32-masm/atomic_support.asm)
  else()
    target_sources(tbbmalloc PRIVATE
      src/tbb/intel64-masm/atomic_support.asm)
  endif()
endif()

# =================================================================================================
# tbbmalloc_proxy
# =================================================================================================

set(tbb_libraries tbb tbbmalloc)
if(BUILD_SHARED_LIBS)
  list(APPEND tbb_libraries tbbmalloc_proxy)

  add_library(tbbmalloc_proxy
    src/tbbmalloc/proxy.cpp
    src/tbbmalloc/tbb_function_replacement.cpp)

  target_compile_definitions(tbbmalloc_proxy PRIVATE __TBBMALLOC_BUILD=1)
  target_include_directories(tbbmalloc_proxy PRIVATE ${CMAKE_CURRENT_BINARY_DIR} src src/rml/include src/tbbmalloc)
  target_link_libraries(tbbmalloc_proxy PUBLIC tbbmalloc)
endif()

# =================================================================================================
# export
# =================================================================================================

if(BUILD_SHARED_LIBS)
  if(WIN32)
    if(CMAKE_SIZEOF_VOID_P STREQUAL 4)
      set(tbb_def ${CMAKE_CURRENT_SOURCE_DIR}/src/tbb/win32-tbb-export.def)
      set(tbbmalloc_def ${CMAKE_CURRENT_SOURCE_DIR}/src/tbbmalloc/win32-tbbmalloc-export.def)
    else()
      set(tbb_def ${CMAKE_CURRENT_SOURCE_DIR}/src/tbb/win64-tbb-export.def)
      set(tbbmalloc_def ${CMAKE_CURRENT_SOURCE_DIR}/src/tbbmalloc/win64-tbbmalloc-export.def)
    endif()
  else()
    if(CMAKE_SIZEOF_VOID_P STREQUAL 4)
      set(tbb_def ${CMAKE_CURRENT_SOURCE_DIR}/src/tbb/lin32-tbb-export.def)
      set(tbbmalloc_def ${CMAKE_CURRENT_SOURCE_DIR}/src/tbbmalloc/lin32-tbbmalloc-export.def)
      if(BUILD_SHARED_LIBS)
        set(tbbmalloc_proxy_def ${CMAKE_CURRENT_SOURCE_DIR}/src/tbbmalloc/lin32-proxy-export.def)
      endif()
    else()
      set(tbb_def ${CMAKE_CURRENT_SOURCE_DIR}/src/tbb/lin64-tbb-export.def)
      set(tbbmalloc_def ${CMAKE_CURRENT_SOURCE_DIR}/src/tbbmalloc/lin64-tbbmalloc-export.def)
      if(BUILD_SHARED_LIBS)
        set(tbbmalloc_proxy_def ${CMAKE_CURRENT_SOURCE_DIR}/src/tbbmalloc/lin64-proxy-export.def)
      endif()
    endif()
  endif()
else()
  target_compile_definitions(tbb PRIVATE __TBB_DYNAMIC_LOAD_ENABLED=0)
  target_compile_definitions(tbbmalloc PRIVATE __TBB_DYNAMIC_LOAD_ENABLED=0)
endif()

# =================================================================================================
# common definitions and codegen
# =================================================================================================

foreach(lib ${tbb_libraries})
  if(WITH_PSTL)
    target_compile_definitions(${lib} PRIVATE _LIBCPP_CONFIG_SITE _LIBCPP_HAS_MERGED_TYPEINFO_NAMES_DEFAULT=0)
  endif()

  target_compile_definitions(${lib} PRIVATE $<$<CONFIG:DEBUG>:TBB_USE_DEBUG>)
  target_compile_definitions(${lib} PRIVATE TBB_SUPPRESS_DEPRECATED_MESSAGES=1 DO_ITT_NOTIFY)

  if(WIN32)
    if(BUILD_SHARED_LIBS)
      target_compile_definitions(${lib} PRIVATE _WINDLL)
    endif()
    target_compile_definitions(${lib} PRIVATE _CRT_SECURE_NO_DEPRECATE _WIN32_WINNT=0x0502 __TBB_LIB_NAME=tbb.lib)
    target_compile_definitions(${lib} PRIVATE USE_WINTHREAD)
  else()
    target_compile_definitions(${lib} PRIVATE USE_PTHREAD)
  endif()

  if(DEFINED ${lib}_def)
    get_target_property(compile_definitions ${lib} COMPILE_DEFINITIONS)
    if(WIN32)
      set(compile_flags "/nologo;/TC;/EP")
      foreach(flag ${tbb_compile_definitions})
        list(APPEND compile_flags "/D${flag}")
      endforeach()
      list(APPEND compile_flags /I"${CMAKE_CURRENT_SOURCE_DIR}/include")
      list(APPEND compile_flags /I"${CMAKE_CURRENT_SOURCE_DIR}/src")
    else()
      set(compile_flags "-E;-x;c++")
      foreach(flag ${tbb_compile_definitions})
        list(APPEND compile_flags "-D${flag}")
      endforeach()
      list(APPEND compile_flags -I"${CMAKE_CURRENT_SOURCE_DIR}/include")
      list(APPEND compile_flags -I"${CMAKE_CURRENT_SOURCE_DIR}/src")
    endif()
    add_custom_command(COMMENT "Generating export files..."
      DEPENDS ${${lib}_def} OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/${lib}.def
      COMMAND ${CMAKE_CXX_COMPILER} ${compile_flags} ${${lib}_def} > ${CMAKE_CURRENT_BINARY_DIR}/${lib}.def
      COMMAND_EXPAND_LISTS)
    target_sources(${lib} PRIVATE ${CMAKE_CURRENT_BINARY_DIR}/${lib}.def)
  endif()
endforeach()

# =================================================================================================
# install
# =================================================================================================

install(TARGETS ${tbb_libraries} EXPORT tbb
  RUNTIME DESTINATION bin
  LIBRARY DESTINATION lib
  ARCHIVE DESTINATION lib)

install(EXPORT tbb FILE TBBTargets.cmake NAMESPACE TBB:: DESTINATION lib/cmake/TBB)

include(CMakePackageConfigHelpers)

configure_package_config_file(TBBConfig.cmake.in ${CMAKE_CURRENT_BINARY_DIR}/TBBConfig.cmake
  INSTALL_DESTINATION lib/cmake/TBB)

write_basic_package_version_file(${CMAKE_CURRENT_BINARY_DIR}/TBBConfigVersion.cmake
  VERSION ${PROJECT_VERSION} COMPATIBILITY AnyNewerVersion)

install(FILES
  ${CMAKE_CURRENT_BINARY_DIR}/TBBConfig.cmake
  ${CMAKE_CURRENT_BINARY_DIR}/TBBConfigVersion.cmake
  DESTINATION lib/cmake/TBB)

if(NOT SKIP_INSTALL_HEADERS)
  install(DIRECTORY include/tbb DESTINATION include)
endif()
