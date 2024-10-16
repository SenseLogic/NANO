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
import std.file : copy, dirEntries, exists, getTimes, mkdirRecurse, readText, thisExePath, SpanMode;
import std.path : absolutePath, globMatch;
import std.process : executeShell;
import std.range : empty;
import std.regex : match, regex;
import std.stdio : writeln, File;
import std.string : endsWith, indexOf, join, lastIndexOf, replace, split, startsWith, strip;

// -- VARIABLES

bool
    KeepOptionIsEnabled,
    RecursiveOptionIsEnabled,
    VerboseOptionIsEnabled;
string
    SourceFolderPath,
    TargetFolderPath,
    ConvertToolPath;

// -- TYPES

class CONFIGURATION
{
    // -- ATTRIBUTES

    string
        FolderPath;
    string[]
        FilterArray;
    string[][ string ]
        SizeArrayByNameMap,
        QualityArrayByNameMap,
        CommandArrayByNameMap;
    double
        DefaultFramingRatio,
        DefaultCroppingRatio;
    string
        DefaultCroppingOrigin;
    string[]
        DefaultSizeArray,
        DefaultQualityArray,
        DefaultCommandArray;
    string
        DefaultName;

    // -- CONSTRUCTORS

    this(
        )
    {
        DefaultFramingRatio = -1;
        DefaultCroppingRatio = -1;
    }

    // -- INQUIRIES

    void Dump(
        string indentation = ""
        )
    {
        writeln( indentation, "FolderPath: ", FolderPath );
        writeln( indentation, "FilterArray: ", FilterArray );
        writeln( indentation, "SizeArrayByNameMap: ", SizeArrayByNameMap );
        writeln( indentation, "QualityArrayByNameMap: ", QualityArrayByNameMap );
        writeln( indentation, "CommandArrayByNameMap: ", CommandArrayByNameMap );
        writeln( indentation, "DefaultFramingRatio: ", DefaultFramingRatio );
        writeln( indentation, "DefaultCroppingRatio: ", DefaultCroppingRatio );
        writeln( indentation, "DefaultCroppingOrigin: ", DefaultCroppingOrigin );
        writeln( indentation, "DefaultSizeArray: ", DefaultSizeArray );
        writeln( indentation, "DefaultQualityArray: ", DefaultQualityArray );
        writeln( indentation, "DefaultCommandArray: ", DefaultCommandArray );
        writeln( indentation, "DefaultName: ", DefaultName );
    }

    // ~~

    bool MatchesFilePath(
        string file_path,
        string filter
        )
    {
        string
            file_name,
            file_name_filter,
            folder_path,
            folder_path_filter;

        folder_path = file_path.GetFolderPath();
        file_name = file_path.GetFileName();

        if ( !folder_path.startsWith( FolderPath ) )
        {
            return false;
        }
        else
        {
            folder_path_filter = filter.GetFolderPath();
            file_name_filter = filter.GetFileName();

            if ( folder_path_filter != "" )
            {
                foreach ( special_character; "^$.|?*+()[]{}#".split( "" ) )
                {
                    folder_path_filter = folder_path_filter.replace( special_character, "\\" ~ special_character );
                }

                if ( folder_path_filter.startsWith( '/' ) )
                {
                    folder_path_filter = FolderPath ~ folder_path_filter[ 1 .. $ ];
                }
                else
                {
                    folder_path_filter = FolderPath ~ "(.+?/)?" ~ folder_path_filter;
                }

                folder_path_filter = folder_path_filter.replace( "//", "/(.+?/)?" );

                if ( !folder_path.match( regex( "^" ~ folder_path_filter ~ "$" ) ) )
                {
                    return false;
                }
            }

            return
                file_name_filter == ""
                || file_name.globMatch( file_name_filter );
        }
    }

    // ~~

    bool MatchesFilePath(
        string file_path
        )
    {
        if ( FilterArray.length == 0 )
        {
            return true;
        }
        else
        {
            foreach ( filter; FilterArray )
            {
                if ( MatchesFilePath( file_path, filter ) )
                {
                    return true;
                }
            }

            return false;
        }
    }

