part of orange;


class Light extends Node {
  static const int NONE = -1;
  static const int AMBIENT = 0;
  static const int DIRECT = 1;
  static const int POINT = 2;
  static const int SPOTLIGHT = 3;
  
  int type;
  Vector3 direction = new Vector3(0.0, 0.0, -1.0);
  Color color;
  double intensity = 1.0;
  double spotCutoff = math.PI / 2;
  double spotExponent = 10.0;
  double constantAttenuation = 1.0; // K0
  double linearAttenuation = 0.045; // K1
  double quadraticAttenuation = 0.0075; // K2

  double get spotCosCutoff => math.cos(spotCutoff);
  
  Light(num hex, [int type = -1]): color = new Color.fromHex(hex), this.type = type, this.intensity = 1.0, super();
  Light.fromColor(this.color, [int type = -1]) : this.type = type, super();
  
  updateMatrix() {
    super.updateMatrix();
    //direction.setValues(0.0, 0.0, 1.0);
//    direction.normalize();
//    rotation.rotate(direction).normalize();
//    rotation.rotate(direction).normalize().setValues(-direction.x, -direction.y, direction.z);
  }
}