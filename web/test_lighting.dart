import 'dart:html' as html;
import '../lib/orange.dart';
import 'package:stats/stats.dart';
import 'dart:math';
import 'dart:typed_data';





const String simpleModelVS = """
precision highp float;
attribute vec3 aPosition;
attribute vec2 aTexcoords;
attribute vec3 aNormal;

uniform mat4 uViewMat;
uniform mat4 uModelMat;
uniform mat4 uProjectionMat;
uniform mat3 uNormalMat;

varying vec4 vPosition;
varying vec2 vTexcoords;
varying vec3 vNormal;

void main(void) {
   mat4 modelViewMat = uViewMat * uModelMat;
   vPosition = modelViewMat * vec4(aPosition, 1.0);
   vTexcoords = aTexcoords;
   vNormal = normalize(uNormalMat * aNormal);

   gl_Position = uProjectionMat * vPosition;
}
""";


const String simpleModelFS = """
precision highp float;

uniform sampler2D uTexture;
uniform bool uUseTextures;

uniform vec3 uSurfaceColor;
uniform float shininess;
uniform vec3 specularColor;
uniform vec3 diffuseColor;
uniform vec3 ambientColor;
uniform vec3 emissiveColor;

$shader_light_structure
$shader_lights

varying vec4 vPosition;
varying vec2 vTexcoords;
varying vec3 vNormal;



vec3 phong2(vec3 position, vec3 normal, LightSource ls, float shininess) {
  vec3 ld;
  if(ls.type == 1) ld = -ls.direction;
  else ld = normalize(ls.position - position);
  float dif = max(dot(normal, ld), 0.0);

  float spec = 0.0;
  float specularIntensity = 0.0;
  if(specularIntensity > 0.0) {
    vec3 eyed = normalize(uCameraPosition - position);
    vec3 refd = reflect(-ld, normal);
    spec = pow((dot(refd, eyed) + 1.0) * 0.5, shininess * 4.0) * specularIntensity;
  }

  if(ls.type == 3) {
    float dd = dot(ld, -ls.direction);
    
  }

  dif *= ls.intensity;
  
  return ls.color * dif + ls.color * spec; 
}

vec3 computeLight2(vec3 position, vec3 normal, LightSource ls, float shininess) {
  if(ls.type < 0 || ls.type > 5)
    return vec3(0.0, 0.0, 0.0);
  if(ls.type == 0)
    return ls.color * ls.intensity;
  return phong2(position, normal, ls, shininess);
}

void main(void) {
  vec3 lighting = emissiveColor + ambientColor +
                 computeLight(vPosition.xyz, vNormal, light0, shininess) + 
                 computeLight(vPosition.xyz, vNormal, light1, shininess) + 
                 computeLight(vPosition.xyz, vNormal, light2, shininess) + 
                 computeLight(vPosition.xyz, vNormal, light3, shininess);

  lighting = emissiveColor + ambientColor +
                 computeLight2(vPosition.xyz, vNormal, light0, shininess) + 
                 computeLight2(vPosition.xyz, vNormal, light1, shininess) + 
                 computeLight2(vPosition.xyz, vNormal, light2, shininess) + 
                 computeLight2(vPosition.xyz, vNormal, light3, shininess);


  vec3 color = vec3(0.4, 0.4, 0.4);

  highp vec4 textureColor = vec4(1.0, 1.0, 1.0, 1.0);
  if(uUseTextures) {
    textureColor = texture2D(uTexture, vTexcoords);
  }

  gl_FragColor = vec4(textureColor.rgb * lighting, textureColor.a);
}




""";





class TestLighting {
  double _lastElapsed = 0.0;
  Renderer renderer;
  Pass pass;
  List<Mesh> meshes = [];
  Mesh ground;
  Stats stats;

  DirectionalLight _directionalLight;
  PointLight _pointLight;
  SpotLight _spotLight;


