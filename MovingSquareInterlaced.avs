LoadCplugin("C:\Program Files (x86)\AviSynth 2.5\plugins\yadif.dll")
ImageSource("D:/PRIVATE/Creative/EncodingGuide/MovingSquare/%02d.bmp", 1, 20, 2)
ConvertToYUY2()

#Interlace
SeparateFields()
SelectEvery(4,0,3)
Weave()

#Deinterlace high quality / slow
#QTGMC(Preset="Slower")
#SelectEven()

#Deinterlace low quality / fast
Yadif()
