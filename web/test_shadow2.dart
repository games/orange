import 'dart:html' as html;
import 'dart:math' as Math;
import 'dart:web_gl' as gl;
import 'package:orange/orange.dart';


Color backgroundColor = new Color.fromHex(0x84A6EE);
html.CanvasElement canvas;
gl.RenderingContext ctx;
Texture lightDepthTexture;
num depthWidth = 512,
    depthHeight = 512;
gl.Framebuffer lightFramebuffer;
Matrix4 lightProj;
Matrix4 lightView;
Matrix3 lightRot;
Shader sceneShader;
Shader depthShader;
Mesh ground;
Mesh mesh1;
Mesh mesh2;
Mesh light;
PerspectiveCamera camera;
int _newMaxEnabledArray = -1;
int _lastMaxEnabledArray = -1;

void main() {
  canvas = html.querySelector("#container");
  ctx = canvas.getContext3d();
  camera = new PerspectiveCamera(canvas.width / canvas.height);
  camera.position.setValues(0.0, 50.0, 110.0);
  camera.lookAt(new Vector3.zero());
  sceneShader = new Shader(ctx, vertSrc, fragSrc, common: commSrc);
  depthShader = new Shader(ctx, depthMapVS, depthMapFS, common: depthMapComm);

  lightDepthTexture = _createTexture(depthWidth, depthHeight);
  lightFramebuffer = ctx.createFramebuffer();
  ctx.bindFramebuffer(gl.FRAMEBUFFER, lightFramebuffer);
  ctx.framebufferTexture2D(gl.FRAMEBUFFER, gl.COLOR_ATTACHMENT0, lightDepthTexture.target, lightDepthTexture.data, 0);
  ctx.bindFramebuffer(gl.FRAMEBUFFER, null);

  light = new Cube(width: 5, height: 5, depth: 5);
  light.position.setValues(0.0, 20.0, 10.0);
  lightProj = new Matrix4.ortho(-10.0, 10.0, -10.0, 10.0, -10.0, 20.0);
  lightView = new Matrix4.identity().lookAt(-light.position, new Vector3.zero(), new Vector3(0.0, 1.0, 0.0));
//  lightView = new Matrix4.identity().lookAt(light.position, new Vector3(-0.3, -2.0, 0.0), new Vector3(0.0, 0.0, 1.0));
  lightRot = new Matrix3.fromMatrix4(lightView);
  
  ground = _createPlane(50.0);
  ground.rotation.rotateX(-Math.PI / 2);

  mesh1 = new Cylinder(topRadius: 20, bottomRadius: 20, height: 10);
  mesh1.position.setValues(0.0, 10.0, 0.0);

  mesh2 = new Cone(bottomRadius: 10, height: 15);
  mesh2.position.setValues(0.0, 30.0, 0.0);

  _render();
}

void _render() {
  ctx.clearColor(backgroundColor.red, backgroundColor.green, backgroundColor.blue, backgroundColor.alpha);
  ctx.clearDepth(1.0);
  ctx.enable(gl.DEPTH_TEST);
  ctx.enable(gl.CULL_FACE);
  ctx.depthFunc(gl.LEQUAL);
  ctx.depthMask(true);
  ctx.viewport(0, 0, canvas.width, canvas.height);
  _animate(0);
}

void _renderDepth() {
  ctx.bindFramebuffer(gl.FRAMEBUFFER, lightFramebuffer);
  ctx.viewport(0, 0, depthWidth.toInt(), depthHeight.toInt());
  ctx.clearColor(1.0, 1.0, 1.0, 1.0);
  ctx.clearDepth(1.0);
  ctx.cullFace(gl.FRONT);
  ctx.useProgram(depthShader.program);
  depthShader.uniform(ctx, "lightView", lightView.storage);
  depthShader.uniform(ctx, "lightProj", lightProj.storage);

  _draw(ground, lightView, depthShader);
  _draw(mesh1, lightView, depthShader);
  _draw(mesh2, lightView, depthShader);
  
  ctx.bindFramebuffer(gl.FRAMEBUFFER, null);
}

