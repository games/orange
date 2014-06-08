import 'dart:html' as html;
import '../lib/orange.dart';
import 'package:stats/stats.dart';
import 'dart:math';
import 'dart:typed_data';





const String simpleModelVS = """
precision highp float;
attribute vec3 aPosition;
attribute vec3 aNormal;

uniform mat4 uViewMat;
uniform mat4 uModelMat;
uniform mat4 uProjectionMat;
uniform mat3 uNormalMat;

varying vec4 vPosition, ecPos;
varying vec3 vNormal;

void main(void) {
   vPosition = uModelMat * vec4(aPosition, 1.0);
   vNormal = normalize(uNormalMat * aNormal);

   /* compute the vertex position  in camera space. */
   ecPos = uViewMat * vPosition;

   gl_Position = uProjectionMat * uViewMat * vPosition;
}
""";


const String simpleModelFS = """
precision highp float;


uniform mat4 uViewMat;
uniform vec3 uSurfaceColor;
uniform float shininess;
uniform vec3 specularColor;
uniform vec3 diffuseColor;
uniform vec3 ambientColor;
uniform vec3 emissiveColor;

$shader_light_structure
$shader_lights

varying vec4 vPosition, ecPos;
varying vec2 vTexcoords;
varying vec3 vNormal;



vec3 phong2(vec3 position, vec3 normal, LightSource ls, float shininess) {
  vec3 lightDir;
  if(ls.type == 1) {
    lightDir = -ls.direction;
  } else {
    lightDir = normalize(ls.position - position);
    lightDir = normalize(vec3(uViewMat * vec4(ls.position, 1.0) - ecPos));
  }
  float att, dist;
  dist = length(lightDir);

  float NdotL = max(dot(normal, lightDir), 0.0);
  vec3 diffuse = diffuseColor * ls.color;
  vec3 ambient = ambientColor * ls.color;
  vec3 specular = vec3(0.0, 0.0, 0.0);
  if(NdotL > 0.0) {
    vec3 Eye = normalize(uCameraPosition - position);
    Eye = normalize(vec3(uViewMat * vec4(uCameraPosition, 1.0) - ecPos));
    vec3 L;
    if(ls.type == 1) {
        L = lightDir;
    } else {
        L = normalize(ls.position - position);
        L = lightDir;
    }
    vec3 H = normalize(Eye + L);
    float NdotHV = max(dot(normal, H), 0.0);
    specular = specularColor * pow(NdotHV, shininess);
  }
  att = 1.0;
  if(ls.type == 2) {
    att = 1.0 / (ls.constantAttenuation +
                ls.linearAttenuation * dist +
                ls.quadraticAttenuation * dist * dist);
  }else if(ls.type == 3) {
    vec3 spotDirection = normalize(vec3(uViewMat * vec4(ls.direction, 1.0)));
    float spotEffect = dot(spotDirection, normalize(-lightDir));
    spotEffect = dot(normalize(ls.direction), normalize(-lightDir));
    if(spotEffect > ls.spotCosCutoff){
      spotEffect = pow(spotEffect, ls.spotExponent);
      att = spotEffect / (ls.constantAttenuation + ls.linearAttenuation * dist + ls.quadraticAttenuation * dist * dist);
    } else {
      att = 0.0;
    }
  }
  return (NdotL * diffuse + ambient) * att + specular * att;
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
                 computeLight(vPosition, vNormal, light0, shininess) + 
                 computeLight(vPosition, vNormal, light1, shininess) + 
                 computeLight(vPosition, vNormal, light2, shininess) + 
                 computeLight(vPosition, vNormal, light3, shininess);

  lighting = 
                 computeLight2(vPosition.xyz, vNormal, light0, shininess) + 
                 computeLight2(vPosition.xyz, vNormal, light1, shininess) + 
                 computeLight2(vPosition.xyz, vNormal, light2, shininess) + 
                 computeLight2(vPosition.xyz, vNormal, light3, shininess);

  gl_FragColor = vec4(lighting, 1.0);
}




""";





class TestLighting3 {
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
    renderer.camera.position = new Vector3(0.0, 10.0, 10.0);
    renderer.camera.lookAt(new Vector3(0.0, 0.0, 0.0));

    renderer.pass = new Pass();
    renderer.pass.shader = new Shader(renderer.ctx, lightingModelVS, lightingModelFS);
//            renderer.pass.shader = new Shader(renderer.ctx, simpleModelVS, simpleModelFS);

    Mesh teapot;
    var objLoader = new ObjLoader();
    objLoader.load("../models/obj/teapot.obj").then((m) {
      teapot = m;
      teapot.material = new Material();
      teapot.material.shininess = 64.0;
      teapot.material.specularColor = new Color.fromList([0.8, 0.8, 0.8]);
      teapot.material.ambientColor = new Color.fromList([0.0, 0.0, 0.0]);
      teapot.material.diffuseColor = new Color.fromList([1.0, 0.0, 0.0]);
      meshes.add(teapot);
    });
    
    var plane = new Plane(width: 20, height: 20);
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

    _directionalLight = new DirectionalLight(0xffffff);
    _directionalLight.direction.setValues(0.0, 0.0, -1.0);
    _directionalLight.intensity = 1.0;
//        renderer.lights.add(_directionalLight);

    _pointLight = new PointLight(0xffffff);
    _pointLight.position = new Vector3(1.0, 1.0, 5.0);
    _pointLight.intensity = 1.0;
//    renderer.lights.add(_pointLight);

    _spotLight = new SpotLight(0xff0000);
    _spotLight.position = new Vector3(7.0, 5.0, 0.0);
//    _spotLight.rotation.rotateZ(PI / 4);
    _spotLight.direction = new Vector3(-0.0, -.0, -1.0);
//    _spotLight.direction = _spotLight.rotation.multiplyVec3(new Vector3(0.0, -1.0, 1.0));
//    _spotLight.intensity = 1.0;
//    _spotLight.spotCutoff = PI / 4;
//    _spotLight.spotExponent = 3.0;
//    _spotLight.constantAttenuation = 0.05;
//    _spotLight.linearAttenuation = 0.05;
//    _spotLight.quadraticAttenuation = 0.11;
    renderer.lights.add(_spotLight);

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
//    _directionalLight.direction.setValues(cos(elapsed / 1000) * 5, 0.0, sin(elapsed / 1000) * 5);
//    _directionalLight.direction.normalize();
//    _spotLight.position.setValues(cos(elapsed / 1000) * 5, 10.0, sin(elapsed / 1000) * 5);
    _spotLight.direction.setValues(cos(elapsed / 1000) * 5, 2.0, sin(elapsed / 1000) * 5).normalize();

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













