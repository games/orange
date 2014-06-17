import 'dart:html' as html;
import '../lib/orange.dart';
import 'package:stats/stats.dart';
import 'dart:math';
import 'dart:web_gl' as gl;


var boilerplate =
    """
#ifdef GL_FRAGMENT_PRECISION_HIGH    
    precision highp int;
    precision highp float;
#else
    precision mediump int;
    precision mediump float;
#endif
#define PI 3.141592653589793
#define TAU 6.283185307179586
#define PIH 1.5707963267948966
""";


var commonSrc =
    """
        $boilerplate
        varying vec3 lighting; 
        varying vec2 vTexcoords;
        uniform mat4 uProjectionMat, uViewMat;
        uniform mat3 uNormalMat;
        uniform mat4 lightProj, lightView; uniform mat3 lightRot;
        uniform mat4 uModelMat;
        uniform bool uUseTextures;
""";

const vertSrc =
    """
        attribute vec3 aPosition, aNormal;
        attribute vec2 aTexcoords;

        void main(){
            vTexcoords = aTexcoords;

            gl_Position = uProjectionMat * uViewMat * uModelMat * vec4(aPosition, 1.0);

            vec3 normal = uNormalMat * aNormal;
            //vec4 normal = uNormalMat * vec4(aNormal, 1.0);
            highp vec3 ambientLight = vec3(0.6, 0.6, 0.6);
            highp vec3 directionalLightColor = vec3(0.5, 0.5, 0.75);
            highp vec3 directionalVector = vec3(0.85, 0.8, 0.75);
            highp float directional = max(dot(normal, directionalVector), 0.0);
            lighting = ambientLight + (directionalLightColor * directional);
        }
""";

const fragSrc =
    """
        uniform sampler2D uTexture;

        void main(){
            if(uUseTextures) {
              highp vec4 textureColor = texture2D(uTexture, vec2(vTexcoords.s, vTexcoords.t));
              gl_FragColor = vec4(textureColor.rgb * lighting, textureColor.a);
            } else {
              gl_FragColor = vec4(lighting, 1.0);
            }
        }
""";




var lightComm =
    """
        $boilerplate
        varying vec3 vWorldNormal; varying vec4 vWorldPosition;
        uniform mat4 lightProj, lightView; uniform mat3 lightRot;
        uniform mat4 uModelMat;
        uniform mat3 uNormalMat;
""";
var lightVS =
    """
        attribute vec3 aPosition, aNormal;

        void main(){
            vWorldNormal = normalize(aNormal * uNormalMat);
            vWorldPosition = uModelMat * vec4(aPosition, 1.0);
            gl_Position = lightProj * lightView * vWorldPosition;
        }
""";
var lightFS =
    """
        void main(){
            vec3 lightPos = (lightView * vWorldPosition).xyz;
            float depth = clamp(length(lightPos)/40.0, 0.0, 1.0);
            gl_FragColor = vec4(vec3(depth), 1.0);
        }
""";


Texture lightDepthTexture;
num depthWidth, depthHeight;
gl.Framebuffer lightFramebuffer;
gl.RenderingContext ctx;
Shader shader;
Shader lightShader;

class TestLighting2 {
  double _lastElapsed = 0.0;
  Renderer renderer;
  Pass pass;
  List<Mesh> meshes = [];
  Plane ground;
  Stats stats;

  Light _directionalLight;
  Light _pointLight;
  Light _spotLight;


