import 'dart:html' as html;
import 'dart:math' as Math;
import 'dart:web_gl' as gl;
import 'package:orange/orange.dart';


Color backgroundColor = new Color.fromHex(0x84A6EE);
html.CanvasElement canvas;
gl.RenderingContext ctx;
Texture lightDepthTexture;
num depthWidth = 512;
num depthHeight = 512;
gl.Framebuffer lightFramebuffer;
Matrix4 lightProj;
Matrix4 lightView;
Matrix3 lightRot;
Shader sceneShader;
Shader depthShader;
Shader showMappingShader;
Mesh ground;
Mesh mesh1;
Mesh mesh2;
Mesh mesh3;
Mesh teapot;
Mesh light;
Mesh mappingBoard;
PerspectiveCamera camera;
int _newMaxEnabledArray = -1;
int _lastMaxEnabledArray = -1;
double _lastElapsed = 0.0;
double _cameraY = 7.0;
double _cameraZ = 13.0;

//controllers
int viewType = 0;
bool rotateCamera = false;

void main() {
  var input = html.querySelector("#scene_view");
  input.onChange.listen((e) => viewType = 0);
  input = html.querySelector("#light_view");
  input.onChange.listen((e) => viewType = 1);
  input = html.querySelector("#depth_view");
  input.onChange.listen((e) => viewType = 2);
  input = html.querySelector("#rotate_camera");
  input.onChange.listen((e) => rotateCamera = !rotateCamera);

  canvas = html.querySelector("#container");
  ctx = canvas.getContext3d();
  camera = new PerspectiveCamera(canvas.width / canvas.height);
  camera.position.setValues(0.0, _cameraY, _cameraZ);
  camera.lookAt(new Vector3.zero());
  sceneShader = new Shader(ctx, vertSrc, fragSrc, common: commSrc);
  depthShader = new Shader(ctx, depthMapVS, depthMapFS, common: depthMapComm);
  showMappingShader = new Shader(ctx, showMappingVS, showMappingFS, common: commSrc);

  lightDepthTexture = _createTexture(depthWidth, depthHeight);
  lightFramebuffer = ctx.createFramebuffer();
  ctx.bindFramebuffer(gl.FRAMEBUFFER, lightFramebuffer);
  ctx.framebufferTexture2D(gl.FRAMEBUFFER, gl.COLOR_ATTACHMENT0, lightDepthTexture.target, lightDepthTexture.data, 0);
  ctx.bindFramebuffer(gl.FRAMEBUFFER, null);

  light = new Cube(width: 10, height: 2, depth: 5);
  light.position.setValues(5.0, 8.0, 8.0);
  lightProj = new Matrix4.perspective(90.0, 1.0, 0.01, 100.0);
  lightView = new Matrix4.identity().lookAt(light.position, new Vector3.zero(), new Vector3(0.0, 1.0, 0.0));
  lightRot = new Matrix3.fromMatrix4(lightView);

  ground = _createPlane(10.0);
  ground.position.setValues(0.0, -0.9, 0.0);
  ground.rotation.rotateX(-Math.PI / 2);

  mesh1 = new Cylinder(topRadius: 1, bottomRadius: 1, height: 5);
  mesh1.position.setValues(-3.0, 0.0, -1.0);

  mesh2 = new Cone(bottomRadius: 1, height: 2);
  mesh2.position.setValues(3.0, 4.0, 0.0);

  var objLoader = new ObjLoader();
  objLoader.load("../models/obj/teapot.obj").then((m) {
    teapot = m;
    teapot.material = new Material();
    teapot.position.setValues(0.0, 0.0, 2.0);
    teapot.material.shininess = 64.0;
    teapot.material.specularColor = new Color.fromList([0.8, 0.8, 0.8]);
    teapot.material.ambientColor = new Color.fromList([0.3, 0.3, 0.3]);
    teapot.material.diffuseColor = new Color.fromList([0.5, 0.0, 0.0]);
  });

  mappingBoard = _createPlane(50.0);

  _render();
}

