![](https://github.com/senselogic/NANO/blob/master/LOGO/nano.png)

# Nano

Image variant generator.

## Description

Nano generates source image variants in a target folder.

The source image file names can have one or several commands before their extension.

For instance :

*   "image.**jl**.png" generates "image.png.960.jpg"
*   "image.**j960**.png" generates "image.png.960.jpg"
*   "image.**j960@90**.png" generates "image.png.960.jpg" at 90% quality
*   "image.**jm@10.jl4**.png" generates "image.png.480.jpg", "image.png.960.jpg", "image.png.1920.jpg", "image.png.2880.jpg", "image.png.3840.jpg"
*   "image.**pt3**.png" generates "image.png.160.png", "image.png.320.png", "image.png.480.png"
*   "image.**p160,320,480**.png" generates "image.png.160.png", "image.png.320.png", "image.png.480.png"
*   "image.**p160,320,480@90,70,60**.png" generates "image.png.160.png" at 90% quality, "image.png.320.png" at 70% quality, "image.png.480.png" at 60% quality

The default command list is used if none was provided.

The first character of a command can be :

*   **@** : use default command list
*   **@** `<definition name>` : use named command list
*   **s** `<surface ratio>` : set surface ratio
*   **a** : generate .avif files
*   **j** : generate .jpg files
*   **p** : generate .png files
*   **w** : generate .webp files

For image generation commands, the next characters specify the target image widths :

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

Those letters stand for **N**ano, **T**iny, **S**mall, **C**ompact, **M**edium, **L**arge, **B**ig, **H**uge, **F**ull and **U**ltra.

A target image quality list can be added after **@**.

## Installation

Install the [DMD 2 compiler](https://dlang.org/download.html) (using the MinGW setup option on Windows).

Build the executable with the following command line :

```bash
dmd -m64 nano.d
```

## Command line

```
nano [`<option>` ...] `<input folder path>` `<output folder path>`
```

### Options

```
--surface <target surface ratio>
--quality <target quality list>
--default <default command list>
--definition <definition name> <named command list>
--tool <tool path>
--keep : keep existing target images if they are newer than their source image.
```

## Sample

```csh
nano --quality 90,80,70,60 --default s16_9.am@10.al4 --definition bg s16_9.am@10.al4 --tool "convert" IN OUT
```

Generate image variants using the provided target image surface ratio, overwriting existing target images.

```csh
nano --quality 90,80,70,60 --default s16_9.am@10.al4 --definition bg s16_9.am@10.al4 --tool "convert" --keep IN OUT
```

Generate image variants using the provided target image surface ratio, keeping existing target images if they are newer than their source image.


## Dependencies

*   ImageMagick convert

## Version

1.0

## Author

Eric Pelzer (ecstatic.coder@gmail.com).

## License

This project is licensed under the GNU General Public License version 3.

See the [LICENSE.md](LICENSE.md) file for details.
