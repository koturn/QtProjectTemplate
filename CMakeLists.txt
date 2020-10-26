cmake_minimum_required(VERSION 3.5)
project(QtProjectTemplate
  DESCRIPTION "A Template Qt project with CMake"
  VERSION "1.0.0.0"
  LANGUAGES CXX)

set(BUILD_TARGET ${PROJECT_NAME})

include(cmake/DetectLatestCxxVersion.cmake)
detect_latest_cxx_version(REQUIRED_VERSION 11)

set(CMAKE_CXX_STANDARD ${LATEST_CXX_VERSION})
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

set(CMAKE_INCLUDE_CURRENT_DIR ON)
if(DEFINED ENV{QTDIR})
  set(CMAKE_PREFIX_PATH "$ENV{QTDIR}")
endif()

set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTOUIC ON)
set(CMAKE_AUTORCC ON)

set(DEFAULT_BUILD_TYPE "Release")
if(NOT CMAKE_BUILD_TYPE AND NOT CMAKE_CONFIGURATION_TYPES)
  message(STATUS "Setting build type to '${DEFAULT_BUILD_TYPE}' as none was specified.")
  set(CMAKE_BUILD_TYPE "${DEFAULT_BUILD_TYPE}" CACHE STRING "Choose the type of build." FORCE)
  set_property(CACHE CMAKE_BUILD_TYPE PROPERTY STRINGS "Debug" "Release" "MinSizeRel" "RelWithDebInfo")
endif()


include(cmake/GenerateGitCommitHashSource.cmake)
set(GCH_SOURCE "${CMAKE_CURRENT_BINARY_DIR}/config/CommitHash.cpp")
set(GCH_HEADER "${CMAKE_CURRENT_BINARY_DIR}/config/CommitHash.h")
generate_gch_sources(
  SOURCE "${GCH_SOURCE}"
  HEADER "${GCH_HEADER}")

if(WIN32 OR CYGWIN OR MINGW OR MSYS)
  include(cmake/GenerateVersionRcFile.cmake)
  set(RCFILE "${CMAKE_CURRENT_BINARY_DIR}/config/VersionInfo.rc")
  generate_version_rcfile(
    "${RCFILE}"
    NAME "${BUILD_TARGET}"
    COMPANY_NAME "koturn"
    ORIGINAL_FILENAME "${BUILD_TARGET}.exe"
    INTERNAL_NAME "${BUILD_TARGET}.exe")
endif()


find_package(Qt5 COMPONENTS Widgets REQUIRED)

file(GLOB SRCS *.c *.cpp *.cxx *.cc *.h *.hpp *.hxx *.hh *.inl *.ui)
add_executable(
  ${BUILD_TARGET}
  ${SRCS}
  ${GCH_SOURCE}
  ${GCH_HEADER}
  ${RCFILE})

target_link_libraries(
  ${BUILD_TARGET} PRIVATE
  Qt5::Core
  Qt5::Gui
  Qt5::Widgets)

target_include_directories(
  ${BUILD_TARGET} PRIVATE
  ${Qt5Widgets_INCLUDES})

target_compile_definitions(
  ${BUILD_TARGET} PRIVATE
  ${Qt5Widgets_DEFINITIONS})

if(WIN32)
  set_target_properties(
    ${BUILD_TARGET}
    PROPERTIES WIN32_EXECUTABLE TRUE)
endif()


if(CMAKE_SYSTEM_PROCESSOR MATCHES "i686.*|i386.*|x86.*")
  set(SYSTEM_PROCESSOR_IS_X86 TRUE)
endif()
if(CMAKE_SYSTEM_PROCESSOR MATCHES "amd64.*|x86_64.*|AMD64.*")
  set(SYSTEM_PROCESSOR_IS_X64 TRUE)
endif()


if(MSVC OR CYGWIN OR MINGW OR MSYS)
  list(APPEND DEFINES "WIN32_LEAN_AND_MEAN" "NOMINMAX")
endif()
if(MSVC)
  list(APPEND DEFINES "_USE_MATH_DEFINES" "_CRT_NONSTDC_NO_WARNINGS" "_CRT_SECURE_NO_WARNINGS")
  list(APPEND DEFINES_DEBUG "_DEBUG")
  list(APPEND DEFINES_RELWITHDEBINFO "_DEBUG")
