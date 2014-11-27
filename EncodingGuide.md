# Encoding DVDs to x264
A guide for lazy people who want a high quality encode

## Needed Software:

DVD to HDD: AnyDVD, DVDDecrpter
Source input: DGIndex
Filter: Avisynth
Encoding: x264
GUI: AvsPmod

## DVD Resolutions and aspect ratios

In a raw video file two types of information are stored. The data of the pixels themselves, meaning color information for x*y pixel and information how these pixels should be displayed.

DAR = Display Aspect Ratio: the aspect ratio of the video the way it's meant to be displayed on screen.
SAR = Storage Aspect Ratio: the ratio of width:height of the pixels stored in the file
PAR = Pixel Aspect Ratio: the aspect ratio of one single pixel

Storage Resolution: The actual pixels in the video file
Display Resolution: The resolution the video is displayed during playback (the resolution the video had, if the pixels were square i.e. PAR = 1)

PAR = DAR / SAR

Valid resolutions and aspect ratios on DVD Video [1]:
```
MPEG-2 / PAL / 25 fps
720x576 pixels 4:3, 16:9
704x576 pixels 4:3
352x576 pixels 4:3
352x288 pixels 4:3

MPEG-2 / NTSC / 29.970 fps
720x480 pixels 4:3, 16:9
704x480 pixels 4:3
352x480 pixels 4:3
352x240 pixels 4:3

MPEG-1 / PAL / 25 fps
352x288 pixels 4:3

MPEG-1 / NTSC / 29.970 fps
352x240 pixels 4:3
```

Most of these are not used on commercial film dvds, so I will concentrate on the following, common ones.

|	Storage Resolution	|	DAR	|	PAR Generic	|	PAR MPEG	|	PAR ITU	|
|	:---:	|	:---:	|	:---:	|	:---:	|	:---:	|
|	720x576	|	4:3	|	16:15	|	12:11	|	128:117	|
|	720x576	|	16:9	|	64:45	|	16:11	|	512:351	|
|	720x480	|	4:3	|	8:9	|	10:11	|	4320:4739	|
|	720x480	|	16:9	|	32:27	|	40:33	|	5760:4739	|

DVDs can be mastered according to one of the three PAR standards: Generic, MPEG, ITU. There is no flag on the DVD which tells us, which standard was used. The difference between _MPEG_ and _ITU_ is less than 0.3% and thus negligable. The difference between _generic_ and _MPEG_ is 2.2%.

![][sr]
![][dr]

[1] http://en.wikipedia.org/wiki/DVD-Video#Video_data

## Interlacing and Telecine

### PAL DVD

1. progressive

    ![][progressive]

	nothing to do

2. phase shifted

	![][phaseshifted]

  Check if `Telecide(guide=2,post=0)` fixes the problem. If it doesn't change anything, then the video is real interlaced. If it fixes most lines, but there are still some minor interlacing artefacts, change the code to `Telecide(guide=2,post=2,vthresh=X)`. X determines the threshold Telecide recognizes the frame as combed. Start with X=50 and lower/increase the value if too many/too few frames are recognized as combed.

3. real interlaced

  ![][interlaced]

  Fast, low quality: `Yadif()`
  Slow, high quality: `QTGMC().SelectEven()`. SelectEven is used, because QTGMC doubles the framerate.

### NTSC DVD

1. progressiv 23.976: fertig NTSC
2. progressiv 29.970: fertig NTSC Video
3. fake telecined 29.970: force film
4. real telecined 29.970: ivtc `tfm().tdecimate()`

`FieldDeinterlace()` is for progressive sources with a few interlacing artefacts, like after `Telecide(post=0)`

## Crop

`Crop(left, top, -right, -bottom)`
Because DVD use a YV12 colorspace, the resulting resolution must be mod2, this means divisible by 2 without remainder.
If there are 1px lines remaining, `FillMargins(left, top, right, bottom)` can be used to interpolate this line from the line next to it.

## Denoise / Degrain

`MCTemporalDenoise(settings="high")`
`hqdn3d()`: high-frequency noise

## Resize / Anamorphic
### Anamorphic

No need to resize anything, just pass the correct PAR to x264.

###  Non-Anamorphic


[sr]: export/StorageResolution.png
[dr]: export/DisplayResolution.png
[progressive]: export/MovingSquare.gif
[phaseshifted]: export/MovingSquarePhaseShifted.gif
[interlaced]: export/MovingSquareInterlaced.gif
