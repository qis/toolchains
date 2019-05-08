get_property(_CMAKE_IN_TRY_COMPILE GLOBAL PROPERTY IN_TRY_COMPILE)
if(NOT _CMAKE_IN_TRY_COMPILE)
  set(VCPKG_ENABLE_EDITANDCONTINUE OFF)
  if(NOT VCPKG_CRT_LINKAGE)
    set(VCPKG_ENABLE_EDITANDCONTINUE ON)
    include(${CMAKE_CURRENT_LIST_DIR}/../../triplets/${VCPKG_TARGET_TRIPLET}.cmake)
  endif()

  if(VCPKG_CRT_LINKAGE STREQUAL "dynamic")
    set(VCPKG_CRT_LINK_FLAG_PREFIX "/MD")
  elseif(VCPKG_CRT_LINKAGE STREQUAL "static")
    set(VCPKG_CRT_LINK_FLAG_PREFIX "/MT")
  else()
    message(FATAL_ERROR "Invalid setting for VCPKG_CRT_LINKAGE: \"${VCPKG_CRT_LINKAGE}\".")
  endif()

  set(CMAKE_CXX_STANDARD 20 CACHE STRING "" FORCE)
  set(CMAKE_CXX_STANDARD_REQUIRED ON CACHE STRING "" FORCE)
  set(CMAKE_CXX_EXTENSIONS OFF CACHE STRING "" FORCE)

  if(NOT VCPKG_CXX_FLAGS MATCHES "/EH")
    set(VCPKG_CXX_FLAGS "${VCPKG_CXX_FLAGS} /EHsc /d2FH4")
  endif()

  if(NOT VCPKG_CXX_FLAGS MATCHES "/GR")
    set(VCPKG_CXX_FLAGS "${VCPKG_CXX_FLAGS} /GR")
  endif()

  set(MSVC_COMMON "/nologo /W3 /DWIN32 /D_WINDOWS /FC /MP /wd28251 /wd26451 /utf-8")
  set(MSVC_COMMON_DEBUG "${VCPKG_CRT_LINK_FLAG_PREFIX}d /Ob0 /Od /RTC1 /GS /Zc:inline /Z7 /D_DEBUG")
  set(MSVC_COMMON_RELEASE "${VCPKG_CRT_LINK_FLAG_PREFIX} /Ox /Os /Oi /GF /Gy /GS- /GL /Zc:inline /Z7 /DNDEBUG")
  set(MSVC_LINKER_FLAGS_DEBUG "/DEBUG:FASTLINK /INCREMENTAL")
  set(MSVC_LINKER_FLAGS_RELEASE "/DEBUG:FULL /OPT:REF /OPT:ICF /INCREMENTAL:NO /LTCG:INCREMENTAL")

  if(VCPKG_ENABLE_EDITANDCONTINUE)
    string(REGEX REPLACE "/Z[7Ii]" "/ZI"
      MSVC_COMMON_DEBUG "${MSVC_COMMON_DEBUG}")
    string(REGEX REPLACE "/DEBUG:FASTLINK" "/DEBUG:FULL /EDITANDCONTINUE"
      MSVC_LINKER_FLAGS_DEBUG "${MSVC_LINKER_FLAGS_DEBUG}")
  endif()

  set(CMAKE_C_FLAGS "${MSVC_COMMON} ${VCPKG_C_FLAGS}" CACHE STRING "")
  set(CMAKE_CXX_FLAGS "${MSVC_COMMON} ${VCPKG_CXX_FLAGS} /Zc:__cplusplus /permissive- /await" CACHE STRING "")

  set(CMAKE_C_FLAGS_DEBUG "${MSVC_COMMON_DEBUG} ${VCPKG_C_FLAGS_DEBUG}" CACHE STRING "")
  set(CMAKE_CXX_FLAGS_DEBUG "${MSVC_COMMON_DEBUG} ${VCPKG_CXX_FLAGS_DEBUG}" CACHE STRING "")

  set(CMAKE_C_FLAGS_RELEASE "${MSVC_COMMON_RELEASE} ${VCPKG_C_FLAGS_RELEASE}" CACHE STRING "")
  set(CMAKE_CXX_FLAGS_RELEASE "${MSVC_COMMON_RELEASE} ${VCPKG_CXX_FLAGS_RELEASE} /await:heapelide" CACHE STRING "")

  set(CMAKE_STATIC_LINKER_FLAGS "/nologo /machine:X64" CACHE STRING "")
  set(CMAKE_SHARED_LINKER_FLAGS "/nologo /machine:X64 ${VCPKG_LINKER_FLAGS}" CACHE STRING "")
  set(CMAKE_EXE_LINKER_FLAGS "/nologo /machine:X64 ${VCPKG_LINKER_FLAGS}" CACHE STRING "")

  set(CMAKE_STATIC_LINKER_FLAGS_DEBUG "" CACHE STRING "")
  set(CMAKE_SHARED_LINKER_FLAGS_DEBUG "${MSVC_LINKER_FLAGS_DEBUG}" CACHE STRING "")
  set(CMAKE_EXE_LINKER_FLAGS_DEBUG "${MSVC_LINKER_FLAGS_DEBUG}" CACHE STRING "")

  set(CMAKE_STATIC_LINKER_FLAGS_RELEASE "/INCREMENTAL:NO /LTCG:INCREMENTAL" CACHE STRING "")
  set(CMAKE_SHARED_LINKER_FLAGS_RELEASE "${MSVC_LINKER_FLAGS_RELEASE}" CACHE STRING "")
  set(CMAKE_EXE_LINKER_FLAGS_RELEASE "${MSVC_LINKER_FLAGS_RELEASE}" CACHE STRING "")

  set(CMAKE_RC_FLAGS "/nologo -c65001 /DWIN32" CACHE STRING "")
endif()
