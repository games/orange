part of orange;



class Material {
  String name;
  Color diffuseColor;
  Texture diffuseTexture;
  Texture bumpTexture;
  double shininess;
  Color specularColor;
  Color ambientColor;
  Texture ambientTexture;
  Color emissiveColor;
  // TODO
  Texture opacityTexture;
  Texture reflectionTexture;
  Texture emissiveTexture;
  Texture specularTexture;

  // TODO : should be multi technique and multi pass per technique
  Technique technique;
  bool wireframe = false;
  bool ready(Mesh mesh) => false;
  void bind(Mesh mesh) {}
}









