# cmake-utilities
#
# Copyright 2019-2023, Andrew Countryman <apcountryman@gmail.com> and the cmake-utilities
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

# File: git-utilities.cmake
# Description: CMake Git utilities.

# Get the path to the nearest Git repository in the source tree.
#
# If a Git repository has not been found by the time the search reaches CMAKE_SOURCE_DIR,
# a fatal error will be reported.
#
# SYNOPSIS
#     get_git_repository_path( <git_repository_path> )
#
# OPTIONS
#     <git_repository_path>
#         The variable to store the path to the Git repository in.
#
# EXAMPLES
#     get_git_repository_path( GIT_REPOSITORY_PATH )
function( get_git_repository_path git_repository_path )
    set( source_directory "${CMAKE_CURRENT_SOURCE_DIR}" )
    set( repository_path "${source_directory}/.git" )
    while( NOT EXISTS "${repository_path}" )
        if( source_directory STREQUAL CMAKE_SOURCE_DIR )
            message( FATAL_ERROR "source tree does not contain a git repository" )
        endif( source_directory STREQUAL CMAKE_SOURCE_DIR )

        get_filename_component( source_directory "${source_directory}" DIRECTORY )
        set( repository_path "${source_directory}/.git" )
    endwhile( NOT EXISTS "${repository_path}" )

    if( IS_DIRECTORY "${repository_path}" )
        set( ${git_repository_path} "${repository_path}" PARENT_SCOPE )
    else( IS_DIRECTORY "${repository_path}" )
        file( READ "${repository_path}" repository_path )
        string( REPLACE "gitdir: " "" repository_path "${repository_path}" )
        string( STRIP "${repository_path}" repository_path )
        set( repository_path "${source_directory}/${repository_path}" )
        get_filename_component( repository_path "${repository_path}" ABSOLUTE )

        set( ${git_repository_path} "${repository_path}" PARENT_SCOPE )
    endif( IS_DIRECTORY "${repository_path}" )
endfunction( get_git_repository_path )

# Get the path to the nearest Git repository's HEAD file.
#
# If a Git repository has not been found by the time the search reaches CMAKE_SOURCE_DIR,
# a fatal error will be reported.
#
# If the HEAD file does not exist, a fatal error will be reported.
#
# SYNOPSIS
#     get_git_repository_head_file_path( <git_repository_head_file_path> )
#
# OPTIONS
#     <git_repository_head_file_path>
#         The variable to store the path to the Git repository's HEAD file in.
#
# EXAMPLES
#     get_git_repository_head_file_path( GIT_REPOSITORY_HEAD_FILE_PATH )
function( get_git_repository_head_file_path git_repository_head_file_path )
    get_git_repository_path( repository_path )
    set( head_file_path "${repository_path}/HEAD" )

    if( NOT EXISTS "${head_file_path}" )
        message( FATAL_ERROR "${head_file_path} does not exist" )
    endif( NOT EXISTS "${head_file_path}" )

    set( ${git_repository_head_file_path} "${head_file_path}" PARENT_SCOPE )
endfunction( get_git_repository_head_file_path )

# Get the contents of the nearest Git repository's HEAD file.
#
# If a Git repository has not been found by the time the search reaches CMAKE_SOURCE_DIR,
# a fatal error will be reported.
#
# If the HEAD file does not exist, a fatal error will be reported.
#
# SYNOPSIS
#     get_git_repository_head_file_contents( <git_repository_head_file_contents> )
#
# OPTIONS
#     <git_repository_head_file_contents>
#         The variable to store the contents of the Git repository's HEAD file in.
#
# EXAMPLES
#     get_git_repository_head_file_contents( GIT_REPOSITORY_HEAD_FILE_CONTENTS )
function( get_git_repository_head_file_contents git_repository_head_file_contents )
    get_git_repository_head_file_path( head_file_path )

    file( READ "${head_file_path}" head_file_contents )
    string( STRIP "${head_file_contents}" head_file_contents )

    set( ${git_repository_head_file_contents} "${head_file_contents}" PARENT_SCOPE )
endfunction( get_git_repository_head_file_contents )

# Get the state of the nearest Git repository's HEAD.
#
# If a Git repository has not been found by the time the search reaches CMAKE_SOURCE_DIR,
# a fatal error will be reported.
#
# If the HEAD file does not exist, a fatal error will be reported.
#
# SYNOPSIS
#     get_git_repository_head_state( <git_repository_head_is_detached> )
#
# OPTIONS
#     <git_repository_head_is_detached>
#         The variable to store the state of the Git repository's head in. If the Git
#         repository's HEAD is detached, this variable will be set to TRUE. If the Git
#         repository's HEAD is not detached, this variable will be set to FALSE.
#
# EXAMPLES
#     get_git_repository_head_state( GIT_REPOSITORY_HEAD_IS_DETACHED )
function( get_git_repository_head_state git_repository_head_is_detached )
    get_git_repository_head_file_contents( head_file_contents )

    if( head_file_contents MATCHES "^ref: " )
        set( ${git_repository_head_is_detached} FALSE PARENT_SCOPE )
    else( head_file_contents MATCHES "^ref: " )
        set( ${git_repository_head_is_detached} TRUE PARENT_SCOPE )
    endif( head_file_contents MATCHES "^ref: " )
