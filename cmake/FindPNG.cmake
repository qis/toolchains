if(PNG_FOUND)
  return()
endif()

if(NOT PNG_INCLUDE_DIR)
  find_path(PNG_INCLUDE_DIR png.h PATH_SUFFIXES include)

  set(PNG_INCLUDE_DIRS "${PNG_INCLUDE_DIR}")

  mark_as_advanced(
    PNG_INCLUDE_DIR
    PNG_INCLUDE_DIRS)
endif()  

if(NOT PNG_LIBRARIES)
  include(SelectLibraryConfigurations)
  get_filename_component(PNG_ROOT_DIR ${PNG_INCLUDE_DIR} DIRECTORY)

  find_library(PNG_LIBRARY_RELEASE NAMES png libpng16 NAMES_PER_DIR
    NO_DEFAULT_PATH PATHS ${PNG_ROOT_DIR}/lib PATH_SUFFIXES lib)
  find_library(PNG_LIBRARY_DEBUG NAMES png pngd libpng16d NAMES_PER_DIR
    NO_DEFAULT_PATH PATHS ${PNG_ROOT_DIR}/debug/lib PATH_SUFFIXES lib)

  select_library_configurations(PNG)

  mark_as_advanced(
    PNG_LIBRARY_RELEASE
    PNG_LIBRARY_DEBUG
    PNG_LIBRARIES)  
endif()

if(NOT PNG_VERSION_STRING AND EXISTS "${PNG_INCLUDE_DIR}/png.h")
  file(STRINGS "${PNG_INCLUDE_DIR}/png.h" PNG_VERSION_STRING
    REGEX "^#define[ \t]+PNG_LIBPNG_VER_STRING[ \t]+\".+\"")

  string(REGEX REPLACE "^#define[ \t]+PNG_LIBPNG_VER_STRING[ \t]+\"([^\"]+)\".*"
    "\\1" PNG_VERSION "${PNG_VERSION_STRING}")

  set(PNG_VERSION_STRING "${PNG_VERSION}")

  mark_as_advanced(
    PNG_VERSION
    PNG_VERSION_STRING)  
endif()

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(PNG
  REQUIRED_VARS
    PNG_INCLUDE_DIR
    PNG_LIBRARIES
    PNG_LIBRARY_RELEASE
    PNG_LIBRARY_DEBUG
  VERSION_VAR
    PNG_VERSION_STRING)

if(PNG_FOUND)
  if(NOT TARGET PNG::PNG)
    add_library(PNG::PNG UNKNOWN IMPORTED)
    set_target_properties(PNG::PNG PROPERTIES
      INTERFACE_INCLUDE_DIRECTORIES "${PNG_INCLUDE_DIR}"
      IMPORTED_LINK_INTERFACE_LANGUAGES "C"
      IMPORTED_CONFIGURATIONS "DEBUG;RELEASE"
      IMPORTED_LOCATION_RELEASE "${PNG_LIBRARY_RELEASE}"
      IMPORTED_LOCATION_DEBUG "${PNG_LIBRARY_DEBUG}"
      MAP_IMPORTED_CONFIG_RELWITHDEBINFO Release
      MAP_IMPORTED_CONFIG_MINSIZEREL Release)
  endif()

  if(DEFINED CMAKE_BUILD_TYPE)
    if(CMAKE_BUILD_TYPE MATCHES "Debug")
      set(PNG_LIBRARY "${PNG_LIBRARY_DEBUG}")
    else()
      set(PNG_LIBRARY "${PNG_LIBRARY_RELEASE}")
    endif()
    set_property(TARGET PNG::PNG APPEND PROPERTY
      IMPORTED_LOCATION "${PNG_LIBRARY}")
  else()
    set(PNG_LIBRARY "${PNG_LIBRARIES}")
  endif()
  mark_as_advanced(PNG_LIBRARY)

  find_package(ZLIB REQUIRED)
  target_link_libraries(PNG::PNG INTERFACE ZLIB::ZLIB)
endif()
