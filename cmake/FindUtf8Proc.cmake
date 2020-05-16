find_path(UTF8PROC_INCLUDE_DIR utf8proc.h PATH_SUFFIXES include)

if(NOT UTF8PROC_LIBRARIES OR NOT UTF8PROC_LIBRARY_RELEASE OR NOT UTF8PROC_LIBRARY_DEBUG)
  get_filename_component(UTF8PROC_ROOT_DIR ${UTF8PROC_INCLUDE_DIR} DIRECTORY)
  find_library(UTF8PROC_LIBRARY_RELEASE NAMES utf8proc utf8proc_static NAMES_PER_DIR
    NO_DEFAULT_PATH PATHS ${UTF8PROC_ROOT_DIR}/lib PATH_SUFFIXES lib)
  find_library(UTF8PROC_LIBRARY_DEBUG NAMES utf8proc utf8proc_static NAMES_PER_DIR
    NO_DEFAULT_PATH PATHS ${UTF8PROC_ROOT_DIR}/debug/lib PATH_SUFFIXES lib)
  include(SelectLibraryConfigurations)
  select_library_configurations(UTF8PROC)
else()
  file(TO_CMAKE_PATH "${UTF8PROC_LIBRARY_RELEASE}" UTF8PROC_LIBRARY_RELEASE)
  file(TO_CMAKE_PATH "${UTF8PROC_LIBRARY_DEBUG}" UTF8PROC_LIBRARY_DEBUG)
  file(TO_CMAKE_PATH "${UTF8PROC_LIBRARIES}" UTF8PROC_LIBRARIES)
endif()

if(UTF8PROC_INCLUDE_DIR AND EXISTS "${UTF8PROC_INCLUDE_DIR}/utf8proc.h")
  file(STRINGS "${UTF8PROC_INCLUDE_DIR}/utf8proc.h" UTF8PROC_VERSION_HEADER
    REGEX "^[ \t]*#define[ \t]+UTF8PROC_VERSION_(MAJOR|MINOR|PATCH)")

  string(REGEX REPLACE ".*UTF8PROC_VERSION_MAJOR ([0-9]+).*" "\\1"
    UTF8PROC_VERSION_MAJOR "${UTF8PROC_VERSION_HEADER}")
  string(REGEX REPLACE ".*UTF8PROC_VERSION_MINOR ([0-9]+).*" "\\1"
    UTF8PROC_VERSION_MINOR "${UTF8PROC_VERSION_HEADER}")
  string(REGEX REPLACE ".*UTF8PROC_VERSION_PATCH ([0-9]+).*" "\\1"
    UTF8PROC_VERSION_PATCH "${UTF8PROC_VERSION_HEADER}")

  set(UTF8PROC_VERSION "${UTF8PROC_VERSION_MAJOR}.${UTF8PROC_VERSION_MINOR}.${UTF8PROC_VERSION_PATCH}")
  set(UTF8PROC_VERSION_STRING "${UTF8PROC_VERSION}")
  unset(UTF8PROC_VERSION_HEADER)
endif()

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(Utf8Proc
  REQUIRED_VARS UTF8PROC_INCLUDE_DIR UTF8PROC_LIBRARIES UTF8PROC_LIBRARY_RELEASE UTF8PROC_LIBRARY_DEBUG
  VERSION_VAR UTF8PROC_VERSION_STRING)

if(UTF8PROC_FOUND)
  set(UTF8PROC_INCLUDE_DIRS ${UTF8PROC_INCLUDE_DIR})
  if(NOT TARGET utf8proc::utf8proc)
    add_library(utf8proc::utf8proc UNKNOWN IMPORTED)
    set_target_properties(utf8proc::utf8proc PROPERTIES
      INTERFACE_INCLUDE_DIRECTORIES "${UTF8PROC_INCLUDE_DIR}"
      IMPORTED_LINK_INTERFACE_LANGUAGES "C"
      IMPORTED_CONFIGURATIONS "DEBUG;RELEASE"
      IMPORTED_LOCATION_RELEASE "${UTF8PROC_LIBRARY_RELEASE}"
      IMPORTED_LOCATION_DEBUG "${UTF8PROC_LIBRARY_DEBUG}"
      MAP_IMPORTED_CONFIG_RELWITHDEBINFO Release
      MAP_IMPORTED_CONFIG_MINSIZEREL Release)
    get_filename_component(UTF8PROC_LIBRARY_NAME_DEBUG ${UTF8PROC_LIBRARY_DEBUG} NAME_WE)
    if(UTF8PROC_LIBRARY_NAME_DEBUG STREQUAL "utf8proc_static")
      set_property(TARGET utf8proc::utf8proc APPEND PROPERTY
        INTERFACE_COMPILE_DEFINITIONS "$<$<CONFIG:Debug>:UTF8PROC_STATIC=1>")
    endif()
    get_filename_component(UTF8PROC_LIBRARY_NAME_RELEASE ${UTF8PROC_LIBRARY_RELEASE} NAME_WE)
    if(UTF8PROC_LIBRARY_NAME_RELEASE STREQUAL "utf8proc_static")
      set_property(TARGET utf8proc::utf8proc APPEND PROPERTY
        INTERFACE_COMPILE_DEFINITIONS "$<$<CONFIG:Release>:UTF8PROC_STATIC=1>")
    endif()
    if(DEFINED CMAKE_BUILD_TYPE)
      if(CMAKE_BUILD_TYPE MATCHES "Debug")
        set(UTF8PROC_LIBRARY "${UTF8PROC_LIBRARY_DEBUG}")
      else()
        set(UTF8PROC_LIBRARY "${UTF8PROC_LIBRARY_RELEASE}")
      endif()
      mark_as_advanced(UTF8PROC_LIBRARY)
      set_property(TARGET utf8proc::utf8proc APPEND PROPERTY
        IMPORTED_LOCATION "${UTF8PROC_LIBRARY}")
    else()
      set(UTF8PROC_LIBRARY "${UTF8PROC_LIBRARIES}")
    endif()
  endif()
endif()

mark_as_advanced(UTF8PROC_INCLUDE_DIR)
