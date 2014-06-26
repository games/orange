part of orange_examples;





class TestWaterScene extends Scene {

  TestWaterScene(Camera camera) : super(camera);

  @override
  void enter() {
    camera.setTranslation(-30.0, 10.0, 30.0);
    camera.lookAt(new Vector3.zero());

    var skybox = new Cube(width: 1000, height: 1000, depth: 1000);
    skybox.material = new StandardMaterial();
    skybox.material.backFaceCulling = false;
    skybox.material.reflectionTexture = new CubeTexture("textures/cube/skybox/sky");
    skybox.material.reflectionTexture.coordinatesMode = Texture.SKYBOX_MODE;
    skybox.material.diffuseColor = new Color.fromList([0.0, 0.0, 0.0]);
    skybox.material.specularColor = new Color.fromList([0.0, 0.0, 0.0]);
    add(skybox);

    var ground = new PlaneMesh(width: 10000, height: 10000, ground: true);
    ground.translate(0.0, -10.0);
    ground.material = new StandardMaterial();
    ground.material.diffuseTexture = Texture.load(graphicsDevice.ctx, {
      "path": "textures/terrain/backgrounddetailed6.jpg",
      "sampler": new Sampler()
          ..minFilter = gl.NEAREST_MIPMAP_NEAREST
          ..magFilter = gl.NEAREST
    });
    ground.material.diffuseTexture.uScale = 60.0;
    ground.material.diffuseTexture.vScale = 60.0;
    add(ground);

    var ground2 = new PlaneMesh.fromHightMap("textures/terrain/heightMap.png", width: 100, height: 100, subdivisions: 100, minHeight: 0, maxHeight: 10);
    ground2.material = new StandardMaterial();
    ground2.material.diffuseTexture = Texture.load(graphicsDevice.ctx, {
      "path": "textures/terrain/backgrounddetailed6.jpg"
    });
    ground2.material.wireframe = false;
    ground2.material.diffuseTexture.uScale = 6.0;
    ground2.material.diffuseTexture.vScale = 6.0;
    ground2.material.specularColor = new Color.fromHex(0x0);
    ground2.translate(0.0, -10.0);
    add(ground2);

    // TODO water
    var water = new PlaneMesh(width: 10000, height: 10000, ground: true);
    water.translate(0.0, -8.0);
    water.material = new ShaderMaterial(graphicsDevice, vs, fs, afterBinding: _updateWater);
    water.material.bumpTexture = Texture.load(graphicsDevice.ctx, {
      "path": "textures/waternormals.jpg"
    });
    water.material.bumpTexture.uScale = 2.0;
    water.material.bumpTexture.vScale = 2.0;
    water.material.reflectionTexture = new MirrorTexture(graphicsDevice, 512, 512);
    water.material.refractionTexture = new RenderTargetTexture(graphicsDevice, 512, 512);

    add(water);


    var light = new DirectionalLight(0xFFFFFF);
    light.direction.setValues(-1.0, -1.0, -1.0);
    add(light);
  }

  void _updateWater(ShaderMaterial material, Mesh mesh, Matrix4 world) {
    var waterColorLevel = 0.2;
    var fresnelLevel = 1.0;
    var reflectionLevel = 0.6;
    var refractionLevel = 0.8;
    var waveLength = 0.1;
    var waveHeight = 0.15;
    var waterDirection = new Vector2(0.0, 1.0);
    var time = elapsed * 0.000001;

    var device = graphicsDevice;
    device.bindColor3("waterColor", new Color.fromList([0.0, 0.3, 0.1]));
    device.bindFloat4("vLevels", waterColorLevel, fresnelLevel, reflectionLevel, refractionLevel);
    device.bindFloat2("waveData", waveLength, waveHeight);
    device.bindMatrix4("windMatrix", material.bumpTexture.textureMatrix * new Matrix4.translation(new Vector3(waterDirection.x * time, waterDirection.y * time, 0.0)));
    device.bindTexture("bumpSampler", material.bumpTexture);
    device.bindTexture("reflectionSampler", material.reflectionTexture);
    device.bindTexture("refractionSampler", material.refractionTexture);
  }

  @override
  exit() {
    super.exit();
    removeChildren();
  }
}




const String vs =
    """
#ifdef GL_ES
precision mediump float;
#endif

// Attributes
attribute vec3 position;
attribute vec3 normal;
attribute vec2 uv;

// Uniforms
uniform vec2 waveData;
uniform mat4 windMatrix;
uniform mat4 world;
uniform mat4 worldViewProjection;

// Normal
varying vec3 vPositionW;
varying vec3 vNormalW;
varying vec4 vUV;
varying vec2 vBumpUV;

void main(void) {
    vec4 outPosition = worldViewProjection * vec4(position, 1.0);
    gl_Position = outPosition;
    
    vPositionW = vec3(world * vec4(position, 1.0));
    vNormalW = normalize(vec3(world * vec4(normal, 0.0)));

    vUV = outPosition;

    vec2 bumpTexCoord = vec2(windMatrix * vec4(uv, 0.0, 1.0));
    vBumpUV = bumpTexCoord / waveData.x;
}
""";

const String fs =
    """
#ifdef GL_ES
precision mediump float;
#endif

uniform vec3 vEyePosition;
uniform vec4 vLevels;
uniform vec3 waterColor;
uniform vec2 waveData;

// Lights
varying vec3 vPositionW;
varying vec3 vNormalW;
uniform vec3 vLightPosition;

// Refs
varying vec2 vBumpUV;
varying vec4 vUV;
uniform sampler2D refractionSampler;
uniform sampler2D reflectionSampler;
uniform sampler2D bumpSampler;

void main(void) {
    vec3 viewDirectionW = normalize(vEyePosition - vPositionW);

    // Light
    vec3 lightVectorW = normalize(vLightPosition - vPositionW);

    // Wave
    vec3 bumpNormal = 2.0 * texture2D(bumpSampler, vBumpUV).rgb - 1.0;
    vec2 perturbation = waveData.y * bumpNormal.rg;

    // diffuse
    float ndl = max(0., dot(vNormalW, lightVectorW));

    // Specular
    vec3 angleW = normalize(viewDirectionW + lightVectorW);
    float specComp = dot(normalize(vNormalW), angleW);
    specComp = pow(specComp, 256.);

    // Refraction
    vec2 texCoords;
    texCoords.x = vUV.x / vUV.w / 2.0 + 0.5;
    texCoords.y = vUV.y / vUV.w / 2.0 + 0.5;

    vec3 refractionColor = texture2D(refractionSampler, texCoords + perturbation).rgb;

    // Reflection
    vec3 reflectionColor = texture2D(reflectionSampler, texCoords + perturbation).rgb;

    // Fresnel
    float fresnelTerm = dot(viewDirectionW, vNormalW);
    fresnelTerm = clamp((1.0 - fresnelTerm) * vLevels.y, 0., 1.);

    // Water color

    vec3 finalColor = (waterColor * ndl) * vLevels.x + (1.0 - vLevels.x) * (reflectionColor * fresnelTerm * vLevels.z + 
                                                       (1.0 - fresnelTerm) * refractionColor * vLevels.w) + specComp;

    
    gl_FragColor = vec4(finalColor, 1.);
}
""";