  run() {
    stats = new Stats();
    html.document.body.children.add(stats.container);

    var canvas = html.querySelector("#container");
    renderer = new Renderer(canvas);
    //    renderer.camera.center = new Vector3(0.0, -1.0, 0.0);
    renderer.camera.near = 1.0;
    renderer.camera.far = 5000.00;
    renderer.camera.position = new Vector3(0.0, 7.0, 6.0);
    renderer.camera.lookAt(new Vector3(0.0, 0.0, 0.0));

    renderer.pass = new Pass();
    renderer.pass.shader = new Shader(renderer.ctx, lightingModelVS, lightingModelFS);
    //        renderer.pass.shader = new Shader(renderer.ctx, simpleModelVS, simpleModelFS);

    Mesh teapot;
    var objLoader = new ObjLoader();
    objLoader.load("../models/obj/teapot.obj").then((m) {
      teapot = m;
      teapot.material = new Material();
      teapot.material.shininess = 64.0;
      teapot.material.specularColor = new Color.fromList([0.8, 0.8, 0.8]);
      teapot.material.ambientColor = new Color.fromList([0.3, 0.3, 0.3]);
      teapot.material.diffuseColor = new Color.fromList([0.5, 0.0, 0.0]);
      meshes.add(teapot);
    });

    var cube = new Cube(width: 1, height: 0.5, depth: 1.5);
    cube.position.setValues(-1.0, 0.5, 0.0);
    cube.material = new Material();
    cube.material.shininess = 64.0;
    cube.material.specularColor = new Color.fromList([0.8, 0.8, 0.8]);
    cube.material.ambientColor = new Color.fromList([0.3, 0.3, 0.3]);
    cube.material.diffuseColor = new Color.fromList([0.3, 0.3, 0.3]);
//    meshes.add(cube);

    var sphere = new Sphere(widthSegments: 20, heightSegments: 20);
    sphere.position.setValues(1.5, 0.0, 0.0);
    sphere.material = new Material();
    sphere.material.shininess = 30.0;
    sphere.material.specularColor = new Color.fromList([0.8, 0.8, 0.8]);
    sphere.material.ambientColor = new Color.fromList([0.3, 0.3, 0.3]);
    sphere.material.diffuseColor = new Color.fromList([0.3, 0.3, 0.3]);
//    meshes.add(sphere);

    var cone = new Cone(bottomRadius: 0.2, height: 0.5);
    cone.position.setValues(0.0, 1.0, 2.0);
    cone.material = new Material();
    cone.material.shininess = 64.0;
    cone.material.specularColor = new Color.fromList([0.8, 0.8, 0.8]);
    cone.material.ambientColor = new Color.fromList([0.3, 0.3, 0.3]);
    cone.material.diffuseColor = new Color.fromList([0.3, 0.3, 0.3]);
//    meshes.add(cone);

    var plane = new Plane(width: 10, height: 10);
    //    plane = createCube();
    plane.rotation.rotateX(-PI / 2);
    //    plane.rotation.rotateZ(PI / 4);
    plane.position.setValues(0.0, 0.0, 0.0);
    plane.material = new Material();
    plane.material.shininess = 64.0;
    plane.material.specularColor = new Color.fromList([0.8, 0.8, 0.8]);
    plane.material.ambientColor = new Color.fromList([0.3, 0.3, 0.3]);
    plane.material.diffuseColor = new Color.fromList([0.3, 0.3, 0.3]);
    ground = plane;

    var textureManager = new TextureManager();
    textureManager.load(renderer.ctx, {
      "path": "cubetexture.png"
    }).then((t) {
      //      cube.material.texture = t;
      sphere.material.diffuseTexture = t;
    });

    _directionalLight = new DirectionalLight(0xffffff);
    _directionalLight.direction.setValues(0.0, 0.0, -1.0);
    _directionalLight.intensity = 1.0;
    //    renderer.lights.add(_directionalLight);

    _pointLight = new PointLight(0xffffff);
    _pointLight.position = new Vector3(5.0, 5.0, 5.0);
    _pointLight.intensity = 1.0;
    renderer.lights.add(_pointLight);

    _spotLight = new SpotLight(0xff0000);
    _spotLight.position = new Vector3(-0.0, 2.0, -3.0);
    _spotLight.rotation.rotateZ(PI / 4);
    _spotLight.direction = new Vector3(0.0, -1.0, 0.0);
    _spotLight.direction = _spotLight.rotation.multiplyVec3(new Vector3(0.0, -1.0, 0.0));
    _spotLight.intensity = 2.0;
    _spotLight.spotCutoff = PI / 6;
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

    meshes.forEach((m) {
//            m.rotation.rotateY(interval / 1000);
    });

    //    renderer.camera.update(interval);
    //    renderer.camera.position.setValues(cos(elapsed / 1000) * 5, 5.0, sin(elapsed / 1000) * 5);
    //    renderer.camera.lookAt(new Vector3.zero());

    _pointLight.position.setValues(cos(elapsed / 1000) * 5, 2.0, sin(elapsed / 1000) * 5);
    _directionalLight.direction.setValues(cos(elapsed / 1000) * 5, 0.0, sin(elapsed / 1000) * 5);
    _directionalLight.direction.normalize();

    //    renderer.camera.updateMatrix();

    if (renderer.prepare()) {
      meshes.forEach((m) => renderer.draw(m));
      renderer.lights.forEach((l) => renderer.draw(l));
      if(ground != null)
      renderer.draw(ground);
    }

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













