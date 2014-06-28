part of orange_examples;





class TestParticles extends Scene {
  TestParticles(Camera camera): super(camera);
  
  
  @override
  void enter() {
    
    var light0 = new PointLight(0xffffff);
    light0.setTranslation(0.0, 2.0, 8.0);
    add(light0);
    
    camera.setTranslation(1.0, 1.0, 20.0);
    camera.lookAt(new Vector3.zero());
    
    var fountain = new Cube();
    fountain.material=new StandardMaterial();
    add(fountain);
    
    var ground = new PlaneMesh(width: 50, height: 50, ground: true);
    ground.setTranslation(0.0, -10.0, 0.0);
    ground.rotateY(PI/2);
    ground.material = new StandardMaterial();
    ground.material.backFaceCulling=false;
    ground.material.diffuseColor=new Color.float(0.3, 0.3, 1.0);
    add(ground);
    
    var particles = new ParticleSystem("particles", 1, this);
    particles.particleTexture=Texture.load(graphicsDevice.ctx, {
      "path": "/orange/models/texture/flare.png"
    });
    particles.emitter = fountain;
    particles.minEmitBox = new Vector3(-1.0, 0.0, 0.0);
    particles.maxEmitBox = new Vector3(1.0, 0.0, 0.0);
    particles.color1 = new Color.float(0.7, 0.8, 1.0, 1.0);
    particles.color2 = new Color.float(0.2, 0.5, 1.0, 1.0);
    particles.colorDead = new Color.float(0.0, 0.0, 0.2, 0.0);
    particles.minSize = 0.1;
    particles.maxSize = 0.5;
    particles.minLifeTime = 0.3;
    particles.maxLifeTime = 1.5;
    particles.emitRate = 1500;
    particles.blendMod = ParticleSystem.BLENDMODE_ONEONE;
    particles.gravity = new Vector3(0.0, -9.81, 0.0);
    particles.direction1 = new Vector3(-7.0, 8.0, 3.0);
    particles.direction2 = new Vector3(7.0, 8.0, -3.0);
    particles.minAngularSpeed = 0.0;
    particles.maxAngularSpeed = PI;
    particles.minEmitPower = 1.0;
    particles.maxEmitPower = 3.0;
    particles.updateSpeed = 0.005;
    particles.start();
  }
}

