void _render() {
  //  ctx.clearColor(backgroundColor.red, backgroundColor.green, backgroundColor.blue, backgroundColor.alpha);
  //  ctx.clearDepth(1.0);
  //  ctx.clear(gl.COLOR_BUFFER_BIT | gl.DEPTH_BUFFER_BIT);
  ctx.enable(gl.DEPTH_TEST);
  ctx.enable(gl.CULL_FACE);
  ctx.depthFunc(gl.LEQUAL);
  //    ctx.depthMask(true);
  //  ctx.viewport(0, 0, canvas.width, canvas.height);
  _animate(0.0);
}

void _renderDepth() {
  ctx.bindFramebuffer(gl.FRAMEBUFFER, lightFramebuffer);

  ctx.useProgram(depthShader.program);
  ctx.viewport(0, 0, depthWidth.toInt(), depthHeight.toInt());
  ctx.clearColor(1.0, 1.0, 1.0, 1.0);
  ctx.clearDepth(1.0);
  ctx.clear(gl.COLOR_BUFFER_BIT | gl.DEPTH_BUFFER_BIT);
  ctx.cullFace(gl.FRONT);
  depthShader.uniform(ctx, "lightView", lightView.storage);
  depthShader.uniform(ctx, "lightProj", lightProj.storage);

  ctx.activeTexture(gl.TEXTURE0);
  ctx.bindTexture(lightDepthTexture.target, lightDepthTexture.data);

  _draw(ground, lightView, depthShader);
  _draw(mesh1, lightView, depthShader);
  _draw(mesh2, lightView, depthShader);
  _draw(teapot, lightView, depthShader);

  ctx.bindFramebuffer(gl.FRAMEBUFFER, null);
}

void _renderScene() {
  ctx.useProgram(sceneShader.program);
  ctx.viewport(0, 0, canvas.width, canvas.height);
  ctx.clearColor(backgroundColor.red, backgroundColor.green, backgroundColor.blue, backgroundColor.alpha);
  ctx.clearDepth(1.0);
  ctx.clear(gl.COLOR_BUFFER_BIT | gl.DEPTH_BUFFER_BIT);
  ctx.cullFace(gl.BACK);

  var viewMat = camera.viewMatrix;
  var projMat = camera.projectionMatrix;
  if (viewType == 1) {
    viewMat = lightView;
    projMat = lightProj;
  }

  sceneShader.uniform(ctx, Semantics.viewMat, viewMat.storage);
  sceneShader.uniform(ctx, Semantics.projectionMat, projMat.storage);
  sceneShader.uniform(ctx, "lightView", lightView.storage);
  sceneShader.uniform(ctx, "lightProj", lightProj.storage);
  sceneShader.uniform(ctx, "lightPos", light.position.storage);
  ctx.activeTexture(gl.TEXTURE0);
  ctx.bindTexture(lightDepthTexture.target, lightDepthTexture.data);
  sceneShader.uniform(ctx, "depthMapping", 0);
  _draw(ground, viewMat, sceneShader);
  _draw(teapot, viewMat, sceneShader);
  _draw(mesh1, viewMat, sceneShader);
  _draw(mesh2, viewMat, sceneShader);
  _draw(light, viewMat, sceneShader);
  ctx.bindTexture(lightDepthTexture.target, null);
}

void _renderMapping() {
  ctx.useProgram(showMappingShader.program);
  ctx.viewport(0, 0, canvas.width, canvas.height);
  ctx.clearColor(backgroundColor.red, backgroundColor.green, backgroundColor.blue, backgroundColor.alpha);
  ctx.clearDepth(1.0);
  ctx.clear(gl.COLOR_BUFFER_BIT | gl.DEPTH_BUFFER_BIT);
  ctx.cullFace(gl.BACK);

  camera.position.setValues(0.0, _cameraY, _cameraZ);
  camera.lookAt(new Vector3.zero());
  camera.updateMatrix();

  showMappingShader.uniform(ctx, Semantics.viewMat, camera.viewMatrix.storage);
  showMappingShader.uniform(ctx, Semantics.projectionMat, camera.projectionMatrix.storage);
  ctx.activeTexture(gl.TEXTURE0);
  ctx.bindTexture(lightDepthTexture.target, lightDepthTexture.data);
  showMappingShader.uniform(ctx, "depthMapping", 0);
  _draw(mappingBoard, camera.viewMatrix, showMappingShader);
  ctx.bindTexture(lightDepthTexture.target, null);
}

