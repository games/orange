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
  double intensity;
  Mesh _view;

  Light(num hexColor, double intensity, int type) {
    color = new Color.fromHex(hexColor);
    this.intensity = intensity;
    this.type = type;
  }

  updateMatrix() {
    super.updateMatrix();
    //direction.setValues(0.0, 0.0, 1.0);
    //    direction.normalize();
    //    rotation.rotate(direction).normalize();
    //    rotation.rotate(direction).normalize().setValues(-direction.x, -direction.y, direction.z);
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
      _view.position = position;
      _view.rotation = rotation;
      _view.updateMatrix();
      _view.worldMatrix.invert();
    }
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
  }
}

class SpotLight extends PointLight {
  Vector3 direction;
  double spotCutoff;
  double spotExponent;
  double get spotCosCutoff => math.cos(spotCutoff);

  SpotLight(num hexColor, {Vector3 direction, spotCutoff: math.PI / 2, spotExponent: 10.0, constantAttenuation: 1.0, linearAttenuation: 0.045, quadraticAttenuation: 0.0075, double intensity: 1.0})
      : super(hexColor, constantAttenuation: constantAttenuation, linearAttenuation: linearAttenuation, quadraticAttenuation: quadraticAttenuation, intensity: intensity) {
    type = Light.SPOTLIGHT;
    if (direction == null) this.direction = new Vector3(0.0, 0.0, -1.0);
  }

  @override
  void bind(gl.RenderingContext ctx, Shader shader, int i) {
    super.bind(ctx, shader, i);
    shader.uniform(ctx, "light${i}.spotExponent", spotExponent);
    shader.uniform(ctx, "light${i}.spotCosCutoff", spotCosCutoff);
  }
}





