part of orange;

final Vector3 WORLD_UP = new Vector3(0.0, 1.0, 0.0);
final Vector3 WORLD_DOWN = new Vector3(0.0, -1.0, 0.0);

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










