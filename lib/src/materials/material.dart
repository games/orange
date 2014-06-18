part of orange;



class Material {
  String name;
  Texture diffuseTexture;
  // TODO
  Texture bumpTexture;
  double shininess;
  Color specularColor;
  Color diffuseColor;
  Color ambientColor;
  Color emissiveColor;

  // TODO : should be multi technique and multi pass per technique
  Technique technique;
  bool wireframe = false;
  bool ready(Scene scene, Mesh mesh) => false;

  void bind(Renderer2 renderer, Scene scene, Mesh mesh) {}
}