void _animate(num elapsed) {
  html.window.requestAnimationFrame(_animate);
  var interval = elapsed - _lastElapsed;
  if (rotateCamera) {
    camera.update(interval);
    camera.position.setValues(Math.cos(elapsed / 1000) * _cameraZ, _cameraY, Math.sin(elapsed / 1000) * _cameraZ);
    camera.lookAt(new Vector3.zero());
  } else {
    camera.position.setValues(0.0, _cameraY, _cameraZ);
    camera.lookAt(new Vector3.zero());
  }
  camera.updateMatrix();

  _renderDepth();
  if (viewType == 2) {
    _renderMapping();
  } else {
    _renderScene();
  }

  _lastElapsed = elapsed;
}

void _draw(Mesh mesh, Matrix4 viewMatrix, Shader shader) {
  if (mesh == null) return;
  _newMaxEnabledArray = -1;
  mesh.updateMatrix();
  shader.uniform(ctx, Semantics.modelMat, mesh.worldMatrix.storage);

  var nm = (viewMatrix * mesh.worldMatrix).normalMatrix3();
  if (nm != null) shader.uniform(ctx, Semantics.normalMat, nm.storage);

  var geometry = mesh.geometry;
  shader.attributes.forEach((semantic, attrib) {
    if (geometry.buffers.containsKey(semantic)) {
      var bufferView = geometry.buffers[semantic];
      bufferView.bindBuffer(ctx);
      ctx.enableVertexAttribArray(attrib.location);
      ctx.vertexAttribPointer(attrib.location, bufferView.size, bufferView.type, bufferView.normalized, bufferView.stride, bufferView.offset);
      if (attrib.location > _newMaxEnabledArray) {
        _newMaxEnabledArray = attrib.location;
      }
    }
  });
  for (var i = (_newMaxEnabledArray + 1); i < _lastMaxEnabledArray; i++) {
    ctx.disableVertexAttribArray(i);
  }
  _lastMaxEnabledArray = _newMaxEnabledArray;
  if (mesh.faces != null) {
    mesh.faces.bindBuffer(ctx);
    ctx.drawElements(gl.TRIANGLES, mesh.faces.count, mesh.faces.type, mesh.faces.offset);
  } else {
    ctx.drawArrays(gl.TRIANGLES, 0, mesh.geometry.buffers[Semantics.position].count);
  }
}

const comm =
    """
precision highp float;

const float Near = 1.0;
const float Far = 100.0;
const float LinearDepthConstant = 1.0 / (Far - Near);

vec4 pack(float depth) {
  const vec4 bias = vec4(1.0 / 255.0,
        1.0 / 255.0,
        1.0 / 255.0,
        0.0);
  float r = depth;
  float g = fract(r * 255.0);
  float b = fract(g * 255.0);
  float a = fract(b * 255.0);
  vec4 colour = vec4(r, g, b, a);
  return colour - (colour.yzww * bias);
}

float unpack(vec4 colour) {
  const vec4 bitShifts = vec4(1.0,
          1.0 / 255.0,
          1.0 / (255.0 * 255.0),
          1.0 / (255.0 * 255.0 * 255.0));
  return dot(colour, bitShifts);
}
""";

