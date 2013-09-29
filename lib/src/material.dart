part of orange;


class Material {
  String textureSource;
  List<double> ambient;
  List<double> diffuse;
  List<double> specular;
  List<double> emissive;
  double shininess = 50.0;
  
  Shader shader;
  gl.Texture texture;
  Color color = new Color.fromHex(0xffffff);
}