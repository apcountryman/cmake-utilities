# cmake-utilities
#
# Copyright 2019-2024, Andrew Countryman <apcountryman@gmail.com> and the cmake-utilities
# contributors
#
# Licensed under the Apache License, Version 2.0 (the "License"); you may not use this
# file except in compliance with the License. You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software distributed under
# the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
# KIND, either express or implied. See the License for the specific language governing
# permissions and limitations under the License.

# Description: CMake lcov utilities.

find_program( LCOV lcov )
mark_as_advanced( LCOV )
if( LCOV STREQUAL "LCOV-NOTFOUND" )
    message( FATAL_ERROR "lcov not found" )
endif( LCOV STREQUAL "LCOV-NOTFOUND" )

find_program( GENHTML genhtml )
mark_as_advanced( GENHTML )
if( GENHTML STREQUAL "GENHTML-NOTFOUND" )
    message( FATAL_ERROR "genhtml not found" )
endif( GENHTML STREQUAL "GENHTML-NOTFOUND" )

# Add lcov coverage target.
#
# The -fprofile-arcs and -ftest-coverage compilation and linking options must be used to
# generate coverage data.
#
# SYNOPSIS
#     add_lcov_coverage_target(
#         <target>
#         <executable>
#         [EXECUTABLE_ARGUMENTS <executable_argument>...]
#         [BASE_DIRECTORY <base_directory>]
#         [INCLUDE_BRANCH_COVERAGE]
#         [EXCLUDE_EXTERNAL_SOURCE_FILES]
#         [REMOVE <pattern>...]
#     )
# OPTIONS
#     <executable>
#         Specify the executable to collect coverage data from.
#     <target>
#         Specify the name of the coverage target. The coverage report will be written to
#         "${CMAKE_CURRENT_BINARY_DIR}/<target>-report/".
#     BASE_DIRECTORY <base_directory>
#         Specify the base directory for relative paths. Equivalent to lcov's
#         "--base-directory <base_directory>" option. Defaults to
#         "${CMAKE_CURRENT_SOURCE_DIR}".
#     EXCLUDE_EXTERNAL_SOURCE_FILES
#         Exclude external source files from the coverage report. Equivalent to lcov's
#         "--no-external" option.
#     EXECUTABLE_ARGUMENTS <executable_argument>...
#         Specify the arguments to pass to <executable>.
#     INCLUDE_BRANCH_COVERAGE
#         Include branch coverage information in the coverage report.
#     REMOVE <pattern>...
#         Specify the patterns for source files to remove from the coverage report.
#         Equivalent to lcov's "--remove tracefile <pattern>..." option.
# EXAMPLES
#     add_lcov_coverage_target(
#         foo-automated-testing-coverage
#         ctest
#         EXECUTABLE_ARGUMENTS --tests-regex test-automated-foo*
#         INCLUDE_BRANCH_COVERAGE
#         EXCLUDE_EXTERNAL_SOURCE_FILES
#         REMOVE
#             */googletest/*
#             */include/foo/testing.h
#             */include/foo/testing/*
#             */source/foo/testing.h
#             */source/foo/testing/*
#             */test/automated/foo/*
#     )
function( add_lcov_coverage_target target executable )
    cmake_parse_arguments(
        add_lcov_coverage_target
        "EXCLUDE_EXTERNAL_SOURCE_FILES;INCLUDE_BRANCH_COVERAGE"
        "BASE_DIRECTORY"
        "EXECUTABLE_ARGUMENTS;REMOVE"
        ${ARGN}
    )

    if( DEFINED add_lcov_coverage_target_UNPARSED_ARGUMENTS )
        message( FATAL_ERROR "'${add_lcov_coverage_target_UNPARSED_ARGUMENTS}' are not supported arguments" )
    endif( DEFINED add_lcov_coverage_target_UNPARSED_ARGUMENTS )

    if( ${add_lcov_coverage_target_EXCLUDE_EXTERNAL_SOURCE_FILES} )
        set( lcov_no_external --no-external )
    endif( ${add_lcov_coverage_target_EXCLUDE_EXTERNAL_SOURCE_FILES} )

    if( ${add_lcov_coverage_target_INCLUDE_BRANCH_COVERAGE} )
        set( lcov_branch_coverage --rc lcov_branch_coverage=1 )
        set( genhtml_branch_coverage --rc genhtml_branch_coverage=1 )
    endif( ${add_lcov_coverage_target_INCLUDE_BRANCH_COVERAGE} )

    if( DEFINED add_lcov_coverage_target_BASE_DIRECTORY )
        set( lcov_base_directory "${add_lcov_coverage_target_BASE_DIRECTORY}" )
        set( genhtml_prefix "${add_lcov_coverage_target_BASE_DIRECTORY}" )
    else( DEFINED add_lcov_coverage_target_BASE_DIRECTORY )
        set( lcov_base_directory "${CMAKE_CURRENT_SOURCE_DIR}" )
        set( genhtml_prefix "${CMAKE_CURRENT_SOURCE_DIR}" )
    endif( DEFINED add_lcov_coverage_target_BASE_DIRECTORY )

    add_custom_target(
        "${target}"
        VERBATIM
        WORKING_DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}"
        COMMAND
            "${LCOV}"
            --zerocounters
            ${lcov_branch_coverage}
            --directory "${CMAKE_CURRENT_BINARY_DIR}"
        COMMAND
            "${LCOV}"
            --capture
            --initial
            ${lcov_branch_coverage}
            ${lcov_no_external}
            --directory "${CMAKE_CURRENT_BINARY_DIR}"
            --base-directory "${lcov_base_directory}"
            --output-file "${CMAKE_CURRENT_BINARY_DIR}/${target}-initial.info"
        COMMAND
            "${executable}"
            ${add_lcov_coverage_target_EXECUTABLE_ARGUMENTS}
        COMMAND
            "${LCOV}"
            --capture
            ${lcov_branch_coverage}
            ${lcov_no_external}
            --directory "${CMAKE_CURRENT_BINARY_DIR}"
            --base-directory "${lcov_base_directory}"
            --output-file "${CMAKE_CURRENT_BINARY_DIR}/${target}-executable.info"
        COMMAND
            "${LCOV}"
            ${lcov_branch_coverage}
            --add-tracefile "${CMAKE_CURRENT_BINARY_DIR}/${target}-initial.info"
            --add-tracefile "${CMAKE_CURRENT_BINARY_DIR}/${target}-executable.info"
            --output-file "${CMAKE_CURRENT_BINARY_DIR}/${target}-combined.info"
        COMMAND
            "${LCOV}"
            ${lcov_branch_coverage}
            --remove "${CMAKE_CURRENT_BINARY_DIR}/${target}-combined.info" ${add_lcov_coverage_target_REMOVE}
            --output-file "${CMAKE_CURRENT_BINARY_DIR}/${target}.info"
        COMMAND
            "${GENHTML}"
            ${genhtml_branch_coverage}
            --prefix "${genhtml_prefix}"
            --output-directory "${CMAKE_CURRENT_BINARY_DIR}/${target}-report"
            "${CMAKE_CURRENT_BINARY_DIR}/${target}.info"
        BYPRODUCTS
            "${CMAKE_CURRENT_BINARY_DIR}/${target}-initial.info"
            "${CMAKE_CURRENT_BINARY_DIR}/${target}-executable.info"
            "${CMAKE_CURRENT_BINARY_DIR}/${target}-combined.info"
            "${CMAKE_CURRENT_BINARY_DIR}/${target}.info"
            "${CMAKE_CURRENT_BINARY_DIR}/${target}-report/"
    )
endfunction( add_lcov_coverage_target )
