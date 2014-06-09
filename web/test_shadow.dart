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

vec4 pack(float depth) {
  const vec4 bitSh = vec4(256 * 256 * 256, 
                          256 * 256,
                          256, 
                          1.0);
  const vec4 bitMsk = vec4(0, 1.0 / 256.0, 1.0 / 256.0, 1.0 / 256.0);
  vec4 comp = fract(depth * bitSh);
  comp -= comp.xxyz * bitMsk;
  return comp;
}

float unpack(vec4 colour) {
  const vec4 bitShifts = vec4(1.0 / (256.0 * 256.0 * 256.0),
                      1.0 / (256.0 * 256.0),
                      1.0 / 256.0,
                      1.0);
  return dot(colour, bitShifts);
}

""";


var commonSrc = """
        $boilerplate
""";


const shadowDepthVS =
    """
attribute vec3 aPosition;
attribute vec2 aTexcoords;
attribute vec3 aNormal;
  
uniform mat4 uProjectionMat;
uniform mat4 uViewMat;
uniform mat4 uModelMat;
  
varying vec2 vUv;
 
void main (void)
{
  gl_Position = uProjectionMat * uViewMat * uModelMat * vec4(aPosition, 1.0);
  vUv = aTexcoords;
}
""";

const shadowDepthFS =
    """
varying vec2 vUv;
uniform sampler2D sLightDepth;

void main (void)
{
  // Decode from RGBA to float
  float depth = unpack(texture2D(sLightDepth, vUv));
  depth = pow(depth, 64.0);
  gl_FragColor = vec4(depth, depth, depth, 1.0);
}
""";



const vertSrc =
    """
precision highp float;
attribute vec3 aPosition;
attribute vec2 aTexcoords;
attribute vec3 aNormal;

uniform mat4 uViewMat;
uniform mat4 uModelMat;
uniform mat4 uProjectionMat;
uniform mat3 uNormalMat;
uniform bool uUseTextures;
uniform mat4 lightProj, lightView;
const mat4 ScaleMatrix = mat4(0.5, 0.0, 0.0, 0.0, 0.0, 0.5, 0.0, 0.0, 0.0, 0.0, 0.5, 0.0, 0.5, 0.5, 0.5, 1.0);

varying vec4 vPosition;
varying vec3 vNormal;
varying vec4 vLightPosition;

void main(void) {
   vPosition = uViewMat * uModelMat * vec4(aPosition, 1.0);
   gl_Position = uProjectionMat * vPosition;
   vNormal = normalize(uNormalMat * aNormal);

   vLightPosition = ScaleMatrix * uProjectionMat * lightView * uModelMat * vec4(aPosition, 1.0);
}
""";

const fragSrc =
    """
precision highp float;
uniform mat4 uViewMat;
uniform sampler2D uTexture;
// material
uniform float shininess;
uniform vec3 specularColor;
uniform vec3 diffuseColor;
uniform vec3 ambientColor;
uniform vec3 emissiveColor;

uniform mat4 lightProj, lightView;
uniform mat3 lightRot;
uniform sampler2D sLightDepth;

$shader_light_structure
$shader_lights

varying vec4 vPosition;
varying vec3 vNormal;
varying vec4 vLightPosition;

vec3 gamma(vec3 color){
    return pow(color, vec3(2.2));
}

