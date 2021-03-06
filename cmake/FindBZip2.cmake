if(BZIP2_FOUND)
  return()
endif()

if(NOT BZIP2_INCLUDE_DIR)
  find_path(BZIP2_INCLUDE_DIR bzlib.h PATH_SUFFIXES include)

  set(BZIP2_INCLUDE_DIRS "${BZIP2_INCLUDE_DIR}")

  mark_as_advanced(
    BZIP2_INCLUDE_DIR
    BZIP2_INCLUDE_DIRS)
endif()

if(NOT BZIP2_LIBRARIES)
  include(SelectLibraryConfigurations)
  get_filename_component(BZIP2_ROOT_DIR ${BZIP2_INCLUDE_DIR} DIRECTORY)

  find_library(BZIP2_LIBRARY_RELEASE NAMES bz2 NAMES_PER_DIR
    NO_DEFAULT_PATH PATHS ${BZIP2_ROOT_DIR}/lib PATH_SUFFIXES lib)
  find_library(BZIP2_LIBRARY_DEBUG NAMES bz2 bz2d NAMES_PER_DIR
    NO_DEFAULT_PATH PATHS ${BZIP2_ROOT_DIR}/debug/lib PATH_SUFFIXES lib)

  select_library_configurations(BZIP2)

  mark_as_advanced(
    BZIP2_LIBRARY_RELEASE
    BZIP2_LIBRARY_DEBUG
    BZIP2_LIBRARIES)
endif()

if(NOT BZIP2_VERSION_STRING AND EXISTS "${BZIP2_INCLUDE_DIR}/bzlib.h")
  file(STRINGS "${BZIP2_INCLUDE_DIR}/bzlib.h" BZIP2_VERSION_STRING
    REGEX "bzip2/libbzip2 version [0-9]+\\.[^ ]+ of [0-9]+ ")

  string(REGEX REPLACE ".* bzip2/libbzip2 version ([0-9]+\\.[^ ]+) of [0-9]+ .*" "\\1"
    BZIP2_VERSION "${BZIP2_VERSION_STRING}")

  set(BZIP2_VERSION_STRING "${BZIP2_VERSION}")

  mark_as_advanced(
    BZIP2_VERSION
    BZIP2_VERSION_STRING)
endif()

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(BZip2
  REQUIRED_VARS
    BZIP2_INCLUDE_DIR
    BZIP2_LIBRARIES
    BZIP2_LIBRARY_RELEASE
    BZIP2_LIBRARY_DEBUG
  VERSION_VAR
    BZIP2_VERSION_STRING)

if(BZIP2_FOUND)
  include(CheckSymbolExists)
  include(CMakePushCheckState)
  cmake_push_check_state()
  set(CMAKE_REQUIRED_QUIET ${BZip2_FIND_QUIETLY})
  set(CMAKE_REQUIRED_INCLUDES ${BZIP2_INCLUDE_DIR})
  set(CMAKE_REQUIRED_LIBRARIES ${BZIP2_LIBRARIES})
  check_symbol_exists(BZ2_bzCompressInit "bzlib.h" BZIP2_NEED_PREFIX)
  cmake_pop_check_state()

  if(NOT TARGET BZip2::BZip2)
    add_library(BZip2::BZip2 UNKNOWN IMPORTED)
    set_target_properties(BZip2::BZip2 PROPERTIES
      INTERFACE_INCLUDE_DIRECTORIES "${BZIP2_INCLUDE_DIR}"
      IMPORTED_LINK_INTERFACE_LANGUAGES "C"
      IMPORTED_CONFIGURATIONS "DEBUG;RELEASE"
      IMPORTED_LOCATION_RELEASE "${BZIP2_LIBRARY_RELEASE}"
      IMPORTED_LOCATION_DEBUG "${BZIP2_LIBRARY_DEBUG}"
      MAP_IMPORTED_CONFIG_RELWITHDEBINFO Release
      MAP_IMPORTED_CONFIG_MINSIZEREL Release)
  endif()

  if(DEFINED CMAKE_BUILD_TYPE)
    if(CMAKE_BUILD_TYPE MATCHES "Debug")
      set(BZIP2_LIBRARY "${BZIP2_LIBRARY_DEBUG}")
    else()
      set(BZIP2_LIBRARY "${BZIP2_LIBRARY_RELEASE}")
    endif()
    set_property(TARGET BZip2::BZip2 APPEND PROPERTY
      IMPORTED_LOCATION "${BZIP2_LIBRARY}")
  else()
    set(BZIP2_LIBRARY "${BZIP2_LIBRARIES}")
  endif()
  mark_as_advanced(BZIP2_LIBRARY)
endif()
