part of orange;






Vector3 getScaleFromMatrix(Matrix4 matrix) {
  var storage = matrix.storage;
  var vec = new Vector3.zero();
  var sx = vec.setValues(storage[0], storage[1], storage[2]).length;
  var sy = vec.setValues(storage[4], storage[5], storage[6]).length;
  var sz = vec.setValues(storage[8], storage[9], storage[10]).length;
  return vec.setValues(sx, sy, sz);
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
    setFromRotation(rotation, new Matrix4(storage[0] / scaling.x, storage[1] / scaling.x, storage[2] / scaling.x, 0.0, storage[4] / scaling.y, storage[5] / scaling.y, storage[6] / scaling.y, 0.0,
        storage[8] / scaling.z, storage[9] / scaling.z, storage[10] / scaling.z, 0.0, 0.0, 0.0, 0.0, 1.0));
  }
}

Matrix4 recompose(Vector3 scale, Quaternion rotation, Vector3 translation) {
  var matrix = fromQuaternion(rotation).scale(scale);
  matrix.setTranslation(translation);
  return matrix;
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
