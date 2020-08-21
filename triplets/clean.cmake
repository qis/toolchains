# File extensions to keep.
set(extensions
  "c" "cc" "c++" "cpp" "cxx"
  "h" "hh" "h++" "hpp" "hxx"
  "i" "ih" "i++" "ipp" "ixx")

# Get vcpkg buildtrees directory.
get_filename_component(VCPKG_BUILDTREES_DIR ${CMAKE_CURRENT_LIST_DIR}/../../../buildtrees ABSOLUTE)

# Delete unused boost subdirectories.
file(GLOB VCPKG_BUILDTREES_BOOST_DIRS LIST_DIRECTORIES ON
  ${VCPKG_BUILDTREES_DIR}/boost/src/*/doc
  ${VCPKG_BUILDTREES_DIR}/boost/src/*/test
  ${VCPKG_BUILDTREES_DIR}/boost/src/*/tools
  ${VCPKG_BUILDTREES_DIR}/boost/src/*/bench
  ${VCPKG_BUILDTREES_DIR}/boost/src/*/example)
foreach(directory ${VCPKG_BUILDTREES_BOOST_DIRS})
  file(REMOVE_RECURSE "${directory}")
endforeach()

# Delete unused boost libs subdirectories.
file(GLOB VCPKG_BUILDTREES_BOOST_LIBS_DIRS LIST_DIRECTORIES ON
  ${VCPKG_BUILDTREES_DIR}/boost/src/*/libs/*/*)
foreach(directory ${VCPKG_BUILDTREES_BOOST_LIBS_DIRS})
  get_filename_component(name ${directory} NAME)
  if(IS_DIRECTORY ${directory} AND NOT name STREQUAL "src")
    file(REMOVE_RECURSE "${directory}")
  endif()
endforeach()

# Delete unused port subdirectories.
file(GLOB VCPKG_BUILDTREES_PORT_DIRS LIST_DIRECTORIES ON
  ${VCPKG_BUILDTREES_DIR}/*/src/*/test)
foreach(directory ${VCPKG_BUILDTREES_PORT_DIRS})
  get_filename_component(name ${directory} NAME)
  if(IS_DIRECTORY ${directory} AND name STREQUAL "test")
    file(REMOVE_RECURSE "${directory}")
  endif()
endforeach()

# Delete unused openssl subdirectories.
file(GLOB VCPKG_BUILDTREES_OPENSSL_DIRS LIST_DIRECTORIES ON
  ${VCPKG_BUILDTREES_DIR}/openssl-*/*/test)
foreach(directory ${VCPKG_BUILDTREES_OPENSSL_DIRS})
  file(REMOVE_RECURSE "${directory}")
endforeach()

# Removes all files and subdirectories in `directory`.
function(clean directory)
  # Delete directory based on name.
  get_filename_component(name ${directory} NAME)
  if(name STREQUAL "ShowIncludes" OR name MATCHES "^CompilerId")
    file(REMOVE_RECURSE ${directory})
    return()
  endif()

  # Get list of subdirectories and files.
  file(GLOB entries LIST_DIRECTORIES ON ${directory}/*)

  # Clean subdirectories.
  foreach(path ${entries})
    if(IS_DIRECTORY ${path})
      clean(${path})
    endif()
  endforeach()

  # Iterate over files.
  foreach(path ${entries})
    if(NOT IS_DIRECTORY ${path})
      # Get file extension.
      get_filename_component(ext ${path} LAST_EXT)
      string(TOLOWER "${ext}" ext)

      # Mark file to be kept based on file extension.
      set(keep OFF)
      foreach(keep_ext ${extensions})
        if(ext STREQUAL ".${keep_ext}")
          set(keep ON)
          break()
        endif()
      endforeach()

      # Get file name.
      get_filename_component(name ${path} NAME)

      # Mark file to be kept based on name.
      if(ext STREQUAL ".pdb" AND NOT name MATCHES "^vc[0-9]+\\.pdb$" AND NOT NAME STREQUAL "b2.pdb")
        set(keep ON)
      endif()

      # Delete files not marked to be kept.
      if(NOT keep)
        file(REMOVE ${path})
      endif()
    endif()
  endforeach()

  # Update list of subdirectories and files.
  file(GLOB entries LIST_DIRECTORIES ON ${directory}/*)

  # Delete directory if empty.
  if(NOT entries)
    file(REMOVE_RECURSE ${directory})
  endif()
endfunction()

# Clean vcpkg buildtrees subdirectories.
clean(${VCPKG_BUILDTREES_DIR})

# Remove vcpkg packages directory.
get_filename_component(VCPKG_PACKAGES_DIR ${CMAKE_CURRENT_LIST_DIR}/../../../packages ABSOLUTE)
file(REMOVE_RECURSE "${VCPKG_PACKAGES_DIR}")