void _renderScene() {
  ctx.useProgram(sceneShader.program);
  ctx.viewport(0, 0, canvas.width, canvas.height);
  ctx.clearColor(0.0, 0.0, 0.0, 0.0);
  ctx.clearDepth(1.0);
  camera.updateMatrix();
  sceneShader.uniform(ctx, Semantics.viewMat, camera.viewMatrix.storage);
  sceneShader.uniform(ctx, Semantics.projectionMat, camera.projectionMatrix.storage);
  sceneShader.uniform(ctx, "lightView", lightView.storage);
  sceneShader.uniform(ctx, "lightProj", lightProj.storage);
  ctx.activeTexture(gl.TEXTURE0);
  ctx.bindTexture(lightDepthTexture.target, lightDepthTexture.data);
  sceneShader.uniform(ctx, "depthMapping", 0);
  _draw(ground, camera.viewMatrix, sceneShader);
  _draw(mesh1, camera.viewMatrix, sceneShader);
  _draw(mesh2, camera.viewMatrix, sceneShader);
  _draw(light, camera.viewMatrix, sceneShader);
  ctx.bindTexture(lightDepthTexture.target, null);
}

void _animate(num) {
  html.window.requestAnimationFrame(_animate);
  ctx.clear(gl.COLOR_BUFFER_BIT | gl.DEPTH_BUFFER_BIT);

  _renderScene();
}

