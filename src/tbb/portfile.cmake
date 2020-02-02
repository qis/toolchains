vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO intel/tbb
  REF v2020.1
  SHA512 4bcde2084c7bfee372d9473876659af59bd273f8e56ebe7fcaef41e51e18dcf8070ca2ab019caddabe6ef5c1c08c0da2f4362567b090872a5d461c9b9b6a73a7
  HEAD_REF tbb_2020
  PATCHES
    fix-comparison-operator.patch
    fix-static-build.patch
    fix-warnings.patch
)

file(COPY ${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt DESTINATION ${SOURCE_PATH})
file(COPY ${CMAKE_CURRENT_LIST_DIR}/TBBConfig.cmake.in DESTINATION ${SOURCE_PATH})

set(WITH_PSTL OFF)
if(pstl IN_LIST FEATURES)
  set(WITH_PSTL ON)
endif()

vcpkg_configure_cmake(
  SOURCE_PATH ${SOURCE_PATH}
  PREFER_NINJA
  OPTIONS
    -DWITH_PSTL=${WITH_PSTL}
  OPTIONS_DEBUG
    -DSKIP_INSTALL_HEADERS=ON
)

vcpkg_install_cmake()
vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/TBB)
vcpkg_copy_pdbs()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
