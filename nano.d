/*
    This file is part of the Nano distribution.

    https://github.com/senselogic/NANO

    Copyright (C) 2022 Eric Pelzer (ecstatic.coder@gmail.com)

    Nano is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, version 3.

    Nano is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with Nano.  If not, see <http://www.gnu.org/licenses/>.
*/

// -- IMPORTS

import core.stdc.stdlib : exit;
import std.conv : to;
import std.datetime : SysTime;
import std.file : dirEntries, exists, getTimes, mkdirRecurse, SpanMode;
import std.path : absolutePath;
import std.process : executeShell;
import std.range : empty;
import std.stdio : writeln, File;
import std.string : endsWith, indexOf, lastIndexOf, replace, split, startsWith;

// -- VARIABLES

bool
    KeepOptionIsEnabled;
double
    TargetSurfaceRatio;
string
    ToolPath,
    SourceFolderPath,
    TargetFolderPath;
string[]
    DefaultCommandArray,
    TargetQualityArray;
string[][ string ]
    CommandArrayByNameMap;

// -- FUNCTIONS

void PrintError(
    string message
    )
{
    writeln( "*** ERROR : ", message );
}

// ~~

void Abort(
    string message
    )
{
    PrintError( message );

    exit( -1 );
}

// ~~

void Abort(
    string message,
    Exception exception
    )
{
    PrintError( message );
    PrintError( exception.msg );

    exit( -1 );
}

// ~~

string GetPhysicalPath(
    string path
    )
{
    return path.replace( '/', '\\' );
}

// ~~

string GetLogicalPath(
    string path
    )
{
    return path.replace( '\\', '/' );
}

// ~~

string GetFolderPath(
    string file_path
    )
{
    long
        slash_character_index;

    slash_character_index = file_path.lastIndexOf( '/' );

    if ( slash_character_index >= 0 )
    {
        return file_path[ 0 .. slash_character_index + 1 ];
    }
    else
    {
        return "";
    }
}

// ~~

string GetFileName(
    string file_path
    )
{
    long
        slash_character_index;

    slash_character_index = file_path.lastIndexOf( '/' );

    if ( slash_character_index >= 0 )
    {
        return file_path[ slash_character_index + 1 .. $ ];
    }
    else
    {
        return file_path;
    }
}

// ~~

string GetFileLabel(
    string file_path
    )
{
    long
        dot_character_index;
    string
        file_name;

    file_name = GetFileName( file_path );
    dot_character_index = file_name.lastIndexOf( '.' );

    if ( dot_character_index >= 0 )
    {
        return file_name[ 0 .. dot_character_index ];
    }
    else
    {
        return file_name;
    }
}

// ~~

string GetFileExtension(
    string file_path
    )
{
    long
        dot_character_index;
    string
        file_name;

    file_name = GetFileName( file_path );
    dot_character_index = file_name.lastIndexOf( '.' );

    if ( dot_character_index >= 0 )
    {
        return file_name[ dot_character_index .. $ ];
    }
    else
    {
        return "";
    }
}

// ~~

string[] GetCommandArrayByName(
    string name
    )
{
    if ( name in CommandArrayByNameMap )
    {
        return CommandArrayByNameMap[ name ];
    }
    else
    {
        return DefaultCommandArray;
    }
}

// ~~

double GetTargetSurfaceRatio(
    string text
    )
{
    string[]
        part_array;

    part_array = text.split( '_' );

    if ( part_array.length == 2 )
    {
        return part_array[ 0 ].to!double() / part_array[ 1 ].to!double();
    }
    else if ( part_array.length == 1 )
    {
        return part_array[ 0 ].to!double();
    }
    else
    {
        return 0.0;
    }
}

// ~~

string GetTargetFileExtension(
    char command_code
    )
{
    switch ( command_code )
    {
        case 'a' : return ".avif";
        case 'j' : return ".jpg";
        case 'p' : return ".png";
        case 'w' : return ".webp";
        default : return "";
    }
}

// ~~

