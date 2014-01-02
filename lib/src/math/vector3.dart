part of orange;


class Vector3 {
  final Float32List storage = new Float32List(3);
  
  Vector3.zero();
  
  Vector3(double x_, double y_, double z_) {
    setValues(x_, y_, z_);
  }
  
  setValues(double x_, double y_, double z_) {
    storage[0] = x_;
    storage[1] = y_;
    storage[2] = z_;
    return this;
  }
  
  Vector3 clone() {
    var vec = new Vector3.zero();
    vec.storage[0] = storage[0];
    vec.storage[1] = storage[1];
    vec.storage[2] = storage[2];
    return vec;
  }
  
  double get x => storage[0];
  double get y => storage[1];
  double get z => storage[2];
  
  double get length {
    var x = storage[0],
        y = storage[1],
        z = storage[2];
    return math.sqrt(x * x + y * y + z * z);
  }
  
  double get squaredLength {
    var x = storage[0],
        y = storage[1],
        z = storage[2];
    return x * x + y * y + z * z;
  }
  
  double operator[](int i) => storage[i];
  void operator[]=(int i, double v) {
    storage[i] = v;
  }
  
  toString() {
    return "vec3($x, $y, $z)";
  }
}