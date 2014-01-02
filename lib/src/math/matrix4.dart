part of orange;



const double GLMAT_EPSILON = 0.000001;



class Matrix4 {
  final Float32List storage = new Float32List(16);
  
  ///
  /// [1, 0, 0, 0,
  ///  0, 1, 0, 0,
  ///  0, 0, 1, 0,
  ///  x, y, z, 0]
  ///
  Matrix4(double arg0, double arg1, double arg2, double arg3,
          double arg4, double arg5, double arg6, double arg7,
          double arg8, double arg9, double arg10, double arg11,
          double arg12, double arg13, double arg14, double arg15) {
    setValues(arg0, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10,
              arg11, arg12, arg13, arg14, arg15);
  }
  
  Matrix4.zero();
  
  Matrix4.identity() {
    setIdentity();
  }
  
  Matrix4.perspective(double fovy, double aspect, double near, double far) {
    var f = 1.0 / math.tan(fovy / 2),
        nf = 1 / (near - far);
    storage[0] = f / aspect;
    storage[1] = 0.0;
    storage[2] = 0.0;
    storage[3] = 0.0;
    storage[4] = 0.0;
    storage[5] = f;
    storage[6] = 0.0;
    storage[7] = 0.0;
    storage[8] = 0.0;
    storage[9] = 0.0;
    storage[10] = (far + near) * nf;
    storage[11] = -1.0;
    storage[12] = 0.0;
    storage[13] = 0.0;
    storage[14] = (2 * far * near) * nf;
    storage[15] = 0.0;
  }
  
  Matrix4.ortho(double left, double right, double bottom, double top, double near, double far) {
    var lr = 1 / (left - right),
        bt = 1 / (bottom - top),
        nf = 1 / (near - far);
    storage[0] = -2 * lr;
    storage[1] = 0.0;
    storage[2] = 0.0;
    storage[3] = 0.0;
    storage[4] = 0.0;
    storage[5] = -2 * bt;
    storage[6] = 0.0;
    storage[7] = 0.0;
    storage[8] = 0.0;
    storage[9] = 0.0;
    storage[10] = 2 * nf;
    storage[11] = 0.0;
    storage[12] = (left + right) * lr;
    storage[13] = (top + bottom) * bt;
    storage[14] = (far + near) * nf;
    storage[15] = 1.0;
  }
  
  Matrix4.frustum(double out, double left, double right, double bottom, double top, double near, double far) {
    var rl = 1 / (right - left),
        tb = 1 / (top - bottom),
        nf = 1 / (near - far);
    storage[0] = (near * 2) * rl;
    storage[1] = 0.0;
    storage[2] = 0.0;
    storage[3] = 0.0;
    storage[4] = 0.0;
    storage[5] = (near * 2) * tb;
    storage[6] = 0.0;
    storage[7] = 0.0;
    storage[8] = (right + left) * rl;
    storage[9] = (top + bottom) * tb;
    storage[10] = (far + near) * nf;
    storage[11] = -1.0;
    storage[12] = 0.0;
    storage[13] = 0.0;
    storage[14] = (far * near * 2) * nf;
    storage[15] = 0.0;
  }
  
