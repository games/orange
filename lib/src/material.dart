part of orange;


class Material {
  String textureSource;
  List<double> ambient;
  List<double> diffuse;
  List<double> specular;
  List<double> emissive;
  
  Shader shader;
  gl.Texture texture;
}