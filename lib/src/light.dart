part of orange;


class Light extends Node {
  static const int NONE = -1;
  /// Type of light: Ambient. Only other setting used by ambient color.
  static const int AMBIENT = 0;
  /// Type of light: Directional. To determine its direction the transforms rotation is used. Other settings used by ths light are: color and intensity.
  static const int DIRECT = 1;
  /// Type of light: Point light. To determine its position the transforms position is used. Other settings used by ths light are: color and intensity.
  static const int POINT = 2;
  /// Type of light: Spotlight. To determine its position and direction the transforms position and rotation is used. Other settings used by ths light are: angle, angleFalloff, color and intensity.
  static const int SPOTLIGHT = 3;
  /// Type of light: Hemisphere light. Hemisphere light is similar to POint light, but the light calculation algorithm is slightly different. All the same parameters are used though.
  static const int HEMISPHERE = 4;
  /// Type of light: Spherical Harmonics. This light type does not have any settings. The coefficients are hardcoded into the shaders currently - (take a look at Lights.glsl) but there are plans to allow conditional compilation in shaders in the future. The one that is currently used is 'Grace Catherdral'.
  static const int SPHERICAL_HARMONICS = 5;
  
  int type;
  Vector3 direction = new Vector3(0.0, 0.0, -1.0);
  Color color;
  double intensity = 0.5;
  double spotCutoff = math.PI / 2; // (range [0.0, 90.0], 180.0)
  double spotExponent = 10.0;
  double constantAttenuation = 1.0; // K0
  double linearAttenuation = 0.045; // K1
  double quadraticAttenuation = 0.0075; // K2
  
  double get spotCosCutoff => math.cos(spotCutoff);
  
  Light(num hex, [int type = -1]): color = new Color.fromHex(hex), this.type = type, this.intensity = 1.0, super();
  Light.fromColor(this.color, [int type = -1]) : this.type = type, super();
  
  updateMatrix() {
    super.updateMatrix();
    direction.setValues(0.0, 0.0, 1.0);
    rotation.rotate(direction).normalize().setValues(-direction.x, -direction.y, direction.z);
  }
}