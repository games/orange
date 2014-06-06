part of orange;



class Material {
  String name;
  Texture texture;
  double shininess;
  Color surfaceColor = new Color.fromHex(0xFFFFFF);
  Color specularColor;
  Color diffuseColor;
  Color ambientColor;
  Color emissiveColor;
}
