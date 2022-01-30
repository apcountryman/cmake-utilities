# cmake-utilities
#
# Copyright 2019-2022, Andrew Countryman <apcountryman@gmail.com> and the cmake-utilities
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

# File: plantuml-utilities.cmake
# Description: CMake PlantUML utilities.

find_program( PLANTUML plantuml )
mark_as_advanced( PLANTUML )
if( PLANTUML STREQUAL "PLANTUML-NOTFOUND" )
    message( FATAL_ERROR "plantuml not found" )
endif( PLANTUML STREQUAL "PLANTUML-NOTFOUND" )

# Generate a PlantUML diagram.
#
# SYNOPSIS
#     add_plantuml_diagram(
#         <source>
#         [FILE <file>]
#         [TARGET <target>]
#     )
#
# OPTIONS
#     <source>
#         The PlantUML source file to generate the diagram from.
#     FILE <file>
#         The variable to store the absolute path of the generated diagram in.
#     TARGET <target>
#         The variable to store the name of the target that triggers generation of the
#         diagram in.
#
# EXAMPLES
#     add_plantuml_diagram( foo.plantuml )
#     add_plantuml_diagram(
#         foo.plantuml
#         FILE FOO_FILE
#     )
#     add_plantuml_diagram(
#         foo.plantuml
#         TARGET FOO_TARGET
#     )
#     add_plantuml_diagram(
#         foo.plantuml
#         FILE   FOO_FILE
#         TARGET FOO_TARGET
#     )
function( add_plantuml_diagram source )
    cmake_parse_arguments(
        add_plantuml_diagram
        ""
        "FILE;TARGET"
        ""
        ${ARGN}
    )

    if( IS_ABSOLUTE "${source}" )
        set( source_file "${source}" )
    else( IS_ABSOLUTE "${source}" )
        set( source_file "${CMAKE_CURRENT_SOURCE_DIR}/${source}" )
    endif( IS_ABSOLUTE "${source}" )

    get_filename_component( diagram_name "${source_file}" NAME_WE )
    set( diagram_file "${CMAKE_CURRENT_BINARY_DIR}/${diagram_name}.png" )
    set( diagram_target "${diagram_name}-png" )

    add_custom_command(
        OUTPUT "${diagram_file}"
        COMMAND "${PLANTUML}" -output "${CMAKE_CURRENT_BINARY_DIR}" "${source_file}"
        MAIN_DEPENDENCY "${source_file}"
    )
    add_custom_target(
        "${diagram_target}" ALL
        DEPENDS "${diagram_file}"
    )

    if( add_plantuml_diagram_FILE )
        set( ${add_plantuml_diagram_FILE} "${diagram_file}" PARENT_SCOPE )
    endif( add_plantuml_diagram_FILE )

    if( add_plantuml_diagram_TARGET )
        set( ${add_plantuml_diagram_TARGET} "${diagram_target}" PARENT_SCOPE )
    endif( add_plantuml_diagram_TARGET )
endfunction( add_plantuml_diagram )
