include_guard(GLOBAL)
include("${CMAKE_CURRENT_LIST_DIR}/config.cmake")

# Set compiler.
set(CMAKE_C_COMPILER "${CMAKE_CURRENT_LIST_DIR}/llvm/bin/clang-cl.exe" CACHE STRING "" FORCE)
set(CMAKE_CXX_COMPILER "${CMAKE_CURRENT_LIST_DIR}/llvm/bin/clang-cl.exe" CACHE STRING "" FORCE)
set(CMAKE_LINKER "${CMAKE_CURRENT_LIST_DIR}/llvm/bin/lld-link.exe" CACHE STRING "" FORCE)
set(CMAKE_ASM_MASM_COMPILER "ml64.exe" CACHE STRING "" FORCE)
set(CMAKE_RC_COMPILER "rc.exe" CACHE STRING "" FORCE)

# Set runtime library.
if(VCPKG_CRT_LINKAGE STREQUAL "dynamic")
  set(CMAKE_MSVC_RUNTIME_LIBRARY "MultiThreaded$<$<CONFIG:Debug>:Debug>DLL" CACHE STRING "")  
  set(VCPKG_CRT_FLAG "/MD")
  set(VCPKG_DBG_FLAG "/Zi")
elseif(VCPKG_CRT_LINKAGE STREQUAL "static")
  set(CMAKE_MSVC_RUNTIME_LIBRARY "MultiThreaded$<$<CONFIG:Debug>:Debug>" CACHE STRING "")  
  set(VCPKG_CRT_FLAG "/MT")
  set(VCPKG_DBG_FLAG "/Z7")
else()
  message(FATAL_ERROR "Invalid VCPKG_CRT_LINKAGE: \"${VCPKG_CRT_LINKAGE}\".")
endif()

# Set charset flag.
set(CHARSET_FLAG "/utf-8")
if (DEFINED VCPKG_SET_CHARSET_FLAG AND NOT VCPKG_SET_CHARSET_FLAG)
  set(CHARSET_FLAG)
endif()

# Set compiler flags.
set(CMAKE_C_FLAGS "/DWIN32 /D_WINDOWS /FC ${VCPKG_C_FLAGS} /clang:-fasm /clang:-fopenmp-simd ${CHARSET_FLAG}" CACHE STRING "")
set(CMAKE_C_FLAGS_DEBUG "/Od /Ob0 /GS /RTC1 ${VCPKG_C_FLAGS_DEBUG} ${VCPKG_CRT_FLAG}d ${VCPKG_DBG_FLAG}" CACHE STRING "")
set(CMAKE_C_FLAGS_RELEASE "/O1 /Oi /Ob2 /GS- ${VCPKG_C_FLAGS_RELEASE} ${VCPKG_CRT_FLAG} /clang:-flto=full /DNDEBUG" CACHE STRING "")
set(CMAKE_C_FLAGS_MINSIZEREL "/O1 /Oi /Ob1 /GS- ${VCPKG_C_FLAGS_RELEASE} ${VCPKG_CRT_FLAG} /clang:-flto=full /DNDEBUG" CACHE STRING "")
set(CMAKE_C_FLAGS_RELWITHDEBINFO "/O2 /Oi /Ob1 /GS- ${VCPKG_C_FLAGS_RELEASE} ${VCPKG_CRT_FLAG} /clang:-flto=full ${VCPKG_DBG_FLAG} /DNDEBUG" CACHE STRING "")

# TODO: Remove /U__cpp_concepts once LLVM adds MS STL support.
set(CMAKE_CXX_FLAGS "/DWIN32 /D_WINDOWS /U__cpp_concepts /FC /permissive- ${VCPKG_CXX_FLAGS} /clang:-fasm /clang:-fopenmp-simd ${CHARSET_FLAG}" CACHE STRING "")
set(CMAKE_CXX_FLAGS_DEBUG "${CMAKE_C_FLAGS_DEBUG} ${VCPKG_CXX_FLAGS_DEBUG} /clang:-fcoroutines-ts" CACHE STRING "")
set(CMAKE_CXX_FLAGS_RELEASE "${CMAKE_C_FLAGS_RELEASE} ${VCPKG_CXX_FLAGS_RELEASE} /clang:-fcoroutines-ts /clang:-fwhole-program-vtables" CACHE STRING "")
set(CMAKE_CXX_FLAGS_MINSIZEREL "${CMAKE_C_FLAGS_MINSIZEREL} ${VCPKG_CXX_FLAGS_RELEASE} /clang:-fcoroutines-ts /clang:-fwhole-program-vtables" CACHE STRING "")
set(CMAKE_CXX_FLAGS_RELWITHDEBINFO "${CMAKE_C_FLAGS_RELWITHDEBINFO} ${VCPKG_CXX_FLAGS_RELEASE} /clang:-fcoroutines-ts /clang:-fwhole-program-vtables" CACHE STRING "")

# Set linker flags.
foreach(LINKER SHARED_LINKER MODULE_LINKER EXE_LINKER)
  set(CMAKE_${LINKER}_FLAGS_INIT "${VCPKG_LINKER_FLAGS}")
  set(CMAKE_${LINKER}_FLAGS_DEBUG "/INCREMENTAL /DEBUG:FULL" CACHE STRING "")
  set(CMAKE_${LINKER}_FLAGS_RELEASE "/OPT:REF /OPT:ICF" CACHE STRING "")
  set(CMAKE_${LINKER}_FLAGS_MINSIZEREL "/OPT:REF /OPT:ICF" CACHE STRING "")
  set(CMAKE_${LINKER}_FLAGS_RELWITHDEBINFO "/OPT:REF /OPT:ICF /DEBUG:FULL" CACHE STRING "")
endforeach()

# Disable logo for compiler and linker.
set(CMAKE_CL_NOLOGO "/nologo" CACHE STRING "")

# Set assembler flags.
set(CMAKE_ASM_MASM_FLAGS_INIT "/nologo")

# Set resource compiler flags.
set(CMAKE_RC_FLAGS_INIT "/nologo -c65001 -DWIN32")
set(CMAKE_RC_FLAGS_DEBUG_INIT "-D_DEBUG")

# Add windows defines.
add_compile_definitions(_WIN64 _WIN32_WINNT=0x0A00 WINVER=0x0A00)
add_compile_definitions(_CRT_SECURE_NO_DEPRECATE _CRT_SECURE_NO_WARNINGS _CRT_NONSTDC_NO_DEPRECATE)
add_compile_definitions(_ATL_SECURE_NO_DEPRECATE _SCL_SECURE_NO_WARNINGS)
