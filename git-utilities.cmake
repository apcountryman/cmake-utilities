# cmake-utilities
#
# Copyright 2019 Andrew Countryman <apcountryman@gmail.com>
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

cmake_minimum_required( VERSION 3.13.4 )

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