void main() {
  vec3 lighting = computeLight(vPosition, vNormal, light0, shininess) + 
                 computeLight(vPosition, vNormal, light1, shininess) + 
                 computeLight(vPosition, vNormal, light2, shininess) + 
                 computeLight(vPosition, vNormal, light3, shininess);

  vec3 depth = vLightPosition.xyz / vLightPosition.w;
  depth.z -= 0.0003;
  if ( (depth.x < 0.0) || (depth.x > 1.0) || (depth.y < 0.0) || (depth.y > 1.0) || (depth.z < 0.0) || (depth.z > 1.0) ){
    gl_FragColor = vec4(lighting, 1.0);
    gl_FragColor.w = 1.0;
  } else {
    float texelSize = 1.0 / 512.0;
    vec3 colour = vec3(0.0, 0.0, 0.0);
    float shadow = 0.0;
    
    // Filter
    int count = 0;
    for (int y = -1; y <= 1; ++y)
    {
      for (int x = -1; x <= 1; ++x)
      {
        vec2 offset = depth.xy + vec2(float(x) * texelSize, float(y) * texelSize);
        if ( (offset.x >= 0.0) && (offset.x <= 1.0) && (offset.y >= 0.0) && (offset.y <= 1.0) )
        {
          // Decode from RGBA to float
          shadow = unpack(texture2D(sLightDepth, offset));

          if ( depth.z > shadow )
            colour += lighting.xyz * vec3(0.1, 0.1, 0.1);
          else
            colour += lighting.xyz;
          
          ++count;
        }
      }
    }
    
    if ( count > 0 )
      colour /= float(count);
    else
      colour = lighting.xyz;
    
    // Clip
    gl_FragColor.x = max(0.0, min(1.0, colour.x));
    gl_FragColor.y = max(0.0, min(1.0, colour.y));
    gl_FragColor.z = max(0.0, min(1.0, colour.z));
    gl_FragColor.w = 1.0;
  }
}
""";

var lightComm =
    """
        $boilerplate
        uniform mat4 lightProj, lightView;
        uniform mat4 uModelMat;
        uniform mat3 uNormalMat;

        varying vec4 vposition;
""";
var lightVS = """
        attribute vec3 aPosition;
        void main(){
            gl_Position = lightProj * lightView * uModelMat * vec4(aPosition, 1.0);
        }
""";
var lightFS =
    """
      varying vec4 vPosition;
      void main (void) {
        gl_FragColor = pack(gl_FragCoord.z);
//        float depth = gl_FragCoord.z;
//        depth = pow(depth, 64.0);
//        gl_FragColor = vec4(depth, depth, depth, 1.0);
      }
