ImageSource("D:/PRIVATE/Creative/EncodingGuide/MovingSquare/%02d.bmp", 1, 20, 2)
ConvertToYUY2()

SelectEven()
#Phase shifted
DoubleWeave().SelectOdd()
#SeparateFields()

#Telecide(post=0)
#or: ?? tfm(slow=2)
