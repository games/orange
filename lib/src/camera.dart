part of orange;


abstract class Camera extends Node {
  double near;
  double far;
  double fov;
  double aspect;
  Matrix4 projectionMatrix;
  Vector3 _focusPosition;
  Quaternion _rotation;
  
  updateProjection();

  lookAt(Vector3 target) {
//    _focusPosition = target.clone();
//    var rotation = new Quaternion.fromRotation(makeViewMatrix(position, _focusPosition, WORLD_UP).getRotation());
//    rotation.inverse();
//    var s = _getScaleFromMatrix(matrix);
//    matrix.fromRotationTranslation(rotation, position);
//    matrix.scale(s);
//    matrix.lookAt(eye, center, up);
    _matrix.lookAt(translation, target, WORLD_UP);
  }
//
//  rotate(Vector3 axis, double angleInRadian) {
//    rotation *= new Quaternion.axisAngle(axis, angleInRadian);
//  }
//  
//  roll(double angleInRadian) {
//    rotate(rotation.rotated(UNIT_Z), angleInRadian);
//  }
//  
//  yaw(double angleInRadian) {
//    rotate(rotation.rotated(UNIT_Y), angleInRadian);
//  }
//  
//  pitch(double angleInRadian) {
//    rotate(rotation.rotated(UNIT_X), angleInRadian);
//  }
//  
//  Vector3 get frontDirection =>  (_focusPosition - position).normalize();
}

class PerspectiveCamera extends Camera {
  
  PerspectiveCamera(double aspect, [double near = 1.0, double far = 1000.0, double fov = 45.0]) {
    this.aspect = aspect;
    this.near = near;
    this.far = far;
    this.fov = fov;
    updateProjection();
  }
  
  updateProjection() {
    projectionMatrix = new Matrix4.perspective(radians(fov), aspect, near, far);
  }
  
  updateMatrixWorld() {
    super.updateMatrixWorld();
    matrixWorld.invert();
  }
}










