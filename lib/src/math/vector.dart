part of orange;


class Vector3 {
  double _x, _y, _z;
  
  Vector3(this._x, this._y, this._z);
  
  Vector3.zero() : this(0.0, 0.0, 0.0);
  
  /*
   * a,b 是系数
   * P,Q,R 是向量
   * 1) P + Q = Q + P
   * 2) (P + Q) + R = P + (Q + R)
   * 3) (ab)P = a(bP)
   * a(P + Q) = aP + aQ
   * (a + b)P = aP + bP
  */
  
  Vector3 operator*(double scale) => new Vector3(scale * _x, scale * _y, scale * _z);
  
  Vector3 operator/(double scale) => this * (1.0 / scale);
  
  Vector3 operator+(Vector3 other) => new Vector3(_x + other._x, _y + other._y, _z + other._z);
  
  Vector3 operator-() => new Vector3(-_x, -_y, -_z);
  
  Vector3 operator-(Vector3 other) => this + (-this);
  
  double get length => math.sqrt(lengthSquared);
  
  double get lengthSquared => _x * _x + _y * _y + _z * _z;
  
  Vector3 normalize() {
    double l = length;
    if(l > 0.0) {
      double s = 1.0 / l;
      _x *= s;
      _y *= s;
      _z *= s;
    }
    return this;
  }
  
  double dot(Vector3 other) => _x * other._x + _y * other._y + _z * other._z;
  
  Vector3 cross(Vector3 other) {
    return new Vector3(
        _y * other._z - _z * other._y,
        _z * other._x - _x * other._z,
        _x * other._y - _y * other._x 
        );
  }
  
  
  
  Vector3 projectTo(Vector3 other) => other * (clone().dot(other) / other.lengthSquared);
  
  Vector3 clone() => new Vector3(_x, _y, _z);
  
  double get x => _x;
  double get y => _y;
  double get z => _z;
}