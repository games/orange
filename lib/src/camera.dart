part of orange;


abstract class Camera {
  num near;
  num far;
  num fov;
  Matrix4 projectionMatrix;
  resize();
}

class PerspectiveCamera extends Camera {
  
  PerspectiveCamera([num near = 1, num far = 1000, num fov = 45]) {
    this.near = near;
    this.far = far;
    this.fov = fov;
    resize();
  }
  
  resize() {
    projectionMatrix = makePerspectiveMatrix(radians(fov), _engine.canvas.width / _engine.canvas.height, near, far);
  }
}