include(${CMAKE_CURRENT_LIST_DIR}/version.cmake)
string(REPLACE "." "_" BOOST_VERSION_NAME ${BOOST_VERSION})

vcpkg_download_distfile(ARCHIVE
  URLS "https://dl.bintray.com/boostorg/release/1.72.0/source/boost_${BOOST_VERSION_NAME}.7z"
  FILENAME "boost_${BOOST_VERSION_NAME}.7z"
  SHA512 96ce928d490a84d76ef54b0f90780d23eeff4b1d79d7a00e4bee51e791b0f8e65eecc5578c86f49c2f791fb670826c114304d40ce097537431bf23ba587c2cae
)

vcpkg_extract_source_archive_ex(
  OUT_SOURCE_PATH SOURCE_PATH
  ARCHIVE ${ARCHIVE}
  REF "${BOOST_VERSION}"
)

file(COPY ${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt DESTINATION ${SOURCE_PATH})

if(NOT VCPKG_CMAKE_SYSTEM_NAME)
  set(B2 ${SOURCE_PATH}/b2.exe)
  set(BOOTSTRAP ${SOURCE_PATH}/bootstrap.bat)
else()
  set(B2 ${SOURCE_PATH}/b2)
  set(BOOTSTRAP ${SOURCE_PATH}/bootstrap.sh)
endif()

if(NOT EXISTS ${B2})
  message(STATUS "Building b2")
  execute_process(COMMAND ${BOOTSTRAP} WORKING_DIRECTORY ${SOURCE_PATH})
endif()

vcpkg_configure_cmake(
  SOURCE_PATH ${SOURCE_PATH}
  PREFER_NINJA
  OPTIONS
    -DB2=${B2}
    -DCRT_LINKAGE=${VCPKG_CRT_LINKAGE}
    -DLIBRARY_LINKAGE=${VCPKG_LIBRARY_LINKAGE}
)

vcpkg_install_cmake()
vcpkg_fixup_cmake_targets(CONFIG_PATH share/boost TARGET_PATH share/boost)
#file(INSTALL ${SOURCE_PATH}/Copyright.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
vcpkg_copy_pdbs()
