part of orange;




class WaterMaterial extends ShaderMaterial {

  Color waterColor = new Color.fromList([0.0, 0.3, 0.1]);
  double waterColorLevel = 0.2;
  double fresnelLevel = 1.0;
  double reflectionLevel = 0.6;
  double refractionLevel = 0.8;
  double waveLength = 0.1;
  double waveHeight = 0.15;
  Vector2 waterDirection = new Vector2(0.0, 1.0);

  RenderTargetTexture _refractionTexture;

  WaterMaterial(GraphicsDevice graphicsDevice) : super(graphicsDevice, SHADER_WATER_VS, SHADER_WATER_FS) {
    afterBinding = _afterBindg;
    reflectionTexture = new MirrorTexture(graphicsDevice, 512, 512);
    _refractionTexture = new RenderTargetTexture(graphicsDevice, 512, 512);
    _renderTargets.add(_refractionTexture);
  }

  void _afterBindg(ShaderMaterial material, Mesh mesh, Matrix4 world) {
    var scene = Director.instance.scene;
    var time = scene.elapsed * 0.000001;
    _graphicsDevice.bindColor3("waterColor", waterColor);
    _graphicsDevice.bindFloat4("vLevels", waterColorLevel, fresnelLevel, reflectionLevel, refractionLevel);
    _graphicsDevice.bindFloat2("waveData", waveLength, waveHeight);
    _graphicsDevice.bindMatrix4("windMatrix", bumpTexture.textureMatrix * new Matrix4.translation(new Vector3(waterDirection.x * time, waterDirection.y * time, 0.0)));
    _graphicsDevice.bindTexture("bumpSampler", bumpTexture);
    _graphicsDevice.bindTexture("reflectionSampler", reflectionTexture);
    _graphicsDevice.bindTexture("refractionSampler", _refractionTexture);
  }



}
