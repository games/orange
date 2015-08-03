module orange {
  export class Mat3 {
    data: Float32Array = new Float32Array(9);

    constructor(a00 = 1, a01 = 0, a02 = 0,
                a10 = 0, a11 = 1, a12 = 0,
                a20 = 0, a21 = 0, a22 = 1) {
      this.set(a00, a01, a02,
               a10, a11, a12,
               a20, a21, a22);
    }

    setIdentity() {
      return this.set(1, 0, 0,
                      0, 1, 0,
                      0, 0, 1);
    }

    set(a00: number, a01: number, a02: number,
        a10: number, a11: number, a12: number,
        a20: number, a21: number, a22: number) {
      var m = this.data;
      m[0] = a00;
      m[1] = a01;
      m[2] = a02;
      m[3] = a10;
      m[4] = a11;
      m[5] = a12;
      m[6] = a20;
      m[7] = a21;
      m[8] = a22;
      return this;
    }
  }
}
