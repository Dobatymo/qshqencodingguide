ImageSource("D:/PRIVATE/Creative/EncodingGuide/MovingSquare/%02d.bmp", 1, 20, 2)
ConvertToYUY2()
SelectEven()
#Telecine
SelectEvery(2,0,0,0,1,1).SeparateFields().SelectEvery(4,1,2).Weave()
#SeparateFields()

#IVTC 1
#tfm(slow=2)
#tdecimate()

#IVTC 2
#Telecide(post=0)
#Decimate(5)
