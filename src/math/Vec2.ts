module orange {
  export class Vec2 {
    data: Float32Array;

    constructor(x: number = 0, y: number = 0) {
      this.data = new Float32Array(2);
      this.data[0] = x;
      this.data[1] = y;
    }

    add(rhs: Vec2) {
      this.data[0] += rhs.data[0];
      this.data[1] += rhs.data[1];
      return this;
    }

    clone() {
      return new Vec2().copy(this);
    }

    copy(rhs: Vec2) {
      this.data[0] = rhs[0];
      this.data[1] = rhs[1];
      return this;
    }

    dot(rhs: Vec2) {
      return this.data[0] * rhs.data[0] + this.data[1] * rhs.data[1];
    }

    equals(rhs: Vec2) {
      return this.data[0] === rhs.data[0] &&
             this.data[1] === rhs.data[1];
    }

    length() {
      return Math.sqrt(this.data[0] * this.data[0] + this.data[1] * this.data[1]);
    }

    lengthSq() {
      return this.data[0] * this.data[0] + this.data[1] * this.data[1];
    }

    mul(rhs: Vec2) {
      this.data[0] *= rhs.data[0];
      this.data[1] *= rhs.data[1];
      return this;
    }

    normalize() {
      return this.scale(1 / this.length());
    }

    scale(scalar: number) {
      this.data[0] *= scalar;
      this.data[1] *= scalar;
      return this;
    }

    set(x: number, y: number) {
      this.data[0] = x;
      this.data[1] = y;
      return this;
    }

    sub(rhs: Vec2) {
      this.data[0] -= rhs.data[0];
      this.data[1] -= rhs.data[1];
      return this;
    }

    toString() {
      return "[" + this.data[0] + ", " + this.data[1] + "]";
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

    static add(lhs: Vec2, rhs: Vec2) {
      return lhs.clone().add(rhs);
    }

    static mul(lhs: Vec2, rhs: Vec2) {
      return lhs.clone().mul(rhs);
    }

    static sub(lhs: Vec2, rhs: Vec2) {
      return lhs.clone().sub(rhs);
    }

    static lerp(lhs: Vec2, rhs: Vec2, alpha: number) {
      var a = lhs.data,
          b = rhs.data,
          r = new Vec2();
      r.data[0] = a[0] + alpha * (b[0] - a[0]);
      r.data[1] = a[1] + alpha * (b[1] - a[1]);
      return r;
    }


  }
}
