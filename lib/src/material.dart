part of orange;


class Material {
  String textureSource;
  List<double> ambient;
  List<double> diffuse;
  List<double> specular;
  List<double> emissive;
  
  Shader shader;
  gl.Texture texture;
  Color color = new Color.fromHex(0xffffff);
  double shininess = 5.0;
}