if(PODOFO_FOUND)
  return()
endif()

if(NOT PODOFO_INCLUDE_DIR)
  find_path(PODOFO_INCLUDE_DIR podofo/podofo.h PATH_SUFFIXES include)

  set(PODOFO_INCLUDE_DIRS "${PODOFO_INCLUDE_DIR}")

  mark_as_advanced(
    PODOFO_INCLUDE_DIR
    PODOFO_INCLUDE_DIRS)
endif()

if(NOT PODOFO_LIBRARIES)
  include(SelectLibraryConfigurations)
  get_filename_component(PODOFO_ROOT_DIR ${PODOFO_INCLUDE_DIR} DIRECTORY)

  find_library(PODOFO_LIBRARY_RELEASE NAMES podofo NAMES_PER_DIR
    NO_DEFAULT_PATH PATHS ${PODOFO_ROOT_DIR}/lib PATH_SUFFIXES lib)
  find_library(PODOFO_LIBRARY_DEBUG NAMES podofo NAMES_PER_DIR
    NO_DEFAULT_PATH PATHS ${PODOFO_ROOT_DIR}/debug/lib PATH_SUFFIXES lib)

  select_library_configurations(PODOFO)

  mark_as_advanced(
    PODOFO_LIBRARY_RELEASE
    PODOFO_LIBRARY_DEBUG
    PODOFO_LIBRARIES)
endif()

if(NOT PODOFO_VERSION_STRING AND EXISTS "${PODOFO_INCLUDE_DIR}/podofo/base/podofo_config.h")
  file(STRINGS "${PODOFO_INCLUDE_DIR}/podofo/base/podofo_config.h" PODOFO_VERSION_STRING
    REGEX "^[ \t]*#define[ \t]+PODOFO_VERSION_(MAJOR|MINOR|RELEASE)")

  string(REGEX REPLACE ".*PODOFO_VERSION_MAJOR ([0-9]+).*" "\\1"
    PODOFO_VERSION_MAJOR "${PODOFO_VERSION_STRING}")
  string(REGEX REPLACE ".*PODOFO_VERSION_MINOR ([0-9]+).*" "\\1"
    PODOFO_VERSION_MINOR "${PODOFO_VERSION_STRING}")
  string(REGEX REPLACE ".*PODOFO_VERSION_PATCH ([0-9]+).*" "\\1"
    PODOFO_VERSION_PATCH "${PODOFO_VERSION_STRING}")

  set(PODOFO_VERSION "${PODOFO_VERSION_MAJOR}.${PODOFO_VERSION_MINOR}.${PODOFO_VERSION_PATCH}")
  set(PODOFO_VERSION_STRING "${PODOFO_VERSION}")  

  mark_as_advanced(
    PODOFO_VERSION
    PODOFO_VERSION_STRING)  
endif()

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(PoDoFo
  REQUIRED_VARS
    PODOFO_INCLUDE_DIR
    PODOFO_LIBRARIES
    PODOFO_LIBRARY_RELEASE
    PODOFO_LIBRARY_DEBUG
  VERSION_VAR
    PODOFO_VERSION_STRING)

if(PODOFO_FOUND)
  if(NOT TARGET podofo::podofo)
    add_library(podofo::podofo UNKNOWN IMPORTED)
    set_target_properties(podofo::podofo PROPERTIES
      INTERFACE_INCLUDE_DIRECTORIES "${PODOFO_INCLUDE_DIR}"
      IMPORTED_LINK_INTERFACE_LANGUAGES "C"
      IMPORTED_CONFIGURATIONS "DEBUG;RELEASE"
      IMPORTED_LOCATION_RELEASE "${PODOFO_LIBRARY_RELEASE}"
      IMPORTED_LOCATION_DEBUG "${PODOFO_LIBRARY_DEBUG}"
      MAP_IMPORTED_CONFIG_RELWITHDEBINFO Release
      MAP_IMPORTED_CONFIG_MINSIZEREL Release)
  endif()

  if(DEFINED CMAKE_BUILD_TYPE)
    if(CMAKE_BUILD_TYPE MATCHES "Debug")
      set(PODOFO_LIBRARY "${PODOFO_LIBRARY_DEBUG}")
    else()
      set(PODOFO_LIBRARY "${PODOFO_LIBRARY_RELEASE}")
    endif()
    set_property(TARGET podofo::podofo APPEND PROPERTY
      IMPORTED_LOCATION "${PODOFO_LIBRARY}")
  else()
    set(PODOFO_LIBRARY "${PODOFO_LIBRARIES}")
  endif()
  mark_as_advanced(PODOFO_LIBRARY)

  if(WIN32)
    target_link_libraries(podofo::podofo INTERFACE crypt32 ws2_32)
  else()
    find_package(OpenSSL REQUIRED)
    target_link_libraries(podofo::podofo INTERFACE OpenSSL::Crypto)
  endif()

  find_package(BZip2 REQUIRED)
  target_link_libraries(podofo::podofo INTERFACE BZip2::BZip2)

  find_package(LibLZMA CONFIG REQUIRED)
  target_link_libraries(podofo::podofo INTERFACE LibLZMA::LibLZMA)

  find_package(freetype CONFIG REQUIRED)
  target_link_libraries(podofo::podofo INTERFACE freetype)

  find_package(harfbuzz CONFIG REQUIRED)
  target_link_libraries(podofo::podofo INTERFACE harfbuzz::harfbuzz)

  find_package(JPEG REQUIRED)
  target_link_libraries(podofo::podofo INTERFACE JPEG::JPEG)

  find_package(PNG REQUIRED)
  target_link_libraries(podofo::podofo INTERFACE PNG::PNG)

  find_package(TIFF REQUIRED)
  target_link_libraries(podofo::podofo INTERFACE TIFF::TIFF)

  find_package(ZLIB REQUIRED)
  target_link_libraries(podofo::podofo INTERFACE ZLIB::ZLIB)
endif()