endfunction( get_git_repository_head_state )

# Get the path to the nearest Git repository's active branch head file.
#
# If a Git repository has not been found by the time the search reaches CMAKE_SOURCE_DIR,
# a fatal error will be reported.
#
# If the HEAD file does not exist, a fatal error will be reported.
#
# If the Git repository's HEAD is detached, a fatal error will be reported.
#
# If the head file for the active branch does not exist, a fatal error will be reported.
#
# SYNOPSIS
#     get_git_repository_active_branch_head_file_path(
#         <git_repository_active_branch_head_file_path>
#     )
#
# OPTIONS
#     <git_repository_active_branch_head_file_path>
#         The variable to store the path to the Git repository's active branch head file
#         in.
#
# EXAMPLES
#     get_git_repository_active_branch_head_file_path( GIT_REPOSITORY_ACTIVE_BRANCH_HEAD_FILE_PATH )
function( get_git_repository_active_branch_head_file_path git_repository_active_branch_head_file_path )
    get_git_repository_head_state( head_is_detached )
    if( head_is_detached )
        message( FATAL_ERROR "detached HEAD" )
    endif( head_is_detached )

    get_git_repository_path( repository_path )
    get_git_repository_head_file_contents( active_branch_head_file_path )
    string( REPLACE "ref: " "" active_branch_head_file_path "${active_branch_head_file_path}" )
    string( STRIP "${active_branch_head_file_path}" active_branch_head_file_path )
    set( active_branch_head_file_path "${repository_path}/${active_branch_head_file_path}" )

    if( NOT EXISTS "${active_branch_head_file_path}" )
        message( FATAL_ERROR "${active_branch_head_file_path} does not exist" )
    endif( NOT EXISTS "${active_branch_head_file_path}" )

    set( ${git_repository_active_branch_head_file_path} "${active_branch_head_file_path}" PARENT_SCOPE )
endfunction( get_git_repository_active_branch_head_file_path )

# Execute a Git command. The command will be executed in CMAKE_CURRENT_SOURCE_DIR. The
# nearest Git repository's HEAD file (and the active branch's head file if the repository
# is not in a detached HEAD state) will be registered as CMake configure dependencies for
# CMAKE_CURRENT_SOURCE_DIR to trigger CMake reconfiguration (and associated execution of
# the command) each time the repository's HEAD changes.
#
# If a Git repository has not been found by the time the search reaches CMAKE_SOURCE_DIR,
# a fatal error will be reported.
#
# If the HEAD file does not exist, a fatal error will be reported.
#
# If the repository's HEAD is not detached and the head file for the active branch does
# not exist, a fatal error will be reported.
#
# If execution of the command fails, a fatal error will be reported.
#
# SYNOPSIS
#     execute_git_command(
#         <git_command_output>
#         COMMAND <command>
#     )
#
# OPTIONS
#     <git_command_output>
#         The variable to store the output of the command in.
#     COMMAND <command>
#         The Git command to execute and its associated arguments.
#
# EXAMPLES
#     execute_git_command(
#         VERSION
#         COMMAND describe --always --dirty
#     )
#     execute_git_command(
#         AUTHOR_DATE
#         COMMAND show --date=short -s --format=format:%ad
#     )
function( execute_git_command git_command_output )
    cmake_parse_arguments(
        execute_git_command
        ""
        ""
        "COMMAND"
        ${ARGN}
    )

    if( execute_git_command_UNPARSED_ARGUMENTS )
        message( FATAL_ERROR "'${execute_git_command_UNPARSED_ARGUMENTS}' are not supported arguments" )
    endif( execute_git_command_UNPARSED_ARGUMENTS )

    if( NOT execute_git_command_COMMAND )
        message( FATAL_ERROR "'COMMAND' not specified" )
    endif( NOT execute_git_command_COMMAND )

    get_git_repository_head_file_path( head_file_path )
    set_property(
        DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}"
        APPEND
        PROPERTY CMAKE_CONFIGURE_DEPENDS "${head_file_path}"
    )

    get_git_repository_head_state( head_is_detached )
    if( NOT head_is_detached )
        get_git_repository_active_branch_head_file_path( active_branch_head_file_path )
        set_property(
            DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}"
            APPEND
            PROPERTY CMAKE_CONFIGURE_DEPENDS "${active_branch_head_file_path}"
        )
    endif( NOT head_is_detached )

    execute_process(
        COMMAND git ${execute_git_command_COMMAND}
        WORKING_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}"
        RESULT_VARIABLE command_result
        OUTPUT_VARIABLE command_output
        ERROR_VARIABLE command_error
        OUTPUT_STRIP_TRAILING_WHITESPACE
        ERROR_STRIP_TRAILING_WHITESPACE
    )
    if( NOT command_result EQUAL 0 )
        message( FATAL_ERROR "git ${execute_git_command_COMMAND}: ${command_error}" )
    endif( NOT command_result EQUAL 0 )

    set( ${git_command_output} "${command_output}" PARENT_SCOPE )
endfunction( execute_git_command )
