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
--default-ratio <ratio><origin>
--default-surface-ratio <ratio>
--default-sizes <size list>
--default-qualities <quality list> (default: 80)
--default-commands <command list>
--default-name <image name format> (default: {l}.{e}.{s}.{x})
--convert-tool-path <convert tool path>
--recursive
--keep
```

## Image size

*   <factor>%
*   <factor>x
*   <width>x<height>
*   <width>
*   <width>w
*   <height>h
*   <width>#<maximum surface ratio>
*   <width>w#<maximum surface ratio>
*   <height>h#<maximum surface ratio>

## Image size lists

Sizes are separated by commas :

*   `<size>`,`<size>`...

The following size lists are predefined :

*   n : 80
*   n2 : 80,160
*   n3 : 80,160,240
*   n4 : 80,160,240,320
*   n5 : 80,160,240,320,400
*   n6 : 80,160,240,320,400,480
*   t : 160
*   t2 : 160,320
*   t3 : 160,320,480
*   t4 : 160,320,480,640
*   t5 : 160,320,480,640,800
*   t6 : 160,320,480,640,800,960
*   s : 320
*   s2 : 320,640
*   s3 : 320,640,960
*   s4 : 320,640,960,1280
*   s5 : 320,640,960,1280,1600
*   s6 : 320,640,960,1280,1600,1920
*   c : 480
*   c2 : 480,960
*   c3 : 480,960,1440
*   c4 : 480,960,1440,1920
*   c5 : 480,960,1440,1920,2400
*   c6 : 480,960,1440,1920,2400,2880
*   m : 640
*   m2 : 640,1280
*   m3 : 640,1280,1920
*   m4 : 640,1280,1920,2560
*   m5 : 640,1280,1920,2560,3200
*   m6 : 640,1280,1920,2560,3200,3840
*   l : 960
*   l2 : 960,1920
*   l3 : 960,1920,2880
*   l4 : 960,1920,2880,3840
*   b : 1280
*   b2 : 1280,2560
*   b3 : 1280,2560,3840
*   h : 1600
*   h2 : 1600,3200
*   f : 1920
*   f2 : 1920,3840
*   u : 3840

They use the following prefixes :

*   n : **N**ano
*   t : **T**iny
*   s : **S**mall
*   c : **C**ompact
*   m : **M**edium
*   l : **L**arge
*   b : **B**ig
*   h : **H**uge
*   f : **F**ull (HD)
*   u : **U**ltra (4K)

## Image quality

*   0 : poor
*   50 : moderate
*   60 : fair
*   70 : good
*   80 : very good
*   90 : excellent
*   100 : perfect

## Image quality lists

Qualities are separated by commas :

*   `<quality>`,`<quality>`...

## Image ratio

Images can be cropped to match a given aspect ratio :

*   `<width>`_`<height><origin>`

The origin suffix can be :

*   tl : top left
*   t : top
*   tr : top right
*   l : left
*   c : center
*   r : right
*   bl : bottom left
*   b : bottom
*   br : bottom right

The cropped image size might be smaller than requested if not enough width or height is available.

## Image command

The first character of an image command can be :

*   **@** `<definition name>` : use a named command list
*   **@** : use the default command list
*   **o** : copy the original source file
*   **r** `<ratio><gravity>` : define the ratio and origin
*   **#** `<ratio>` : define the maximum surface ratio
*   **a** : generate .avif files
*   **h** : generate .heic files
*   **j** : generate .jpg files
*   **p** : generate .png files
*   **s** : generate .svg files
*   **w** : generate .webp files

In image generation commands, the next characters specify the target size list :

*   `<size>`,`<size>`...

They can also have a custom quality list, specified after **@** :

*   `<size>`,`<size>`...@`<quality>`,`<quality>`...

## Image command list

They are separated by dots :

*   `<command>`,`<command>`...

Source image file names can have a command list before the file extension.

If none is provided, the default command list will be build fro :

## Configuration file

It can contain the following statements :

*   # comment
*   for <file path filter> ...
*   sizes <name> <size list>
*   qualities <name> <quality list>
*   commands <name> <command list>
*   default-ratio <ratio><origin>
*   default-surface-ratio <ratio>
*   default-sizes <size list>
*   default-qualities <quality list>
*   default-commands <command list>
*   default-name <image name format>

Image generation settings are built from the following sources :

*   Application arguments
*   Application configuration file : .nano
*   Image parent folders configuration file : .nano
*   Image folder configuration file : .nano
*   Image configuration file : image.nano
*   Image file name : image.command.command.etc.png

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

### Image file name

*   "**image.jl.png**" generates "image.png.960.jpg"
*   "**image.j960.png**" generates "image.png.960.jpg"
*   "**image.j960@90.png**" generates "image.png.960.jpg" at 90% quality
*   "**image.jm@10.jl4@80.png**" generates "image.png.480.jpg" at 10% quality, "image.png.960.jpg", "image.png.1920.jpg", "image.png.2880.jpg", "image.png.3840.jpg" at 80% quality
*   "**image.pt3.png**" generates "image.png.160.png", "image.png.320.png", "image.png.480.png"
*   "**image.p160,320,480.png**" generates "image.png.160.png", "image.png.320.png", "image.png.480.png"
*   "**image.a160,320,480@80,70,60.png**" generates "image.png.160.avif" at 80% quality, "image.png.320.avif" at 70% quality, "image.png.480.avif" at 60% quality

### Command line

```csh
nano --default-commands r16_9.a1920@70 --default-name @l.@x --convert-tool-path "convert" --recursive --keep SOURCE/ TARGET/
```

```csh
nano --default-qualities 75,70,65,60 --default-commands r16_9.am@10.al4 --convert-tool-path "convert" --recursive --keep SOURCE/ TARGET/
```

```csh
nano --sizes m5 640,1280,1920,2560,3200 --commands m5 ac@10.am5 --commands sm5 r16_9.ac@10.am5
     --default-qualities 80 --default-commands @m5 --convert-tool-path "convert" --recursive --keep SOURCE/ TARGET/
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