string[] GetTargetWidthArray(
    string target_width_format
    )
{
    switch ( target_width_format )
    {
        case "n" : return [ "80" ];
        case "n2" : return [ "80", "160" ];
        case "n3" : return [ "80", "160", "240" ];
        case "n4" : return [ "80", "160", "240", "320" ];
        case "t" : return [ "160" ];
        case "t2" : return [ "160", "320" ];
        case "t3" : return [ "160", "320", "480" ];
        case "t4" : return [ "160", "320", "480", "640" ];
        case "s" : return [ "320" ];
        case "s2" : return [ "320", "640" ];
        case "s3" : return [ "320", "640", "960" ];
        case "s4" : return [ "320", "640", "960", "1280" ];
        case "c" : return [ "480" ];
        case "c2" : return [ "480", "960" ];
        case "c3" : return [ "480", "960", "1440" ];
        case "c4" : return [ "480", "960", "1440", "1920" ];
        case "m" : return [ "640" ];
        case "m2" : return [ "640", "1280" ];
        case "m3" : return [ "640", "1280", "1920" ];
        case "m4" : return [ "640", "1280", "1920", "2560" ];
        case "l" : return [ "960" ];
        case "l2" : return [ "960", "1920" ];
        case "l3" : return [ "960", "1920", "2880" ];
        case "l4" : return [ "960", "1920", "2880", "3840" ];
        case "b" : return [ "1280" ];
        case "b2" : return [ "1280", "2560" ];
        case "b3" : return [ "1280", "2560", "3840" ];
        case "h" : return [ "1600" ];
        case "h2" : return [ "1600", "3200" ];
        case "f" : return [ "1920" ];
        case "f2" : return [ "1920", "3840" ];
        case "u" : return [ "3840" ];
        default : return target_width_format.split( ',' );
    }
}

// ~~

SysTime GetFileModificationTime(
    string file_path
    )
{
    SysTime
        file_access_time,
        file_modification_time;

    file_path.getTimes( file_access_time, file_modification_time );

    return file_modification_time;
}

// ~~

void WriteImage(
    string source_file_path,
    string target_file_path,
    string target_file_extension,
    string target_width,
    double target_surface_ratio,
    string target_quality,
    )
{
    double
        real_target_width;
    long
        target_pixel_count;
    string
        command;

    target_file_path ~= "." ~ target_width ~ target_file_extension;

    if ( !KeepOptionIsEnabled
         || !target_file_path.exists()
         || source_file_path.GetFileModificationTime() > target_file_path.GetFileModificationTime() )
    {
        writeln( "Writing file : ", target_file_path );

        command
            = ToolPath.GetPhysicalPath()
              ~ " \""
              ~ source_file_path.GetPhysicalPath()
              ~ "\"";

        if ( target_file_extension == ".jpg" )
        {
            command
                ~= " -background white -alpha remove -alpha off";
        }

        if ( target_surface_ratio > 0.0 )
        {
            real_target_width = target_width.to!double();
            target_pixel_count = ( real_target_width * real_target_width / target_surface_ratio ).to!long();

            command
                ~= " -resize "
                   ~ target_pixel_count.to!string()
                   ~ "@";
        }
        else
        {
            command
                ~= " -resize "
                   ~ target_width
                   ~ "x";
        }

        if ( target_file_extension == ".jpg" )
        {
            command
                ~= " -interlace Plane";
        }

        command
            ~= " -quality "
               ~ target_quality
               ~ " -strip \""
               ~ target_file_path.GetPhysicalPath()
               ~ "\"";

        executeShell( command );
    }
    else
    {
        writeln( "Keeping file: ", target_file_path );
    }
}

// ~~

void ProcessFile(
    string source_file_path,
    string source_folder_path,
    string target_file_name,
    string[] command_array
    )
{
    char
        command_code;
    double
        target_surface_ratio;
    long
        command_index;
    string
        command,
        target_extension_format,
        target_file_extension,
        target_file_path,
        target_folder_path,
        target_quality,
        target_width_format;
    string[]
        command_part_array,
        target_quality_array,
        target_width_array;

    writeln( "Reading file : ", source_file_path );

    if ( command_array.length == 0 )
    {
        command_array = DefaultCommandArray;
    }

    target_surface_ratio = TargetSurfaceRatio;

    for ( command_index = 0;
          command_index < command_array.length;
          ++command_index )
    {
        command = command_array[ command_index ];
        command_code = command[ 0 ];

        if ( command_code == '@' )
        {
            command_array
                = command_array[ 0 .. command_index ]
                  ~ GetCommandArrayByName( command[ 1 .. $ ] )
                  ~ command_array[ command_index + 1 .. $ ];

            --command_index;
        }
        else if ( command_code == 's' )
        {
            target_surface_ratio = GetTargetSurfaceRatio( command[ 1 .. $ ] );
        }
        else if ( "ajpw".indexOf( command_code ) >= 0 )
        {
            target_file_extension = GetTargetFileExtension( command_code );
            command_part_array = command.split( '@' );
            target_width_array = GetTargetWidthArray( command_part_array[ 0 ][ 1 .. $ ] );

            if ( command_part_array.length == 2 )
            {
                target_quality_array = command_part_array[ 1 ].split( ',' );
            }
            else
            {
                target_quality_array = TargetQualityArray;
            }

            if ( !target_width_array.empty )
            {
                target_folder_path = TargetFolderPath ~ source_folder_path[ SourceFolderPath.length .. $ ];

                if ( !exists( target_folder_path ) )
                {
                    target_folder_path.mkdirRecurse();
                }

                target_file_path = target_folder_path ~ target_file_name;

                foreach ( target_width_index, target_width; target_width_array )
                {
                    target_quality = target_quality_array[ target_width_index % target_quality_array.length ];

                    WriteImage(
                        source_file_path,
                        target_file_path,
                        target_file_extension,
                        target_width,
                        target_surface_ratio,
                        target_quality
                        );
                }
            }
        }
    }
}

