module orange {
  export class Vec3 {
    data: Float32Array;

    constructor(x: number = 0, y: number = 0, z: number = 0) {
      this.data = new Float32Array(3);
      this.data[0] = x;
      this.data[1] = y;
      this.data[2] = z;
    }

    add(rhs: Vec3) {
      var a = this.data,
          b = rhs.data;

      a[0] += b[0];
      a[1] += b[1];
      a[2] += b[2];

      return this;
    }

    add2(lhs: Vec3, rhs: Vec3) {
      var a = lhs.data,
          b = rhs.data,
          r = this.data;

      r[0] = a[0] + b[0];
      r[1] = a[1] + b[1];
      r[2] = a[2] + b[2];

      return this;
    }

    clone() {
      return new Vec3().copy(this);
    }

    copy(rhs: Vec3) {
      var a = this.data,
          b = rhs.data;

      a[0] = b[0];
      a[1] = b[1];
      a[2] = b[2];

      return this;
    }

    dot(rhs: Vec3) {
      var a = this.data,
          b = rhs.data;

      return a[0] * b[0] + a[1] * b[1] + a[2] * b[2];
    }

    equals(rhs: Vec3) {
      var a = this.data,
          b = rhs.data;

      return a[0] === b[0] && a[1] === b[1] && a[2] === b[2];
    }

    length() {
      var v = this.data;
      return Math.sqrt(v[0] * v[0] + v[1] * v[1] + v[2] * v[2]);
    }

    lengthSq() {
      var v = this.data;
      return v[0] * v[0] + v[1] * v[1] + v[2] * v[2];
    }

    mul(rhs: Vec3) {
      var a = this.data,
          b = rhs.data;

      a[0] *= b[0];
      a[1] *= b[1];
      a[2] *= b[2];

      return this;
    }

    mul2(lhs: Vec3, rhs: Vec3) {
      var a = lhs.data,
          b = rhs.data,
          r = this.data;

      r[0] = a[0] * b[0];
      r[1] = a[1] * b[1];
      r[2] = a[2] * b[2];

      return this;
    }

    normalize() {
      return this.scale(1 / this.length());
    }

    scale(scalar: number) {
      var v = this.data;

      v[0] *= scalar;
      v[1] *= scalar;
      v[2] *= scalar;

      return this;
    }

    set(x: number, y: number, z: number) {
      var v = this.data;

      v[0] = x;
      v[1] = y;
      v[2] = z;

      return this;
    }

    sub(rhs: Vec3) {
      var a = this.data,
          b = rhs.data;

      a[0] -= b[0];
      a[1] -= b[1];
      a[2] -= b[2];

      return this;
    }

    sub2(lhs: Vec3, rhs: Vec3) {
      var a = lhs.data,
          b = rhs.data,
          r = this.data;

      r[0] = a[0] - b[0];
      r[1] = a[1] - b[1];
      r[2] = a[2] - b[2];

      return this;
    }

    cross(lhs: Vec3, rhs: Vec3) {
      var a, b, r, ax, ay, az, bx, by, bz;
      a = lhs.data;
      b = rhs.data;
      r = this.data;

      ax = a[0];
      ay = a[1];
      az = a[2];
      bx = b[0];
      by = b[1];
      bz = b[2];

      r[0] = ay * bz - by * az;
      r[1] = az * bx - bz * ax;
      r[2] = ax * by - bx * ay;

      return this;
    }

    project(rhs: Vec3) {
      var a = this.data;
      var b = rhs.data;
      var a_dot_b = a[0] * b[0] + a[1] * b[1] + a[2] * b[2];
      var b_dot_b = b[0] * b[0] + b[1] * b[1] + b[2] * b[2];
      var s = a_dot_b / b_dot_b;
      a[0] = b[0] * s;
      a[1] = b[1] * s;
      a[2] = b[2] * s;
      return this;
    }

    lerp(lhs: Vec3, rhs: Vec3, alpha: number) {
      var a = lhs.data,
          b = rhs.data,
          r = this.data;

      r[0] = a[0] + alpha * (b[0] - a[0]);
      r[1] = a[1] + alpha * (b[1] - a[1]);
      r[2] = a[2] + alpha * (b[2] - a[2]);

      return this;
    }

    get x(): number {
      return this.data[0];
    }

    set x(val: number) {
      this.data[0] = val;
    }

    get y(): number {
      return this.data[1];
    }

    set y(val: number) {
      this.data[1] = val;
    }

    get z(): number {
      return this.data[2];
    }

    set z(val: number) {
      this.data[2] = val;
    }

    toString() {
      return "[" + this.data[0] + ", " + this.data[1] + ", " + this.data[2] + "]";
    }

    static get BACK() {
      return new Vec3(0, 0, 1);
    }

    static get DOWN() {
      return new Vec3(0, -1, 0);
    }

    static get FORWARD() {
      return new Vec3(0, 0, -1);
    }

    static get LEFT() {
      return new Vec3(-1, 0, 0);
    }

    static get RIGHT() {
      return new Vec3(1, 0, 0);
    }

    static get UP() {
      return new Vec3(0, 1, 0);
    }

    static get ZERO() {
      return  new Vec3(0, 0, 0);
    }

    static get ONE() {
      return  new Vec3(1, 1, 1);
    }
  }
}
