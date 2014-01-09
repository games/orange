part of orange;


class Quaternion {
  final Float32List storage = new Float32List(4);
  
  Quaternion(double x, double y, double z, double w) {
    storage[0] = x;
    storage[1] = y;
    storage[2] = z;
    storage[3] = w;
  }
  
  Quaternion.fromList(List<num> list) {
    for(var i = 0; i < 4; i++) {
      storage[i] = list[i].toDouble();
    }
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
  
  Vector3 multiplyVec3(Vector3 vec) {
    var dest = new Vector3.zero();

    var x = vec[0], y = vec[1], z = vec[2],
        qx = this[0], qy = this[1], qz = this[2], qw = this[3],

        // calculate quat * vec
        ix = qw * x + qy * z - qz * y,
        iy = qw * y + qz * x - qx * z,
        iz = qw * z + qx * y - qy * x,
        iw = -qx * x - qy * y - qz * z;

    // calculate result * inverse quat
    dest[0] = ix * qw + iw * -qx + iy * -qz - iz * -qy;
    dest[1] = iy * qw + iw * -qy + iz * -qx - ix * -qz;
    dest[2] = iz * qw + iw * -qz + ix * -qy - iy * -qx;

    return dest;
  }
  
  Quaternion multiply(Quaternion other) {
    var qax = this[0], qay = this[1], qaz = this[2], qaw = this[3],
        qbx = other[0], qby = other[1], qbz = other[2], qbw = other[3];

    this[0] = qax * qbw + qaw * qbx + qay * qbz - qaz * qby;
    this[1] = qay * qbw + qaw * qby + qaz * qbx - qax * qbz;
    this[2] = qaz * qbw + qaw * qbz + qax * qby - qay * qbx;
    this[3] = qaw * qbw - qax * qbx - qay * qby - qaz * qbz;

    return this;
  }
  
  double operator[](int i) => storage[i];
  void operator[]=(int i, double v) {
    storage[i] = v;
  }
  
  Quaternion clone() => new Quaternion(storage[0], storage[1], storage[2], storage[3]);
  
  String toString() {
    return 'quat(${storage[0]}, ${storage[1]}, ${storage[2]}, ${storage[3]})';
  }
  
}