""";

Pass showDepthMapping;
Pass displayPass;
Pass shadowPass;
Texture lightDepthTexture;
num depthWidth, depthHeight;
gl.Framebuffer lightFramebuffer;
Matrix4 lightProj;
Matrix4 lightView;
Matrix3 lightRot;

class TestShadow {
  double _lastElapsed = 0.0;
  Renderer renderer;
  gl.RenderingContext ctx;
  Pass pass;
  List<Mesh> meshes = [];
  Plane ground;
  Mesh board;
  Stats stats;

  DirectionalLight _directionalLight;
  PointLight _pointLight;
  SpotLight _spotLight;
  html.CanvasElement canvas;


  run() {
    stats = new Stats();
    html.document.body.children.add(stats.container);

    canvas = html.querySelector("#container");
    renderer = new Renderer(canvas);
    renderer.camera.position = new Vector3(0.0, 2.0, 5.0);
    renderer.camera.lookAt(new Vector3.zero());
    ctx = renderer.ctx;

    displayPass = new Pass();
    displayPass.shader = new Shader(renderer.ctx, vertSrc, fragSrc, common: commonSrc);
    //    displayPass.shader = new Shader(ctx, lightingModelVS, lightingModelFS);

    shadowPass = new Pass();
    shadowPass.shader = new Shader(renderer.ctx, lightVS, lightFS, common: lightComm);
    //    shadowPass.shader = new Shader(ctx, lightingModelVS, lightingModelFS);

    showDepthMapping = new Pass();
    showDepthMapping.shader = new Shader(ctx, shadowDepthVS, shadowDepthFS, common: commonSrc);

    depthWidth = 512;//canvas.width;
    depthHeight = 512;//canvas.height;

    lightProj = new Matrix4.perspective(90.0, 1.0, 0.01, 100.0);

    lightDepthTexture = _createTexture(depthWidth, depthHeight);
    lightFramebuffer = ctx.createFramebuffer();
    ctx.bindFramebuffer(gl.FRAMEBUFFER, lightFramebuffer);
    ctx.framebufferTexture2D(gl.FRAMEBUFFER, gl.COLOR_ATTACHMENT0, lightDepthTexture.target, lightDepthTexture.data, 0);
    ctx.bindFramebuffer(gl.FRAMEBUFFER, null);
    
//    Mesh teapot;
//    var objLoader = new ObjLoader();
//    objLoader.load("../models/obj/teapot.obj").then((m) {
//      teapot = m;
//      teapot.material = new Material();
//      teapot.material.shininess = 64.0;
//      teapot.material.specularColor = new Color.fromList([0.8, 0.8, 0.8]);
//      teapot.material.ambientColor = new Color.fromList([0.3, 0.3, 0.3]);
//      teapot.material.diffuseColor = new Color.fromList([0.5, 0.0, 0.0]);
//      meshes.add(teapot);
//    });

    var cube = new Cube(width: 1, height: 0.5, depth: 1.5);
    cube.position.setValues(-1.0, -0.4, 0.0);
    cube.material = new Material();
    cube.material.shininess = 64.0;
    cube.material.specularColor = new Color.fromList([0.8, 0.8, 0.8]);
    cube.material.ambientColor = new Color.fromList([1.0, 0.0, 0.0]);
    cube.material.diffuseColor = new Color.fromList([0.3, 0.3, 0.3]);
    meshes.add(cube);

    var sphere = new Sphere(widthSegments: 20, heightSegments: 20);
    sphere.position.setValues(1.5, 0.0, 0.0);
    sphere.material = new Material();
    sphere.material.shininess = 64.0;
    sphere.material.specularColor = new Color.fromList([0.8, 0.8, 0.8]);
    sphere.material.ambientColor = new Color.fromList([0.3, 0.3, 0.3]);
    sphere.material.diffuseColor = new Color.fromList([0.3, 0.3, 0.3]);
    //    sphere.wireframe = true;
    meshes.add(sphere);

    var cone = new Cone(bottomRadius: 0.2, height: 0.5);
    cone.position.setValues(0.0, 0.0, 2.0);
    cone.material = new Material();
    cone.material.shininess = 64.0;
    cone.material.specularColor = new Color.fromList([0.8, 0.8, 0.8]);
    cone.material.ambientColor = new Color.fromList([0.0, 1.0, 0.3]);
    cone.material.diffuseColor = new Color.fromList([0.3, 0.3, 0.3]);
    meshes.add(cone);

    var plane = new Plane(width: 10, height: 10);
    plane.rotation.rotateX(-PI / 2);
    plane.rotation.rotateZ(PI / 4);
    plane.position.setValues(0.0, -1.0, 0.0);
    plane.material = new Material();
    plane.material.shininess = 64.0;
    plane.material.specularColor = new Color.fromList([0.8, 0.8, 0.8]);
    plane.material.ambientColor = new Color.fromList([0.3, 0.3, 0.3]);
    plane.material.diffuseColor = new Color.fromList([0.3, 0.3, 0.3]);
    ground = plane;

    board = new Plane(width: 10, height: 10);
    board.position.setValues(0.0, 0.0, -10.0);
    //    board = new Cube();
    board.material = new Material();
    board.material.shininess = 64.0;
    board.material.specularColor = new Color.fromList([0.8, 0.8, 0.8]);
    board.material.ambientColor = new Color.fromList([0.3, 0.3, 0.3]);
    board.material.diffuseColor = new Color.fromList([0.3, 0.3, 0.3]);

    var coordinate = new Coordinate();
    coordinate.position.setValues(0.0, 0.0, 1.0);
    //    meshes.add(coordinate);

    _directionalLight = new DirectionalLight(0xffffff);
    _directionalLight.rotation.rotateX(-PI);
    _directionalLight.intensity = 1.0;
    //    renderer.lights.add(_directionalLight);

    _pointLight = new PointLight(0xffffff);
    _pointLight.position = new Vector3(3.2, 1.0, 4.0);
    _pointLight.intensity = 2.0;
    renderer.lights.add(_pointLight);

    _spotLight = new SpotLight(0xff0000);
    _spotLight.position = new Vector3(0.0, 5.0, 0.0);
    _spotLight.intensity = 2.0;
    _spotLight.direction = new Vector3(0.0, -1.0, 0.0);
    _spotLight.spotCutoff = PI / 2;
    _spotLight.spotExponent = 10.0;
    _spotLight.constantAttenuation = 0.05;
    _spotLight.linearAttenuation = 0.05;
    _spotLight.quadraticAttenuation = 0.01;
    //    renderer.lights.add(_spotLight);

    html.window.requestAnimationFrame(_animate);
  }


  _animate(num elapsed) {
    var interval = elapsed - _lastElapsed;
    stats.begin();


    //    meshes.forEach((m) {
    //      m.rotation.rotateY(interval / 1000);
    //    });

    renderer.camera.update(interval);
    renderer.camera.updateMatrix();

    //    _pointLight.position.setValues(cos(elapsed / 1000) * 5, 2.0, sin(elapsed / 1000) * 5);
    //    _pointLight.updateMatrix();

    lightView = new Matrix4.identity().lookAt(_pointLight.position, new Vector3.zero(), new Vector3(0.0, 1.0, 0.0));
    lightRot = new Matrix3.fromMatrix4(lightView);

    _renderShadowDepth();
    _renderScene();
//    _renderDepthToScene(interval);


    stats.end();
    _lastElapsed = elapsed;
    html.window.requestAnimationFrame(_animate);
  }

  _renderShadowDepth() {
    ctx.bindFramebuffer(gl.FRAMEBUFFER, lightFramebuffer);
    renderer.pass = shadowPass;
    ctx
        ..viewport(0, 0, depthWidth, depthHeight)
        ..clearColor(1, 1, 1, 1)
        ..clearDepth(1)
        ..cullFace(gl.FRONT);

    if (renderer.prepare()) {
      shadowPass.shader
          ..uniform(ctx, "lightView", lightView.storage)
          ..uniform(ctx, "lightProj", lightProj.storage);
      //          ..uniform(ctx, "lightProj", renderer.camera.projectionMatrix.storage);
      //                  ..uniform(ctx, "lightRot", lightRot);
      meshes.forEach((m) => renderer.draw(m));
    }
    ctx.bindFramebuffer(gl.FRAMEBUFFER, null);
  }

  _renderScene() {
    ctx
        ..viewport(0, 0, canvas.width, canvas.height)
        ..cullFace(gl.BACK)
        ..clearColor(0, 0, 0, 0)
        ..clearDepth(1);

    renderer.pass = displayPass;
    if (renderer.prepare()) {
      ctx.activeTexture(gl.TEXTURE0);
      ctx.bindTexture(lightDepthTexture.target, lightDepthTexture.data);
      displayPass.shader
          ..uniform(ctx, "lightView", lightView.storage)
          ..uniform(ctx, "lightProj", lightProj.storage)
          ..uniform(ctx, "lightRot", lightRot.storage)
          ..uniform(ctx, "sLightDepth", 0);

      //      displayPass.shader.uniform(ctx, Semantics.viewMat, lightView.storage);
      //      displayPass.shader.uniform(ctx, Semantics.projectionMat, lightProj.storage);

      meshes.forEach((m) => renderer.draw(m));
      //      renderer.draw(board);
      renderer.draw(ground);
      //      renderer.draw(_pointLight);
    }
  }

  _renderDepthToScene(interval) {
    //    board.rotation.rotateX(interval / 1000);
    //    board.rotation.rotateY(interval / 1000);

    renderer.camera.position = new Vector3(0.0, 0.0, 5.0);
    renderer.camera.lookAt(new Vector3.zero());
    ctx
        ..viewport(0, 0, canvas.width, canvas.height)
        ..cullFace(gl.BACK)
        ..clearColor(0, 0, 0, 0)
        ..clearDepth(1);

    renderer.pass = showDepthMapping;
    if (renderer.prepare()) {

      ctx.activeTexture(gl.TEXTURE0);
      ctx.bindTexture(lightDepthTexture.target, lightDepthTexture.data);
      showDepthMapping.shader.uniform(ctx, "sLightDepth", 0);
//      showDepthMapping.shader.uniform(ctx, Semantics.viewMat, lightView.storage);
//      showDepthMapping.shader.uniform(ctx, Semantics.projectionMat, lightProj.storage);
      renderer.draw(board);
    }
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
}









