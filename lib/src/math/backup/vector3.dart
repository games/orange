part of orange;


class Vector3 {
  final Float32List storage = new Float32List(3);

  Vector3.zero();

  Vector3(double x_, double y_, double z_) {
    setValues(x_, y_, z_);
  }

  Vector3.fromList(List<num> list) {
    setValues(list[0].toDouble(), list[1].toDouble(), list[2].toDouble());
  }

  setValues(double x_, double y_, double z_) {
    storage[0] = x_;
    storage[1] = y_;
    storage[2] = z_;
    return this;
  }

  setZero() => setValues(0.0, 0.0, 0.0);

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

  Vector3 add(Vector3 arg) {
    storage[0] = storage[0] + arg.storage[0];
    storage[1] = storage[1] + arg.storage[1];
    storage[2] = storage[2] + arg.storage[2];
    return this;
  }

  Vector3 normalize() {
    double l = length;
    if (l == 0.0) {
      return this;
    }
    l = 1.0 / l;
    storage[0] *= l;
    storage[1] *= l;
    storage[2] *= l;
    return this;
  }

  /// Inner product.
  double dot(Vector3 other) {
    double sum;
    sum = storage[0] * other.storage[0];
    sum += storage[1] * other.storage[1];
    sum += storage[2] * other.storage[2];
    return sum;
  }

  /// Cross product.
  Vector3 cross(Vector3 other) {
    double _x = storage[0];
    double _y = storage[1];
    double _z = storage[2];
    double ox = other.storage[0];
    double oy = other.storage[1];
    double oz = other.storage[2];
    return new Vector3(_y * oz - _z * oy, _z * ox - _x * oz, _x * oy - _y * ox);
  }

  /// Negate
  Vector3 operator -() => new Vector3(-storage[0], -storage[1], -storage[2]);

  /// Subtract two vectors.
  Vector3 operator -(Vector3 other) => new Vector3(storage[0] - other.storage[0], storage[1] - other.storage[1], storage[2] - other.storage[2]);
  /// Scale.
  Vector3 operator /(double scale) {
    var o = 1.0 / scale;
    return new Vector3(storage[0] * o, storage[1] * o, storage[2] * o);
  }

  /// Scale.
  Vector3 operator *(double scale) {
    var o = scale;
    return new Vector3(storage[0] * o, storage[1] * o, storage[2] * o);
  }

  double operator [](int i) => storage[i];
  void operator []=(int i, double v) {
    storage[i] = v;
  }

  Vector3 operator +(Vector3 other) => clone().add(other);

  toString() {
    return "vec3($x, $y, $z)";
  }
}




/**
 * Performs a linear interpolation between two vec3's
 *
 * @param {vec3} a the first operand
 * @param {vec3} b the second operand
 * @param {Number} t interpolation amount between the two inputs
 * @returns {vec3} out
 */
Vector3 lerp(Vector3 a, Vector3 b, double t) {
  var out = new Vector3.zero();
  var ax = a[0],
      ay = a[1],
      az = a[2];
  out[0] = ax + t * (b[0] - ax);
  out[1] = ay + t * (b[1] - ay);
  out[2] = az + t * (b[2] - az);
  return out;
}





