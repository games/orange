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
  
  Quaternion.axisAngle(Vector3 axis, double angle) {
    setAxisAngle(axis, angle);
  }
  
  Quaternion.identity() {
    setIdentity();
  }
  
  void setAxisAngle(Vector3 axis, double radians) {
    double len = axis.length;
    if (len == 0.0) {
      return;
    }
    double halfSin = math.sin(radians * 0.5) / len;
    storage[0] = axis.storage[0] * halfSin;
    storage[1] = axis.storage[1] * halfSin;
    storage[2] = axis.storage[2] * halfSin;
    storage[3] = math.cos(radians * 0.5);
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
  
  Quaternion add(Quaternion other) {
    storage[0] + other.storage[0];
    storage[1] + other.storage[1];
    storage[2] + other.storage[2];
    storage[3] + other.storage[3];
    return this;
  }
  
  Quaternion operator+(Quaternion other) => clone().add(other);
  
  double operator[](int i) => storage[i];
  void operator[]=(int i, double v) {
    storage[i] = v;
  }
  
  Quaternion clone() => new Quaternion(storage[0], storage[1], storage[2], storage[3]);
  
  String toString() {
    return 'quat(${storage[0]}, ${storage[1]}, ${storage[2]}, ${storage[3]})';
  }
  
}



/**
 * Performs a spherical linear interpolation between two quat
 *
 * @param {quat} a the first operand
 * @param {quat} b the second operand
 * @param {Number} t interpolation amount between the two inputs
 * @returns {quat} out
 */
Quaternion slerp(Quaternion a, Quaternion b, double t) {
  Quaternion out = new Quaternion.identity();
  // benchmarks:
  //    http://jsperf.com/quaternion-slerp-implementations

  var ax = a[0], ay = a[1], az = a[2], aw = a[3],
      bx = b[0], by = b[1], bz = b[2], bw = b[3];

  var omega, cosom, sinom, scale0, scale1;

  // calc cosine
  cosom = ax * bx + ay * by + az * bz + aw * bw;
  // adjust signs (if necessary)
  if ( cosom < 0.0 ) {
    cosom = -cosom;
    bx = - bx;
    by = - by;
    bz = - bz;
    bw = - bw;
  }
  // calculate coefficients
  if ( (1.0 - cosom) > 0.000001 ) {
    // standard case (slerp)
    omega  = math.acos(cosom);
    sinom  = math.sin(omega);
    scale0 = math.sin((1.0 - t) * omega) / sinom;
    scale1 = math.sin(t * omega) / sinom;
  } else {        
    // "from" and "to" quaternions are very close 
    //  ... so we can do a linear interpolation
    scale0 = 1.0 - t;
    scale1 = t;
  }
  // calculate final values
  out[0] = scale0 * ax + scale1 * bx;
  out[1] = scale0 * ay + scale1 * by;
  out[2] = scale0 * az + scale1 * bz;
  out[3] = scale0 * aw + scale1 * bw;
  
  return out;
}

