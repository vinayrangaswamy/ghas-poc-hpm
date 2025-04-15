# Distributed under the OSI-approved BSD 3-Clause License.  See accompanying
# file LICENSE.rst or https://cmake.org/licensing for details.

#[=======================================================================[.rst:
FindFLEX
--------

Find Fast Lexical Analyzer (Flex) executable and provide a macro
to generate custom build rules.

The module defines the following variables:

``FLEX_FOUND``
  True if ``flex`` executable is found.

``FLEX_EXECUTABLE``
  The path to the ``flex`` executable.

``FLEX_VERSION``
  The version of ``flex``.

``FLEX_LIBRARIES``
  The ``flex`` libraries.

``FLEX_INCLUDE_DIRS``
  The path to the ``flex`` headers.

The minimum required version of ``flex`` can be specified using the
standard CMake syntax, e.g. :command:`find_package(FLEX 2.5.13)`.

If ``flex`` is found on the system, the module defines the macro:

.. command:: flex_target

  .. code-block:: cmake

    flex_target(<Name> <FlexInput> <FlexOutput>
                [OPTIONS <options>...]
                [COMPILE_FLAGS <string>]
                [DEFINES_FILE <string>]
                )

which creates a custom command to generate the ``<FlexOutput>`` file from
the ``<FlexInput>`` file.  ``<Name>`` is an alias used to get details of this
custom command.

The options are:

``OPTIONS <options>...``
  .. versionadded:: 4.0

  A :ref:`semicolon-separated list <CMake Language Lists>` of flex options added
  to the ``flex`` command line.

``COMPILE_FLAGS <string>``
  .. deprecated:: 4.0

  Space-separated flex options added to the ``flex`` command line.
  A :ref:`;-list <CMake Language Lists>` will not work.
  This option is deprecated in favor of ``OPTIONS <options>...``.

``DEFINES_FILE <string>``
  .. versionadded:: 3.5

  If flex is configured to output a header file, this option may be used to
  specify its name.

.. versionchanged:: 3.17
  When :policy:`CMP0098` is set to ``NEW``, ``flex`` runs in the
  :variable:`CMAKE_CURRENT_BINARY_DIR` directory.

The macro defines the following variables:

``FLEX_<Name>_DEFINED``
  True if the macro ran successfully.

``FLEX_<Name>_OUTPUTS``
  The source file generated by the custom rule, an alias for ``<FlexOutput>``.

``FLEX_<Name>_INPUT``
  The flex source file, an alias for ``<FlexInput>``.

``FLEX_<Name>_OUTPUT_HEADER``
  The header flex output, if any.

``FLEX_<Name>_OPTIONS``
  .. versionadded:: 4.0

  Options used in the ``flex`` command line.

Flex scanners often use tokens defined by Bison: the code generated
by Flex depends of the header generated by Bison.  This module also
defines a macro:

.. command:: add_flex_bison_dependency

  .. code-block:: cmake

    add_flex_bison_dependency(<FlexTarget> <BisonTarget>)

which adds the required dependency between a scanner and a parser
where ``<FlexTarget>`` and ``<BisonTarget>`` are the first parameters of
respectively ``flex_target`` and ``bison_target`` macros.

Examples
^^^^^^^^

.. code-block:: cmake

  find_package(BISON)
  find_package(FLEX)

  bison_target(MyParser parser.y ${CMAKE_CURRENT_BINARY_DIR}/parser.cpp)
  flex_target(MyScanner lexer.l  ${CMAKE_CURRENT_BINARY_DIR}/lexer.cpp)
  add_flex_bison_dependency(MyScanner MyParser)

  include_directories(${CMAKE_CURRENT_BINARY_DIR})
  add_executable(Foo
    Foo.cc
    ${BISON_MyParser_OUTPUTS}
    ${FLEX_MyScanner_OUTPUTS}
  )
  target_link_libraries(Foo ${FLEX_LIBRARIES})

Adding additional command-line options to the ``flex`` executable can be passed
as a list. For example, adding the ``--warn`` option to report warnings, and the
``--noline`` (``-L``) to not generate ``#line`` directives.

.. code-block:: cmake

  find_package(FLEX)

  if(FLEX_FOUND)
    flex_target(MyScanner lexer.l lexer.cpp OPTIONS --warn --noline)
  endif()

Generator expressions can be used in ``OPTIONS <options...``. For example, to
add the ``--debug`` (``-d``) option only for the ``Debug`` build type:

.. code-block:: cmake

  find_package(FLEX)

  if(FLEX_FOUND)
    flex_target(MyScanner lexer.l lexer.cpp OPTIONS $<$<CONFIG:Debug>:--debug>)
  endif()
#]=======================================================================]

find_program(FLEX_EXECUTABLE NAMES flex win-flex win_flex DOC "path to the flex executable")
mark_as_advanced(FLEX_EXECUTABLE)

