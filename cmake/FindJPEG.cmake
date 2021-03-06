if(JPEG_FOUND)
  return()
endif()

if(NOT JPEG_INCLUDE_DIR)
  find_path(JPEG_INCLUDE_DIR jpeglib.h PATH_SUFFIXES include)

  set(JPEG_INCLUDE_DIRS "${JPEG_INCLUDE_DIR}")

  mark_as_advanced(
    JPEG_INCLUDE_DIR
    JPEG_INCLUDE_DIRS)
endif()

if(NOT JPEG_LIBRARIES)
  include(SelectLibraryConfigurations)
  get_filename_component(JPEG_ROOT_DIR ${JPEG_INCLUDE_DIR} DIRECTORY)

  find_library(JPEG_LIBRARY_RELEASE NAMES jpeg NAMES_PER_DIR
    NO_DEFAULT_PATH PATHS ${JPEG_ROOT_DIR}/lib PATH_SUFFIXES lib)
  find_library(JPEG_LIBRARY_DEBUG NAMES jpeg jpegd NAMES_PER_DIR
    NO_DEFAULT_PATH PATHS ${JPEG_ROOT_DIR}/debug/lib PATH_SUFFIXES lib)

  select_library_configurations(JPEG)

  mark_as_advanced(
    JPEG_LIBRARY_RELEASE
    JPEG_LIBRARY_DEBUG
    JPEG_LIBRARIES)
endif()

if(NOT JPEG_VERSION_STRING AND EXISTS "${JPEG_INCLUDE_DIR}/jconfig.h")
  file(STRINGS "${JPEG_INCLUDE_DIR}/jconfig.h" JPEG_VERSION_STRING
    REGEX "^#define[\t ]+JPEG_LIB_VERSION[\t ]+.*")

  string(REGEX REPLACE "^#define[\t ]+JPEG_LIB_VERSION[\t ]+([0-9]+).*" "\\1"
    JPEG_VERSION "${JPEG_VERSION_STRING}")

  set(JPEG_VERSION_STRING "${JPEG_VERSION}")

  mark_as_advanced(
    JPEG_VERSION
    JPEG_VERSION_STRING)
endif()

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(JPEG
  REQUIRED_VARS
    JPEG_INCLUDE_DIR
    JPEG_LIBRARIES
    JPEG_LIBRARY_RELEASE
    JPEG_LIBRARY_DEBUG
  VERSION_VAR
    JPEG_VERSION_STRING)

if(JPEG_FOUND)
  if(NOT TARGET JPEG::JPEG)
    add_library(JPEG::JPEG UNKNOWN IMPORTED)
    set_target_properties(JPEG::JPEG PROPERTIES
      INTERFACE_INCLUDE_DIRECTORIES "${JPEG_INCLUDE_DIR}"
      IMPORTED_LINK_INTERFACE_LANGUAGES "C"
      IMPORTED_CONFIGURATIONS "DEBUG;RELEASE"
      IMPORTED_LOCATION_RELEASE "${JPEG_LIBRARY_RELEASE}"
      IMPORTED_LOCATION_DEBUG "${JPEG_LIBRARY_DEBUG}"
      MAP_IMPORTED_CONFIG_RELWITHDEBINFO Release
      MAP_IMPORTED_CONFIG_MINSIZEREL Release)
  endif()

  if(DEFINED CMAKE_BUILD_TYPE)
    if(CMAKE_BUILD_TYPE MATCHES "Debug")
      set(JPEG_LIBRARY "${JPEG_LIBRARY_DEBUG}")
    else()
      set(JPEG_LIBRARY "${JPEG_LIBRARY_RELEASE}")
    endif()
    set_property(TARGET JPEG::JPEG APPEND PROPERTY
      IMPORTED_LOCATION "${JPEG_LIBRARY}")
  else()
    set(JPEG_LIBRARY "${JPEG_LIBRARIES}")
  endif()
  mark_as_advanced(JPEG_LIBRARY)
endif()
