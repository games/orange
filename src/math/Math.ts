module orange.math {
  export const DEG_TO_RAD = Math.PI / 180;
  export const RAD_TO_DEG = 180 / Math.PI;
  export const INV_LOG2 = 1 / Math.log(2);

  export function clamp(value: number, min: number, max: number) {
    if(value >= max) return max;
    if(value <= min) return min;
    return value;
  }

  export function intToBytes24(i: number) {
    var r, g, b;

    r = (i >> 16) & 0xff;
    g = (i >> 8) & 0xff;
    b = (i) & 0xff;

    return [r, g, b];
  }

  export function intToBytes32(i: number) {
    var r, g, b, a;

    r = (i >> 24) & 0xff;
    g = (i >> 16) & 0xff;
    b = (i >> 8) & 0xff;
    a = (i) & 0xff;

    return [r, g, b, a];
  }

  // r: number | array
  export function bytesToInt24(r, g: number, b: number) {
    if (r.length) {
        b = r[2];
        g = r[1];
        r = r[0];
    }
    return ((r << 16) | (g << 8) | b);
  }

  export function bytesToInt32(r, g: number, b: number, a: number) {
    if (r.length) {
        a = r[3];
        b = r[2];
        g = r[1];
        r = r[0];
    }
    // Why ((r << 24)>>>32)?
    // << operator uses signed 32 bit numbers, so 128<<24 is negative.
    // >>> used unsigned so >>>32 converts back to an unsigned.
    // See http://stackoverflow.com/questions/1908492/unsigned-integer-in-javascript
    return ((r << 24) | (g << 16) | (b << 8) | a)>>>32;
  }

  export function lerp(a: number, b: number, alpha: number) {
      return a + (b - a) * orange.math.clamp(alpha, 0, 1);
  }

  export function lerpAngle(a, b, alpha) {
    if (b - a > 180 ) {
        b -= 360;
    }
    if (b - a < -180 ) {
        b += 360;
    }
    return orange.math.lerp(a, b, orange.math.clamp(alpha, 0, 1));
  }

  export function powerOfTwo (x: number) {
      return ((x !== 0) && !(x & (x - 1)));
  }

  export function nextPowerOfTwo(val: number) {
    val--;
    val = (val >> 1) | val;
    val = (val >> 2) | val;
    val = (val >> 4) | val;
    val = (val >> 8) | val;
    val = (val >> 16) | val;
    val++;
    return val;
  }

  export function random(min: number, max: number) {
    var diff = max - min;
    return Math.random() * diff + min;
  }

  export function smoothstep(min: number, max: number, x: number) {
    if (x <= min) return 0;
    if (x >= max) return 1;

    x = (x - min) / (max - min);

    return x * x * (3 - 2 * x);
  }

  export function smootherstep(min, max, x) {
    if (x <= min) return 0;
    if (x >= max) return 1;

    x = (x - min) / (max - min);

    return x * x * x * (x * (x * 6 - 15) + 10);
  }
}
