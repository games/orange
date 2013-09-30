part of orange;

final Vector3 WORLD_UP = new Vector3(0.0, 1.0, 0.0);
final Vector3 WORLD_LEFT = new Vector3(-1.0, 0.0, 0.0);
final Vector3 WORLD_RIGHT = new Vector3(1.0, 0.0, 0.0);
final Vector3 WORLD_DOWN = new Vector3(0.0, -1.0, 0.0);

final Vector3 UNIT_X = new Vector3(1.0, 0.0, 0.0);
final Vector3 UNIT_Y = new Vector3(0.0, 1.0, 0.0);
final Vector3 UNIT_Z = new Vector3(0.0, 0.0, 1.0);

abstract class Camera extends Transform {
  double near;
  double far;
  double fov;
  Matrix4 projectionMatrix;
  Vector3 _focusPosition;
  updateProjection();

  lookAt(Vector3 target) {
    _focusPosition = target.clone();
    rotation = new Quaternion.fromRotation(makeViewMatrix(position, _focusPosition, WORLD_UP).getRotation());
    rotation.inverse();
  }
  
  copyViewMatrixIntoArray(Float32List vm) {
    matrix.copyIntoArray(vm);
  }

  rotate(Vector3 axis, double angleInRadian) {
    rotation *= new Quaternion.axisAngle(axis, angleInRadian);
  }
  
  roll(double angleInRadian) {
    rotate(rotation.rotated(UNIT_Z), angleInRadian);
  }
  
  yaw(double angleInRadian) {
    rotate(rotation.rotated(UNIT_Y), angleInRadian);
  }
  
  pitch(double angleInRadian) {
    rotate(rotation.rotated(UNIT_X), angleInRadian);
  }
  
  Vector3 get frontDirection =>  (_focusPosition - position).normalize();
}

class PerspectiveCamera extends Camera {
  
  PerspectiveCamera([double near = 1.0, double far = 1000.0, double fov = 45.0]) {
    this.near = near;
    this.far = far;
    this.fov = fov;
    lookAt(new Vector3(0.0, 0.0, -1.0));
    updateProjection();
  }
  
  updateProjection() {
    projectionMatrix = makePerspectiveMatrix(radians(fov), _director.canvas.width / _director.canvas.height, near, far);
  }
  
  updateMatrix() {
    super.updateMatrix();
    matrix.invert();
  }
}










