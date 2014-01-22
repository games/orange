part of orange;


class Color {
  final Float32List storage = new Float32List(3);
  
  Color(int r, int g, int b, [double alpha = 1.0]) {
    storage[0] = r / 255.0;
    storage[1] = g / 255.0;
    storage[2] = b / 255.0;
//    storage[3] = alpha;
  }
  
  Color.fromHex(num hexColor) {
    hex = hexColor;
  }
  
  Color.fromList(List list) {
    storage[0] = list[0];
    storage[1] = list[1];
    storage[2] = list[2];
//    if(list.length == 4) {
//      storage[3] = list[3];
//    } else {
//      storage[3] = 1.0;
//    }
  }
  
  set hex(num hexColor) {
    var h = hexColor.floor().toInt();
    storage[0] = ((h & 0xFF0000) >> 16) / 255;
    storage[1] = ((h & 0x00FF00) >> 8) / 255;
    storage[2] = (h & 0x0000FF) / 255;
//    storage[3] = 1.0;
  }
  
  Vector3 get rgb => new Vector3.fromList(storage);
  double get red => storage[0];
  double get green => storage[1];
  double get blue => storage[2];
  double get alpha => 1.0; //storage[3];
}