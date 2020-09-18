if(JPEGTURBO_FOUND)
  return()
endif()

if(NOT JPEGTURBO_INCLUDE_DIR)
  find_path(JPEGTURBO_INCLUDE_DIR turbojpeg.h PATH_SUFFIXES include)

  set(JPEGTURBO_INCLUDE_DIRS "${JPEGTURBO_INCLUDE_DIR}")

  mark_as_advanced(
    JPEGTURBO_INCLUDE_DIR
    JPEGTURBO_INCLUDE_DIRS)
endif()  

if(NOT JPEGTURBO_LIBRARIES)
  include(SelectLibraryConfigurations)
  get_filename_component(JPEGTURBO_ROOT_DIR ${JPEGTURBO_INCLUDE_DIR} DIRECTORY)

  find_library(JPEGTURBO_LIBRARY_RELEASE NAMES turbojpeg NAMES_PER_DIR
    NO_DEFAULT_PATH PATHS ${JPEGTURBO_ROOT_DIR}/lib PATH_SUFFIXES lib)
  find_library(JPEGTURBO_LIBRARY_DEBUG NAMES turbojpeg turbojpegd NAMES_PER_DIR
    NO_DEFAULT_PATH PATHS ${JPEGTURBO_ROOT_DIR}/debug/lib PATH_SUFFIXES lib)

  select_library_configurations(JPEGTURBO)

  mark_as_advanced(
    JPEGTURBO_LIBRARY_RELEASE
    JPEGTURBO_LIBRARY_DEBUG
    JPEGTURBO_LIBRARIES)
endif()

if(NOT JPEGTURBO_VERSION_STRING AND EXISTS "${JPEGTURBO_INCLUDE_DIR}/jconfig.h")
  file(STRINGS "${JPEGTURBO_INCLUDE_DIR}/jconfig.h" JPEGTURBO_VERSION_STRING
    REGEX "^#define[\t ]+JPEG_LIB_VERSION[\t ]+.*")

  string(REGEX REPLACE "^#define[\t ]+JPEG_LIB_VERSION[\t ]+([0-9]+).*" "\\1"
    JPEGTURBO_VERSION "${JPEGTURBO_VERSION_STRING}")

  set(JPEGTURBO_VERSION_STRING "${JPEGTURBO_VERSION}")

  mark_as_advanced(
    JPEGTURBO_VERSION
    JPEGTURBO_VERSION_STRING)  
endif()

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(JPEGTURBO
  REQUIRED_VARS
    JPEGTURBO_INCLUDE_DIR
    JPEGTURBO_LIBRARIES
    JPEGTURBO_LIBRARY_RELEASE
    JPEGTURBO_LIBRARY_DEBUG
  VERSION_VAR
    JPEGTURBO_VERSION_STRING)

if(JPEGTURBO_FOUND)
  if(NOT TARGET JPEGTURBO::JPEGTURBO)
    add_library(JPEGTURBO::JPEGTURBO UNKNOWN IMPORTED)
    set_target_properties(JPEGTURBO::JPEGTURBO PROPERTIES
      INTERFACE_INCLUDE_DIRECTORIES "${JPEGTURBO_INCLUDE_DIR}"
      IMPORTED_LINK_INTERFACE_LANGUAGES "C"
      IMPORTED_CONFIGURATIONS "DEBUG;RELEASE"
      IMPORTED_LOCATION_RELEASE "${JPEGTURBO_LIBRARY_RELEASE}"
      IMPORTED_LOCATION_DEBUG "${JPEGTURBO_LIBRARY_DEBUG}"
      MAP_IMPORTED_CONFIG_RELWITHDEBINFO Release
      MAP_IMPORTED_CONFIG_MINSIZEREL Release)
  endif()

  if(DEFINED CMAKE_BUILD_TYPE)
    if(CMAKE_BUILD_TYPE MATCHES "Debug")
      set(JPEGTURBO_LIBRARY "${JPEGTURBO_LIBRARY_DEBUG}")
    else()
      set(JPEGTURBO_LIBRARY "${JPEGTURBO_LIBRARY_RELEASE}")
    endif()
    set_property(TARGET JPEGTURBO::JPEGTURBO APPEND PROPERTY
      IMPORTED_LOCATION "${JPEGTURBO_LIBRARY}")
  else()
    set(JPEGTURBO_LIBRARY "${JPEGTURBO_LIBRARIES}")
  endif()
  mark_as_advanced(JPEGTURBO_LIBRARY)
endif()