else()
  list(APPEND DEFINES_RELEASE "NDEBUG")
  list(APPEND DEFINES_MINSIZEREL "NDEBUG")
  list(APPEND DEFINES_DEBUG "_FORTIFY_SOURCE=2" "_GLIBCXX_DEBUG")
endif()

if(MSVC)
  foreach(TARGET_FLAG
      CMAKE_CXX_FLAGS
      CMAKE_CXX_FLAGS_DEBUG
      CMAKE_CXX_FLAGS_RELEASE
      CMAKE_CXX_FLAGS_MINSIZEREL
      CMAKE_CXX_FLAGS_RELWITHDEBINFO)
    string(REGEX REPLACE "/RTC[^ ]*" "" ${TARGET_FLAG} "${${TARGET_FLAG}}")
    string(REGEX REPLACE "/W[0-4]" "/W4" ${TARGET_FLAG} "${${TARGET_FLAG}}")
  endforeach(TARGET_FLAG)

  list(APPEND CXX_FLAGS_DEBUG "/Oi" "/Oy")
  list(APPEND CXX_FLAGS_RELEASE "/Ob2" "/Oi" "/Ot" "/Ox" "/Oy" "/GL")
  list(APPEND CXX_FLAGS_MINSIZEREL "/Os")

  list(APPEND EXE_LINKER_FLAGS_RELEASE "/LTCG")
