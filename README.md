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
--default-cropping-ratio <ratio><origin>
--default-framing-ratio <ratio>
--default-sizes <size list>
--default-qualities <quality list> (default: 80)
--default-commands <command list>
--default-name <image name format> (default: {l}.{w}.{x})
--convert-tool-path <convert tool path>
--recursive
--keep
```

## Image size

*   `<factor>%`
*   `<factor>x`
*   `<width>x<height>`
*   `<width>`
*   `<width>w`
*   `<height>h`
*   `<width>#<framing ratio>`
*   `<width>w#<framing ratio>`
*   `<height>h#<framing ratio>`

## Image size lists

Sizes are separated by commas :

*   `<size>`,`<size>`...

The following size lists are predefined :

*   **n** : 360
*   **n2** : 360,480
*   **n3** : 360,480,640
*   **n4** : 360,480,640,960
*   **n5** : 360,480,640,960,1280
*   **n6** : 360,480,640,960,1280,1920
*   **n7** : 360,480,640,960,1280,1920,2560
*   **n8** : 360,480,640,960,1280,1920,2560,3840
*   **t** : 480
*   **t2** : 480,640
*   **t3** : 480,640,960
*   **t4** : 480,640,960,1280
*   **t5** : 480,640,960,1280,1920
*   **t6** : 480,640,960,1280,1920,2560
*   **t7** : 480,640,960,1280,1920,2560,3840
*   **s** : 640
*   **s2** : 640,960
*   **s3** : 640,960,1280
*   **s4** : 640,960,1280,1920
*   **s5** : 640,960,1280,1920,2560
*   **s6** : 640,960,1280,1920,2560,3840
*   **m** : 960
*   **m2** : 960,1280
*   **m3** : 960,1280,1920
*   **m4** : 960,1280,1920,2560
*   **m5** : 960,1280,1920,2560,3840
*   **w** : 1280
*   **w2** : 1280,1920
*   **w3** : 1280,1920,2560
*   **w4** : 1280,1920,2560,3840
*   **l** : 1920
*   **l2**: 1920,2560
*   **l3**: 1920,2560,3840
*   **b** : 2560
*   **b2** : 2560,3840
*   **h** : 3840

They use the following prefixes :

*   n : **N**ano (360)
*   t : **T**iny (480)
*   s : **S**mall (640)
*   m : **M**edium (960)
*   w : **W**ide (1280)
*   l : **L**arge (1920)
*   b : **B**ig (2560)
*   h : **H**uge (3840)

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

## Image cropping

Images can be cropped to match a given aspect ratio :

*   `<width>`_`<height><origin>`

The cropping origin suffix can be :

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
*   **c** `<ratio><gravity>` : define the cropping ratio and origin
*   **f** `<ratio>` : define the framing ratio
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
*   default-cropping-ratio <ratio><origin>
*   default-framing-ratio <ratio>
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

*   "**image.jl.png**" generates "image.1920.jpg"
*   "**image.j1920.png**" generates "image.960.jpg"
*   "**image.j1920@90.png**" generates "image.1920.jpg" at 90% quality
*   "**image.jm@30.jl3@80.png**" generates "image.960.jpg" at 30% quality, "image.1920.jpg", "image.2560.jpg", "image.3840.jpg" at 90% quality
*   "**image.pt3.png**" generates "image.160.png", "image.320.png", "image.480.png"
*   "**image.p160,320,480.png**" generates "image.160.png", "image.320.png", "image.480.png"
*   "**image.a160,320,480@80,70,60.png**" generates "image.160.avif" at 80% quality, "image.320.avif" at 70% quality, "image.480.avif" at 60% quality

### Command line

```csh
nano --default-commands c16_9.a1920@70 --default-name @l.@x --convert-tool-path "convert" --recursive --keep SOURCE/ TARGET/
```

```csh
nano --default-qualities 75,70,65,60 --default-commands c16_9.am@30.al4 --convert-tool-path "convert" --recursive --keep SOURCE/ TARGET/
```

```csh
nano --sizes m5 640,1280,1920,2560,3200 --commands m5 as@30.am5 --commands cm5 c16_9.as@30.am5
     --default-qualities 80 --default-commands @m5 --convert-tool-path "convert" --recursive --keep SOURCE/ TARGET/
```

## Dependencies

*   ImageMagick convert

## Version

3.0

## Author

Eric Pelzer (ecstatic.coder@gmail.com).

## License

This project is licensed under the GNU General Public License version 3.

See the [LICENSE.md](LICENSE.md) file for details.
