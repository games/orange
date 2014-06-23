part of orange;






Vector3 getScaleFromMatrix(Matrix4 matrix) {
  var storage = matrix.storage;
  var vec = new Vector3.zero();
  var sx = vec.setValues(storage[0], storage[1], storage[2]).length;
  var sy = vec.setValues(storage[4], storage[5], storage[6]).length;
  var sz = vec.setValues(storage[8], storage[9], storage[10]).length;
  return vec.setValues(sx, sy, sz);
}


Matrix4 recompose(Vector3 scale, Quaternion rotation, Vector3 translation) {
  var matrix = fromQuaternion(rotation).scale(scale);
  matrix.setTranslation(translation);
  return matrix;
//  return new Matrix4.translation(translation)  * fromQuaternion(rotation) * new Matrix4.diagonal3(scale);
}

Matrix4 fromQuaternion(Quaternion q) {
  var mat = new Matrix4.identity();
  var storage = mat.storage;
  var x = q[0],
      y = q[1],
      z = q[2],
      w = q[3],
      x2 = x + x,
      y2 = y + y,
      z2 = z + z,

      xx = x * x2,
      yx = y * x2,
      yy = y * y2,
      zx = z * x2,
      zy = z * y2,
      zz = z * z2,
      wx = w * x2,
      wy = w * y2,
      wz = w * z2;

  storage[0] = 1 - yy - zz;
  storage[1] = yx + wz;
  storage[2] = zx - wy;
  storage[3] = 0.0;

  storage[4] = yx - wz;
  storage[5] = 1 - xx - zz;
  storage[6] = zy + wx;
  storage[7] = 0.0;

  storage[8] = zx + wy;
  storage[9] = zy - wx;
  storage[10] = 1 - xx - yy;
  storage[11] = 0.0;

  storage[12] = 0.0;
  storage[13] = 0.0;
  storage[14] = 0.0;
  storage[15] = 1.0;
  return mat;
}