  run() {
    stats = new Stats();
    html.document.body.children.add(stats.container);

    var canvas = html.querySelector("#container");
    renderer = new Renderer(canvas);
    ctx = renderer.ctx;
    //    renderer.camera.center = new Vector3(0.0, -1.0, 0.0);
    renderer.camera.position = new Vector3(0.0, 3.0, 5.0);
    renderer.camera.lookAt(new Vector3.zero());

    renderer.pass = new Pass();
    //    renderer.pass.shader = new Shader(renderer.ctx, lightingModelVS, lightingModelFS);
    //    renderer.pass.shader = new Shader(renderer.ctx, skinnedModelVS, skinnedModelFS);
    shader = new Shader(renderer.ctx, vertSrc, fragSrc, common: commonSrc);
    lightShader = new Shader(ctx, lightVS, lightFS, common: commonSrc);

    depthWidth = 64;
    depthHeight = 64;

    lightDepthTexture = _createTexture(depthWidth, depthHeight);
    lightFramebuffer = ctx.createFramebuffer();
    ctx.bindFramebuffer(gl.FRAMEBUFFER, lightFramebuffer);
    ctx.framebufferTexture2D(gl.FRAMEBUFFER, gl.COLOR_ATTACHMENT0, lightDepthTexture.target, lightDepthTexture.data, 0);
    ctx.bindFramebuffer(gl.FRAMEBUFFER, null);

    var cube = new Cube(width: 1, height: 0.5, depth: 1.5);
    cube = createCube();
    cube.position.setValues(0.0, 0.5, 0.0);
    cube.material = new Material();
    cube.material.shininess = 64.0;
    cube.material.specularColor = new Color.fromList([0.8, 0.8, 0.8]);
    cube.material.ambientColor = new Color.fromList([0.3, 0.3, 0.3]);
    cube.material.diffuseColor = new Color.fromList([0.3, 0.3, 0.3]);
    meshes.add(cube);

    var plane = new Plane(width: 10, height: 10);
    plane.rotation.rotateX(-PI / 2);
    plane.rotation.rotateZ(PI / 4);
    plane.position.setValues(0.0, -1.0, 0.0);
    plane.material = new Material();
    plane.material.shininess = 0.0;
    //    plane.material.surfaceColor = new Color.fromList([0.8, 0.0, 0.1]);
    plane.material.specularColor = new Color.fromList([0.8, 0.8, 0.8]);
    plane.material.ambientColor = new Color.fromList([0.3, 0.3, 0.3]);
    plane.material.diffuseColor = new Color.fromList([0.3, 0.3, 0.3]);
    ground = plane;


    var textureManager = new TextureManager();
    textureManager.load(renderer.ctx, {
      "path": "cubetexture.png"
    }).then((t) {
      cube.material.diffuseTexture = t;
      //            plane.material.texture = t;
    });

    _directionalLight = new Light(0xffffff, Light.DIRECT);
    _directionalLight.rotation.rotateX(-PI);
    _directionalLight.intensity = 1.0;
    //        renderer.lights.add(_directionalLight);

    _pointLight = new Light(0xffffff, Light.POINT);
    _pointLight.position.setValues(0.0, 0.0, 0.0);
    _pointLight.intensity = 2.0;
    renderer.lights.add(_pointLight);

    //    _spotLight = new Light(0xff0000, Light.SPOTLIGHT);
    //    _spotLight.position = new Vector3(-3.0, 2.0, -2.0);
    //    _spotLight.rotation.rotateZ(PI / 4);
    //    _spotLight.direction = new Vector3(0.0, -1.0, 0.0);
    //    _spotLight.direction = _spotLight.rotation.multiplyVec3(new Vector3(0.0, -1.0, 0.0));
    //    _spotLight.intensity = 2.0;
    //    _spotLight.spotCutoff = PI / 6;
    //    _spotLight.spotExponent = 10.0;
    //    _spotLight.constantAttenuation = 0.05;
    //    _spotLight.linearAttenuation = 0.05;
    //    _spotLight.quadraticAttenuation = 0.01;
    //    renderer.lights.add(_spotLight);

    html.window.requestAnimationFrame(_animate);
  }


  _animate(num elapsed) {
    var interval = elapsed - _lastElapsed;
    stats.begin();

    //    meshes.forEach((m) {
    //      m.rotation.rotateY(interval / 1000);
    //    });

    //    renderer.camera.update(interval);
    //    renderer.camera.position.setValues(cos(elapsed / 1000) * 5, 2.0, sin(elapsed / 1000) * 5);
    //    renderer.camera.lookAt(new Vector3.zero());
    //    renderer.camera.updateMatrix();

    renderer.pass.shader = shader;
    renderer.prepare();
    meshes.forEach((m) => renderer.draw(m));
    renderer.draw(ground);

    ctx.bindFramebuffer(gl.FRAMEBUFFER, lightFramebuffer);
    ctx
        ..viewport(0, 0, depthWidth, depthHeight)
        ..clearColor(1, 1, 1, 1)
        ..clearDepth(1)
        ..cullFace(gl.FRONT);
    renderer.pass.shader = lightShader;
    if (renderer.prepare()) {
      lightShader
          ..uniform(ctx, "lightView", lightView.storage)
          ..uniform(ctx, "lightProj", lightProj.storage)
          ..uniform(ctx, "lightRot", lightRot);
      meshes.forEach((m) => renderer.draw(m));
      renderer.draw(ground);
    }

    ctx.bindFramebuffer(gl.FRAMEBUFFER, null);


    stats.end();
    _lastElapsed = elapsed;
    html.window.requestAnimationFrame(_animate);
  }
}