    // ~~

    string[] GetSizeArray(
        string size_format
        )
    {
        string[]
            size_array;

        if ( size_format in SizeArrayByNameMap )
        {
            size_array = SizeArrayByNameMap[ size_format ];
        }
        else
        {
            size_array = size_format.split( ',' );

            if ( size_array.length == 0 )
            {
                size_array = DefaultSizeArray;
            }
        }

        return size_array;
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

    string GetTargetFileName(
        string source_file_label,
        string source_file_extension,
        string target_size,
        string target_dimension,
        string target_width,
        string target_height,
        string target_factor,
        string target_quality,
        string target_file_extension
        )
    {
        return
            DefaultName
                .replace( "{l}", source_file_label )
                .replace( "{e}", source_file_extension[ 1 .. $ ] )
                .replace( "{s}", target_size )
                .replace( "{d}", target_dimension )
                .replace( "{w}", target_width )
                .replace( "{h}", target_height )
                .replace( "{f}", target_factor )
                .replace( "{q}", target_quality )
                .replace( "{x}", target_file_extension[ 1 .. $ ] );
    }
}

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

string GetApplicationFolderPath(
    )
{
    return thisExePath.GetLogicalPath().GetFolderPath();
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

bool IsUpdatedFile(
    string source_file_path,
    string target_file_path
    )
{
    return
        !KeepOptionIsEnabled
        || !target_file_path.exists()
        || source_file_path.GetFileModificationTime() > target_file_path.GetFileModificationTime();
}

// ~~

string ReadText(
    string file_path
    )
{
    string
        file_text;

    writeln( "Reading file : ", file_path );

    try
    {
        file_text = file_path.readText();
    }
    catch ( Exception exception )
    {
        Abort( "Can't read file : " ~ file_path, exception );
    }

    return file_text;
}

// ~~

double GetRatio(
    string ratio_text
    )
{
    string[]
        ratio_text_part_array;

    ratio_text_part_array = ratio_text.split( '_' );

    if ( ratio_text_part_array.length == 2 )
    {
        return ratio_text_part_array[ 0 ].to!double() / ratio_text_part_array[ 1 ].to!double();
    }
    else if ( ratio_text_part_array.length == 1 )
    {
        return ratio_text_part_array[ 0 ].to!double();
    }
    else
    {
        return 0.0;
    }
}

// ~~

void GetCroppingRatioAndOrigin(
    ref double cropping_ratio,
    ref string cropping_origin,
    string cropping
    )
{
    if ( cropping.endsWith( "tl" ) )
    {
        cropping_origin = "NorthWest";
        cropping = cropping[ 0 .. $ - 2 ];
    }
    else if ( cropping.endsWith( "t" ) )
    {
        cropping_origin = "North";
        cropping = cropping[ 0 .. $ - 1 ];
    }
    else if ( cropping.endsWith( "tr" ) )
    {
        cropping_origin = "NorthEast";
        cropping = cropping[ 0 .. $ - 2 ];
    }
    else if ( cropping.endsWith( "l" ) )
    {
        cropping_origin = "West";
        cropping = cropping[ 0 .. $ - 1 ];
    }
    else if ( cropping.endsWith( "c" ) )
    {
        cropping_origin = "Center";
        cropping = cropping[ 0 .. $ - 1 ];
    }
    else if ( cropping.endsWith( "r" ) )
    {
        cropping_origin = "East";
        cropping = cropping[ 0 .. $ - 1 ];
    }
    else if ( cropping.endsWith( "bl" ) )
    {
        cropping_origin = "SouthWest";
        cropping = cropping[ 0 .. $ - 2 ];
    }
    else if ( cropping.endsWith( "b" ) )
    {
        cropping_origin = "South";
        cropping = cropping[ 0 .. $ - 1 ];
    }
    else if ( cropping.endsWith( "br" ) )
    {
        cropping_origin = "SouthEast";
        cropping = cropping[ 0 .. $ - 2 ];
    }
    else
    {
        cropping_origin = "";
        cropping = "";
    }

    cropping_ratio = GetRatio( cropping );
}

// ~~

string GetFileExtensionFromCommandCode(
    char command_code
    )
{
    switch ( command_code )
    {
        case 'a' : return ".avif";
        case 'h' : return ".heic";
        case 'j' : return ".jpg";
        case 'p' : return ".png";
        case 's' : return ".svg";
        case 'w' : return ".webp";
        default : return "";
    }
}

// ~~

CONFIGURATION[] ReadConfigurationArray(
    string configuration_file_path,
    string folder_path
    )
{
    string
        command_name,
        configuration_file_text,
        stripped_line;
    string[]
        argument_array,
        filter_array,
        line_array,
        word_array;
    CONFIGURATION
        configuration;
    CONFIGURATION[]
        configuration_array;

    if ( configuration_file_path.exists() )
    {
        configuration_file_text = configuration_file_path.ReadText().replace( "\t", "    " ).replace( "\r", "" );
        line_array = configuration_file_text.split( "\n" );

        foreach ( line_index, line; line_array )
        {
            stripped_line = line.strip();

            if ( stripped_line != ""
                 && !stripped_line.startsWith( "#" ) )
            {
                if ( stripped_line.startsWith( "for " ) )
                {
                    filter_array ~= stripped_line[ 4 .. $ ].strip().split( ' ' );

                    configuration = null;
                }
                else
                {
                    if ( configuration is null )
                    {
                        configuration = new CONFIGURATION();
                        configuration.FolderPath = folder_path;
                        configuration.FilterArray = filter_array;
                        configuration_array ~= configuration;

                        filter_array = null;
                    }

                    word_array = stripped_line.split( ' ' );

                    command_name = word_array[ 0 ];
                    argument_array = word_array[ 1 .. $ ];

                    if ( command_name == "sizes"
                         && argument_array.length == 2 )
                    {
                        configuration.SizeArrayByNameMap[ argument_array[ 0 ] ] = argument_array[ 1 ].split( ',' );
                    }
                    else if ( command_name == "qualities"
                              && argument_array.length == 2 )
                    {
                        configuration.QualityArrayByNameMap[ argument_array[ 0 ] ] = argument_array[ 1 ].split( ',' );
                    }
                    else if ( command_name == "commands"
                              && argument_array.length == 2 )
                    {
                        configuration.CommandArrayByNameMap[ argument_array[ 0 ] ] = argument_array[ 1 ].split( '.' );
                    }
                    else if ( command_name == "default-cropping-ratio"
                              && argument_array.length == 1 )
                    {
                        GetCroppingRatioAndOrigin(
                            configuration.DefaultCroppingRatio,
                            configuration.DefaultCroppingOrigin,
                            argument_array[ 0 ]
                            );
                    }
                    else if ( command_name == "default-framing-ratio"
                              && argument_array.length == 1 )
                    {
                        configuration.DefaultFramingRatio = GetRatio( argument_array[ 0 ] );
                    }
                    else if ( command_name == "default-sizes"
                              && argument_array.length == 1 )
                    {
                        configuration.DefaultSizeArray = argument_array[ 0 ].split( ',' );
                    }
                    else if ( command_name == "default-qualities"
                              && argument_array.length == 1 )
                    {
                        configuration.DefaultQualityArray = argument_array[ 0 ].split( ',' );
                    }
                    else if ( command_name == "default-commands"
                              && argument_array.length == 1 )
                    {
                        configuration.DefaultCommandArray = argument_array[ 0 ].split( '.' );
                    }
                    else if ( command_name == "default-name"
                              && argument_array.length == 1 )
                    {
                        configuration.DefaultName = argument_array[ 0 ];
                    }
                    else
                    {
                        Abort( configuration_file_path ~ ":" ~ ( line_index + 1 ).to!string() ~ " Invalid configuration : " ~ stripped_line );
                    }
                }
            }
        }
    }

    return configuration_array;
}

// ~~

CONFIGURATION GetSourceFileConfiguration(
    string source_file_path,
    CONFIGURATION[] file_configuration_array
    )
{
    CONFIGURATION
        source_file_configuration;

    source_file_configuration = new CONFIGURATION();

    foreach ( file_configuration; file_configuration_array )
    {
        if ( file_configuration.MatchesFilePath( source_file_path[ SourceFolderPath.length .. $ ] ) )
        {
            foreach ( name, size_array; file_configuration.SizeArrayByNameMap )
            {
                source_file_configuration.SizeArrayByNameMap[ name ] = size_array;
            }

            foreach ( name, size_array; file_configuration.QualityArrayByNameMap )
            {
                source_file_configuration.QualityArrayByNameMap[ name ] = size_array;
            }

            foreach ( name, size_array; file_configuration.CommandArrayByNameMap )
            {
                source_file_configuration.CommandArrayByNameMap[ name ] = size_array;
            }

            if ( file_configuration.DefaultFramingRatio >= 0.0 )
            {
                source_file_configuration.DefaultFramingRatio = file_configuration.DefaultFramingRatio;
            }

            if ( file_configuration.DefaultSizeArray.length > 0 )
            {
                source_file_configuration.DefaultSizeArray = file_configuration.DefaultSizeArray;
            }

            if ( file_configuration.DefaultQualityArray.length > 0 )
            {
                source_file_configuration.DefaultQualityArray = file_configuration.DefaultQualityArray;
            }

            if ( file_configuration.DefaultCommandArray.length > 0 )
            {
                source_file_configuration.DefaultCommandArray = file_configuration.DefaultCommandArray;
            }

            if ( file_configuration.DefaultName.length > 0 )
            {
                source_file_configuration.DefaultName = file_configuration.DefaultName;
            }
        }
    }

    return source_file_configuration;
}

// ~~

void CopyImage(
    string source_file_path,
    string target_file_path
    )
{
    if ( IsUpdatedFile( source_file_path, target_file_path ) )
    {
        writeln( "Writing file : ", target_file_path );

        try
        {
            source_file_path.copy( target_file_path );
        }
        catch ( Exception exception )
        {
            Abort( "Can't write file", exception );
        }
    }
    else
    {
        writeln( "Keeping file : ", target_file_path );
    }
}

// ~~

void GenerateImage(
    string source_file_path,
    string source_file_label,
    string source_file_extension,
    string target_folder_path,
    string target_file_extension,
    string target_size,
    double target_framing_ratio,
    double target_cropping_ratio,
    string target_cropping_origin,
    string target_quality,
    CONFIGURATION configuration
    )
{
    double
        real_target_height,
        real_target_width;
    long
        target_pixel_count;
    string
        command,
        target_cropping,
        target_dimension,
        target_factor,
        target_file_name,
        target_file_path,
        target_height,
        target_width;
    string[]
        target_size_part_array;

    if ( VerboseOptionIsEnabled )
    {
        writeln( "Target size : ", target_size );
    }

    target_size_part_array = target_size.split( '#' );

    if ( target_size_part_array.length == 2 )
    {
        target_framing_ratio = GetRatio( target_size_part_array[ 2 ] );
        target_size = target_size_part_array[ 0 ];
    }

    target_size_part_array = target_size.split( 'x' );

    if ( target_size_part_array.length == 2 )
    {
        if ( target_size.endsWith( 'x' ) )
        {
            target_factor = ( target_size_part_array[ 0 ].to!long() * 100 ).to!string();
            target_dimension = target_factor ~ "%";
        }
        else
        {
            target_width = target_size_part_array[ 0 ];
            target_height = target_size_part_array[ 1 ];
            target_dimension = target_width ~ "x" ~ target_height;
        }
    }
    else if ( target_size.endsWith( '%' ) )
    {
        target_factor = target_size[ 0 .. $ - 1 ];
        target_dimension = target_factor ~ "%";
    }
    else if ( target_size.endsWith( 'h' ) )
    {
        target_height = target_size[ 0 .. $ - 1 ];
        target_width = "";
        target_dimension = "x" ~ target_height;
    }
    else if ( target_size.endsWith( 'w' ) )
    {
        target_width = target_size[ 0 .. $ - 1 ];
        target_height = "";
        target_dimension = target_width ~ "x";
    }
    else
    {
        target_width = target_size;
        target_height = "";
        target_dimension = target_width ~ "x";
    }

    if ( VerboseOptionIsEnabled )
    {
        writeln( "Target width : ", target_width );
        writeln( "Target height : ", target_height );
        writeln( "Target dimension : ", target_dimension );
    }

    target_file_name
        = configuration.GetTargetFileName(
              source_file_label,
              source_file_extension,
              target_size,
              target_dimension,
              target_width,
              target_height,
              target_factor,
              target_quality,
              target_file_extension
              );

    target_file_path = target_folder_path ~ target_file_name;

    if ( IsUpdatedFile( source_file_path, target_file_path ) )
    {
        writeln( "Writing file : ", target_file_path );

        command
            = ConvertToolPath.GetPhysicalPath()
              ~ " \""
              ~ source_file_path.GetPhysicalPath()
              ~ "\"";

        if ( source_file_extension == ".svg" )
        {
            command
                ~= " -background none -alpha set -size " ~ target_dimension;
        }

        if ( target_file_extension == ".jpg" )
        {
            command
                ~= " -background white -alpha remove -alpha off";
        }

        if ( target_framing_ratio > 0.0 )
        {
            if ( VerboseOptionIsEnabled )
            {
                writeln( "Target framing ratio : ", target_framing_ratio );
            }

            if ( target_width != "" )
            {
                real_target_width = target_width.to!double();
                target_dimension = target_width ~ "x" ~ ( real_target_width / target_framing_ratio ).to!long().to!string();
            }
            else if ( target_height != "" )
            {
                real_target_height = target_height.to!double();
                target_dimension = ( real_target_height * target_framing_ratio ).to!long().to!string() ~ "x" ~ target_height;
            }
        }

        if ( VerboseOptionIsEnabled )
        {
            writeln( "Target dimension : ", target_dimension );
        }

        command
            ~= " -resize "
               ~ target_dimension;

        if ( target_cropping_ratio > 0.0 )
        {
            if ( VerboseOptionIsEnabled )
            {
                writeln( "Target cropping ratio : ", target_cropping_ratio );
            }

            if ( target_width != "" )
            {
                target_cropping
                    = target_width
                      ~ "x"
                      ~ ( target_width.to!double() / target_cropping_ratio ).to!long().to!string();
            }
            else if ( target_height != "" )
            {
                target_cropping
                    = ( target_height.to!double() * target_cropping_ratio ).to!long().to!string()
                      ~ "x"
                      ~ target_height;
            }

            if ( VerboseOptionIsEnabled )
            {
                writeln( "Target cropping origin : ", target_cropping_origin );
                writeln( "Target cropping : ", target_cropping );
            }

            command
                ~= " -gravity "
                   ~ target_cropping_origin
                   ~ " -crop "
                   ~ target_cropping
                   ~ "+0+0 +repage";
        }

        if ( target_file_extension == ".jpg" )
        {
            command
                ~= " -interlace Plane";
        }

        if ( VerboseOptionIsEnabled )
        {
            writeln( "Target quality : ", target_quality );
        }

        command
            ~= " -quality "
               ~ target_quality
               ~ " -filter Lanczos -strip \""
               ~ target_file_path.GetPhysicalPath()
               ~ "\"";

        writeln( "Running : ", command );

        try
        {
            executeShell( command );
        }
        catch ( Exception exception )
        {
            Abort( "Can't write file", exception );
        }
    }
    else
    {
        writeln( "Keeping file : ", target_file_path );
    }
}

// ~~

void ProcessSourceFile(
    string source_file_path,
    string source_folder_path,
    string source_file_label,
    string source_file_extension,
    string[] command_array,
    CONFIGURATION configuration
    )
{
    char
        command_code;
    double
        target_framing_ratio,
        target_cropping_ratio;
    long
        command_index;
    string
        command,
        target_extension_format,
        target_file_extension,
        target_file_name,
        target_file_path,
        target_folder_path,
        target_cropping_origin,
        target_quality,
        target_size_format;
    string[]
        command_part_array,
        target_quality_array,
        target_size_array;

    writeln( "Reading file : ", source_file_path );

    if ( command_array.length == 0 )
    {
        command_array = configuration.DefaultCommandArray;
    }

    target_framing_ratio = configuration.DefaultFramingRatio;
    target_cropping_ratio = configuration.DefaultCroppingRatio;
    target_cropping_origin = configuration.DefaultCroppingOrigin;

    if ( VerboseOptionIsEnabled )
    {
        writeln( "Configuration :" );
        configuration.Dump( "    " );
    }

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
                  ~ configuration.GetCommandArray( command[ 1 .. $ ] )
                  ~ command_array[ command_index + 1 .. $ ];

            --command_index;
        }
        else if ( command_code == 'c' )
        {
            GetCroppingRatioAndOrigin(
                target_cropping_ratio,
                target_cropping_origin,
                command[ 1 .. $ ]
                );
        }
        else if ( command_code == 'f' )
        {
            target_framing_ratio = GetRatio( command[ 1 .. $ ] );
        }
        else if ( command_code == 'o' )
        {
            target_folder_path = TargetFolderPath ~ source_folder_path[ SourceFolderPath.length .. $ ];
            target_file_path = target_folder_path ~ source_file_label ~ source_file_extension;

            CopyImage( source_file_path, target_file_path );
        }
        else if ( "ahjpsw".indexOf( command_code ) >= 0 )
        {
            target_file_extension = GetFileExtensionFromCommandCode( command_code );
            command_part_array = command.split( '@' );
            target_size_array = configuration.GetSizeArray( command_part_array[ 0 ][ 1 .. $ ] );

            if ( command_part_array.length == 2 )
            {
                target_quality_array = command_part_array[ 1 ].split( ',' );
            }
            else
            {
                target_quality_array = configuration.DefaultQualityArray;
            }

            if ( VerboseOptionIsEnabled )
            {
                writeln( "Target size array : ", target_size_array );
                writeln( "Target quality array : ", target_quality_array );
            }

            if ( !target_size_array.empty )
            {
                target_folder_path = TargetFolderPath ~ source_folder_path[ SourceFolderPath.length .. $ ];

                if ( !exists( target_folder_path ) )
                {
                    target_folder_path.mkdirRecurse();
                }

                foreach ( target_size_index, target_size; target_size_array )
                {
                    target_quality = target_quality_array[ target_size_index % target_quality_array.length ];

                    GenerateImage(
                        source_file_path,
                        source_file_label,
                        source_file_extension,
                        target_folder_path,
                        target_file_extension,
                        target_size,
                        target_framing_ratio,
                        target_cropping_ratio,
                        target_cropping_origin,
                        target_quality,
                        configuration
                        );
                }
            }
        }
    }
}