else()
  set(GNU_CLANG_COMMON_WARNING_FLAGS
    "-Wall"
    "-Wextra"
    "-Wabi"
    "-Wcast-align"
    "-Wcast-qual"
    "-Wconversion"
    "-Wdisabled-optimization"
    "-Wfloat-equal"
    "-Wformat=2"
    "-Winit-self"
    "-Winvalid-pch"
    "-Wmissing-declarations"
    "-Wpointer-arith"
    "-Wredundant-decls"
    "-Wstack-protector"
    "-Wstrict-aliasing=2"
    "-Wstrict-overflow=5"
    "-Wswitch-enum"
    "-Wswitch-default"
    "-Wunknown-pragmas"
    "-Wunreachable-code"
    "-Wwrite-strings"
    "-pedantic")

  option(ENABLE_ADDITIONAL_WARNING_FLAGS "Enable additional warning flags." OFF)
  if(ENABLE_ADDITIONAL_WARNING_FLAGS)
    list(APPEND GNU_CLANG_COMMON_WARNING_FLAGS "-Winline" "-Wsign-conversion")
  endif()

  set(GNU_COMMON_WARNING_FLAGS "${GNU_CLANG_COMMON_WARNING_FLAGS}" "-Wlogical-op")
  if(ENABLE_ADDITIONAL_WARNING_FLAGS)
    list(APPEND GNU_COMMON_WARNING_FLAGS "-Wunsafe-loop-optimizations")
  endif()

  set(CLANG_COMMON_WARNING_FLAGS "${GNU_CLANG_COMMON_WARNING_FLAGS}" "-Wsign-promo")

  if(CMAKE_COMPILER_IS_GNUCXX)
    set(CXX_WARNING_FLAGS
      "${GNU_COMMON_WARNING_FLAGS}"
      "-Weffc++"
      "-Wctor-dtor-privacy"
      "-Wnon-virtual-dtor"
      "-Wold-style-cast"
      "-Woverloaded-virtual"
      "-Wreorder"
      "-Wsign-promo"
      "-Wstrict-null-sentinel")

    if(CMAKE_CXX_COMPILER_VERSION VERSION_GREATER_EQUAL 4.3)
      message(STATUS "Add warning flags implemented in g++ 4.3")
      list(APPEND CXX_WARNING_FLAGS "-Wc++0x-compat")
    endif()
    if(CMAKE_CXX_COMPILER_VERSION VERSION_GREATER_EQUAL 4.6)
      message(STATUS "Add warning flags implemented in g++ 4.6")
      list(APPEND CXX_WARNING_FLAGS
        "-Wdouble-promotion"
        "-Wnoexcept"
        "-Wsuggest-attribute=const"
        "-Wsuggest-attribute=noreturn"
        "-Wsuggest-attribute=pure"
        "-Wtrampolines")
    endif()
    if(CMAKE_CXX_COMPILER_VERSION VERSION_GREATER_EQUAL 4.7)
      message(STATUS "Add warning flags implemented in g++ 4.7")
      string(REGEX REPLACE "-Wc\\+\\+0x-compat" "-Wc++11-compat" CXX_WARNING_FLAGS "${CXX_WARNING_FLAGS}")
      list(APPEND CXX_WARNING_FLAGS
        "-Wdelete-non-virtual-dtor"
        "-Wvector-operation-performance"
        "-Wno-return-local-addr"
        "-Wzero-as-null-pointer-constant")
    endif()
    if(CMAKE_CXX_COMPILER_VERSION VERSION_GREATER_EQUAL 4.8)
      message(STATUS "Add warning flags implemented in g++ 4.8")
      list(APPEND CXX_WARNING_FLAGS
        "-Wsuggest-attribute=format"
        "-Wuseless-cast")
    endif()
    if(CMAKE_CXX_COMPILER_VERSION VERSION_GREATER_EQUAL 4.9)
      message(STATUS "Add warning flags implemented in g++ 4.9")
      list(APPEND CXX_WARNING_FLAGS "-Wconditionally-supported")
    endif()
    if(CMAKE_CXX_COMPILER_VERSION VERSION_GREATER_EQUAL 5.1)
      message(STATUS "Add warning flags implemented in g++ 5.1")
      list(APPEND CXX_WARNING_FLAGS
        "-Wc++14-compat"
        "-Wformat-signedness"
        "-Wsuggest-final-methods"
        "-Wsuggest-final-types"
        "-Wsuggest-override")
    endif()
    if(CMAKE_CXX_COMPILER_VERSION VERSION_GREATER_EQUAL 6.0)
      message(STATUS "Add warning flags implemented in g++ 6.0")
      list(APPEND CXX_WARNING_FLAGS
        "-Wduplicated-cond"
        "-Wplacement-new=2"
        "-Wshift-overflow=2")
    endif()
    if(CMAKE_CXX_COMPILER_VERSION VERSION_GREATER_EQUAL 7.0)
      message(STATUS "Add warning flags implemented in g++ 7.0")
      string(REGEX REPLACE "-Wabi" "-Wabi=11" CXX_WARNING_FLAGS "${CXX_WARNING_FLAGS}")
      list(APPEND CXX_WARNING_FLAGS
        "-Wc++17-compat"
        "-Walloc-zero"
        "-Wduplicated-branches"
        "-Wformat-overflow=2"
        "-Wformat-truncation=2"
        "-Wregister"
        "-Wrestrict"
        "-Wshadow-local"
        "-Wstringop-overflow=4")
    endif()
    if(CMAKE_CXX_COMPILER_VERSION VERSION_GREATER_EQUAL 8.0)
      message(STATUS "Add warning flags implemented in g++ 8.0")
      string(REGEX REPLACE "-Wcast-align" "-Wcast-align=strict" CXX_WARNING_FLAGS "${CXX_WARNING_FLAGS}")
      list(APPEND CXX_WARNING_FLAGS "-Wsuggest-attribute=malloc")
    endif()

    set(CXX_FLAGS "${CMAKE_CXX_FLAGS}" "-pipe" "${CXX_WARNING_FLAGS}")
    set(CXX_FLAGS_DEBUG "-g3" "-O0" "-ftrapv" "-fstack-protector-all")
    set(CXX_FLAGS_RELEASE "-O3")
    set(CXX_FLAGS_MINSIZEREL "-Os")
    if(SYSTEM_PROCESSOR_IS_X86 OR SYSTEM_PROCESSOR_IS_X64)
      list(APPEND CXX_FLAGS_RELEASE "-mtune=native" "-march=native")
      list(APPEND CXX_FLAGS_MINSIZEREL "-mtune=native" "-march=native")
    endif()
    if(CMAKE_CXX_COMPILER_VERSION VERSION_LESS 4.8)
      set(CXX_FLAGS_RELWITHDEBINFO "-g" "-O2")
    else()
      set(CXX_FLAGS_RELWITHDEBINFO "-g" "-Og")
    endif()
  elseif(CMAKE_CXX_COMPILER_ID STREQUAL "Clang")
    set(CXX_WARNING_FLAGS "${CLANG_COMMON_WARNING_FLAGS}")
    list(APPEND CXX_WARNING_FLAGS
      "-Wc++11-compat"
      "-Weffc++"
      "-Wctor-dtor-privacy"
      "-Wdelete-non-virtual-dtor"
      "-Wnon-virtual-dtor"
      "-Wold-style-cast"
      "-Woverloaded-virtual"
      "-Wreorder")

    if(CMAKE_CXX_COMPILER_VERSION VERSION_GREATER_EQUAL 3.5)
      message(STATUS "Add warning flags implemented in clang++ 3.5")
      list(APPEND CXX_WARNING_FLAGS "-Wc++14-compat")
    endif()
    if(CMAKE_CXX_COMPILER_VERSION VERSION_GREATER_EQUAL 3.8)
      message(STATUS "Add warning flags implemented in clang++ 3.8")
      list(APPEND CXX_WARNING_FLAGS
        "-Wc++1z-compat"
        "-Wdouble-promotion")
    endif()
    if(CMAKE_CXX_COMPILER_VERSION VERSION_GREATER_EQUAL 5.0)
      message(STATUS "Add warning flags implemented in clang++ 5.0")
      string(REGEX REPLACE "-Wc\\+\\+1z-compat" "-Wc++17-compat" CXX_WARNING_FLAGS "${CXX_WARNING_FLAGS}")
      list(CXX_WARNING_FLAGS "-Wzero-as-null-pointer-constant")
    endif()

    set(CXX_FLAGS "${CMAKE_CXX_FLAGS}" "-pipe" "${CXX_WARNING_FLAGS}")
    set(CXX_FLAGS_DEBUG "-g3" "-O0" "-ftrapv" "-fstack-protector-all")
    set(CXX_FLAGS_RELEASE "-O3")
    set(CXX_FLAGS_MINSIZEREL "-s")
    if(SYSTEM_PROCESSOR_IS_X86 OR SYSTEM_PROCESSOR_IS_X64)
      list(APPEND CXX_FLAGS_RELEASE "-mtune=native" "-march=native")
      list(APPEND CXX_FLAGS_MINSIZEREL "-mtune=native" "-march=native")
    endif()
    if(CMAKE_CXX_COMPILER_VERSION VERSION_LESS 4.0)
      set(CXX_FLAGS_RELWITHDEBINFO "-g" "-O2")
    else()
      set(CXX_FLAGS_RELWITHDEBINFO "-g" "-Og")
    endif()
  else()
    set(CXX_FLAGS "${CMAKE_CXX_FLAGS}")
    set(CXX_FLAGS_DEBUG "${CMAKE_CXX_FLAGS_DEBUG}")
    set(CXX_FLAGS_RELEASE "${CMAKE_CXX_FLAGS_RELEASE}")
    set(CXX_FLAGS_MINSIZEREL "${CMAKE_CXX_FLAGS_MINSIZEREL}")
    set(CXX_FLAGS_RELWITHDEBINFO "${CMAKE_CXX_FLAGS_RELWITHDEBINFO}")
  endif()

  set(EXE_LINKER_FLAGS_RELEASE "${CMAKE_EXE_LINKER_FLAGS_RELEASE}" "-s" "-Wl,-O1")
  set(EXE_LINKER_FLAGS_MINSIZEREL "${CMAKE_EXE_LINKER_FLAGS_MINSIZEREL}" "-s")

  install(TARGETS ${BUILD_TARGET}
    RUNTIME DESTINATION bin
    LIBRARY DESTINATION lib
    ARCHIVE DESTINATION lib/static)

  add_custom_target(uninstall xargs rm < install_manifest.txt)
