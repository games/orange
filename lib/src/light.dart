part of orange;


abstract class Light extends Node {
  static const int NONE = -1;
  static const int AMBIENT = 0;
  static const int DIRECT = 1;
  static const int POINT = 2;
  static const int SPOTLIGHT = 3;
  static const int HEMISPHERE = 4;
  static const int SPHERICAL_HARMONICS = 5;

  int type;
  Color color;
  double intensity = 1.0;
  bool enabled = true;
  Mesh _view;

  //NEW
  Color diffuse = new Color(255, 255, 255);
  Color specular = new Color(255, 255, 255);
  double range = double.MAX_FINITE;

  Light(num hexColor, double intensity, int type) {
    color = new Color.fromHex(hexColor);
    this.intensity = intensity;
    this.type = type;
  }

  void bind(gl.RenderingContext ctx, Shader shader, int i) {
    shader.uniform(ctx, "light${i}.type", type);
    shader.uniform(ctx, "light${i}.intensity", intensity);
    shader.uniform(ctx, "light${i}.color", color.storage);
    shader.uniform(ctx, "light${i}.position", position.storage);
  }

  Mesh get view {
    if (_view == null) {
      _view = new Coordinate();
    }
    _view.position = position;
    _view.rotation = rotation;
    _view.updateMatrix();
    return _view;
  }
}









class AmbientLight extends Light {
  AmbientLight(num hexColor, {double intensity: 1.0}) : super(hexColor, intensity, Light.AMBIENT);
}

class DirectionalLight extends Light {
  Vector3 direction;
  DirectionalLight(num hexColor, {Vector3 direction, double intensity: 1.0})
      : super(hexColor, intensity, Light.DIRECT) {
    if (direction == null) this.direction = new Vector3(0.0, 0.0, -1.0);
  }

  @override
  void bind(gl.RenderingContext ctx, Shader shader, int i) {
    super.bind(ctx, shader, i);
    shader.uniform(ctx, "light${i}.direction", direction.storage);

    ctx.uniform4f(shader.uniforms["vLightData$i"].location, direction.x, direction.y, direction.z, 1.0);
  }
}

class PointLight extends Light {
  // K0
  double constantAttenuation;
  // K1
  double linearAttenuation;
  // K2
  double quadraticAttenuation;

  PointLight(num hexColor, {this.constantAttenuation: 1.0, this.linearAttenuation: 0.045, this.quadraticAttenuation: 0.0075, double intensity: 1.0})
      : super(hexColor, intensity, Light.POINT);

  @override
  void bind(gl.RenderingContext ctx, Shader shader, int i) {
    super.bind(ctx, shader, i);
    shader.uniform(ctx, "light${i}.constantAttenuation", constantAttenuation);
    shader.uniform(ctx, "light${i}.linearAttenuation", linearAttenuation);
    shader.uniform(ctx, "light${i}.quadraticAttenuation", quadraticAttenuation);
    
    ctx.uniform4f(shader.uniforms["vLightData$i"].location, position.x, position.y, position.z, 0.0);
  }
}

class SpotLight extends PointLight {
  Vector3 direction;
  double spotCutoff;
  double spotExponent;
  double angle = 0.8;
  double get spotCosCutoff => math.cos(spotCutoff);

  SpotLight(num hexColor, {Vector3 direction, spotCutoff: math.PI / 4, spotExponent: 3.0, constantAttenuation: 0.1, linearAttenuation: 0.05, quadraticAttenuation: 0.11, double intensity: 1.0})
      : super(hexColor, constantAttenuation: constantAttenuation, linearAttenuation: linearAttenuation, quadraticAttenuation: quadraticAttenuation, intensity: intensity) {
    type = Light.SPOTLIGHT;
    this.spotCutoff = spotCutoff;
    this.spotExponent = spotExponent;
    if (direction == null) this.direction = new Vector3(0.0, -1.0, 0.0);
  }

  @override
  void bind(gl.RenderingContext ctx, Shader shader, int i) {
    super.bind(ctx, shader, i);
    shader.uniform(ctx, "light${i}.direction", direction.storage);
    shader.uniform(ctx, "light${i}.spotExponent", spotExponent);
    shader.uniform(ctx, "light${i}.spotCosCutoff", spotCosCutoff);

    direction.normalize();
    ctx.uniform4f(shader.uniforms["vLightData$i"].location, position.x, position.y, position.z, spotExponent);
    ctx.uniform4f(shader.uniforms["vLightDirection$i"].location, direction.x, direction.y, direction.z, math.cos(angle * 0.5));
  }
}




