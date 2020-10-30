find_package(Doxygen)

set(DOXYGEN_CURRENT_LIST_DIR "${CMAKE_CURRENT_LIST_DIR}")

if(DOXYGEN_FOUND)
  add_custom_target(doxygen)
endif()


function(add_doxygen)
  if(NOT DOXYGEN_FOUND)
    return()
  endif()

  set(options)
  set(oneValueArgs
    NAME
    OUTPUT_DIRECTORY)
  set(multiValueArgs
    TARGETS
    QT_TARGETS
    SOURCES
    INCLUDE_DIRECTORIES
    COMPILE_DEFINITIONS)
  cmake_parse_arguments(DOXYGEN "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

  if(NOT DOXYGEN_NAME)
    if(DEFINED PROJECT_NAME AND NOT "${PROJECT_NAME}" STREQUAL "")
      set(DOXYGEN_NAME "${PROJECT_NAME}")
    else()
      message(FATAL_ERROR "Name of document is empty")
    endif()
  endif()

  if(NOT DEFINED DOXYGEN_OUTPUT_DIRECTORY)
    set(DOXYGEN_OUTPUT_DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}/document")
  endif()

  foreach(target ${DOXYGEN_TARGETS} ${DOXYGEN_QT_TARGETS})
    get_property(sources
      TARGET ${target}
      PROPERTY SOURCES)
    list(APPEND DOXYGEN_SOURCES ${sources})

    get_property(incdirs
      TARGET ${target}
      PROPERTY INCLUDE_DIRECTORIES)
    list(APPEND DOXYGEN_INCLUDE_DIRECTORIES ${incdirs})

    get_property(defs
      DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
      PROPERTY COMPILE_DEFINITIONS)
    list(APPEND DOXYGEN_COMPILE_DEFINITIONS ${defs})
  endforeach(target)

  set(abs_autogen_source_paths "")
  foreach(target ${DOXYGEN_QT_TARGETS})
    file(GLOB_RECURSE autogen_sources
      "${CMAKE_CURRENT_BINARY_DIR}/${target}_autogen/*.cpp"
      "${CMAKE_CURRENT_BINARY_DIR}/${target}_autogen/*.h")
    list(APPEND abs_autogen_source_paths ${autogen_sources})
  endforeach(target)

  # Convert to absolute path.
  set(abs_source_paths "")
  foreach(source ${DOXYGEN_SOURCES})
    string(TOLOWER "${source}" source_lower)
    if("${source_lower}" MATCHES "\\.(c|cc|cxx|cpp|c\\+\\+|ii|ixx|ipp|i\\+\\+|inl|h|hh|hxx|hpp|h\\+\\+|inc)")
      if(IS_ABSOLUTE "${source}")
        list(APPEND abs_source_paths "${source}")
      else()
        get_filename_component(abs_source "${source}" ABSOLUTE)
        list(APPEND abs_source_paths "${abs_source}")
      endif()
    endif()
  endforeach(source)
  list(REMOVE_DUPLICATES abs_source_paths)

  set(abs_incdir_header_paths "")
  foreach(incdir ${DOXYGEN_INCLUDE_DIRECTORIES})
    file(GLOB headers
      ${incdir}/*.ii
      ${incdir}/*.ixx
      ${incdir}/*.ipp
      ${incdir}/*.i++
      ${incdir}/*.inl
      ${incdir}/*.h
      ${incdir}/*.hh
      ${incdir}/*.hxx
      ${incdir}/*.hpp
      ${incdir}/*.h++
      ${incdir}/*.inc)
    list(APPEND abs_incdir_header_paths ${headers})
  endforeach(incdir)
  list(REMOVE_DUPLICATES abs_incdir_header_paths)

  set(abs_input_dir_paths "")
  foreach(input_dir ${DOXYGEN_INPUT_DIRECTORIES})
    if(IS_ABSOLUTE "${input_dir}")
      list(APPEND abs_input_dir_paths "${input_dir}")
    else()
      get_filename_component(abs_input_dir "${input_dir}" ABSOLUTE)
      list(APPEND abs_input_dir_paths "${abs_input_dir}")
    endif()
  endforeach()
  message(STATUS "abs_input_dir_paths: ${abs_input_dir_paths}")

  # Convert lists to whitespace separated strings
  string(REPLACE ";" " " abs_source_paths_ws_splited "${abs_source_paths}")
  string(REPLACE ";" " " abs_autogen_source_paths_ws_splited "${abs_autogen_source_paths}")
  string(REPLACE ";" " " abs_incdir_header_paths_ws_splited "${abs_incdir_header_paths}")
  string(REPLACE ";" " " abs_incdir_paths_ws_splited "${INCLUDE_DIRECTORIES}")
  string(REPLACE ";" " " defs_ws_splited "${DOXYGEN_COMPILE_DEFINITIONS}")

  # Create output directory
  add_custom_command(
    OUTPUT "${DOXYGEN_OUTPUT_DIRECTORY}/${DOXYGEN_NAME}"
    COMMAND cmake -E make_directory "${DOXYGEN_OUTPUT_DIRECTORY}/${DOXYGEN_NAME}"
    COMMENT "Creating documentation directory for ${DOXYGEN_NAME}...")

  # Create Doxyfile from Doxyfile.in.
  add_custom_command(
    OUTPUT "${DOXYGEN_OUTPUT_DIRECTORY}/${DOXYGEN_NAME}/Doxyfile"
    COMMAND ${CMAKE_COMMAND}
      -D "DOXYGEN_TEMPLATE=${DOXYGEN_CURRENT_LIST_DIR}/templates/Doxyfile.in"
      -D "DOXY_PROJECT_INPUT=${abs_source_paths_ws_splited} ${abs_incdir_header_paths_ws_splited} ${abs_autogen_source_paths_ws_splited} "
      -D "DOXY_PROJECT_INCLUDE_DIR=${abs_incdir_paths_ws_splited}"
      -D "DOXY_PROJECT_PREDEFINED=${predef_spaces}"
      -D "DOXY_PROJECT_STRIP_FROM_PATH=${CMAKE_SOURCE_DIR}"
      -D "DOXY_DOCUMENTATION_OUTPUT_PATH=${DOXYGEN_OUTPUT_DIRECTORY}"
      -D "DOXY_PROJECT_NAME=${DOXYGEN_NAME}"
      -P "${DOXYGEN_CURRENT_LIST_DIR}/DoxygenScript.cmake"
    DEPENDS "${DOXYGEN_CURRENT_LIST_DIR}/templates/Doxyfile.in" "${DOXYGEN_OUTPUT_DIRECTORY}/${DOXYGEN_NAME}"
    WORKING_DIRECTORY "${DOXYGEN_OUTPUT_DIRECTORY}/${DOXYGEN_NAME}"
    COMMENT "Generating Doxyfile for ${DOXYGEN_NAME}...")

  # Execute doxygen.
  add_custom_command(
    OUTPUT "${DOXYGEN_OUTPUT_DIRECTORY}/${DOXYGEN_NAME}/index.html"
    COMMAND ${DOXYGEN_EXECUTABLE}
    DEPENDS "${DOXYGEN_OUTPUT_DIRECTORY}/${DOXYGEN_NAME}/Doxyfile"
    WORKING_DIRECTORY "${DOXYGEN_OUTPUT_DIRECTORY}/${DOXYGEN_NAME}"
    COMMENT "Creating HTML documentation for ${DOXYGEN_NAME}...")

  add_custom_target(doxygen-${DOXYGEN_NAME}
    DEPENDS "${DOXYGEN_OUTPUT_DIRECTORY}/${DOXYGEN_NAME}/index.html")

  add_dependencies(doxygen doxygen-${DOXYGEN_NAME})
  foreach(target ${DOXYGEN_QT_TARGETS})
    add_dependencies(doxygen-${DOXYGEN_NAME} "${target}_autogen")
  endforeach(target)
endfunction()
