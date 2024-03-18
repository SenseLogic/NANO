![](https://github.com/senselogic/NANO/blob/master/LOGO/nano.png)

# Nano

Image variant generator.

## Description

Nano generates image variants in different sizes and file formats.

## Source file extensions

*    .avif
*    .heic
*    .heif
*    .jpg
*    .png
*    .svg
*    .webp

## Target file extensions

*    .avif
*    .heic
*    .jpg
*    .png
*    .webp

## Installation

Install the [DMD 2 compiler](https://dlang.org/download.html) (using the MinGW setup option on Windows).

Build the executable with the following command line :

```bash
dmd -m64 nano.d
```

## Command line

```
nano [`<option>` ...] `<source folder path>` `<target folder path>`
```

### Options

```
--surface-ratio <surface ratio>
--quality-list <quality list>
--width-list <name> <width list>
--command-list <name> <command list>
--default-command-list <default command list>
--file-name-format <file name format>
--tool-path <tool path>
--recursive
--keep
```

## Command lists

Each source image can have a command list between dots, put just before the file extension.

If none is provided, the default command list will be used.

The first character of a command can be :

*   **@** `<definition name>` : use a named command list
*   **@** : use the default command list
*   **s** `<surface ratio>` : use a pixel count computed from this surface ratio and the target width
*   **a** : generate .avif files
*   **h** : generate .heic files
*   **j** : generate .jpg files
*   **p** : generate .png files
*   **w** : generate .webp files

In image generation commands, the next characters specify the target width list, either explicitely, or using a named width list :

*   `<width>`,`<width>`,...
*   **n** : 80
*   **n2** : 80, 160
*   **n3** : 80, 160, 240
*   **n4** : 80, 160, 240, 320
*   **t** : 160
*   **t2** : 160, 320
*   **t3** : 160, 320, 480
*   **t4** : 160, 320, 480, 640
*   **s** : 320
*   **s2** : 320, 640
*   **s3** : 320, 640, 960
*   **s4** : 320, 640, 960, 1280
*   **c** : 480
*   **c2** : 480, 960
*   **c3** : 480, 960, 1440
*   **c4** : 480, 960, 1440, 1920
*   **m** : 640
*   **m2** : 640, 1280
*   **m3** : 640, 1280, 1920
*   **m4** : 640, 1280, 1920, 2560
*   **l** : 960
*   **l2** : 960, 1920
*   **l3** : 960, 1920, 2880
*   **l4** : 960, 1920, 2880, 3840
*   **b** : 1280
*   **b2** : 1280, 2560
*   **b3** : 1280, 2560, 3840
*   **h** : 1600
*   **h2** : 1600, 3200
*   **f** : 1920
*   **f2** : 1920, 3840
*   **u** : 3840

Those letters stand for : **N**ano, **T**iny, **S**mall, **C**ompact, **M**edium, **L**arge, **B**ig, **H**uge, **F**ull, **U**ltra.

Width lists can be added or changed using the `--width-list` option.

By default, the image will be resized to match the required width.

Alternatively, if a surface ratio is specified, the image will be resized to match the amount of pixels of an image with this width and aspect ratio.

In both cases, the image original aspect ratio will be preserved.

An image generation command can also have a custom target quality list, put after **@**.

## Target file name format

The target file name format can be specified using the following letters :

*   **{l}** : source image label
*   **{e}** : source image extension
*   **{w}** : target image width
*   **{q}** : target image quality
*   **{x}** : target image extension

The default target image name is : **{l}.{e}.{w}.{x}**

## Samples

### File name

*   "image.**jl**.png" generates "image.png.960.jpg"
*   "image.**j960**.png" generates "image.png.960.jpg"
*   "image.**j960@90**.png" generates "image.png.960.jpg" at 90% quality
*   "image.**jm@10.jl4@80**.png" generates "image.png.480.jpg" at 10% quality, "image.png.960.jpg", "image.png.1920.jpg", "image.png.2880.jpg", "image.png.3840.jpg" at 80% quality
*   "image.**pt3**.png" generates "image.png.160.png", "image.png.320.png", "image.png.480.png"
*   "image.**p160,320,480**.png" generates "image.png.160.png", "image.png.320.png", "image.png.480.png"
*   "image.**a160,320,480@80,70,60**.png" generates "image.png.160.avif" at 80% quality, "image.png.320.avif" at 70% quality, "image.png.480.avif" at 60% quality

### Command line

```csh
nano --default-command-list s16_9.a1920@70 --file-name-format @l.@x --tool-path "convert" --recursive --keep SOURCE/ TARGET/
```

```csh
nano --quality-list 75,70,65,60 --default-command-list s16_9.am@10.al4 --tool-path "convert" --recursive --keep SOURCE/ TARGET/
```

```csh
nano --quality-list 80 --width-list m5 640,1280,1920,2560,3200 --command-list m5 ac@10.am5 --command-list sm5 s16_9.ac@10.am5
     --default-command-list @m5 --tool-path "convert" --recursive --keep SOURCE/ TARGET/
```

## Dependencies

*   ImageMagick convert

## Version

1.0

## Author

Eric Pelzer (ecstatic.coder@gmail.com).

## License

This project is licensed under the GNU General Public License version 3.

See the [LICENSE.md](LICENSE.md) file for details.
