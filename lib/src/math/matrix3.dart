part of orange;



class Matrix3 {
  final Float32List storage = new Float32List(9);

  Matrix3(double arg0, double arg1, double arg2, double arg3, double arg4, double arg5, double arg6, double arg7, double arg8) {
    setValues(arg0, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8);
  }

  Matrix3.zero();

  Matrix3.identity() {
    setIdentity();
  }

  Matrix3.fromMatrix4(Matrix4 m) {
    storage[0] = m[0];
    storage[1] = m[1];
    storage[2] = m[2];
    storage[3] = m[4];
    storage[4] = m[5];
    storage[5] = m[6];
    storage[6] = m[8];
    storage[7] = m[9];
    storage[8] = m[10];
  }
  Matrix3 setIdentity() {
    storage[0] = 1.0;
    storage[1] = 0.0;
    storage[2] = 0.0;
    storage[3] = 0.0;
    storage[4] = 1.0;
    storage[5] = 0.0;
    storage[6] = 0.0;
    storage[7] = 0.0;
    storage[8] = 1.0;
    return this;
  }

  Matrix3 setValues(double arg0, double arg1, double arg2, double arg3, double arg4, double arg5, double arg6, double arg7, double arg8) {
    storage[8] = arg8;
    storage[7] = arg7;
    storage[6] = arg6;
    storage[5] = arg5;
    storage[4] = arg4;
    storage[3] = arg3;
    storage[2] = arg2;
    storage[1] = arg1;
    storage[0] = arg0;
    return this;
  }

  double determinant() {
    double x = storage[0] * ((storage[4] * storage[8]) - (storage[5] * storage[7]));
    double y = storage[1] * ((storage[3] * storage[8]) - (storage[5] * storage[6]));
    double z = storage[2] * ((storage[3] * storage[7]) - (storage[4] * storage[6]));
    return x - y + z;
  }

  double invert() {
    double det = determinant();
    if (det == 0.0) {
      return 0.0;
    }
    double invDet = 1.0 / det;
    double ix = invDet * (storage[4] * storage[8] - storage[5] * storage[7]);
    double iy = invDet * (storage[2] * storage[7] - storage[1] * storage[8]);
    double iz = invDet * (storage[1] * storage[5] - storage[2] * storage[4]);
    double jx = invDet * (storage[5] * storage[6] - storage[3] * storage[8]);
    double jy = invDet * (storage[0] * storage[8] - storage[2] * storage[6]);
    double jz = invDet * (storage[2] * storage[3] - storage[0] * storage[5]);
    double kx = invDet * (storage[3] * storage[7] - storage[4] * storage[6]);
    double ky = invDet * (storage[1] * storage[6] - storage[0] * storage[7]);
    double kz = invDet * (storage[0] * storage[4] - storage[1] * storage[3]);
    storage[0] = ix;
    storage[1] = iy;
    storage[2] = iz;
    storage[3] = jx;
    storage[4] = jy;
    storage[5] = jz;
    storage[6] = kx;
    storage[7] = ky;
    storage[8] = kz;
    return det;
  }

  Matrix3 transpose() {
    var a01 = storage[1],
        a02 = storage[2],
        a12 = storage[5];
    storage[1] = storage[3];
    storage[2] = storage[6];
    storage[3] = a01;
    storage[5] = storage[7];
    storage[6] = a02;
    storage[7] = a12;
    return this;
  }

  double operator [](int i) => storage[i];
  void operator []=(int i, double v) {
    storage[i] = v;
  }

  void copyIntoArray(List<num> array, [int offset = 0]) {
    int i = offset;
    array[i + 8] = storage[8];
    array[i + 7] = storage[7];
    array[i + 6] = storage[6];
    array[i + 5] = storage[5];
    array[i + 4] = storage[4];
    array[i + 3] = storage[3];
    array[i + 2] = storage[2];
    array[i + 1] = storage[1];
    array[i + 0] = storage[0];
  }

  String toString() {
    String s = '';
    s = '$s[0] ${storage[0]} ${storage[1]} ${storage[2]} \n';
    s = '$s[1] ${storage[3]} ${storage[4]} ${storage[5]} \n';
    s = '$s[2] ${storage[6]} ${storage[7]} ${storage[8]} \n';
    return s;
  }
}