// ~~

void ProcessFiles(
    )
{
    string
        source_file_extension,
        source_file_label,
        source_file_name,
        source_file_path,
        source_folder_path,
        target_file_name;
    string[]
        source_file_name_part_array,
        command_array;

    writeln( "Reading folder : ", SourceFolderPath );

    try
    {
        foreach ( source_folder_entry; dirEntries( SourceFolderPath, SpanMode.depth ) )
        {
            if ( source_folder_entry.isFile )
            {
                source_file_path = source_folder_entry.GetLogicalPath();
                source_folder_path = source_file_path.GetFolderPath();
                source_file_name = source_file_path.GetFileName();
                source_file_name_part_array = source_file_name.split( '.' );

                if ( source_file_path.startsWith( SourceFolderPath )
                     && source_file_name_part_array.length >= 2 )
                {
                    source_file_label = source_file_name_part_array[ 0 ];
                    command_array = source_file_name_part_array[ 1 .. $ - 1 ];
                    source_file_extension = "." ~ source_file_name_part_array[ $ - 1 ];

                    if ( source_file_extension == ".avif"
                         || source_file_extension == ".jpeg"
                         || source_file_extension == ".jpg"
                         || source_file_extension == ".png"
                         || source_file_extension == ".webp" )
                    {
                        target_file_name = source_file_label ~ source_file_extension;

                        ProcessFile(
                            source_file_path,
                            source_folder_path,
                            target_file_name,
                            command_array
                            );
                    }
                }
            }
        }
    }
    catch ( Exception exception )
    {
        Abort( "Can't process files", exception );
    }
}

// ~~

void main(
    string[] argument_array
    )
{
    long
        argument_count;
    string
        option;

    argument_array = argument_array[ 1 .. $ ];

    TargetSurfaceRatio = 0.0;
    TargetQualityArray = [ "90", "80", "70", "60" ];
    DefaultCommandArray = null;
    CommandArrayByNameMap = null;
    ToolPath = "convert";
    KeepOptionIsEnabled = false;
    SourceFolderPath = "";
    TargetFolderPath = "";

    while ( argument_array.length >= 1
            && argument_array[ 0 ].startsWith( "--" ) )
    {
        option = argument_array[ 0 ];

        argument_array = argument_array[ 1 .. $ ];

        if ( option == "--ratio"
             && argument_array.length >= 1 )
        {
            TargetSurfaceRatio = GetTargetSurfaceRatio( argument_array[ 0 ] );
            argument_array = argument_array[ 1 .. $ ];
        }
        else if ( option == "--quality"
             && argument_array.length >= 1 )
        {
            TargetQualityArray = argument_array[ 0 ].split( ',' );
            argument_array = argument_array[ 1 .. $ ];
        }
        else if ( option == "--default"
             && argument_array.length >= 1 )
        {
            DefaultCommandArray = argument_array[ 0 ].split( '.' );
            argument_array = argument_array[ 1 .. $ ];
        }
        else if ( option == "--definition"
             && argument_array.length >= 2 )
        {
            CommandArrayByNameMap[ argument_array[ 0 ] ] = argument_array[ 1 ].split( '.' );
            argument_array = argument_array[ 2 .. $ ];
        }
        else if ( option == "--tool"
                  && argument_array.length >= 1 )
        {
            ToolPath = argument_array[ 0 ];
            argument_array = argument_array[ 1 .. $ ];
        }
        else if ( option == "--keep" )
        {
            KeepOptionIsEnabled = true;
        }
        else
        {
            break;
        }
    }

    if ( argument_array.length == 2 )
    {
        SourceFolderPath = argument_array[ 0 ].GetLogicalPath();
        TargetFolderPath = argument_array[ 1 ].GetLogicalPath();
    }

    if ( SourceFolderPath.GetLogicalPath().endsWith( '/' )
         && TargetFolderPath.GetLogicalPath().endsWith( '/' ) )
    {
        ProcessFiles();
    }
    else
    {
        writeln( "Usage :" );
        writeln( "    nano [options] <source folder path> <target folder path>" );

        Abort( "Invalid arguments : " ~ argument_array.to!string() );
    }
}