find_library(FL_LIBRARY NAMES fl
  DOC "Path to the fl library")

find_path(FLEX_INCLUDE_DIR FlexLexer.h
  DOC "Path to the flex headers")

mark_as_advanced(FL_LIBRARY FLEX_INCLUDE_DIR)

set(FLEX_INCLUDE_DIRS ${FLEX_INCLUDE_DIR})
set(FLEX_LIBRARIES ${FL_LIBRARY})

if(FLEX_EXECUTABLE)

  execute_process(COMMAND ${FLEX_EXECUTABLE} --version
    OUTPUT_VARIABLE FLEX_version_output
    ERROR_VARIABLE FLEX_version_error
    RESULT_VARIABLE FLEX_version_result
    OUTPUT_STRIP_TRAILING_WHITESPACE)
  if(NOT ${FLEX_version_result} EQUAL 0)
    if(FLEX_FIND_REQUIRED)
      message(SEND_ERROR "Command \"${FLEX_EXECUTABLE} --version\" failed with output:\n${FLEX_version_output}\n${FLEX_version_error}")
    else()
      message("Command \"${FLEX_EXECUTABLE} --version\" failed with output:\n${FLEX_version_output}\n${FLEX_version_error}\nFLEX_VERSION will not be available")
    endif()
  else()
    # older versions of flex printed "/full/path/to/executable version X.Y"
    # newer versions use "basename(executable) X.Y"
    get_filename_component(FLEX_EXE_NAME_WE "${FLEX_EXECUTABLE}" NAME_WE)
    get_filename_component(FLEX_EXE_EXT "${FLEX_EXECUTABLE}" EXT)
    string(REGEX REPLACE "^.*${FLEX_EXE_NAME_WE}(${FLEX_EXE_EXT})?\"? (version )?([0-9]+[^ ]*)( .*)?$" "\\3"
      FLEX_VERSION "${FLEX_version_output}")
    unset(FLEX_EXE_EXT)
    unset(FLEX_EXE_NAME_WE)
  endif()

  #============================================================
  # FLEX_TARGET (public macro)
  #============================================================
  #
  macro(FLEX_TARGET Name Input Output)

    set(FLEX_TARGET_PARAM_OPTIONS)
    set(FLEX_TARGET_PARAM_ONE_VALUE_KEYWORDS
      COMPILE_FLAGS
      DEFINES_FILE
      )
    set(FLEX_TARGET_PARAM_MULTI_VALUE_KEYWORDS OPTIONS)

    cmake_parse_arguments(
      FLEX_TARGET_ARG
      "${FLEX_TARGET_PARAM_OPTIONS}"
      "${FLEX_TARGET_PARAM_ONE_VALUE_KEYWORDS}"
      "${FLEX_TARGET_PARAM_MULTI_VALUE_KEYWORDS}"
      ${ARGN}
      )

    string(
      JOIN "\n" FLEX_TARGET_usage
      "Usage:"
      "  flex_target("
      "    <Name>"
      "    <Input>"
      "    <Output>"
      "    [OPTIONS <options>...]"
      "    [COMPILE_FLAGS <string>]"
      "    [DEFINES_FILE <string>]"
      "  )"
    )

    if(NOT "${FLEX_TARGET_ARG_UNPARSED_ARGUMENTS}" STREQUAL "")
      message(
        SEND_ERROR
        "Unrecognized arguments: ${FLEX_TARGET_ARG_UNPARSED_ARGUMENTS}\n"
        "${FLEX_TARGET_usage}"
      )
    else()

      cmake_policy(GET CMP0098 _flex_CMP0098
          PARENT_SCOPE # undocumented, do not use outside of CMake
        )
      set(_flex_INPUT "${Input}")
      if("x${_flex_CMP0098}x" STREQUAL "xNEWx")
        set(_flex_WORKING_DIR "${CMAKE_CURRENT_BINARY_DIR}")
        if(NOT IS_ABSOLUTE "${_flex_INPUT}")
          set(_flex_INPUT "${CMAKE_CURRENT_SOURCE_DIR}/${_flex_INPUT}")
        endif()
      else()
        set(_flex_WORKING_DIR "${CMAKE_CURRENT_SOURCE_DIR}")
      endif()
      unset(_flex_CMP0098)

      set(_flex_OUTPUT "${Output}")
      if(NOT IS_ABSOLUTE ${_flex_OUTPUT})
        set(_flex_OUTPUT "${_flex_WORKING_DIR}/${_flex_OUTPUT}")
      endif()
      set(_flex_TARGET_OUTPUTS "${_flex_OUTPUT}")

      set(_flex_EXE_OPTS "")
      if(NOT "${FLEX_TARGET_ARG_COMPILE_FLAGS}" STREQUAL "")
        set(_flex_EXE_OPTS "${FLEX_TARGET_ARG_COMPILE_FLAGS}")
        separate_arguments(_flex_EXE_OPTS)
      endif()

      if(FLEX_TARGET_ARG_OPTIONS)
        list(APPEND _flex_EXE_OPTS ${FLEX_TARGET_ARG_OPTIONS})
      endif()

      set(_flex_OUTPUT_HEADER "")
      if(NOT "${FLEX_TARGET_ARG_DEFINES_FILE}" STREQUAL "")
        set(_flex_OUTPUT_HEADER "${FLEX_TARGET_ARG_DEFINES_FILE}")
        if(IS_ABSOLUTE "${_flex_OUTPUT_HEADER}")
          set(_flex_OUTPUT_HEADER_ABS "${_flex_OUTPUT_HEADER}")
        else()
          set(_flex_OUTPUT_HEADER_ABS "${_flex_WORKING_DIR}/${_flex_OUTPUT_HEADER}")
        endif()
        list(APPEND _flex_TARGET_OUTPUTS "${_flex_OUTPUT_HEADER_ABS}")
        list(APPEND _flex_EXE_OPTS --header-file=${_flex_OUTPUT_HEADER_ABS})
      endif()

      # Flex cannot create output directories. Create any missing determined
      # directories where the files will be generated if they don't exist yet.
      set(_flex_MAKE_DIRECTORY_COMMAND "")
      foreach(output IN LISTS _flex_TARGET_OUTPUTS)
        cmake_path(GET output PARENT_PATH dir)
        if(dir)
          list(APPEND _flex_MAKE_DIRECTORY_COMMAND ${dir})
        endif()
        unset(dir)
      endforeach()
      if(_flex_MAKE_DIRECTORY_COMMAND)
        list(REMOVE_DUPLICATES _flex_MAKE_DIRECTORY_COMMAND)
        list(
          PREPEND
          _flex_MAKE_DIRECTORY_COMMAND
          COMMAND ${CMAKE_COMMAND} -E make_directory
        )
      endif()

      get_filename_component(_flex_EXE_NAME_WE "${FLEX_EXECUTABLE}" NAME_WE)
      add_custom_command(OUTPUT ${_flex_TARGET_OUTPUTS}
        ${_flex_MAKE_DIRECTORY_COMMAND}
        COMMAND ${FLEX_EXECUTABLE} ${_flex_EXE_OPTS} -o${_flex_OUTPUT} ${_flex_INPUT}
        VERBATIM
        DEPENDS ${_flex_INPUT}
        COMMENT "[FLEX][${Name}] Building scanner with ${_flex_EXE_NAME_WE} ${FLEX_VERSION}"
        WORKING_DIRECTORY ${_flex_WORKING_DIR}
        COMMAND_EXPAND_LISTS)

      set(FLEX_${Name}_DEFINED TRUE)
      set(FLEX_${Name}_OUTPUTS ${_flex_TARGET_OUTPUTS})
      set(FLEX_${Name}_INPUT ${_flex_INPUT})
      set(FLEX_${Name}_OPTIONS ${_flex_EXE_OPTS})
      set(FLEX_${Name}_COMPILE_FLAGS ${_flex_EXE_OPTS})
      set(FLEX_${Name}_OUTPUT_HEADER ${_flex_OUTPUT_HEADER})

      unset(_flex_EXE_NAME_WE)
      unset(_flex_EXE_OPTS)
      unset(_flex_INPUT)
      unset(_flex_MAKE_DIRECTORY_COMMAND)
      unset(_flex_OUTPUT)
      unset(_flex_OUTPUT_HEADER)
      unset(_flex_OUTPUT_HEADER_ABS)
      unset(_flex_TARGET_OUTPUTS)
      unset(_flex_WORKING_DIR)
    endif()
  endmacro()
  #============================================================


  #============================================================
  # ADD_FLEX_BISON_DEPENDENCY (public macro)
  #============================================================
  #
  macro(ADD_FLEX_BISON_DEPENDENCY FlexTarget BisonTarget)

    if(NOT FLEX_${FlexTarget}_OUTPUTS)
      message(SEND_ERROR "Flex target `${FlexTarget}' does not exist.")
    endif()

    if(NOT BISON_${BisonTarget}_OUTPUT_HEADER)
      message(SEND_ERROR "Bison target `${BisonTarget}' does not exist.")
    endif()

    set_source_files_properties(${FLEX_${FlexTarget}_OUTPUTS}
      PROPERTIES OBJECT_DEPENDS ${BISON_${BisonTarget}_OUTPUT_HEADER})
  endmacro()
  #============================================================

endif()

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(FLEX REQUIRED_VARS FLEX_EXECUTABLE
                                       VERSION_VAR FLEX_VERSION)
