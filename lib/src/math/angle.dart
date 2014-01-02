part of orange;



const double degrees2radians = math.PI/180.0;
const double radians2degrees = 180.0/math.PI;
const double sqrtOneHalf = 0.70710678118;

/// Convert [radians] to degrees.
double degrees(double radians) {
  return radians * radians2degrees;
}

/// Convert [degrees] to radians.
double radians(double degrees) {
  return degrees * degrees2radians;
}