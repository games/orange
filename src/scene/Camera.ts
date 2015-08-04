module orange {
  export class Camera {
    private _nearClip = 0.1;
    private _farClip = 10000;
    private _fov = 45;
    private _orthoHeight = 10;
    private _aspect = 16 / 9;
    private _horizontalFov = false;
    frustumCulling = false;

    private _projMat = new Mat4();
    private _viewMat = new Mat4();
    private _viewProjMat = new Mat4();

    renderTarget;

    constructor() {
      this._projMat.setPerspective(this._fov, this._aspect, this._nearClip, this._farClip, this._horizontalFov);
    }

    get projectionMatrix() {
      return this._projMat;
    }
  }
}
