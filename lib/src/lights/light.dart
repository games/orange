part of orange;


abstract class Light extends Node {
  static const int MAX_LIGHTS = 4;
  
  static const int NONE = -1;
  static const int AMBIENT = 0;
  static const int DIRECT = 1;
  static const int POINT = 2;
  static const int SPOTLIGHT = 3;
  static const int HEMISPHERE = 4;
  static const int SPHERICAL_HARMONICS = 5;

  int type;
  double intensity = 1.0;
  bool enabled = true;
  Color diffuse = new Color(255, 255, 255);
  Color specular = new Color(255, 255, 255);
  double range = double.MAX_FINITE;

  Light(num hexColor, this.intensity, this.type) {
    diffuse = new Color.fromHex(hexColor);
  }

  void bind(gl.RenderingContext ctx, Shader shader, int i) {}
}

class AmbientLight extends Light {
  AmbientLight(num hexColor, {double intensity: 1.0}) : super(hexColor, intensity, Light.AMBIENT);
}

class DirectionalLight extends Light {
  Vector3 direction;
  ShadowRenderer shadowRenderer;

  DirectionalLight(num hexColor, {Vector3 direction, double intensity: 1.0})
      : super(hexColor, intensity, Light.DIRECT) {
    if (direction == null) this.direction = new Vector3(0.0, 0.0, -1.0);
  }

  @override
  void bind(gl.RenderingContext ctx, Shader shader, int i) {
    super.bind(ctx, shader, i);
    ctx.uniform4f(shader.uniforms["vLightData$i"].location, direction.x, direction.y, direction.z, 1.0);
  }
}

class PointLight extends Light {

  PointLight(num hexColor, {double intensity: 1.0})
      : super(hexColor, intensity, Light.POINT);

  @override
  void bind(gl.RenderingContext ctx, Shader shader, int i) {
    super.bind(ctx, shader, i);
    ctx.uniform4f(shader.uniforms["vLightData$i"].location, position.x, position.y, position.z, 0.0);
  }
}

class SpotLight extends DirectionalLight {
  double exponent;
  double angle = 0.8;

  SpotLight(num hexColor, {Vector3 direction, this.exponent: 3.0, double intensity: 1.0})
      : super(hexColor, intensity: intensity) {
    type = Light.SPOTLIGHT;
    if (direction == null) this.direction = new Vector3(0.0, -1.0, 0.0);
  }

  @override
  void bind(gl.RenderingContext ctx, Shader shader, int i) {
    super.bind(ctx, shader, i);
    direction.normalize();
    ctx.uniform4f(shader.uniforms["vLightData$i"].location, position.x, position.y, position.z, exponent);
    ctx.uniform4f(shader.uniforms["vLightDirection$i"].location, direction.x, direction.y, direction.z, math.cos(angle * 0.5));
  }
}