  Matrix4 setValues(double arg0, double arg1, double arg2,
                    double arg3, double arg4, double arg5,
                    double arg6, double arg7, double arg8,
                    double arg9, double arg10, double arg11,
                    double arg12, double arg13, double arg14, double arg15) {
    storage[15] = arg15;
    storage[14] = arg14;
    storage[13] = arg13;
    storage[12] = arg12;
    storage[11] = arg11;
    storage[10] = arg10;
    storage[9] = arg9;
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
  
  Matrix4 setZero() {
    storage[0] = 0.0;
    storage[1] = 0.0;
    storage[2] = 0.0;
    storage[3] = 0.0;
    storage[4] = 0.0;
    storage[5] = 0.0;
    storage[6] = 0.0;
    storage[7] = 0.0;
    storage[8] = 0.0;
    storage[9] = 0.0;
    storage[10] = 0.0;
    storage[11] = 0.0;
    storage[12] = 0.0;
    storage[13] = 0.0;
    storage[14] = 0.0;
    storage[15] = 0.0;
    return this;
  }
  
  Matrix4 setIdentity() {
    storage[0] = 1.0;
    storage[1] = 0.0;
    storage[2] = 0.0;
    storage[3] = 0.0;
    storage[4] = 0.0;
    storage[5] = 1.0;
    storage[6] = 0.0;
    storage[7] = 0.0;
    storage[8] = 0.0;
    storage[9] = 0.0;
    storage[10] = 1.0;
    storage[11] = 0.0;
    storage[12] = 0.0;
    storage[13] = 0.0;
    storage[14] = 0.0;
    storage[15] = 1.0;
    return this;
  }
  
  Matrix4 clone() {
    var m = new Matrix4.zero();
    m[0] = storage[0];
    m[1] = storage[1];
    m[2] = storage[2];
    m[3] = storage[3];
    m[4] = storage[4];
    m[5] = storage[5];
    m[6] = storage[6];
    m[7] = storage[7];
    m[8] = storage[8];
    m[9] = storage[9];
    m[10] = storage[10];
    m[11] = storage[11];
    m[12] = storage[12];
    m[13] = storage[13];
    m[14] = storage[14];
    m[15] = storage[15];
    return m;
  }
  
  Matrix4 transpose() {
    var a01 = storage[1], a02 = storage[2], a03 = storage[3],
        a12 = storage[6], a13 = storage[7],
        a23 = storage[11];
    storage[1] = storage[4];
    storage[2] = storage[8];
    storage[3] = storage[12];
    storage[4] = a01;
    storage[6] = storage[9];
    storage[7] = storage[13];
    storage[8] = a02;
    storage[9] = a12;
    storage[11] = storage[14];
    storage[12] = a03;
    storage[13] = a13;
    storage[14] = a23;
    return this;
  }
  
  Matrix4 fromRotationTranslation(Quaternion rotation, Vector3 translation) {
    var x = rotation.storage[0], y = rotation.storage[1], z = rotation.storage[2], w = rotation.storage[3],
        x2 = x + x,
        y2 = y + y,
        z2 = z + z,

        xx = x * x2,
        xy = x * y2,
        xz = x * z2,
        yy = y * y2,
        yz = y * z2,
        zz = z * z2,
        wx = w * x2,
        wy = w * y2,
        wz = w * z2;

    storage[0] = 1 - (yy + zz);
    storage[1] = xy + wz;
    storage[2] = xz - wy;
    storage[3] = 0.0;
    storage[4] = xy - wz;
    storage[5] = 1 - (xx + zz);
    storage[6] = yz + wx;
    storage[7] = 0.0;
    storage[8] = xz + wy;
    storage[9] = yz - wx;
    storage[10] = 1 - (xx + yy);
    storage[11] = 0.0;
    storage[12] = translation.storage[0];
    storage[13] = translation.storage[1];
    storage[14] = translation.storage[2];
    storage[15] = 1.0;
    
    return this;
  }
  
  Matrix4 fromQuaternion(Quaternion q) {
    var x = q[0], y = q[1], z = q[2], w = q[3],
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
  }
  
  /**
   * Generates a look-at matrix with the given eye position, focal point, and up axis
   * @param [Vector3] eye Position of the viewer
   * @param [Vector3] center Point the viewer is looking at
   * @param [Vector3] up vec3 pointing up
   */
  Matrix4 lookAt(Vector3 eye, Vector3 center, Vector3 up) {
    var x0, x1, x2, y0, y1, y2, z0, z1, z2, len,
    eyex = eye.storage[0],
    eyey = eye.storage[1],
    eyez = eye.storage[2],
    upx = up.storage[0],
    upy = up.storage[1],
    upz = up.storage[2],
    centerx = center.storage[0],
    centery = center.storage[1],
    centerz = center.storage[2];

    if ((eyex - centerx).abs() < GLMAT_EPSILON &&
        (eyey - centery).abs() < GLMAT_EPSILON &&
        (eyez - centerz).abs() < GLMAT_EPSILON) {
        return setIdentity();
    }

    z0 = eyex - centerx;
    z1 = eyey - centery;
    z2 = eyez - centerz;

    len = 1 / math.sqrt(z0 * z0 + z1 * z1 + z2 * z2);
    z0 *= len;
    z1 *= len;
    z2 *= len;

    x0 = upy * z2 - upz * z1;
    x1 = upz * z0 - upx * z2;
    x2 = upx * z1 - upy * z0;
    len = math.sqrt(x0 * x0 + x1 * x1 + x2 * x2);
    if (len == 0.0) {
        x0 = 0;
        x1 = 0;
        x2 = 0;
    } else {
        len = 1 / len;
        x0 *= len;
        x1 *= len;
        x2 *= len;
    }

    y0 = z1 * x2 - z2 * x1;
    y1 = z2 * x0 - z0 * x2;
    y2 = z0 * x1 - z1 * x0;

    len = math.sqrt(y0 * y0 + y1 * y1 + y2 * y2);
    if (len == 0.0) {
        y0 = 0;
        y1 = 0;
        y2 = 0;
    } else {
        len = 1 / len;
        y0 *= len;
        y1 *= len;
        y2 *= len;
    }

    storage[0] = x0;
    storage[1] = y0;
    storage[2] = z0;
    storage[3] = 0.0;
    storage[4] = x1;
    storage[5] = y1;
    storage[6] = z1;
    storage[7] = 0.0;
    storage[8] = x2;
    storage[9] = y2;
    storage[10] = z2;
    storage[11] = 0.0;
    storage[12] = -(x0 * eyex + x1 * eyey + x2 * eyez);
    storage[13] = -(y0 * eyex + y1 * eyey + y2 * eyez);
    storage[14] = -(z0 * eyex + z1 * eyey + z2 * eyez);
    storage[15] = 1.0;

    return this;
  }
  
  double invert() {
    var a00 = storage[0], a01 = storage[1], a02 = storage[2], a03 = storage[3],
        a10 = storage[4], a11 = storage[5], a12 = storage[6], a13 = storage[7],
        a20 = storage[8], a21 = storage[9], a22 = storage[10], a23 = storage[11],
        a30 = storage[12], a31 = storage[13], a32 = storage[14], a33 = storage[15],

        b00 = a00 * a11 - a01 * a10,
        b01 = a00 * a12 - a02 * a10,
        b02 = a00 * a13 - a03 * a10,
        b03 = a01 * a12 - a02 * a11,
        b04 = a01 * a13 - a03 * a11,
        b05 = a02 * a13 - a03 * a12,
        b06 = a20 * a31 - a21 * a30,
        b07 = a20 * a32 - a22 * a30,
        b08 = a20 * a33 - a23 * a30,
        b09 = a21 * a32 - a22 * a31,
        b10 = a21 * a33 - a23 * a31,
        b11 = a22 * a33 - a23 * a32,

        // Calculate the determinant
        det = b00 * b11 - b01 * b10 + b02 * b09 + b03 * b08 - b04 * b07 + b05 * b06;

    if (det == 0.0) {
        return det; 
    }
    det = 1.0 / det;

    storage[0] = (a11 * b11 - a12 * b10 + a13 * b09) * det;
    storage[1] = (a02 * b10 - a01 * b11 - a03 * b09) * det;
    storage[2] = (a31 * b05 - a32 * b04 + a33 * b03) * det;
    storage[3] = (a22 * b04 - a21 * b05 - a23 * b03) * det;
    storage[4] = (a12 * b08 - a10 * b11 - a13 * b07) * det;
    storage[5] = (a00 * b11 - a02 * b08 + a03 * b07) * det;
    storage[6] = (a32 * b02 - a30 * b05 - a33 * b01) * det;
    storage[7] = (a20 * b05 - a22 * b02 + a23 * b01) * det;
    storage[8] = (a10 * b10 - a11 * b08 + a13 * b06) * det;
    storage[9] = (a01 * b08 - a00 * b10 - a03 * b06) * det;
    storage[10] = (a30 * b04 - a31 * b02 + a33 * b00) * det;
    storage[11] = (a21 * b02 - a20 * b04 - a23 * b00) * det;
    storage[12] = (a11 * b07 - a10 * b09 - a12 * b06) * det;
    storage[13] = (a00 * b09 - a01 * b07 + a02 * b06) * det;
    storage[14] = (a31 * b01 - a30 * b03 - a32 * b00) * det;
    storage[15] = (a20 * b03 - a21 * b01 + a22 * b00) * det;
    return det;
  }
  
  Matrix4 adjoint() {
    var out = new Matrix4.zero();
    var a00 = storage[0], a01 = storage[1], a02 = storage[2], a03 = storage[3],
        a10 = storage[4], a11 = storage[5], a12 = storage[6], a13 = storage[7],
        a20 = storage[8], a21 = storage[9], a22 = storage[10], a23 = storage[11],
        a30 = storage[12], a31 = storage[13], a32 = storage[14], a33 = storage[15];

    out[0]  =  (a11 * (a22 * a33 - a23 * a32) - a21 * (a12 * a33 - a13 * a32) + a31 * (a12 * a23 - a13 * a22));
    out[1]  = -(a01 * (a22 * a33 - a23 * a32) - a21 * (a02 * a33 - a03 * a32) + a31 * (a02 * a23 - a03 * a22));
    out[2]  =  (a01 * (a12 * a33 - a13 * a32) - a11 * (a02 * a33 - a03 * a32) + a31 * (a02 * a13 - a03 * a12));
    out[3]  = -(a01 * (a12 * a23 - a13 * a22) - a11 * (a02 * a23 - a03 * a22) + a21 * (a02 * a13 - a03 * a12));
    out[4]  = -(a10 * (a22 * a33 - a23 * a32) - a20 * (a12 * a33 - a13 * a32) + a30 * (a12 * a23 - a13 * a22));
    out[5]  =  (a00 * (a22 * a33 - a23 * a32) - a20 * (a02 * a33 - a03 * a32) + a30 * (a02 * a23 - a03 * a22));
    out[6]  = -(a00 * (a12 * a33 - a13 * a32) - a10 * (a02 * a33 - a03 * a32) + a30 * (a02 * a13 - a03 * a12));
    out[7]  =  (a00 * (a12 * a23 - a13 * a22) - a10 * (a02 * a23 - a03 * a22) + a20 * (a02 * a13 - a03 * a12));
    out[8]  =  (a10 * (a21 * a33 - a23 * a31) - a20 * (a11 * a33 - a13 * a31) + a30 * (a11 * a23 - a13 * a21));
    out[9]  = -(a00 * (a21 * a33 - a23 * a31) - a20 * (a01 * a33 - a03 * a31) + a30 * (a01 * a23 - a03 * a21));
    out[10] =  (a00 * (a11 * a33 - a13 * a31) - a10 * (a01 * a33 - a03 * a31) + a30 * (a01 * a13 - a03 * a11));
    out[11] = -(a00 * (a11 * a23 - a13 * a21) - a10 * (a01 * a23 - a03 * a21) + a20 * (a01 * a13 - a03 * a11));
    out[12] = -(a10 * (a21 * a32 - a22 * a31) - a20 * (a11 * a32 - a12 * a31) + a30 * (a11 * a22 - a12 * a21));
    out[13] =  (a00 * (a21 * a32 - a22 * a31) - a20 * (a01 * a32 - a02 * a31) + a30 * (a01 * a22 - a02 * a21));
    out[14] = -(a00 * (a11 * a32 - a12 * a31) - a10 * (a01 * a32 - a02 * a31) + a30 * (a01 * a12 - a02 * a11));
    out[15] =  (a00 * (a11 * a22 - a12 * a21) - a10 * (a01 * a22 - a02 * a21) + a20 * (a01 * a12 - a02 * a11));
    return out;
  }
  
  double determinant() {
    var a00 = storage[0], a01 = storage[1], a02 = storage[2], a03 = storage[3],
        a10 = storage[4], a11 = storage[5], a12 = storage[6], a13 = storage[7],
        a20 = storage[8], a21 = storage[9], a22 = storage[10], a23 = storage[11],
        a30 = storage[12], a31 = storage[13], a32 = storage[14], a33 = storage[15],

        b00 = a00 * a11 - a01 * a10,
        b01 = a00 * a12 - a02 * a10,
        b02 = a00 * a13 - a03 * a10,
        b03 = a01 * a12 - a02 * a11,
        b04 = a01 * a13 - a03 * a11,
        b05 = a02 * a13 - a03 * a12,
        b06 = a20 * a31 - a21 * a30,
        b07 = a20 * a32 - a22 * a30,
        b08 = a20 * a33 - a23 * a30,
        b09 = a21 * a32 - a22 * a31,
        b10 = a21 * a33 - a23 * a31,
        b11 = a22 * a33 - a23 * a32;

    // Calculate the determinant
    return b00 * b11 - b01 * b10 + b02 * b09 + b03 * b08 - b04 * b07 + b05 * b06;
  }
  
  Matrix4 multiply(Matrix4 mat) {
    var a00 = storage[0], a01 = storage[1], a02 = storage[2], a03 = storage[3],
        a10 = storage[4], a11 = storage[5], a12 = storage[6], a13 = storage[7],
        a20 = storage[8], a21 = storage[9], a22 = storage[10], a23 = storage[11],
        a30 = storage[12], a31 = storage[13], a32 = storage[14], a33 = storage[15];

    // Cache only the current line of the second matrix
    var b0  = mat[0], b1 = mat[1], b2 = mat[2], b3 = mat[3];  
    storage[0] = b0*a00 + b1*a10 + b2*a20 + b3*a30;
    storage[1] = b0*a01 + b1*a11 + b2*a21 + b3*a31;
    storage[2] = b0*a02 + b1*a12 + b2*a22 + b3*a32;
    storage[3] = b0*a03 + b1*a13 + b2*a23 + b3*a33;

    b0 = mat[4]; b1 = mat[5]; b2 = mat[6]; b3 = mat[7];
    storage[4] = b0*a00 + b1*a10 + b2*a20 + b3*a30;
    storage[5] = b0*a01 + b1*a11 + b2*a21 + b3*a31;
    storage[6] = b0*a02 + b1*a12 + b2*a22 + b3*a32;
    storage[7] = b0*a03 + b1*a13 + b2*a23 + b3*a33;

    b0 = mat[8]; b1 = mat[9]; b2 = mat[10]; b3 = mat[11];
    storage[8] = b0*a00 + b1*a10 + b2*a20 + b3*a30;
    storage[9] = b0*a01 + b1*a11 + b2*a21 + b3*a31;
    storage[10] = b0*a02 + b1*a12 + b2*a22 + b3*a32;
    storage[11] = b0*a03 + b1*a13 + b2*a23 + b3*a33;

    b0 = mat[12]; b1 = mat[13]; b2 = mat[14]; b3 = mat[15];
    storage[12] = b0*a00 + b1*a10 + b2*a20 + b3*a30;
    storage[13] = b0*a01 + b1*a11 + b2*a21 + b3*a31;
    storage[14] = b0*a02 + b1*a12 + b2*a22 + b3*a32;
    storage[15] = b0*a03 + b1*a13 + b2*a23 + b3*a33;
    return this;
  }
  
  Matrix4 translate(Vector3 v) {
    var x = v[0], y = v[1], z = v[2],
        a00, a01, a02, a03,
        a10, a11, a12, a13,
        a20, a21, a22, a23,
        a30, a31, a32, a33;

        a00 = storage[0]; a01 = storage[1]; a02 = storage[2]; a03 = storage[3];
        a10 = storage[4]; a11 = storage[5]; a12 = storage[6]; a13 = storage[7];
        a20 = storage[8]; a21 = storage[9]; a22 = storage[10]; a23 = storage[11];
        a30 = storage[12]; a31 = storage[13]; a32 = storage[14]; a33 = storage[15];
    
    storage[0] = a00 + a03*x;
    storage[1] = a01 + a03*y;
    storage[2] = a02 + a03*z;
    storage[3] = a03;

    storage[4] = a10 + a13*x;
    storage[5] = a11 + a13*y;
    storage[6] = a12 + a13*z;
    storage[7] = a13;

    storage[8] = a20 + a23*x;
    storage[9] = a21 + a23*y;
    storage[10] = a22 + a23*z;
    storage[11] = a23;
    storage[12] = a30 + a33*x;
    storage[13] = a31 + a33*y;
    storage[14] = a32 + a33*z;
    storage[15] = a33;
    return this;
  }
  
  Matrix4 scale(dynamic x, [double y = null, double z = null]) {
    var x_, y_, z_;
    if(x is Vector3) {
      x_ = x[0];
      y_ = x[1];
      z_ = x[2];
    } else {
      x_ = x;
      y_ = y == null ? x : y;
      z_ = z == null ? x : z;
    }
    storage[0] = storage[0] * x_;
    storage[1] = storage[1] * x_;
    storage[2] = storage[2] * x_;
    storage[3] = storage[3] * x_;
    storage[4] = storage[4] * y_;
    storage[5] = storage[5] * y_;
    storage[6] = storage[6] * y_;
    storage[7] = storage[7] * y_;
    storage[8] = storage[8] * z_;
    storage[9] = storage[9] * z_;
    storage[10] = storage[10] * z_;
    storage[11] = storage[11] * z_;
    return this;
  }
  
  Matrix4 rotate(double rad, Vector3 axis) {
    var x = axis[0], y = axis[1], z = axis[2],
        len = math.sqrt(x * x + y * y + z * z),
        s, c, t,
        a00, a01, a02, a03,
        a10, a11, a12, a13,
        a20, a21, a22, a23,
        b00, b01, b02,
        b10, b11, b12,
        b20, b21, b22;

    if (len.abs() < GLMAT_EPSILON) { return null; }
    
    len = 1 / len;
    x *= len;
    y *= len;
    z *= len;

    s = math.sin(rad);
    c = math.cos(rad);
    t = 1 - c;

    a00 = storage[0]; a01 = storage[1]; a02 = storage[2]; a03 = storage[3];
    a10 = storage[4]; a11 = storage[5]; a12 = storage[6]; a13 = storage[7];
    a20 = storage[8]; a21 = storage[9]; a22 = storage[10]; a23 = storage[11];

    // Construct the elements of the rotation matrix
    b00 = x * x * t + c; b01 = y * x * t + z * s; b02 = z * x * t - y * s;
    b10 = x * y * t - z * s; b11 = y * y * t + c; b12 = z * y * t + x * s;
    b20 = x * z * t + y * s; b21 = y * z * t - x * s; b22 = z * z * t + c;

    // Perform rotation-specific matrix multiplication
    storage[0] = a00 * b00 + a10 * b01 + a20 * b02;
    storage[1] = a01 * b00 + a11 * b01 + a21 * b02;
    storage[2] = a02 * b00 + a12 * b01 + a22 * b02;
    storage[3] = a03 * b00 + a13 * b01 + a23 * b02;
    storage[4] = a00 * b10 + a10 * b11 + a20 * b12;
    storage[5] = a01 * b10 + a11 * b11 + a21 * b12;
    storage[6] = a02 * b10 + a12 * b11 + a22 * b12;
    storage[7] = a03 * b10 + a13 * b11 + a23 * b12;
    storage[8] = a00 * b20 + a10 * b21 + a20 * b22;
    storage[9] = a01 * b20 + a11 * b21 + a21 * b22;
    storage[10] = a02 * b20 + a12 * b21 + a22 * b22;
    storage[11] = a03 * b20 + a13 * b21 + a23 * b22;
    return this;
  }
  
  Matrix4 rotateX(double rad) {
    var s = math.sin(rad),
        c = math.cos(rad),
        a10 = storage[4],
        a11 = storage[5],
        a12 = storage[6],
        a13 = storage[7],
        a20 = storage[8],
        a21 = storage[9],
        a22 = storage[10],
        a23 = storage[11];
    // Perform axis-specific matrix multiplication
    storage[4] = a10 * c + a20 * s;
    storage[5] = a11 * c + a21 * s;
    storage[6] = a12 * c + a22 * s;
    storage[7] = a13 * c + a23 * s;
    storage[8] = a20 * c - a10 * s;
    storage[9] = a21 * c - a11 * s;
    storage[10] = a22 * c - a12 * s;
    storage[11] = a23 * c - a13 * s;
    return this;
  }
  
  Matrix4 rotateY(double rad) {
    var s = math.sin(rad),
        c = math.cos(rad),
        a00 = storage[0],
        a01 = storage[1],
        a02 = storage[2],
        a03 = storage[3],
        a20 = storage[8],
        a21 = storage[9],
        a22 = storage[10],
        a23 = storage[11];

    // Perform axis-specific matrix multiplication
    storage[0] = a00 * c - a20 * s;
    storage[1] = a01 * c - a21 * s;
    storage[2] = a02 * c - a22 * s;
    storage[3] = a03 * c - a23 * s;
    storage[8] = a00 * s + a20 * c;
    storage[9] = a01 * s + a21 * c;
    storage[10] = a02 * s + a22 * c;
    storage[11] = a03 * s + a23 * c;
    return this;
  }
  
  Matrix4 rotateZ(double rad) {
    var s = math.sin(rad),
        c = math.cos(rad),
        a00 = storage[0],
        a01 = storage[1],
        a02 = storage[2],
        a03 = storage[3],
        a10 = storage[4],
        a11 = storage[5],
        a12 = storage[6],
        a13 = storage[7];

    // Perform axis-specific matrix multiplication
    storage[0] = a00 * c + a10 * s;
    storage[1] = a01 * c + a11 * s;
    storage[2] = a02 * c + a12 * s;
    storage[3] = a03 * c + a13 * s;
    storage[4] = a10 * c - a00 * s;
    storage[5] = a11 * c - a01 * s;
    storage[6] = a12 * c - a02 * s;
    storage[7] = a13 * c - a03 * s;
    return this;
  }
  
  Vector3 getTranslation() {
    double z = storage[14];
    double y = storage[13];
    double x = storage[12];
    return new Vector3(x, y, z);
  }
  
  Vector3 getScale() {
    var vec = new Vector3.zero();
    var sx = vec.setValues(storage[0], storage[1], storage[2]).length;
    var sy = vec.setValues(storage[4], storage[5], storage[6]).length;
    var sz = vec.setValues(storage[8], storage[9], storage[10]).length;
    return vec.setValues(sx, sy, sz);
  }
  
  Matrix3 normalMatrix3() {
    var out = new Matrix3.zero();
    var a00 = storage[0], a01 = storage[1], a02 = storage[2], a03 = storage[3],
        a10 = storage[4], a11 = storage[5], a12 = storage[6], a13 = storage[7],
        a20 = storage[8], a21 = storage[9], a22 = storage[10], a23 = storage[11],
        a30 = storage[12], a31 = storage[13], a32 = storage[14], a33 = storage[15],

        b00 = a00 * a11 - a01 * a10,
        b01 = a00 * a12 - a02 * a10,
        b02 = a00 * a13 - a03 * a10,
        b03 = a01 * a12 - a02 * a11,
        b04 = a01 * a13 - a03 * a11,
        b05 = a02 * a13 - a03 * a12,
        b06 = a20 * a31 - a21 * a30,
        b07 = a20 * a32 - a22 * a30,
        b08 = a20 * a33 - a23 * a30,
        b09 = a21 * a32 - a22 * a31,
        b10 = a21 * a33 - a23 * a31,
        b11 = a22 * a33 - a23 * a32,

        // Calculate the determinant
        det = b00 * b11 - b01 * b10 + b02 * b09 + b03 * b08 - b04 * b07 + b05 * b06;

    if (det == 0.0) { 
        return null; 
    }
    det = 1.0 / det;

    out[0] = (a11 * b11 - a12 * b10 + a13 * b09) * det;
    out[1] = (a12 * b08 - a10 * b11 - a13 * b07) * det;
    out[2] = (a10 * b10 - a11 * b08 + a13 * b06) * det;

    out[3] = (a02 * b10 - a01 * b11 - a03 * b09) * det;
    out[4] = (a00 * b11 - a02 * b08 + a03 * b07) * det;
    out[5] = (a01 * b08 - a00 * b10 - a03 * b06) * det;

    out[6] = (a31 * b05 - a32 * b04 + a33 * b03) * det;
    out[7] = (a32 * b02 - a30 * b05 - a33 * b01) * det;
    out[8] = (a30 * b04 - a31 * b02 + a33 * b00) * det;
    return out;
  }
  
  decompose(Vector3 translation, Quaternion rotation, Vector3 scaling) {
    translation[0] = storage[12];
    translation[1] = storage[13];
    translation[2] = storage[14];
    
    var xs, ys, zs;
    if((storage[0] * storage[1] * storage[2] * storage[3]) < 0) {
      xs = -1.0;
    } else {
      xs = 1.0;
    }
    
    if((storage[4] * storage[5] * storage[6] * storage[7]) < 0) {
      ys = -1.0;
    } else {
      ys = 1.0;
    }
    
    if((storage[8] * storage[9] * storage[10] * storage[11]) < 0) {
      zs = -1.0;
    } else {
      zs = 1.0;
    }
    xs=ys=zs=1.0;
    
    scaling[0] = xs * math.sqrt(storage[0] * storage[0] + storage[1] * storage[1] + storage[2] * storage[2]);
    scaling[1] = ys * math.sqrt(storage[4] * storage[4] + storage[5] * storage[5] + storage[6] * storage[6]);
    scaling[2] = zs * math.sqrt(storage[8] * storage[8] + storage[9] * storage[9] + storage[10] * storage[10]);
    
    if(scaling.x == 0.0 || scaling.y == 0.0 || scaling.z == 0.0) {
      rotation.setIdentity();
    } else {
      rotation.setFromRotation(new Matrix4(
          storage[0] / scaling.x, storage[1] / scaling.x, storage[2] / scaling.x, 0.0,
          storage[4] / scaling.y, storage[5] / scaling.y, storage[6] / scaling.y, 0.0,
          storage[8] / scaling.z, storage[9] / scaling.z, storage[10] / scaling.z, 0.0,
          0.0, 0.0, 0.0, 1.0));      
    }
  }
  
  double operator[](int i) => storage[i];
  void operator[]=(int i, double v) {
    storage[i] = v;
  }
  
  Matrix4 operator*(Matrix4 mat) {
    return clone().multiply(mat);
  }
  
  void copyIntoArray(List<num> array, [int offset=0]) {
    int i = offset;
    array[i+15] = storage[15];
    array[i+14] = storage[14];
    array[i+13] = storage[13];
    array[i+12] = storage[12];
    array[i+11] = storage[11];
    array[i+10] = storage[10];
    array[i+9] = storage[9];
    array[i+8] = storage[8];
    array[i+7] = storage[7];
    array[i+6] = storage[6];
    array[i+5] = storage[5];
    array[i+4] = storage[4];
    array[i+3] = storage[3];
    array[i+2] = storage[2];
    array[i+1] = storage[1];
    array[i+0] = storage[0];
  }
  
  String toString() {
    String s = '';
    s = '$s[0] ${storage[0]} ${storage[1]} ${storage[2]} ${storage[3]}\n';
    s = '$s[1] ${storage[4]} ${storage[5]} ${storage[6]} ${storage[7]}\n';
    s = '$s[2] ${storage[8]} ${storage[9]} ${storage[10]} ${storage[11]}\n';
    s = '$s[3] ${storage[12]} ${storage[13]} ${storage[14]} ${storage[15]}\n';
    return s;
  }
}
























