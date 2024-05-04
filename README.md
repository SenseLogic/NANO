![](https://github.com/senselogic/NANO/blob/master/LOGO/nano.png)

# Nano

Image variant generator.

## Description

Nano generates image variants in different sizes and file formats.

## Source file extensions

*   .avif
*   .heic
*   .heif
*   .jpg
*   .png
*   .svg
*   .webp

## Target file extensions

*   .avif
*   .heic
*   .jpg
*   .png
*   .svg
*   .webp

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
--sizes <name> <size list>
--qualities <name> <quality list>
--commands <name> <command list>
--default-ratio <ratio>
--default-sizes <size list>
--default-qualities <quality list> (default: 80)
--default-commands <command list>
--default-name <image name format> (default: {l}.{e}.{s}.{x})
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
*   **o** : copy the original source file
*   **r** `<ratio>` : define the aspect ratio
*   **f** `<frame>` : define the cropping frame
*   **a** : generate .avif files
*   **h** : generate .heic files
*   **j** : generate .jpg files
*   **p** : generate .png files
*   **s** : generate .svg files
*   **w** : generate .webp files

In image generation commands, the next characters specify the target size list :

*   `<size>`,`<size>`,...


Those letters stand for : **N**ano, **T**iny, **S**mall, **C**ompact, **M**edium, **L**arge, **B**ig, **H**uge, **F**ull, **U**ltra.

Width lists can be added or changed using the `--sizes` option.

By default, the image will be resized to match the required size.

Alternatively, if a ratio is specified, the image will be resized to match the amount of pixels of an image with this size and aspect ratio.

In both cases, the image original aspect ratio will be preserved.

An image generation command can also have a custom target quality list, put after **@**.

## Image frame

*   <width>x<height>{+-}<horizontal offset>{+-}<vertical offset><origin>

## Image origin

*   tl : top left
*   t : top
*   tr : top right
*   l : left
*   c : center
*   r : right
*   bl : bottom left
*   b : bottom
*   br : bottom right

## Image size

*   <factor>%
*   <factor>x
*   <width>x<height>
*   <width>
*   <width>w
*   <height>h
*   <width>#<ratio>
*   <width>w#<ratio>
*   <height>h#<ratio>


## Image name format

The target file name format can be specified using the following letters :

*   **{l}** : source image label
*   **{e}** : source image extension
*   **{s}** : target image size
*   **{d}** : target image dimension
*   **{w}** : target image width
*   **{h}** : target image height
*   **{f}** : target image factor
*   **{q}** : target image quality
*   **{x}** : target image extension

## Samples

### File name

*   "**image.jl.png**" generates "image.png.960.jpg"
*   "**image.j960.png**" generates "image.png.960.jpg"
*   "**image.j960@90.png**" generates "image.png.960.jpg" at 90% quality
*   "**image.jm@10.jl4@80.png**" generates "image.png.480.jpg" at 10% quality, "image.png.960.jpg", "image.png.1920.jpg", "image.png.2880.jpg", "image.png.3840.jpg" at 80% quality
*   "**image.pt3.png**" generates "image.png.160.png", "image.png.320.png", "image.png.480.png"
*   "**image.p160,320,480.png**" generates "image.png.160.png", "image.png.320.png", "image.png.480.png"
*   "**image.a160,320,480@80,70,60.png**" generates "image.png.160.avif" at 80% quality, "image.png.320.avif" at 70% quality, "image.png.480.avif" at 60% quality

### Command line

```csh
nano --commands r16_9.a1920@70 --name @l.@x --tool-path "convert" --recursive --keep SOURCE/ TARGET/
```

```csh
nano --qualities 75,70,65,60 --commands r16_9.am@10.al4 --tool-path "convert" --recursive --keep SOURCE/ TARGET/
```

```csh
nano --qualities 80 --sizes m5 640,1280,1920,2560,3200 --commands m5 ac@10.am5 --commands sm5 r16_9.ac@10.am5
     --commands @m5 --tool-path "convert" --recursive --keep SOURCE/ TARGET/
```

## Dependencies

*   ImageMagick convert

## Version

2.0

## Author

Eric Pelzer (ecstatic.coder@gmail.com).

## License

This project is licensed under the GNU General Public License version 3.

See the [LICENSE.md](LICENSE.md) file for details.
