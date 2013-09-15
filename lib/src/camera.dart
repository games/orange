part of orange;


abstract class Camera extends Transform {
  double near;
  double far;
  double fov;
  Matrix4 projectionMatrix;
  resize();
}

class PerspectiveCamera extends Camera {
  
  PerspectiveCamera([double near = 1.0, double far = 1000.0, double fov = 45.0]) {
    this.near = near;
    this.far = far;
    this.fov = fov;
    resize();
  }
  
  resize() {
    projectionMatrix = makePerspectiveMatrix(radians(fov), _director.canvas.width / _director.canvas.height, near, far);
  }
}