if(ZLIB_FOUND)
  return()
endif()

if(NOT ZLIB_INCLUDE_DIR)
  find_path(ZLIB_INCLUDE_DIR zlib.h PATH_SUFFIXES include)

  set(ZLIB_INCLUDE_DIRS "${ZLIB_INCLUDE_DIR}")

  mark_as_advanced(
    ZLIB_INCLUDE_DIR
    ZLIB_INCLUDE_DIRS)
endif()

if(NOT ZLIB_LIBRARIES)
  include(SelectLibraryConfigurations)
  get_filename_component(ZLIB_ROOT_DIR ${ZLIB_INCLUDE_DIR} DIRECTORY)

  find_library(ZLIB_LIBRARY_RELEASE NAMES z zlib NAMES_PER_DIR
    NO_DEFAULT_PATH PATHS ${ZLIB_ROOT_DIR}/lib PATH_SUFFIXES lib)
  find_library(ZLIB_LIBRARY_DEBUG NAMES z zd zlib zlibd NAMES_PER_DIR
    NO_DEFAULT_PATH PATHS ${ZLIB_ROOT_DIR}/debug/lib PATH_SUFFIXES lib)

  select_library_configurations(ZLIB)

  mark_as_advanced(
    ZLIB_LIBRARY_RELEASE
    ZLIB_LIBRARY_DEBUG
    ZLIB_LIBRARIES)
endif()

if(NOT ZLIB_VERSION_STRING AND EXISTS "${ZLIB_INCLUDE_DIR}/zlib.h")
  file(STRINGS "${ZLIB_INCLUDE_DIR}/zlib.h" ZLIB_VERSION_STRING
    REGEX "^#define ZLIB_VERSION \"[^\"]*\"$")

  string(REGEX REPLACE "^.*ZLIB_VERSION \"([0-9]+).*$" "\\1"
    ZLIB_VERSION_MAJOR "${ZLIB_VERSION_STRING}")
  string(REGEX REPLACE "^.*ZLIB_VERSION \"[0-9]+\\.([0-9]+).*$" "\\1"
    ZLIB_VERSION_MINOR  "${ZLIB_VERSION_STRING}")
  string(REGEX REPLACE "^.*ZLIB_VERSION \"[0-9]+\\.[0-9]+\\.([0-9]+).*$" "\\1"
    ZLIB_VERSION_PATCH "${ZLIB_VERSION_STRING}")

  set(ZLIB_VERSION "${ZLIB_VERSION_MAJOR}.${ZLIB_VERSION_MINOR}.${ZLIB_VERSION_PATCH}")
  set(ZLIB_VERSION_STRING "${ZLIB_VERSION}")

  mark_as_advanced(
    ZLIB_VERSION
    ZLIB_VERSION_STRING)  
endif()

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(ZLIB
  REQUIRED_VARS
    ZLIB_INCLUDE_DIR
    ZLIB_LIBRARIES
    ZLIB_LIBRARY_RELEASE
    ZLIB_LIBRARY_DEBUG
  VERSION_VAR
    ZLIB_VERSION_STRING)

if(ZLIB_FOUND)
  if(NOT TARGET ZLIB::ZLIB)
    add_library(ZLIB::ZLIB UNKNOWN IMPORTED)
    set_target_properties(ZLIB::ZLIB PROPERTIES
      INTERFACE_INCLUDE_DIRECTORIES "${ZLIB_INCLUDE_DIR}"
      IMPORTED_LINK_INTERFACE_LANGUAGES "C"
      IMPORTED_CONFIGURATIONS "DEBUG;RELEASE"
      IMPORTED_LOCATION_RELEASE "${ZLIB_LIBRARY_RELEASE}"
      IMPORTED_LOCATION_DEBUG "${ZLIB_LIBRARY_DEBUG}"
      MAP_IMPORTED_CONFIG_RELWITHDEBINFO Release
      MAP_IMPORTED_CONFIG_MINSIZEREL Release)
  endif()

  if(DEFINED CMAKE_BUILD_TYPE)
    if(CMAKE_BUILD_TYPE MATCHES "Debug")
      set(ZLIB_LIBRARY "${ZLIB_LIBRARY_DEBUG}")
    else()
      set(ZLIB_LIBRARY "${ZLIB_LIBRARY_RELEASE}")
    endif()
    set_property(TARGET ZLIB::ZLIB APPEND PROPERTY
      IMPORTED_LOCATION "${ZLIB_LIBRARY}")
  else()
    set(ZLIB_LIBRARY "${ZLIB_LIBRARIES}")
  endif()
  mark_as_advanced(ZLIB_LIBRARY)
endif()
