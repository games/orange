part of orange;


class Color {
  double red;
  double green;
  double blue;
  
  Color.fromHex([num hexColor]) : red = 1.0, green = 1.0, blue = 1.0 {
    if(hexColor != null) {
      hex = hexColor;
    }
  }
  
  set hex(num hexColor) {
    var h = hexColor.floor().toInt();
    red = ((h & 0xFF0000) >> 16) / 255;
    green = ((h & 0x00FF00) >> 8) / 255;
    blue = (h & 0x0000FF) / 255;
  }
  
  Vector3 get rgb => new Vector3(red, green, blue);
}