void _draw(Mesh mesh, Matrix4 viewMatrix, Shader shader) {
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

const comm = """
precision highp float;

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




/*
 * VS
 * 
 * Offset matrix offsetMatrix, 
 * use to multiplied by the light matrix. 
 * This is to transform the shadow-map texture coordinates 
 * from range [−1, 1] to range [0, 1] without having to add 
 * any extra lines of code for this in the shaders.
 
 uniform mat4 offsetMat = [0.5f, 0.0f, 0.0f, 0.5f,
  0.0f, 0.5f, 0.0f, 0.5f,
  0.0f, 0.0f, 0.5f, 0.5f,
  0.0f, 0.0f, 0.0f, 1.0f];
  

 uniform mat4 lightMat = offsetMatrix * lightProjectionMatrix * lightModelViewMatrix 
 out vec4 shadowMapCoord;
 void main(){
   gl_Position = gl_ModelViewProjectionMatrix * gl_Vertex;
   shadowMapCoord = lightMatrix * gl_Vertex;
 }
 * 
 *   
 * 
 * ￼FS
in vec4 shadowMapCoord;
uniform sampler2DShadow shadowMapTex;
void main() {
  vec3 color = ...;
  float visibility = textureProj(shadowMapTex, shadowMapCoord);
  gl_FragColor = vec4(color * visibility, 1.0);
}
 * 
 */


///http://www.opengl-tutorial.org/intermediate-tutorials/tutorial-16-shadow-mapping/


const commSrc = """
$comm
uniform highp mat3 uNormalMat;
uniform highp mat4 uViewMat;
uniform highp mat4 uModelMat;
uniform highp mat4 uProjectionMat;
uniform mat4 lightProj;
uniform mat4 lightView; 
uniform mat3 lightRot;
varying highp vec3 vNormal;
varying highp vec4 vPosition;

vec3 computeLight(vec3 normal) {
  highp vec3 ambientLight = vec3(0.6, 0.6, 0.6);
  highp vec3 directionalLightColor = vec3(0.5, 0.5, 0.75);
  highp vec3 directionalVector = vec3(0.85, 0.8, 0.75);
  highp float directional = max(dot(normal, directionalVector), 0.0);
  return ambientLight + (directionalLightColor * directional);
}

""";

const vertSrc = """
attribute highp vec3 aNormal;
attribute highp vec3 aPosition;

void main(void) {
  vPosition = uModelMat * vec4(aPosition, 1.0);
  gl_Position = uProjectionMat * uViewMat * vPosition;
  vNormal = normalize(uNormalMat * aNormal);
}
""";

const fragSrc = """
uniform sampler2D depthMapping;
      
void main(void) {
  mediump vec4 texelColor = vec4(0.6, 0.6, 0.6, 1.0);

  vec3 lighting = computeLight(vNormal);

  // shadow calculation
  vec4 lightClipPos = lightProj * lightView * vPosition;
  vec3 projCoords = lightClipPos.xyz / lightClipPos.w;
  projCoords.z -= 0.0003;
  vec2 uv = 0.5 * projCoords.xy + vec2(0.5, 0.5);
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

varying vec3 vWorldNormal; varying vec4 vWorldPosition;
uniform mat4 lightProj, lightView; uniform mat3 lightRot;
uniform mat4 uModelMat;
varying vec4 vPosition;
""";

const depthMapVS = """
attribute highp vec3 aNormal;
attribute highp vec3 aPosition;
void main(){
    vWorldNormal = aNormal;
    vWorldPosition = uModelMat * vec4(aPosition, 1.0);
    vPosition = lightProj * lightView * uModelMat * vec4(aPosition, 1.0);
    gl_Position = lightProj * lightView * vWorldPosition;
}
""";

const depthMapFS = """
void main(){
    gl_FragColor = pack(vPosition.z / vPosition.w);
}
""";















Texture _createTexture(num width, num height) {
  var texture = new Texture();
  texture.target = gl.TEXTURE_2D;
  texture.internalFormat = gl.RGBA;
  texture.format = gl.RGBA;
  texture.data = ctx.createTexture();
  ctx.getExtension("OES_texture_float");
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



// 50, 8, 0, pi*2
Mesh _createCircle2(radius, segments, thetaStart, thetaLength) {
  PolygonMesh circle = new PolygonMesh();
  var vertices = [],
      uvs = [],
      normals = [],
      faces = [];

  var center = new Vector3.zero();
  var centerUV = new Vector2(0.5, 0.5);
  vertices.addAll(center.storage);
  uvs.addAll(centerUV.storage);

  for (var i = 0; i <= segments; i++) {
    var segment = thetaStart + i / segments * thetaLength;
    var vx = radius * Math.cos(segment);
    var vy = radius * Math.sin(segment);

    vertices.add(vx);
    vertices.add(vy);
    vertices.add(0.0);

    uvs.add((vx / radius + 1) / 2);
    uvs.add((vy / radius + 1) / 2);
  }

  var n = new Vector3(0.0, 0.0, 1.0);

  for (var i = 1; i <= segments; i++) {
    faces.add(i);
    faces.add(i + 1);
    faces.add(0);
    uvs.add(uvs[i]);
    uvs.add(uvs[i + 1]);
    uvs.add(uvs[i + 2]);
    uvs.add(uvs[i + 3]);
    uvs.add(centerUV.x);
    uvs.add(centerUV.y);
  }

  circle.setVertices(vertices);
  circle.setTexCoords(uvs);
  circle.setFaces(faces);
  circle.calculateSurfaceNormals();
  return circle;
}

Mesh _createCircle(int dots, num scale) {
  PolygonMesh circle = new PolygonMesh();
  var p = [],
      n = [];
  var f = (i, j) {
    var ra = 0.4,
        rb = 0.2,
        a = Math.PI * 2 * i / dots,
        b = Math.PI * 2 * j / dots,
        sa = Math.sin(a),
        sb = Math.sin(b),
        ca = Math.cos(a),
        cb = Math.cos(b),
        l = sb * rb + ra,
        y = cb * rb,
        x = sa * l,
        z = ca * l,
        x0 = sa * ra,
        z0 = ca * ra;
    p
        ..add(x * scale)
        ..add(y * scale)
        ..add(z * scale);
    n
        ..add(x - x0)
        ..add(y)
        ..add(z - z0);
  };
  for (var i = 1; i <= dots; i++) {
    for (var j = 1; j <= dots; j++) {
      f(i, j);
      f(i - 1, j);
      f(i, j - 1);
      f(i, j - 1);
      f(i - 1, j);
      f(i - 1, j - 1);
    }
  }
  circle.setVertices(p);
  circle.setNormals(n);
  return circle;
}

Mesh _createPlane([double scale = 1.0]) {
  var mesh = new PolygonMesh();
  mesh.setVertices([-scale, -scale, 1.0, scale, -scale, 1.0, scale, scale, 1.0, -scale, scale, 1.0]);
  mesh.setFaces([0, 1, 2, 0, 2, 3]);
  mesh.setTexCoords([0.0, 0.0, 1.0, 0.0, 1.0, 1.0, 0.0, 1.0]);
  mesh.calculateSurfaceNormals();
  return mesh;
}
