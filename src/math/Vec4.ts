module orange {
  export class Vec4 {
    data: Float32Array = new Float32Array(4);

    constructor(x: number = 0, y: number = 0, z: number = 0, w: number = 0) {
      this.data[0] = x;
      this.data[1] = y;
      this.data[2] = z;
      this.data[3] = w;
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

    get w(): number {
      return this.data[3];
    }

    set w(val: number) {
      this.data[3] = val;
    }
  }
}
