if(NOT DEFINED VCPKG_TARGET_TRIPLET)
  set(VCPKG_TARGET_TRIPLET "x64-windows-ipo" CACHE STRING "")
endif()

include("${CMAKE_CURRENT_LIST_DIR}/config.cmake")

if(DEFINED CMAKE_CXX_CLANG_TIDY)
  unset(CMAKE_CXX_CLANG_TIDY CACHE)
endif()

# Set runtime library.
set(CMAKE_MSVC_RUNTIME_LIBRARY "" CACHE STRING "")
if(VCPKG_CRT_LINKAGE STREQUAL "dynamic")
  set(VCPKG_CRT_FLAG "/MD")
  set(VCPKG_DBG_FLAG "/ZI")
elseif(VCPKG_CRT_LINKAGE STREQUAL "static")
  set(VCPKG_CRT_FLAG "/MT")
  set(VCPKG_DBG_FLAG "/Z7")
else()
  message(FATAL_ERROR "Invalid VCPKG_CRT_LINKAGE: \"${VCPKG_CRT_LINKAGE}\".")
endif()

# Set charset flag.
set(CHARSET_FLAG "/utf-8")
if(DEFINED VCPKG_SET_CHARSET_FLAG AND NOT VCPKG_SET_CHARSET_FLAG)
  set(CHARSET_FLAG)
endif()

# Set compiler flags.
set(COMMON_FLAGS "/W3 /wd4101 /wd26812 /wd28251 /wd4275 /D_WIN64 /D_WIN32_WINNT=0x0A00 /DWINVER=0x0A00")
set(COMMON_FLAGS "${COMMON_FLAGS} /D_CRT_SECURE_NO_DEPRECATE /D_CRT_SECURE_NO_WARNINGS /D_CRT_NONSTDC_NO_DEPRECATE")
set(COMMON_FLAGS "${COMMON_FLAGS} /D_ATL_SECURE_NO_DEPRECATE /D_SCL_SECURE_NO_WARNINGS")

set(CMAKE_C_FLAGS "/DWIN32 /D_WINDOWS /FC /permissive- ${COMMON_FLAGS} ${VCPKG_C_FLAGS} ${CHARSET_FLAG}" CACHE STRING "")
set(CMAKE_C_FLAGS_DEBUG "/Od /Ob0 /GS /RTC1 ${VCPKG_C_FLAGS_DEBUG} ${VCPKG_CRT_FLAG}d ${VCPKG_DBG_FLAG}" CACHE STRING "")
set(CMAKE_C_FLAGS_RELEASE "/O1 /Oi /Ob2 /GS- ${VCPKG_C_FLAGS_RELEASE} ${VCPKG_CRT_FLAG} /GL /DNDEBUG" CACHE STRING "")
set(CMAKE_C_FLAGS_MINSIZEREL "/O1 /Oi /Ob1 /GS- ${VCPKG_C_FLAGS_RELEASE} ${VCPKG_CRT_FLAG} /GL /DNDEBUG" CACHE STRING "")
set(CMAKE_C_FLAGS_RELWITHDEBINFO "/O2 /Oi /Ob1 /GS- ${VCPKG_C_FLAGS_RELEASE} ${VCPKG_CRT_FLAG} /GL /Z7 /DNDEBUG" CACHE STRING "")

set(CMAKE_CXX_FLAGS "${CMAKE_C_FLAGS} ${VCPKG_CXX_FLAGS}" CACHE STRING "")
set(CMAKE_CXX_FLAGS_DEBUG "${CMAKE_C_FLAGS_DEBUG} ${VCPKG_CXX_FLAGS_DEBUG} /await" CACHE STRING "")
set(CMAKE_CXX_FLAGS_RELEASE "${CMAKE_C_FLAGS_RELEASE} ${VCPKG_CXX_FLAGS_RELEASE} /await /await:heapelide" CACHE STRING "")
set(CMAKE_CXX_FLAGS_MINSIZEREL "${CMAKE_C_FLAGS_MINSIZEREL} ${VCPKG_CXX_FLAGS_RELEASE} /await /await:heapelide" CACHE STRING "")
set(CMAKE_CXX_FLAGS_RELWITHDEBINFO "${CMAKE_C_FLAGS_RELWITHDEBINFO} ${VCPKG_CXX_FLAGS_RELEASE} /await /await:heapelide" CACHE STRING "")

# Set linker flags.
foreach(LINKER SHARED_LINKER MODULE_LINKER EXE_LINKER)
  set(CMAKE_${LINKER}_FLAGS_INIT "/ignore:4042 ${VCPKG_LINKER_FLAGS}")
  set(CMAKE_${LINKER}_FLAGS_DEBUG "/INCREMENTAL /DEBUG:FASTLINK" CACHE STRING "")
  set(CMAKE_${LINKER}_FLAGS_RELEASE "/OPT:REF /OPT:ICF /LTCG" CACHE STRING "")
  set(CMAKE_${LINKER}_FLAGS_MINSIZEREL "/OPT:REF /OPT:ICF /LTCG" CACHE STRING "")
  set(CMAKE_${LINKER}_FLAGS_RELWITHDEBINFO "/OPT:REF /OPT:ICF /DEBUG:FASTLINK /LTCG:INCREMENTAL" CACHE STRING "")
endforeach()

# Disable logo for compiler and linker.
set(CMAKE_CL_NOLOGO "/nologo" CACHE STRING "")

# Set assembler flags.
set(CMAKE_ASM_MASM_FLAGS_INIT "/nologo")

# Set resource compiler flags.
set(CMAKE_RC_FLAGS "/nologo -c65001 /DWIN32" CACHE STRING "" FORCE)
set(CMAKE_RC_FLAGS_DEBUG_INIT "-D_DEBUG")
