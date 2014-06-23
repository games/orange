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





decompose(Matrix4 matrix, Vector3 translation, Quaternion rotation, [Vector3 scaling]) {
  var storage = matrix.storage;
  translation[0] = storage[12];
  translation[1] = storage[13];
  translation[2] = storage[14];

  var xs, ys, zs;
  if ((storage[0] * storage[1] * storage[2] * storage[3]) < 0) {
    xs = -1.0;
  } else {
    xs = 1.0;
  }

  if ((storage[4] * storage[5] * storage[6] * storage[7]) < 0) {
    ys = -1.0;
  } else {
    ys = 1.0;
  }

  if ((storage[8] * storage[9] * storage[10] * storage[11]) < 0) {
    zs = -1.0;
  } else {
    zs = 1.0;
  }
  xs = ys = zs = 1.0;

  if (scaling == null) {
    scaling = new Vector3.zero();
  }

  scaling[0] = xs * math.sqrt(storage[0] * storage[0] + storage[1] * storage[1] + storage[2] * storage[2]);
  scaling[1] = ys * math.sqrt(storage[4] * storage[4] + storage[5] * storage[5] + storage[6] * storage[6]);
  scaling[2] = zs * math.sqrt(storage[8] * storage[8] + storage[9] * storage[9] + storage[10] * storage[10]);

  if (scaling.x == 0.0 || scaling.y == 0.0 || scaling.z == 0.0) {
    rotation.storage[0] = 0.0;
    rotation.storage[1] = 0.0;
    rotation.storage[2] = 0.0;
    rotation.storage[3] = 1.0;
  } else {
    setFromRotation(rotation, new Matrix4(storage[0] / scaling.x, storage[1] / scaling.x, storage[2] / scaling.x, 0.0, storage[4] / scaling.y, storage[5] / scaling.y, storage[6] / scaling.y, 0.0, storage[8] / scaling.z, storage[9] / scaling.z, storage[10] / scaling.z, 0.0, 0.0, 0.0, 0.0, 1.0));
  }
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
