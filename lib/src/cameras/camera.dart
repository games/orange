part of orange;




abstract class CameraController {
  void attach(Camera camera, html.Element element);
  void detach();
  void update();
}


class Camera extends Node {
  CameraController controller;
  Matrix4 _projectionMatrix;
  Matrix4 _viewMatrix;

  void lookAt(Vector3 target) {
    _viewMatrix = makeViewMatrix(position, target, Axis.UP);
    rotation = new Quaternion.fromRotation(_viewMatrix.getRotation());
  }

  void update() {
    if (controller != null) controller.update();
  }

  Matrix4 get viewProjectionMatrix => _projectionMatrix * viewMatrix;
  Matrix4 get projectionMatrix => _projectionMatrix;
  Matrix4 get viewMatrix => _viewMatrix;
}

class PerspectiveCamera extends Camera {

  double near;
  double far;
  double fov;
  double aspect;

  PerspectiveCamera(this.aspect, {this.near: 1.0, this.far: 2000.0, this.fov: 50.0}) {
    _viewMatrix = new Matrix4.identity();
    updateProjection();
  }

  updateProjection() {
    _projectionMatrix = makePerspectiveMatrix(radians(fov), aspect, near, far);
  }

  void setLens(num focalLen, [num frameHeight = 24]) {
    fov = 2 * degrees(math.atan(frameHeight / (focalLen * 2)));
    updateProjection();
  }
}

class OrthographicCamera extends Camera {
  double left;
  double right;
  double top;
  double bottom;
  double near;
  double far;

  OrthographicCamera(this.left, this.right, this.top, this.bottom, {this.near: 1.0, this.far: 2000.0}) {
    updateProjection();
  }

  updateProjection() {
    _projectionMatrix = makeOrthographicMatrix(left, right, bottom, top, near, far);
  }
}







