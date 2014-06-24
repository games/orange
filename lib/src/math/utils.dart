part of orange;





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

  var ax = a[0],
      ay = a[1],
      az = a[2],
      aw = a[3],
      bx = b[0],
      by = b[1],
      bz = b[2],
      bw = b[3];

  var omega, cosom, sinom, scale0, scale1;

  // calc cosine
  cosom = ax * bx + ay * by + az * bz + aw * bw;
  // adjust signs (if necessary)
  if (cosom < 0.0) {
    cosom = -cosom;
    bx = -bx;
    by = -by;
    bz = -bz;
    bw = -bw;
  }
  // calculate coefficients
  if ((1.0 - cosom) > 0.000001) {
    // standard case (slerp)
    omega = math.acos(cosom);
    sinom = math.sin(omega);
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



Vector3 clamp(Vector3 value, Vector3 min, Vector3 max) {
  var x = value.x;
  x = (x > max.x) ? max.x : x;
  x = (x < min.x) ? min.x : x;

  var y = value.y;
  y = (y > max.y) ? max.y : y;
  y = (y < min.y) ? min.y : y;

  var z = value.z;
  z = (z > max.z) ? max.z : z;
  z = (z < min.z) ? min.z : z;

  return new Vector3(x, y, z);
}

void setFromRotation(Quaternion quaternion, Matrix4 m) {
  // http://www.euclideanspace.com/maths/geometry/rotations/conversions/matrixToQuaternion/index.htm
  // assumes the upper 3x3 of m is a pure rotation matrix (i.e, unscaled)
  var te = m.storage,

      m11 = te[0],
      m12 = te[4],
      m13 = te[8],
      m21 = te[1],
      m22 = te[5],
      m23 = te[9],
      m31 = te[2],
      m32 = te[6],
      m33 = te[10],

      trace = m11 + m22 + m33,
      s;

  if (trace > 0) {

    s = 0.5 / math.sqrt(trace + 1.0);

    quaternion[3] = 0.25 / s;
    quaternion[0] = (m32 - m23) * s;
    quaternion[1] = (m13 - m31) * s;
    quaternion[2] = (m21 - m12) * s;

  } else if (m11 > m22 && m11 > m33) {

    s = 2.0 * math.sqrt(1.0 + m11 - m22 - m33);

    quaternion[3] = (m32 - m23) / s;
    quaternion[0] = 0.25 * s;
    quaternion[1] = (m12 + m21) / s;
    quaternion[2] = (m13 + m31) / s;

  } else if (m22 > m33) {

    s = 2.0 * math.sqrt(1.0 + m22 - m11 - m33);

    quaternion[3] = (m13 - m31) / s;
    quaternion[0] = (m12 + m21) / s;
    quaternion[1] = 0.25 * s;
    quaternion[2] = (m23 + m32) / s;

  } else {

    s = 2.0 * math.sqrt(1.0 + m33 - m11 - m22);

    quaternion[3] = (m21 - m12) / s;
    quaternion[0] = (m13 + m31) / s;
    quaternion[1] = (m23 + m32) / s;
    quaternion[2] = 0.25 * s;
  }
}


class MathUtils {

  static void rotateX(Quaternion quaternion, double rad) {
    rad *= 0.5;
    var storage = quaternion.storage;
    var ax = storage[0],
        ay = storage[1],
        az = storage[2],
        aw = storage[3],
        bx = math.sin(rad),
        bw = math.cos(rad);
    storage[0] = ax * bw + aw * bx;
    storage[1] = ay * bw + az * bx;
    storage[2] = az * bw - ay * bx;
    storage[3] = aw * bw - ax * bx;
  }

  static void rotateY(Quaternion quaternion, double rad) {
    rad *= 0.5;
    var storage = quaternion.storage;
    var ax = storage[0],
        ay = storage[1],
        az = storage[2],
        aw = storage[3],
        by = math.sin(rad),
        bw = math.cos(rad);
    storage[0] = ax * bw - az * by;
    storage[1] = ay * bw + aw * by;
    storage[2] = az * bw + ax * by;
    storage[3] = aw * bw - ay * by;
  }

  static void rotateZ(Quaternion quaternion, double rad) {
    rad *= 0.5;
    var storage = quaternion.storage;
    var ax = storage[0],
        ay = storage[1],
        az = storage[2],
        aw = storage[3],
        bz = math.sin(rad),
        bw = math.cos(rad);

    storage[0] = ax * bw + ay * bz;
    storage[1] = ay * bw - ax * bz;
    storage[2] = az * bw + aw * bz;
    storage[3] = aw * bw - az * bz;
  }
}
