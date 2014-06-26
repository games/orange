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
  Texture emissiveTexture;
  Texture specularTexture;

  List<RenderTargetTexture> _renderTargets = [];

  Texture _reflectionTexture;

  void set reflectionTexture(Texture texture) {
    if (texture is RenderTargetTexture) _renderTargets.add(texture);
    if (_renderTargets.contains(_reflectionTexture)) _renderTargets.remove(_reflectionTexture);
    _reflectionTexture = texture;
  }

  Texture get reflectionTexture => _reflectionTexture;

  Texture _refractionTexture;

  void set refractionTexture(Texture texture) {
    if (texture is RenderTargetTexture) _renderTargets.add(texture);
    if (_renderTargets.contains(_refractionTexture)) _renderTargets.remove(_refractionTexture);
    _refractionTexture = texture;
  }

  Texture get refractionTexture => _refractionTexture;

  bool wireframe = false;
  bool backFaceCulling = true;
  bool ready([Mesh mesh]) => false;
  void bind({Mesh mesh, Matrix4 worldMatrix}) {}
  void unbind() {}

  bool get needAlphaBlending => alpha < 1.0 || opacityTexture != null;
}
