ImageSource("D:/PRIVATE/Creative/EncodingGuide/MovingSquare/%02d.bmp", 1, 20, 2)
SelectEven()

Function Blend(clip Clip)
{
    bob = Clip.Bob()
    Return Overlay(bob.SelectEven(), bob.SelectOdd(), mode="blend", opacity=0.5)
}
