part of orange;


class Quaternion {
  final Float32List storage = new Float32List(4);
  
  Quaternion(double x, double y, double z, double w) {
    storage[0] = x;
    storage[1] = y;
    storage[2] = z;
    storage[3] = w;
  }
  
  Quaternion.identity() {
    setIdentity();
  }
  
  Quaternion setFromRotation(Matrix4 m) {
    // http://www.euclideanspace.com/maths/geometry/rotations/conversions/matrixToQuaternion/index.htm
    // assumes the upper 3x3 of m is a pure rotation matrix (i.e, unscaled)
    var te = m.storage,

      m11 = te[0], m12 = te[4], m13 = te[8],
      m21 = te[1], m22 = te[5], m23 = te[9],
      m31 = te[2], m32 = te[6], m33 = te[10],

      trace = m11 + m22 + m33,
      s;

    if ( trace > 0 ) {

      s = 0.5 / math.sqrt( trace + 1.0 );

      this[3] = 0.25 / s;
      this[0] = ( m32 - m23 ) * s;
      this[1] = ( m13 - m31 ) * s;
      this[2] = ( m21 - m12 ) * s;

    } else if ( m11 > m22 && m11 > m33 ) {

      s = 2.0 * math.sqrt( 1.0 + m11 - m22 - m33 );

      this[3] = (m32 - m23 ) / s;
      this[0] = 0.25 * s;
      this[1] = (m12 + m21 ) / s;
      this[2] = (m13 + m31 ) / s;

    } else if ( m22 > m33 ) {

      s = 2.0 * math.sqrt( 1.0 + m22 - m11 - m33 );

      this[3] = (m13 - m31 ) / s;
      this[0] = (m12 + m21 ) / s;
      this[1] = 0.25 * s;
      this[2] = (m23 + m32 ) / s;

    } else {

      s = 2.0 * math.sqrt( 1.0 + m33 - m11 - m22 );

      this[3] = ( m21 - m12 ) / s;
      this[0] = ( m13 + m31 ) / s;
      this[1] = ( m23 + m32 ) / s;
      this[2] = 0.25 * s;

    }


    return this;
  }
  
  Quaternion setIdentity() {
    storage[0] = 0.0;
    storage[1] = 0.0;
    storage[2] = 0.0;
    storage[3] = 1.0;
  }
  
  Quaternion inverse() {
    var a0 = storage[0], a1 = storage[1], a2 = storage[2], a3 = storage[3],
        dot = a0*a0 + a1*a1 + a2*a2 + a3*a3,
        invDot = dot ? 1.0/dot : 0;
    // TODO: Would be faster to return [0,0,0,0] immediately if dot == 0
    storage[0] = -a0*invDot;
    storage[1] = -a1*invDot;
    storage[2] = -a2*invDot;
    storage[3] = a3*invDot;
    return this;
  }
  
  double operator[](int i) => storage[i];
  void operator[]=(int i, double v) {
    storage[i] = v;
  }
  
  String toString() {
    return 'quat(${storage[0]}, ${storage[1]}, ${storage[2]}, ${storage[3]})';
  }
  
}