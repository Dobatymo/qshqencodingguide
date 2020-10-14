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

|	Storage Resolution	|	DAR	|	PAR Generic	|	PAR MPEG	|	PAR ITU [2]	|
|	:---:	|	:---:	|	:---:	|	:---:	|	:---:	|
|	720x576	|	4:3	|	16:15	|	12:11	|	128:117	|
|	720x576	|	16:9	|	64:45	|	16:11	|	512:351	|
|	720x480	|	4:3	|	8:9	|	10:11	|	4320:4739	|
|	720x480	|	16:9	|	32:27	|	40:33	|	5760:4739	|

DVDs can be mastered according to one of the three PAR standards: Generic, MPEG, ITU. There is no flag on the DVD which tells us, which standard was used. The difference between _MPEG_ and _ITU_ is less than 0.3% and thus negligable. The difference between _generic_ and _MPEG_ is 2.2%.

![][sr]
![][dr]

[1] http://en.wikipedia.org/wiki/DVD-Video#Video_data
[2] http://www.itu.int/rec/R-REC-BT.601

## Interlacing and Telecine

Field order:
AssumeTFF().SeparateFields()
AssumeBFF().SeparateFields()

default filter params:

FFVideoSource(path)
MPEG2Source(path, cpu=0) cpu=post processing, cpu=0 none, cpu=6 full (deblocking, deringing)

TIVTC v1.0.5 (Jan. 2008)
TFM[http://avisynth.org.ru/docs/english/externalfilters/tivtc.htm](mode=1, pp=6, slow=1) mode=field matching strategy, default ist ok. pp=post processing, default is ok. use pp=0 to disable pp. use slow=2 for better quality. use d2v param??
TDecimate[http://avisynth.org.ru/docs/english/externalfilters/tivtc.htm](mode=0, cycleR=1, cycle=5) default does standard ivtc (29.970 => 23.976 fps) use mode=1 for anime
Decomb v5.2.4 (Feb. 2013)
Telecide[http://rationalqm.us/decomb/](guide=0, post=2, blend=false) #use guide=1 for NTSC Video and 2 for PAL. post=post processing, default is ok. use post=0 to disable pp
#blend=true enables blending instead of interpolating in combed areas. Interpolating is faster. idk
Decimate[http://rationalqm.us/decomb/](cycle=5, mode=0, quality=2), normal ivtc, use quality=3 for best quality, use mode=2 for anime

FieldDeinterlace(), TDeint()??

Yadif[http://avisynth.org.ru/yadif/yadif.html](mode=0), default is ok
QTGMC[http://avisynth.nl/index.php/QTGMC](Preset="Slower", InputType=0), use "Placebo" or "Very Slow" for better quality. use InputType=1 for general progressive material. InputType=2 & 3 for badly deinterlaced material (FPSDivisor=2 instead of SelectEven())

### PAL DVD

1. progressive

    ![][progressive]

	nothing to do

2. phase/field shifted

	![][phaseshifted]

  #reverse 2:2 pulldown is needed
  Check if `Telecide(guide=2,post=0)` fixes the problem. If it doesn't change anything, then the video is real interlaced. If it fixes most lines, but there are still some minor interlacing artefacts, change the code to `Telecide(guide=2,post=2,vthresh=X)`. X determines the threshold Telecide recognizes the frame as combed. Start with X=50 and lower/increase the value if too many/too few frames are recognized as combed.
  # can be done with `TFM(pp=0)` too. if only partial fix, set pp=6

3. real interlaced

  ![][interlaced]

  Fast, low quality: `Yadif()`
  Slow, high quality: `QTGMC().SelectEven()`. SelectEven is used, because QTGMC doubles the framerate.

4. field blended

  ![][fieldblended]
  
  should be very rare with movies, but is sometimes used with animes
  very difficult to fix.
  try PAL:
  `QTGMC("Very Slow")
  Srestore(speed=-1)`
  NTSC:
  `QTGMC(Preset="Very Slow")
  Srestore(speed=-1,frate=23.976)`
  or just normal deinterlace

### NTSC DVD

1. progressiv 23.976: fertig NTSC
2. progressiv 29.970: fertig NTSC Video
3. interlaced 29.970: deinterlace
4. fake/soft telecined 29.970: force film
5. real/hard telecined 29.970: ivtc `TFM(slow=2).TDecimate()`

`FieldDeinterlace()` is for progressive sources with a few interlacing artefacts, like after `Telecide(post=0)`

 hybrid material? if mostly film, blend decimate video. if mostly video: deinterlace?? TDeint??

### Dup frames

use `TDecimate()` without `TFM()`.

## Crop

`Crop(left, top, -right, -bottom)`
Because DVD use a YV12 colorspace, the resulting resolution must be mod2, this means divisible by 2 without remainder.
If there are 1px lines remaining, `FillMargins(left, top, right, bottom)` can be used to interpolate this line from the line next to it.

## Denoise / Degrain

"very low", "low" [Default] , "medium", "high", "very high"
`MCTemporalDenoise(settings="low")`
`hqdn3d()`: high-frequency noise

## Anti-aliasing / Fixing jagged edges
`QTGMC(Preset="Slower", InputType=3)`
`santiag(2, 2)`

## Resize / Anamorphic
### Anamorphic

No need to resize anything, just pass the correct PAR to x264.

###  Non-Anamorphic

## ColorMatrix??

use `MPEG2Source("*.d2v", Info=1)` to show Res, AR and Colorimetry

use "--colormatrix  bt709" for hd to sd conversion
hd to hd and sd to sd don't need it, but it's still nice to set
PAL DVD Rec. 601: bt470bg
NTSC DVD Rec. 601: smpte170m
HD: bt709
Unknown: bt470m,bt470gb,fcc ?

or for devices which don't read the metadata, convert
`ColorMatrix(d2v=path)`

## Black and White
`Grayscale()`

[sr]: export/StorageResolution.png
[dr]: export/DisplayResolution.png
[progressive]: export/MovingSquare.gif
[phaseshifted]: export/MovingSquarePhaseShifted.gif
[interlaced]: export/MovingSquareInterlaced.gif

# Audio

## Resample
- SSRC

## PCM
- to flac
- or if too large, to AAC using QAAC
