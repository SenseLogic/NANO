![](https://github.com/senselogic/NANO/blob/master/LOGO/nano.png)

# Nano

Image variant generator.

## Description

Nano generates source image variants in a target folder.

The source image file names must have a special suffix just before their extension.

For instance :

*   "image.**j960**.jpg" generates "image.960.jpg"
*   "image.**jl**.png" generates "image.960.jpg"
*   "image.**pt3**.png" generates "image.160.png", "image.320.png", "image.480.png"

The first character specifies the target file format :

*   **j** : .jpg
*   **p** : .png

The next characters specify the target image width, or the name of a predefined width list :

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
*   **h** : 1920
*   **h2** : 1920, 3840
*   **u** : 3840

The above letters stand for **T**iny, **S**mall, **M**edium, **L**arge, **B**ig, **H**uge and **U**ltra.

## Arguments

*   Source folder path
*   Target folder path
*   JPEG quality array
*   Generation tool path
*   Generation mode : skip | overwrite

## Sample

```csh
powershell -NoProfile -ExecutionPolicy Bypass -File "nano.ps1" IN OUT "90 80 70 60" "imagemagick\convert" skip
```

Generate image variants, keeping existing target image files if they are newer than their source image file.


```csh
powershell -NoProfile -ExecutionPolicy Bypass -File "nano.ps1" IN OUT "90 80 70 60" "imagemagick\convert" overwrite
```

Generate image variants, overwriting existing target image files.

## Dependencies

*   ImageMagick convert

## Version

1.0

## Author

Eric Pelzer (ecstatic.coder@gmail.com).

## License

This project is licensed under the GNU General Public License version 3.

See the [LICENSE.md](LICENSE.md) file for details.
