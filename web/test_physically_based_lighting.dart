part of orange_examples;






class TestPhysicallyBasedLighting extends Scene {
  TestPhysicallyBasedLighting(Camera camera) : super(camera);

  @override
  void enter() {
    var urls = [
                    "models/obj/head.obj", 
                    "models/obj/train.obj", 
                    "models/obj/female02/female02.obj", 
                    "models/obj/cow-nonormals.obj", 
                    "models/obj/pumpkin_tall_10k.obj", 
                    "models/obj/teapot.obj", 
                    "models/obj/teddy.obj",
                    "models/obj/tree.obj"];
    
    var selector = new html.SelectElement();
    urls.forEach((u) {
      var option = new html.OptionElement(data: u.split("/").last, value: u);
      selector.children.add(option);
    });
    selector.onChange.listen((e) {
      var opt = selector.options[selector.selectedIndex];
      _loadModel(opt.value);
    });
    html.querySelector("#controllers").children.add(selector);
    
    _loadModel("models/obj/head.obj");
  }

  void _loadModel(String url) {
    var loader = new ObjLoader();
    loader.load(url).then((m) {
      removeChildren();
      add(m);
      

      m.material = new ShaderMaterial(graphicsDevice, PhysicallyVS, PhysicallyFS);
      m.material.backFaceCulling = false;
      (m.material as ShaderMaterial).afterBinding = (ShaderMaterial material, Mesh mesh, Matrix4 worldMatrix) {
        
      };
      var box = m.boundingInfo.boundingBox;
      var radius = m.boundingInfo.boundingSphere.radius;
      camera.position = box.center + new Vector3(0.0, radius * 0, radius * 2);
      camera.lookAt(box.center);
    });
  }

  @override
  void exit() {
    dispose();
  }
}





const PhysicallyVS = """
precision mediump float;

attribute vec3 position;
attribute vec3 normal;
uniform mat4 world;
uniform mat4 view;
uniform mat4 viewProjection;
uniform mat4 worldViewProjection;
uniform vec3 vEyePosition;

varying vec3 vWorldPosition;
varying vec3 vNormal;

void main(void) {
  vec4 wp = world * vec4(position, 1.0);
  vWorldPosition = wp.xyz; 
  vNormal = normalize(vec3(world * vec4(normal, 0.0)));
 
  gl_Position = viewProjection * wp;
}
""";

// http://www.altdev.co/2011/08/23/shader-code-for-physically-based-lighting/
const PhysicallyFS = """
precision mediump float;

#define PI 3.1415926535897932384626433832795
#define PI_OVER_TWO 1.5707963267948966
#define PI_OVER_FOUR 0.7853981633974483

uniform vec3 vEyePosition;

varying vec3 vWorldPosition;
varying vec3 vNormal;

void main(void) {
  vec3 color = vec3(0.7, 0.3, 0.3);
  vec3 light_colour = vec3(1.0, 1.0, 1.0);
  vec3 light_direction = normalize(vec3(1.0, 1.0, 1.0));
  

  vec3 diffuse = clamp(dot(vNormal, light_direction), 0.0, 1.0) * light_colour;

  float specular_power = 32.0;
  float specular_colour = 0.01;
  float normalisation_term = (specular_power + 2.0) / 2.0 * PI;
  vec3 viewDirection = normalize(vEyePosition - vWorldPosition);
  vec3 halfVector = normalize(viewDirection + light_direction);
  float n_dot_h = clamp(dot(vNormal, halfVector), 0.0, 1.0);
  float blinn_phong = pow(n_dot_h, specular_power);    // n_dot_h is the saturated dot product of the normal and half vectors 
  float specular_term = normalisation_term * blinn_phong;

  float n_dot_l = clamp(dot(vNormal, light_direction), 0.0, 1.0);
  float cosine_term = n_dot_l;

  // Dot product of half vector and light vector. No need to saturate as it can't go above 90 degrees
  float h_dot_l = dot(halfVector, light_direction);
  float base = 1.0 - h_dot_l;
  float exponential = pow(base, 5.0);
  float fresnel_term = specular_colour + (1.0 - specular_colour) * exponential;

  float alpha = 1.0 / (sqrt(PI_OVER_FOUR * specular_power + PI_OVER_TWO));
  float n_dot_v = clamp(dot(vNormal, vWorldPosition), 0.0, 1.0);
  float visibility_term = (n_dot_l * (1.0 - alpha) + alpha) * (n_dot_v * (1.0 - alpha) + alpha);
  visibility_term = 1.0 / visibility_term;

  vec3 specular = (PI / 4.0) * specular_term * cosine_term * fresnel_term * visibility_term * light_colour;

  vec3 slow_hardware_specular = specular_term * cosine_term * light_colour; 
  vec3 mid_hardware_specular = specular_term * cosine_term * fresnel_term * light_colour; 
  vec3 fast_hardware_specular = specular_term * cosine_term * fresnel_term * visibility_term * light_colour;


  gl_FragColor = vec4(color * diffuse  + specular, 1.);
}
""";
