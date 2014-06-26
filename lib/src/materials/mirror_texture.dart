part of orange;




class MirrorTexture extends RenderTargetTexture {

  Plane mirrorPlane = new Plane.components(0.0, 1.0, 0.0, 1.0);
  Matrix4 _transformMatrix = new Matrix4.zero();
  Matrix4 _mirrorMatrix = new Matrix4.zero();

  MirrorTexture(GraphicsDevice device, int width, int height) : super(device, width, height);

  @override
  void render(Scene scene, Matrix4 viewMatrix, Matrix4 viewProjectionMatrix, Matrix4 projectionMatrix, Vector3 eyePosition) {

    var device = scene.graphicsDevice;
    device.bindFramebuffer(this);
    device.clear(new Color(0, 0, 0), backBuffer: true, depthStencil: true);
    device.ctx.viewport(0, 0, width, height);

    reflectionTo(mirrorPlane, _mirrorMatrix);
    _transformMatrix = scene.camera.viewMatrix * _mirrorMatrix;
    scene.clipPlane = mirrorPlane;
    scene.graphicsDevice._cullBackFaces = false;
    Orange.instance._renderGroup.render(scene, _transformMatrix, scene.camera.projectionMatrix * _transformMatrix, scene.camera.projectionMatrix, scene.camera.position);
    scene.graphicsDevice._cullBackFaces = true;
    scene.graphicsDevice._cullingState = null;
    scene.clipPlane = null;

    device.unbindFramebuffer();
  }
}


void reflectionTo(Plane plane, Matrix4 result) {
  plane.normalize();
  var x = plane.normal.x;
  var y = plane.normal.y;
  var z = plane.normal.z;
  var temp = -2 * x;
  var temp2 = -2 * y;
  var temp3 = -2 * z;
  result[0] = (temp * x) + 1;
  result[1] = temp2 * x;
  result[2] = temp3 * x;
  result[3] = 0.0;
  result[4] = temp * y;
  result[5] = (temp2 * y) + 1;
  result[6] = temp3 * y;
  result[7] = 0.0;
  result[8] = temp * z;
  result[9] = temp2 * z;
  result[10] = (temp3 * z) + 1;
  result[11] = 0.0;
  result[12] = temp * plane.constant;
  result[13] = temp2 * plane.constant;
  result[14] = temp3 * plane.constant;
  result[15] = 1.0;
}
