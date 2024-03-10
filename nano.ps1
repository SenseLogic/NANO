param(
    $source_base_folder_path,
    $target_base_folder_path,
    $quality_list,
    $generation_tool_path,
    $generation_mode
    )

if ( -not ( Test-Path $target_base_folder_path ) )
{
    New-Item -ItemType Directory -Force -Path $target_base_folder_path | Out-Null
}

$source_base_folder_path = ( Resolve-Path -Path $source_base_folder_path  ).Path
$target_base_folder_path = ( Resolve-Path -Path $target_base_folder_path  ).Path
$quality_array = $quality_list -split ' '

function GenerateJpgImage
{
    param(
        $source_file_path,
        $target_file_path,
        $width,
        $quality
        )

    $target_file_path = "$target_file_path.$width.jpg"

    if ( ( $generation_mode -ne "keep" ) -or ( -not ( Test-Path $target_file_path ) ) -or ( Get-Item $source_file_path ).LastWriteTime -gt ( Get-Item $target_file_path ).LastWriteTime ) {
        echo "Writing file : $target_file_path"
        & $generation_tool_path $source_file_path -background white -alpha remove -alpha off -resize "${Width}x" -interlace Plane -quality $quality -strip $target_file_path
    }
    else
    {
        echo "Keeping file : $target_file_path"
    }
}

function GeneratePngImage
{
    param(
        $source_file_path,
        $target_file_path,
        $width
        )

    $target_file_path = "$target_file_path.$width.png"

    if ( ( $generation_mode -ne "keep" ) -or ( -not ( Test-Path $target_file_path ) ) -or ( Get-Item $source_file_path ).LastWriteTime -gt ( Get-Item $target_file_path ).LastWriteTime )
    {
        echo "Writing file : $target_file_path"
        & $generation_tool_path $source_file_path -resize "${Width}x" -strip $target_file_path
    }
    else
    {
        echo "Keeping file : $target_file_path"
    }
}

echo "Reading folder : $source_base_folder_path"

Get-ChildItem -Path $source_base_folder_path -Filter "*.*.*" -Recurse | ForEach-Object {

    $file_name_part_array = $_.Name.Split( "." )

    if ( $file_name_part_array.length -eq 3 )
    {
        $target_format = $file_name_part_array[1]
        $target_extension_format = $target_format.Substring( 0, 1 )
        $target_width_format = $target_format.Substring( 1 )

        $width_array = @()
        $target_file_extension = ""

        $target_file_extension = switch ( $target_extension_format )
        {
            "j" { "jpg" }
            "p" { "png" }
            default { Continue }
        }

        $width_array = switch ( $target_width_format )
        {
            "t" { 160 }
            "t2" { 160, 320 }
            "t3" { 160, 320, 480 }
            "t4" { 160, 320, 480, 640 }
            "s" { 320 }
            "s2" { 320, 640 }
            "s3" { 320, 640, 960 }
            "s4" { 320, 640, 960, 1280 }
            "m" { 640 }
            "m2" { 640, 1280 }
            "m3" { 640, 1280, 1920 }
            "m4" { 640, 1280, 1920, 2560 }
            "l" { 960 }
            "l2" { 960, 1920 }
            "l3" { 960, 1920, 2880 }
            "l4" { 960, 1920, 2880, 3840 }
            "b" { 1280 }
            "b2" { 1280, 2560 }
            "b3" { 1280, 2560, 3840 }
            "h" { 1600 }
            "h2" { 1600, 3200 }
            "f" { 1920 }
            "f2" { 1920, 3840 }
            "u" { 3840 }
            Default { [int]$target_width_format }
        }

        $relative_file_path = $_.DirectoryName.Substring( $source_base_folder_path.Length )
        $target_folder_path = Join-Path $target_base_folder_path $relative_file_path

        if ( -not ( Test-Path $target_folder_path ) )
        {
            New-Item -ItemType Directory -Force -Path $target_folder_path | Out-Null
        }

        $source_file_path = $_.FullName
        $target_file_path = Join-Path $target_folder_path ( $_.BaseName -replace "\.$target_format$", "" )

        echo "Reading file : $source_file_path"

        foreach ( $width_index in 0..( $width_array.Count - 1 ) )
        {
            $width = $width_array[ $width_index ]
            $quality = $quality_array[ $width_index % $quality_array.Count ]

            if ( $target_file_extension -eq "jpg" )
            {
                GenerateJpgImage -source_file_path $_.FullName -target_file_path $target_file_path -width $width -quality $quality
            }
            elseif ( $target_file_extension -eq "png" )
            {
                GeneratePngImage -source_file_path $_.FullName -target_file_path $target_file_path -width $width
            }
        }
    }
}