createCube() {
  var mesh = new PolygonMesh();
  mesh.setVertices([// Front face
    -1.0, -1.0, 1.0, 1.0, -1.0, 1.0, 1.0, 1.0, 1.0, -1.0, 1.0, 1.0, // Back face
    -1.0, -1.0, -1.0, -1.0, 1.0, -1.0, 1.0, 1.0, -1.0, 1.0, -1.0, -1.0, // Top face
    -1.0, 1.0, -1.0, -1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, -1.0, // Bottom face
    -1.0, -1.0, -1.0, 1.0, -1.0, -1.0, 1.0, -1.0, 1.0, -1.0, -1.0, 1.0, // Right face
    1.0, -1.0, -1.0, 1.0, 1.0, -1.0, 1.0, 1.0, 1.0, 1.0, -1.0, 1.0, // Left face
    -1.0, -1.0, -1.0, -1.0, -1.0, 1.0, -1.0, 1.0, 1.0, -1.0, 1.0, -1.0]);

  mesh.setNormals([// Front
    0.0, 0.0, 1.0, 0.0, 0.0, 1.0, 0.0, 0.0, 1.0, 0.0, 0.0, 1.0, // Back
    0.0, 0.0, -1.0, 0.0, 0.0, -1.0, 0.0, 0.0, -1.0, 0.0, 0.0, -1.0, // Top
    0.0, 1.0, 0.0, 0.0, 1.0, 0.0, 0.0, 1.0, 0.0, 0.0, 1.0, 0.0, // Bottom
    0.0, -1.0, 0.0, 0.0, -1.0, 0.0, 0.0, -1.0, 0.0, 0.0, -1.0, 0.0, // Right
    1.0, 0.0, 0.0, 1.0, 0.0, 0.0, 1.0, 0.0, 0.0, 1.0, 0.0, 0.0, // Left
    -1.0, 0.0, 0.0, -1.0, 0.0, 0.0, -1.0, 0.0, 0.0, -1.0, 0.0, 0.0]);

  mesh.setTexCoords([// Front
    0.0, 0.0, 1.0, 0.0, 1.0, 1.0, 0.0, 1.0, // Back
    0.0, 0.0, 1.0, 0.0, 1.0, 1.0, 0.0, 1.0, // Top
    0.0, 0.0, 1.0, 0.0, 1.0, 1.0, 0.0, 1.0, // Bottom
    0.0, 0.0, 1.0, 0.0, 1.0, 1.0, 0.0, 1.0, // Right
    0.0, 0.0, 1.0, 0.0, 1.0, 1.0, 0.0, 1.0, // Left
    0.0, 0.0, 1.0, 0.0, 1.0, 1.0, 0.0, 1.0]);

  mesh.setFaces([0, 1, 2, 0, 2, 3, // front
    4, 5, 6, 4, 6, 7, // back
    8, 9, 10, 8, 10, 11, // top
    12, 13, 14, 12, 14, 15, // bottom
    16, 17, 18, 16, 18, 19, // right
    20, 21, 22, 20, 22, 23 // left
  ]);
  return mesh;
}

Texture _createTexture(num width, num height) {
  var texture = new Texture();
  texture.target = gl.TEXTURE_2D;
  texture.internalFormat = gl.RGBA;
  texture.format = gl.RGBA;
  texture.data = ctx.createTexture();
  ctx.activeTexture(gl.TEXTURE0);
  ctx.bindTexture(texture.target, texture.data);
  ctx.texParameteri(texture.target, gl.TEXTURE_WRAP_S, gl.CLAMP_TO_EDGE);
  ctx.texParameteri(texture.target, gl.TEXTURE_WRAP_T, gl.CLAMP_TO_EDGE);
  ctx.texParameteri(texture.target, gl.TEXTURE_MIN_FILTER, gl.NEAREST);
  ctx.texParameteri(texture.target, gl.TEXTURE_MAG_FILTER, gl.NEAREST);
  ctx.texImage2D(texture.target, 0, texture.internalFormat, width, height, 0, texture.format, gl.UNSIGNED_BYTE, null);
  //  ctx.bindTexture(texture.target, null);
  return texture;
}