// ~~

void ProcessSourceFolder(
    string source_folder_path,
    CONFIGURATION[] configuration_array
    )
{
    string
        source_file_extension,
        source_file_label,
        source_file_name,
        source_file_path,
        target_file_name;
    string[]
        source_file_name_part_array,
        command_array;
    CONFIGURATION[]
        file_configuration_array,
        folder_configuration_array;

    writeln( "Reading folder : ", source_folder_path );

    folder_configuration_array
        = configuration_array
          ~ ReadConfigurationArray(
                source_folder_path ~ ".nano",
                source_folder_path[ SourceFolderPath.length .. $ ]
                );

    try
    {
        foreach ( source_folder_entry; dirEntries( source_folder_path, SpanMode.shallow ) )
        {
            if ( source_folder_entry.isFile )
            {
                source_file_path = source_folder_entry.name.GetLogicalPath();
                source_file_name = source_file_path.GetFileName();
                source_file_name_part_array = source_file_name.split( '.' );

                if ( source_file_path.startsWith( source_folder_path )
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
                        file_configuration_array
                            = folder_configuration_array
                              ~ ReadConfigurationArray(
                                    source_file_path ~ ".nano",
                                    source_folder_path[ SourceFolderPath.length .. $ ]
                                    );

                        ProcessSourceFile(
                            source_file_path,
                            source_folder_path,
                            source_file_label,
                            source_file_extension,
                            command_array,
                            GetSourceFileConfiguration( source_file_path, file_configuration_array )
                            );
                    }
                }
            }
            else if ( source_folder_entry.isDir
                      && RecursiveOptionIsEnabled )
            {
                ProcessSourceFolder(
                    source_folder_entry.name.GetLogicalPath() ~ '/',
                    folder_configuration_array
                    );
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
        configuration_text,
        option;

    argument_array = argument_array[ 1 .. $ ];

    ConvertToolPath = "convert";
    RecursiveOptionIsEnabled = false;
    KeepOptionIsEnabled = false;
    VerboseOptionIsEnabled = false;
    SourceFolderPath = "";
    TargetFolderPath = "";

    configuration_text = "*.*\n";

    while ( argument_array.length >= 1
            && argument_array[ 0 ].startsWith( "--" ) )
    {
        option = argument_array[ 0 ];
        argument_array = argument_array[ 1 .. $ ];

        if ( ( option == "--sizes"
               || option == "--qualities"
               || option == "--commands" )
               && argument_array.length >= 2 )
        {
            configuration_text ~= option[ 2 .. $ ] ~ " " ~ argument_array[ 0 .. 1 ].join( ' '  ) ~ "\n";
            argument_array = argument_array[ 2 .. $ ];
        }
        else if ( ( option == "--default-cropping-ratio"
                    || option == "--default-framing-ratio"
                    || option == "--default-sizes"
                    || option == "--default-qualities"
                    || option == "--default-commands"
                    || option == "--default-name" )
                  && argument_array.length >= 1 )
        {
            configuration_text ~= option[ 2 .. $ ] ~ " " ~ argument_array[ 0 ] ~ "\n";
            argument_array = argument_array[ 1 .. $ ];
        }
        else if ( option == "--convert-tool-path"
                  && argument_array.length >= 1 )
        {
            ConvertToolPath = argument_array[ 0 ];
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
        else if ( option == "--verbose" )
        {
            VerboseOptionIsEnabled = true;
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

        if ( SourceFolderPath.GetLogicalPath().endsWith( '/' )
             && TargetFolderPath.GetLogicalPath().endsWith( '/' ) )
        {
            ProcessSourceFolder(
                SourceFolderPath,
                ReadConfigurationArray(
                    GetApplicationFolderPath() ~ ".nano",
                    ""
                    )
                );

            return;
        }
    }

    writeln( "Usage :" );
    writeln( "    nano [options] <source folder path> <target folder path>" );
    writeln( "Options :" );
    writeln( "    --sizes <name> <size list>" );
    writeln( "    --qualities <name> <quality list>" );
    writeln( "    --commands <name> <command list>" );
    writeln( "    --default-cropping-ratio <ratio><origin>" );
    writeln( "    --default-framing-ratio <ratio>" );
    writeln( "    --default-sizes <size list>" );
    writeln( "    --default-qualities <quality list>" );
    writeln( "    --default-commands <command list>" );
    writeln( "    --default-name <image name format>" );
    writeln( "    --convert-tool-path <convert tool path>" );
    writeln( "    --recursive" );
    writeln( "    --keep" );

    Abort( "Invalid arguments : " ~ argument_array.to!string() );
}
