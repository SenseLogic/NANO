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
    KeepOptionIsEnabled,
    RecursiveOptionIsEnabled;
double
    TargetSurfaceRatio;
string
    ToolPath,
    SourceFolderPath,
    TargetFolderPath,
    TargetFileNameFormat;
string[]
    DefaultCommandArray,
    TargetQualityArray;
string[][ string ]
    CommandArrayByNameMap,
    WidthArrayByNameMap;

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

string[] GetCommandArray(
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
        case 'h' : return ".heic";
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
    if ( target_width_format in WidthArrayByNameMap )
    {
        return WidthArrayByNameMap[ target_width_format ];
    }
    else
    {
        return target_width_format.split( ',' );
    }
}

// ~~

string GetTargetFileName(
    string source_file_label,
    string source_file_extension,
    string target_width,
    string target_quality,
    string target_file_extension
    )
{
    return
        TargetFileNameFormat
            .replace( "{l}", source_file_label )
            .replace( "{e}", source_file_extension[ 1 .. $ ] )
            .replace( "{w}", target_width )
            .replace( "{q}", target_quality )
            .replace( "{x}", target_file_extension[ 1 .. $ ] );
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
        writeln( "Keeping file : ", target_file_path );
    }
}

// ~~

void ProcessFile(
    string source_file_path,
    string source_folder_path,
    string source_file_label,
    string source_file_extension,
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
        target_file_name,
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
                  ~ GetCommandArray( command[ 1 .. $ ] )
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

                foreach ( target_width_index, target_width; target_width_array )
                {
                    target_quality = target_quality_array[ target_width_index % target_quality_array.length ];

                    target_file_name
                        = GetTargetFileName(
                              source_file_label,
                              source_file_extension,
                              target_width,
                              target_quality,
                              target_file_extension
                              );

                    target_file_path = target_folder_path ~ target_file_name;

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
        foreach ( source_folder_entry; dirEntries( SourceFolderPath, RecursiveOptionIsEnabled ? SpanMode.depth : SpanMode.shallow ) )
        {
            if ( source_folder_entry.isFile )
            {
                source_file_path = source_folder_entry.name.GetLogicalPath();
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
                         || source_file_extension == ".heic"
                         || source_file_extension == ".heif"
                         || source_file_extension == ".jpg"
                         || source_file_extension == ".png"
                         || source_file_extension == ".svg"
                         || source_file_extension == ".webp" )
                    {
                        ProcessFile(
                            source_file_path,
                            source_folder_path,
                            source_file_label,
                            source_file_extension,
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
    TargetQualityArray = [ "80" ];
    TargetFileNameFormat = "{l}.{e}.{w}.{x}";
    DefaultCommandArray = null;
    WidthArrayByNameMap = null;
    WidthArrayByNameMap[ "n" ] = [ "80" ];
    WidthArrayByNameMap[ "n2" ] = [ "80", "160" ];
    WidthArrayByNameMap[ "n3" ] = [ "80", "160", "240" ];
    WidthArrayByNameMap[ "n4" ] = [ "80", "160", "240", "320" ];
    WidthArrayByNameMap[ "t" ] = [ "160" ];
    WidthArrayByNameMap[ "t2" ] = [ "160", "320" ];
    WidthArrayByNameMap[ "t3" ] = [ "160", "320", "480" ];
    WidthArrayByNameMap[ "t4" ] = [ "160", "320", "480", "640" ];
    WidthArrayByNameMap[ "s" ] = [ "320" ];
    WidthArrayByNameMap[ "s2" ] = [ "320", "640" ];
    WidthArrayByNameMap[ "s3" ] = [ "320", "640", "960" ];
    WidthArrayByNameMap[ "s4" ] = [ "320", "640", "960", "1280" ];
    WidthArrayByNameMap[ "c" ] = [ "480" ];
    WidthArrayByNameMap[ "c2" ] = [ "480", "960" ];
    WidthArrayByNameMap[ "c3" ] = [ "480", "960", "1440" ];
    WidthArrayByNameMap[ "c4" ] = [ "480", "960", "1440", "1920" ];
    WidthArrayByNameMap[ "m" ] = [ "640" ];
    WidthArrayByNameMap[ "m2" ] = [ "640", "1280" ];
    WidthArrayByNameMap[ "m3" ] = [ "640", "1280", "1920" ];
    WidthArrayByNameMap[ "m4" ] = [ "640", "1280", "1920", "2560" ];
    WidthArrayByNameMap[ "l" ] = [ "960" ];
    WidthArrayByNameMap[ "l2" ] = [ "960", "1920" ];
    WidthArrayByNameMap[ "l3" ] = [ "960", "1920", "2880" ];
    WidthArrayByNameMap[ "l4" ] = [ "960", "1920", "2880", "3840" ];
    WidthArrayByNameMap[ "b" ] = [ "1280" ];
    WidthArrayByNameMap[ "b2" ] = [ "1280", "2560" ];
    WidthArrayByNameMap[ "b3" ] = [ "1280", "2560", "3840" ];
    WidthArrayByNameMap[ "h" ] = [ "1600" ];
    WidthArrayByNameMap[ "h2" ] = [ "1600", "3200" ];
    WidthArrayByNameMap[ "f" ] = [ "1920" ];
    WidthArrayByNameMap[ "f2" ] = [ "1920", "3840" ];
    WidthArrayByNameMap[ "u" ] = [ "3840" ];
    CommandArrayByNameMap = null;
    ToolPath = "convert";
    RecursiveOptionIsEnabled = false;
    KeepOptionIsEnabled = false;
    SourceFolderPath = "";
    TargetFolderPath = "";

    while ( argument_array.length >= 1
            && argument_array[ 0 ].startsWith( "--" ) )
    {
        option = argument_array[ 0 ];

        argument_array = argument_array[ 1 .. $ ];

        if ( option == "--surface-ratio"
             && argument_array.length >= 1 )
        {
            TargetSurfaceRatio = GetTargetSurfaceRatio( argument_array[ 0 ] );
            argument_array = argument_array[ 1 .. $ ];
        }
        else if ( option == "--quality-list"
             && argument_array.length >= 1 )
        {
            TargetQualityArray = argument_array[ 0 ].split( ',' );
            argument_array = argument_array[ 1 .. $ ];
        }
        else if ( option == "--width-list"
             && argument_array.length >= 2 )
        {
            WidthArrayByNameMap[ argument_array[ 0 ] ] = argument_array[ 1 ].split( ',' );
            argument_array = argument_array[ 2 .. $ ];
        }
        else if ( option == "--command-list"
             && argument_array.length >= 2 )
        {
            CommandArrayByNameMap[ argument_array[ 0 ] ] = argument_array[ 1 ].split( '.' );
            argument_array = argument_array[ 2 .. $ ];
        }
        else if ( option == "--default-command-list"
             && argument_array.length >= 1 )
        {
            DefaultCommandArray = argument_array[ 0 ].split( '.' );
            argument_array = argument_array[ 1 .. $ ];
        }
        else if ( option == "--file-name-format"
             && argument_array.length >= 1 )
        {
            TargetFileNameFormat = argument_array[ 0 ];
            argument_array = argument_array[ 1 .. $ ];
        }
        else if ( option == "--tool-path"
                  && argument_array.length >= 1 )
        {
            ToolPath = argument_array[ 0 ];
            argument_array = argument_array[ 1 .. $ ];
        }
        else if ( option == "--recursive" )
        {
            RecursiveOptionIsEnabled = true;
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
        writeln( "Options :" );
        writeln( "    --surface-ratio <surface ratio>" );
        writeln( "    --quality-list <quality list>" );
        writeln( "    --width-list <name> <width list>" );
        writeln( "    --command-list <name> <command list>" );
        writeln( "    --default-command-list <default command list>" );
        writeln( "    --file-name-format <image name format>" );
        writeln( "    --tool-path <tool path>" );
        writeln( "    --recursive" );
        writeln( "    --keep" );

        Abort( "Invalid arguments : " ~ argument_array.to!string() );
    }
}
