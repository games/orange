part of orange;



class Material {
  String name;
  Technique technique;

  double shininess;
  double alpha = 1.0;
  Color diffuseColor = new Color.fromHex(0xFFFFFF);
  Color specularColor;
  Color ambientColor;
  Color emissiveColor;
  Texture diffuseTexture;
  Texture bumpTexture;
  Texture ambientTexture;
  Texture opacityTexture;
  Texture reflectionTexture;
  Texture emissiveTexture;
  Texture specularTexture;
  

  Texture refractionTexture;

  bool wireframe = false;
  bool backFaceCulling = true;
  bool ready([Mesh mesh]) => false;
  void bind({Mesh mesh, Matrix4 worldMatrix}) {}
  void unbind() {}

  bool get needAlphaBlending => alpha < 1.0 || opacityTexture != null;
}