const commSrc =
    """
$comm
uniform highp mat3 uNormalMat;
uniform highp mat4 uViewMat;
uniform highp mat4 uModelMat;
uniform highp mat4 uProjectionMat;
uniform mat4 lightProj;
uniform mat4 lightView; 
uniform mat3 lightRot;
uniform vec3 lightPos;
const mat4 offsetMat = mat4(0.5, 0.0, 0.0, 0.0, 0.0, 0.5, 0.0, 0.0, 0.0, 0.0, 0.5, 0.0, 0.5, 0.5, 0.5, 1.0);
varying highp vec3 vNormal;
varying highp vec4 vPosition;

vec3 computeLight(vec3 normal) {
  highp vec3 ambientLight = vec3(0.6, 0.6, 0.6);
  highp vec3 directionalLightColor = vec3(0.5, 0.5, 0.75);
  highp vec3 directionalVector = vec3(0.85, 0.8, 0.75);
  highp float directional = max(dot(normal, directionalVector), 0.0);
  return ambientLight + (directionalLightColor * directional);
}

float PCF() {
  return 1.0;
}

""";

const vertSrc =
    """
attribute highp vec3 aNormal;
attribute highp vec3 aPosition;
varying vec4 vLightClipPos;

void main(void) {
  vPosition = uModelMat * vec4(aPosition, 1.0);
  vNormal = normalize(uNormalMat * aNormal);
  vLightClipPos = offsetMat * lightProj * lightView * vPosition;

  gl_Position = uProjectionMat * uViewMat * vPosition;
}
""";

const fragSrc =
    """
uniform sampler2D depthMapping;
varying vec4 vLightClipPos;
      
void main(void) {
  mediump vec4 texelColor = vec4(0.6, 0.6, 0.6, 1.0);

  vec3 lighting = computeLight(vNormal);

  // shadow calculation
  vec3 projCoords = vLightClipPos.xyz / vLightClipPos.w;
  projCoords.z = length(vPosition.xyz - lightPos) * LinearDepthConstant;
  projCoords.z *= 0.96;

  vec2 uv = projCoords.xy;
  float illuminated = 1.0; 
  if (uv.x < 0. || uv.x > 1.0 || uv.y < 0. || uv.y > 1.0) {
    illuminated = 1.0;
  } else {
    float shadow = unpack(texture2D(depthMapping, uv));
    if (projCoords.z > shadow) {
      illuminated = 0.2;
    }
  }
  
  
  gl_FragColor = vec4(texelColor.rgb * lighting * illuminated, texelColor.a);
}
""";

const depthMapComm = """
$comm
uniform mat4 lightProj;
uniform mat4 lightView; 
uniform mat4 uModelMat;
uniform mat3 lightRot;
varying vec4 vPosition;
""";

const depthMapVS =
    """
attribute highp vec3 aNormal;
attribute highp vec3 aPosition;
void main(){
    vPosition = lightView * uModelMat * vec4(aPosition, 1.0);
    gl_Position = lightProj * vPosition;
}
""";

const depthMapFS = """
void main(){
    float linearDepth = length(vPosition) * LinearDepthConstant;
    gl_FragColor = pack(linearDepth);
}
""";

const showMappingVS =
    """
attribute vec3 aPosition;
attribute vec2 aTexcoords;
attribute vec3 aNormal;
varying vec2 vTexcoords;
 
void main (void) {
  gl_Position = uProjectionMat * uViewMat * uModelMat * vec4(aPosition, 1.0);
  vTexcoords = aTexcoords;
}
""";

const showMappingFS =
    """
varying vec2 vTexcoords;
uniform sampler2D depthMapping;

void main (void) {
  float depth = unpack(texture2D(depthMapping, vTexcoords));
  depth = pow(depth, 64.0);
  gl_FragColor = vec4(depth, depth, depth, 1.0);
}
""";




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
  ctx.bindTexture(texture.target, null);
  return texture;
}

Mesh _createPlane([double scale = 1.0]) {
  var mesh = new PolygonMesh();
  mesh.setVertices([-scale, -scale, 1.0, scale, -scale, 1.0, scale, scale, 1.0, -scale, scale, 1.0]);
  mesh.setFaces([0, 1, 2, 0, 2, 3]);
  mesh.setTexCoords([0.0, 0.0, 1.0, 0.0, 1.0, 1.0, 0.0, 1.0]);
  mesh.calculateSurfaceNormals();
  return mesh;
}
