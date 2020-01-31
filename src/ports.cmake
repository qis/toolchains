include(config.cmake)
file(REMOVE_RECURSE ports)

include(src/boost/version.cmake)

file(MAKE_DIRECTORY ports/boost)
file(WRITE ports/boost/CONTROL "\
Source: boost
Version: ${BOOST_VERSION}
Homepage: https://boost.org
Description: Peer-reviewed portable C++ source libraries\n")

file(GLOB BOOST_FILES src/boost/*)
file(COPY ${BOOST_FILES} DESTINATION ports/boost)

file(GLOB BOOST_PORTS ${VCPKG_ROOT}/ports/boost-*)
foreach(PORT_SRC ${BOOST_PORTS})
  get_filename_component(PORT ${PORT_SRC} NAME)
  string(REGEX REPLACE "^boost-" "" NAME ${PORT})
  string(REPLACE "-" " " NAME ${NAME})
  file(MAKE_DIRECTORY ports/${PORT})
  file(WRITE  ports/${PORT}/CONTROL "Source: ${PORT}\n")
  file(APPEND ports/${PORT}/CONTROL "Version: ${BOOST_VERSION}\n")
  file(APPEND ports/${PORT}/CONTROL "Homepage: https://boost.org\n")
  file(APPEND ports/${PORT}/CONTROL "Description: Boost ${NAME} module\n")
  file(APPEND ports/${PORT}/CONTROL "Build-Depends: boost\n")
  file(WRITE  ports/${PORT}/portfile.cmake "set(VCPKG_POLICY_EMPTY_PACKAGE enabled)\n")
endforeach()

message("vcpkg install --overlay-ports=\"${CMAKE_CURRENT_LIST_DIR}/ports\" boost")
message("vcpkg install --overlay-ports=\"C:/Workspace/vcpkg/scripts/toolchains/ports\" boost")