endif()

target_compile_definitions(
  ${BUILD_TARGET} PRIVATE
  ${DEFINES}
  $<$<CONFIG:Release>:${DEFINES_RELEASE}>
  $<$<CONFIG:Debug>:${DEFINES_DEBUG}>
  $<$<CONFIG:RelWithDebInfo>:${DEFINES_RELWITHDEBINFO}>
  $<$<CONFIG:MinSizeRel>:${DEFINES_MINSIZEREL}>)

get_property(PROJECT_LANGUAGES GLOBAL PROPERTY ENABLED_LANGUAGES)

if("CXX" IN_LIST PROJECT_LANGUAGES)
  target_compile_options(
    ${BUILD_TARGET} PRIVATE
    $<$<COMPILE_LANGUAGE:CXX>:
      ${CXX_FLAGS}
      $<$<CONFIG:Release>:${CXX_FLAGS_RELEASE}>
      $<$<CONFIG:Debug>:${CXX_FLAGS_DEBUG}>
      $<$<CONFIG:RelWithDebInfo>:${CXX_FLAGS_RELWITHDEBINFO}>
      $<$<CONFIG:MinSizeRel>:${CXX_FLAGS_MINSIZEREL}>
    >)
endif()

if(CMAKE_VERSION VERSION_GREATER_EQUAL 3.13)
  target_link_options(
    ${BUILD_TARGET} PRIVATE
    ${EXE_LINKER_FLAGS}
    $<$<CONFIG:Release>:${EXE_LINKER_FLAGS_RELEASE}>
    $<$<CONFIG:Debug>:${EXE_LINKER_FLAGS_DEBUG}>
    $<$<CONFIG:RelWithDebInfo>:${EXE_LINKER_FLAGS_RELWITHDEBINFO}>
    $<$<CONFIG:MinSizeRel>:${EXE_LINKER_FLAGS_MINSIZEREL}>)
