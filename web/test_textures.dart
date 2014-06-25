part of orange_examples;





class TestTexturesScene extends Scene {

  TestTexturesScene(Camera camera) : super(camera);

  @override
  void enter() {

    camera.setTranslation(0.0, 2.0, 4.0);
    camera.lookAt(new Vector3.zero());

    var sphere = new SphereMesh();
    sphere.material = new StandardMaterial();
    sphere.material.diffuseColor = new Color(0, 255, 0);
    sphere.material.specularColor = new Color(255, 255, 255);
    sphere.material.emissiveColor = new Color(255, 0, 0);
    
    sphere.material.reflectionTexture = Texture.load(graphicsDevice.ctx, {
      "path": "textures/reflectiontexture.jpg"
    });
    sphere.material.reflectionTexture.coordinatesMode = Texture.SPHERICAL_MODE;
    
    sphere.material.emissiveTexture = Texture.load(graphicsDevice.ctx, {
      "path": "textures/leaf_textures.jpg"
    });
    
    sphere.material.diffuseTexture = Texture.load(graphicsDevice.ctx, {
      "path": "textures/tree.png"
    });
    
    sphere.material.opacityTexture = Texture.load(graphicsDevice.ctx, {
      "path": "textures/ani2.jpg"
    });
    sphere.material.opacityTexture.getAlphaFromRGB = true;
    
    sphere.material.bumpTexture = Texture.load(graphicsDevice.ctx, {
      "path": "textures/bump.png"
    });

    add(sphere);

    var pointLight0 = new PointLight(0xffffff);
    pointLight0.translate(new Vector3(-5.0, 3.0, 0.0));
    add(pointLight0);
  }
  
  @override
  void exit() {
    removeChildren();
  }
}
