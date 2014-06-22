part of orange;


class Color {

  final Float32List storage = new Float32List(4);

  Color(int r, int g, int b, [double alpha = 1.0]) {
    storage[0] = r / 255.0;
    storage[1] = g / 255.0;
    storage[2] = b / 255.0;
    storage[3] = alpha;
  }

  Color.fromHex(num hexColor) {
    hex = hexColor;
  }

  Color.fromList(List list) {
    storage[0] = list[0].toDouble();
    storage[1] = list[1].toDouble();
    storage[2] = list[2].toDouble();
    if (list.length == 4) {
      storage[3] = list[3].toDouble();
    } else {
      storage[3] = 1.0;
    }
  }

  Color scaled(num val) {
    Color c = new Color.fromList(storage);
    c.storage[0] *= val;
    c.storage[1] *= val;
    c.storage[2] *= val;
    return c;
  }

  set hex(num hexColor) {
    var h = hexColor.floor().toInt();
    storage[0] = ((h & 0xFF0000) >> 16) / 255;
    storage[1] = ((h & 0x00FF00) >> 8) / 255;
    storage[2] = (h & 0x0000FF) / 255;
    storage[3] = 1.0;
  }

  Vector3 get rgb => new Vector3.array(storage);
  double get red => storage[0];
  double get green => storage[1];
  double get blue => storage[2];
  double get alpha => storage[3];
}