else()
  foreach(TARGET_FLAG
      EXE_LINKER_FLAGS
      EXE_LINKER_FLAGS_DEBUG
      EXE_LINKER_FLAGS_RELEASE
      EXE_LINKER_FLAGS_RELWITHDEBINFO
      EXE_LINKER_FLAGS_MINSIZEREL)
    string(REPLACE ";" " " ${TARGET_FLAG} "${${TARGET_FLAG}}")
    string(REGEX REPLACE "  +" " " "CMAKE_${TARGET_FLAG}" "${${TARGET_FLAG}}")
  endforeach(TARGET_FLAG)
endif()


option(ENABLE_TESTING "Enable testing with Google Test." OFF)
if(ENABLE_TESTING)
  enable_testing()
  include(cmake/gtest.cmake)
  add_subdirectory(test)
endif()

option(ENABLE_DOXYGEN "Enable to generate document with Doxygen." OFF)
if(ENABLE_DOXYGEN)
  include(cmake/doxygen.cmake)
  add_doxygen(${BUILD_TARGET})
endif()


get_target_property(QMAKE_EXECUTABLE Qt5::qmake IMPORTED_LOCATION)
get_filename_component(QT_BIN_DIR "${QMAKE_EXECUTABLE}" DIRECTORY)
set(DEPLOY_DIR "Deploy")

if(WIN32 OR CYGWIN OR MINGW OR MSYS)
  set(DEPLOYQT_NAME "windeployqt")
  find_program(
    DEPLOYQT_PATH
    "${DEPLOYQT_NAME}"
    HINTS "${QT_BIN_DIR}")
  if(NOT DEPLOYQT_PATH)
    message(WARNING "${DEPLOYQT_NAME} was not found.")
  endif()
  add_custom_target(
    deploy
    COMMAND ${CMAKE_COMMAND} -E make_directory "${DEPLOY_DIR}"
    COMMAND ${CMAKE_COMMAND} -E copy ${BUILD_TARGET}.exe "${DEPLOY_DIR}"
    COMMAND "${DEPLOYQT_PATH}" "${DEPLOY_DIR}/${BUILD_TARGET}.exe"
    DEPENDS ${BUILD_TARGET}
    WORKING_DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}"
    COMMENT "Deploying...")
elseif(APPLE)
  set(DEPLOYQT_NAME "macdeployqt")
  find_program(
    DEPLOYQT_PATH
    "${DEPLOYQT_NAME}"
    HINTS "${QT_BIN_DIR}")
  if(NOT DEPLOYQT_PATH)
    message(WARNING "${DEPLOYQT_NAME} was not found.")
  endif()
  add_custom_target(
    deploy
    COMMAND ${CMAKE_COMMAND} -E make_directory "${DEPLOY_DIR}"
    COMMAND ${CMAKE_COMMAND} -E copy "${BUILD_TARGET}" "${DEPLOY_DIR}"
    COMMAND "${DEPLOYQT_PATH}" "${DEPLOY_DIR}/${BUILD_TARGET}"
    DEPENDS ${BUILD_TARGET}
    WORKING_DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}"
    COMMENT "Deploying...")
endif()


