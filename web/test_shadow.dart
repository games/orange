import 'dart:html' as html;
import '../lib/orange.dart';
import 'package:stats/stats.dart';
import 'dart:math';


var comm = """
  varying vec3 vWorldNormal; varying vec4 vWorldPosition;
  uniform mat4 ${Semantics.projectionMat}, ${Semantics.viewMat};
  uniform mat4 lightProj, lightView; uniform mat3 lightRot;
  uniform mat4 ${Semantics.modelMat};
""";

var vs = """
  precision highp float;
  $comm
  attribute vec3 ${Semantics.position}, ${Semantics.normal};
  void main(){
      vWorldNormal = ${Semantics.normal};
      vWorldPosition = ${Semantics.modelMat} * vec4(${Semantics.position}, 1.0);
      gl_Position = ${Semantics.projectionMat} * ${Semantics.viewMat} * vWorldPosition;
  }
""";

var fs = """
  $comm
  uniform LightSource light0;
  uniform LightSource light1;
  uniform LightSource light2;
  uniform LightSource light3;
  uniform vec3 uCameraPosition;

  float attenuation(vec3 dir){
      float dist = length(dir);
      float radiance = 1.0/(1.0+pow(dist/10.0, 2.0));
      return clamp(radiance*10.0, 0.0, 1.0);
  }

  float influence(vec3 normal, float coneAngle){
      float minConeAngle = ((360.0-coneAngle-10.0)/360.0)*PI;
      float maxConeAngle = ((360.0-coneAngle)/360.0)*PI;
      return smoothstep(minConeAngle, maxConeAngle, acos(normal.z));
  }
  
  float lambert(vec3 surfaceNormal, vec3 lightDirNormal){
      return max(0.0, dot(surfaceNormal, lightDirNormal));
  }
  
  vec3 skyLight(vec3 normal){
      return vec3(smoothstep(0.0, PI, PI-acos(normal.y)))*0.4;
  }
  
  vec3 gamma(vec3 color){
      return pow(color, vec3(2.2));
  }
  
  void main(){
      vec3 worldNormal = normalize(vWorldNormal);
  
      vec3 camPos = (${Semantics.viewMat} * vWorldPosition).xyz;
      vec3 lightPos = (lightView * vWorldPosition).xyz;
      vec3 lightPosNormal = normalize(lightPos);
      vec3 lightSurfaceNormal = lightRot * worldNormal;
  
      vec3 excident = (
          skyLight(worldNormal) +
          lambert(lightSurfaceNormal, -lightPosNormal) *
          influence(lightPosNormal, 55.0) *
          attenuation(lightPos)
      );
      gl_FragColor = vec4(gamma(excident), 1.0);
  }
""";


class TestShadow {
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
    renderer.camera.position = new Vector3(0.0, 0.0, 5.0);
    renderer.pass = new Pass();
    renderer.pass.shader = new Shader(renderer.ctx, lightingModelVS, lightingModelFS);
    
    var cube = new Cube(width: 1, height: 0.5, depth: 1.5);
    cube.position.setValues(-1.0, -0.4, 0.0);
    cube.material = new Material();
    cube.material.shininess = 64.0;
    cube.material.specularColor = new Color.fromList([0.8, 0.8, 0.8]);
    cube.material.ambientColor = new Color.fromList([0.3, 0.3, 0.3]);
    cube.material.diffuseColor = new Color.fromList([0.3, 0.3, 0.3]);
    meshes.add(cube);
    
    var sphere = new Sphere(widthSegments: 20, heightSegments: 20);
    sphere.position.setValues(1.5, 0.0, 0.0);
    sphere.material = new Material();
    sphere.material.shininess = 64.0;
    sphere.material.specularColor = new Color.fromList([0.8, 0.8, 0.8]);
    sphere.material.ambientColor = new Color.fromList([0.3, 0.3, 0.3]);
    sphere.material.diffuseColor = new Color.fromList([0.3, 0.3, 0.3]);
    sphere.wireframe = true;
    meshes.add(sphere);
    
    var cone = new Cone(bottomRadius: 0.2, height: 0.5);
    cone.position.setValues(0.0, -0.4, 2.0);
    cone.material = new Material();
    cone.material.shininess = 64.0;
    cone.material.specularColor = new Color.fromList([0.8, 0.8, 0.8]);
    cone.material.ambientColor = new Color.fromList([0.3, 0.3, 0.3]);
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
    
    var coordinate = new Coordinate();
    meshes.add(coordinate);
    
    _directionalLight = new Light(0xffffff, Light.DIRECT);
    _directionalLight.rotation.rotateX(-PI);
    _directionalLight.intensity = 1.0;
    renderer.lights.add(_directionalLight);
    
    _pointLight = new Light(0xffffff, Light.POINT);
    _pointLight.position = new Vector3(5.0, 5.0, 5.0);
    _pointLight.intensity = 2.0;
    renderer.lights.add(_pointLight);
    
    _spotLight = new Light(0xff0000, Light.SPOTLIGHT);
    _spotLight.position = new Vector3(0.0, 5.0, 0.0);
    _spotLight.intensity = 2.0;
    _spotLight.direction = new Vector3(0.0, -1.0, 0.0);
    _spotLight.spotCutoff = PI / 2;
    _spotLight.spotExponent = 10.0;
    _spotLight.constantAttenuation = 0.05;
    _spotLight.linearAttenuation = 0.05;
    _spotLight.quadraticAttenuation = 0.01;
    renderer.lights.add(_spotLight);
    
    html.window.requestAnimationFrame(_animate);
  }


  _animate(num elapsed) {
    var interval = elapsed - _lastElapsed;
    stats.begin();
    
    meshes.forEach((m){
      m.rotation.rotateY(interval / 1000);
    });
    
    renderer.camera.update(interval);
    renderer.camera.updateMatrix();
    renderer.prepare();
    meshes.forEach((m) => renderer.draw(m));
    renderer.draw(ground);

    stats.end();
    _lastElapsed = elapsed;
    html.window.requestAnimationFrame(_animate);
  }
}























