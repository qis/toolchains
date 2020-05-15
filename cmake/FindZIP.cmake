find_path(ZIP_INCLUDE_DIR zip.h PATH_SUFFIXES include)

if(NOT ZIP_LIBRARIES OR NOT ZIP_LIBRARY_RELEASE OR NOT ZIP_LIBRARY_DEBUG)
  get_filename_component(ZIP_ROOT_DIR ${ZIP_INCLUDE_DIR} DIRECTORY)
  find_library(ZIP_LIBRARY_RELEASE NAMES zip NAMES_PER_DIR
    NO_DEFAULT_PATH PATHS ${ZIP_ROOT_DIR}/lib PATH_SUFFIXES lib)
  find_library(ZIP_LIBRARY_DEBUG NAMES zip zipd NAMES_PER_DIR
    NO_DEFAULT_PATH PATHS ${ZIP_ROOT_DIR}/debug/lib PATH_SUFFIXES lib)
  include(SelectLibraryConfigurations)
  select_library_configurations(ZIP)
else()
  file(TO_CMAKE_PATH "${ZIP_LIBRARY_RELEASE}" ZIP_LIBRARY_RELEASE)
  file(TO_CMAKE_PATH "${ZIP_LIBRARY_DEBUG}" ZIP_LIBRARY_DEBUG)
  file(TO_CMAKE_PATH "${ZIP_LIBRARIES}" ZIP_LIBRARIES)
endif()

if(ZIP_INCLUDE_DIR AND EXISTS "${ZIP_INCLUDE_DIR}/zipconf.h")
  file(STRINGS "${ZIP_INCLUDE_DIR}/zipconf.h" ZIP_VERSION_HEADER
    REGEX "^#define[\t ]+LIBZIP_VERSION[\t ]+.*")

  string(REGEX REPLACE "^#define[\t ]+LIBZIP_VERSION[\t ]+\"([0-9\.]+)\".*" "\\1"
    ZIP_VERSION "${ZIP_VERSION_HEADER}")

  set(ZIP_VERSION_STRING "${ZIP_VERSION}")
  unset(ZIP_VERSION_HEADER)
endif()

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(ZIP
  REQUIRED_VARS ZIP_LIBRARIES ZIP_LIBRARY_RELEASE ZIP_LIBRARY_DEBUG ZIP_INCLUDE_DIR
  VERSION_VAR ZIP_VERSION_STRING)

if(ZIP_FOUND)
  set(ZIP_INCLUDE_DIRS ${ZIP_INCLUDE_DIR})
  if(NOT TARGET ZIP::ZIP)
    add_library(ZIP::ZIP UNKNOWN IMPORTED)
    set_target_properties(ZIP::ZIP PROPERTIES
      INTERFACE_INCLUDE_DIRECTORIES "${ZIP_INCLUDE_DIR}"
      IMPORTED_LINK_INTERFACE_LANGUAGES "C"
      IMPORTED_CONFIGURATIONS "DEBUG;RELEASE"
      IMPORTED_LOCATION_RELEASE "${ZIP_LIBRARY_RELEASE}"
      IMPORTED_LOCATION_DEBUG "${ZIP_LIBRARY_DEBUG}"
      MAP_IMPORTED_CONFIG_RELWITHDEBINFO Release
      MAP_IMPORTED_CONFIG_MINSIZEREL Release)
    if(DEFINED CMAKE_BUILD_TYPE)
      if(CMAKE_BUILD_TYPE MATCHES "Debug")
        set(ZIP_LIBRARY "${ZIP_LIBRARY_DEBUG}")
      else()
        set(ZIP_LIBRARY "${ZIP_LIBRARY_RELEASE}")
      endif()
      mark_as_advanced(ZIP_LIBRARY)
      set_property(TARGET ZIP::ZIP APPEND PROPERTY
        IMPORTED_LOCATION "${ZIP_LIBRARY}")
    else()
      set(ZIP_LIBRARY "${ZIP_LIBRARIES}")
    endif()
  endif()
endif()

mark_as_advanced(ZIP_INCLUDE_DIR)