if(WIN32)
  set(CMAKE_INSTALL_SYSTEM_RUNTIME_LIBS_SKIP TRUE)
  install(
    TARGETS ${BUILD_TARGET}
    RUNTIME DESTINATION bin
    COMPONENT applications)
  message(STATUS "${CMAKE_CURRENT_BINARY_DIR}/${DEPLOY_DIR}/")
  file(GLOB dlls "${CMAKE_CURRENT_BINARY_DIR}/${DEPLOY_DIR}/*.dll")
  message(STATUS "DLLs: ${dlls}")
  install(
    PROGRAMS ${dlls}
    DESTINATION bin
    COMPONENT applications)
  install(
    DIRECTORY
    "${CMAKE_CURRENT_BINARY_DIR}/${DEPLOY_DIR}/iconengines"
    "${CMAKE_CURRENT_BINARY_DIR}/${DEPLOY_DIR}/imageformats"
    "${CMAKE_CURRENT_BINARY_DIR}/${DEPLOY_DIR}/platforms"
    "${CMAKE_CURRENT_BINARY_DIR}/${DEPLOY_DIR}/translations"
    DESTINATION bin
    COMPONENT applications)
  include(InstallRequiredSystemLibraries)
  install(
    PROGRAMS ${CMAKE_INSTALL_SYSTEM_RUNTIME_LIBS}
    DESTINATION programs
    COMPONENT applications)
  set(CPACK_PACKAGE_NAME "${BUILD_TARGET}")
  set(CPACK_PACKAGE_VENDOR "koturn")
  set(CPACK_PACKAGE_DESCRIPTION_SUMMARY "${PROJECT_DESCRIPTION}")
  set(CPACK_PACKAGE_VERSION_MAJOR "${PROJECT_VERSION_MAJOR}")
  set(CPACK_PACKAGE_VERSION_MINOR "${PROJECT_VERSION_MINOR}")
  set(CPACK_PACKAGE_VERSION_PATCH "${PROJECT_VERSION_PATCH}")
  set(CPACK_PACKAGE_VERSION "${PROJECT_VERSION_TWEEK}")
  set(CPACK_RESOURCE_FILE_LICENSE "${CMAKE_CURRENT_SOURCE_DIR}/LICENSE")
  set(CPACK_PACKAGE_INSTALL_DIRECTORY "installer")
  set(CPACK_COMPONENT_APPLICATIONS_DISPLAY_NAME "applications (${BUILD_TARGET})")
  # set(CPACK_NSIS_MUI_ICON "${CMAKE_CURRENT_BINARY_DIR}/WindowsAppIcon.ico")
  # set(CPACK_NSIS_MUI_UNIICON "${CMAKE_CURRENT_BINARY_DIR}/WindowsAppIcon.ico")
  set(CPACK_NSIS_MENU_LINKS "programs/${BUILD_TARGET}" "${BUILD_TARGET}")
  include(CPack)
  # add_dependencies(package deploy)
endif()


message(STATUS "Variables")

foreach(VARNAME
    CMAKE_SYSTEM_NAME
    CMAKE_SYSTEM_PROCESSOR
    CMAKE_SOURCE_DIR
    CMAKE_BINARY_DIR
    CMAKE_BUILD_TYPE
    CMAKE_CONFIGURATION_TYPES
    CMAKE_COMPILER_IS_GNUCC
    CMAKE_COMPILER_IS_GNUCXX
    CMAKE_CXX_COMPILER
    CMAKE_CXX_COMPILER_VERSION
    CMAKE_CXX_COMPILER_ID
    CMAKE_CXX_STANDARD
    CMAKE_CXX_STANDARD_REQUIRED
    CMAKE_CXX_EXTENSIONS
    CMAKE_CXX_FLAGS
    CMAKE_CXX_FLAGS_DEBUG
    CMAKE_CXX_FLAGS_RELEASE
    CMAKE_CXX_FLAGS_RELWITHDEBINFO
    CMAKE_CXX_FLAGS_MINSIZEREL
    CMAKE_EXE_LINKER_FLAGS
    CMAKE_EXE_LINKER_FLAGS_DEBUG
    CMAKE_EXE_LINKER_FLAGS_RELEASE
    CMAKE_EXE_LINKER_FLAGS_RELWITHDEBINFO
    CMAKE_EXE_LINKER_FLAGS_MINSIZEREL
    LATEST_CXX_VERSION
    Qt5Core_INCLUDES
    Qt5Core_DEFINITIONS
    Qt5Core_EXECUTABLE_COMPILE_FLAGS
    Qt5Gui_INCLUDES
    Qt5Gui_DEFINITIONS
    Qt5Gui_EXECUTABLE_COMPILE_FLAGS
    Qt5Widgets_INCLUDES
    Qt5Widgets_DEFINITIONS
    Qt5Widgets_EXECUTABLE_COMPILE_FLAGS
    QT_USE_FILE
    QT_DEFINITION
    QT5_USE_FILE
    QT5_DEFINITION)
  message(STATUS "${VARNAME}: ${${VARNAME}}")
endforeach(VARNAME)
