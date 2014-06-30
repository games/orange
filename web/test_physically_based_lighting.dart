part of orange_examples;




// TODO :
//  http://d.hatena.ne.jp/hanecci/20140423/p1
//  http://www.filmicworlds.com/images/ggx-opt/optimized-ggx.hlsl

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
      
      var envTexture = new CubeTexture("textures/cube/Bridge2/bridge");

      m.material = new ShaderMaterial(graphicsDevice, PhysicallyVS, PhysicallyFS);
      m.material.backFaceCulling = false;
      (m.material as ShaderMaterial).afterBinding = (ShaderMaterial material, Mesh mesh, Matrix4 worldMatrix) {
        graphicsDevice.bindTexture("env", envTexture);
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
  vec3 color = vec3(78.0 / 255.0, 58.0 / 255.0, 49.0 / 255.0);
  vec3 light_colour = vec3(1.0, 1.0, 1.0);
  vec3 light_direction = normalize(vec3(1.0, 1.0, 1.0));
  

  vec3 diffuse = clamp(dot(vNormal, light_direction), 0.0, 1.0) * light_colour;

  float specular_power = 32.0;
  float specular_colour = 0.02;
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

//  options
//  vec3 slow_hardware_specular = specular_term * cosine_term * light_colour; 
//  vec3 mid_hardware_specular = specular_term * cosine_term * fresnel_term * light_colour; 
//  vec3 fast_hardware_specular = specular_term * cosine_term * fresnel_term * visibility_term * light_colour;


  gl_FragColor = vec4(color * diffuse + specular, 1.);
}
""";


//https://github.com/skurmedel/webglmat/blob/master/src/shaders/metal_fs.glsl
const FS2 = """

precision mediump float;

#define PI 3.1415926535897932384626433832795
#define PI_OVER_TWO 1.5707963267948966
#define PI_OVER_FOUR 0.7853981633974483

uniform vec3 vEyePosition;
uniform mat4 view;
uniform samplerCube env;

varying vec3 vWorldPosition;
varying vec3 vNormal;

struct directions {
  vec3 H;
  vec3 L;
  vec3 N;
  vec3 V;

  vec3 TN;
  vec3 BTN;
};

float schlick(float F0, float HdotV)
{
  return F0 + (1.0 - F0) * pow((1.0 - HdotV), 5.0);
}

float schlick_ior(float ior1, float ior2, float HdotV)
{
  float F0 = (ior1 - ior2) / (ior1 + ior2);
  return schlick(F0 * F0, HdotV);
}

float d_gtr2(float roughness, float NdotH)
{
  float a2 = roughness * roughness;
  float term1 = PI;
  float term2 = (NdotH * NdotH) * (a2 - 1.0) + 1.0;
  float deno = term1 * (term2 * term2);
  return a2 / deno;
}

vec3 d_gtr2_sample(float roughness, vec3 x, vec3 y, vec3 n, vec3 v, float r)
{
  float ax = roughness;
  float ay = ax;

  /*
    Make up some kind of rx and ry.
  */
  float rx = (r + n.x + n.y) / 3.0;
  float ry = (1.0 - r + n.z + n.x + rx) / (3.0 + rx);

  float term1 = sqrt(ry / (1.0 - ry));
  vec3  term2 = (ax * cos(2.0 * PI * rx) * x) + (ay * sin(2.0 * PI * rx) * y);

  vec3 h = normalize(term1 * term2 + n);

  vec3 L = (2.0 * dot(v, h) * h) - v;

  return textureCube(env, normalize(L), roughness * 2.0).xyz;
}

vec3 compute_specular(float ior, float roughness, directions dir, float F)
{
  /*
    Cook-Torrance Microfacet model.

    D = microfacet slope distribution.
    G = geometric attenuation.
    F = fresnel coefficient.
  */
  float NdotH = max(0.0, dot(dir.N, dir.H));
  float NdotV = max(0.0, dot(dir.N, dir.V));
  float VdotH = max(0.0, dot(dir.V, dir.H));
  float NdotL = max(0.0, dot(dir.N, dir.L));

  /*
    Sample environment.
  */
  vec3 x = dir.N.zyx;
  vec3 y = normalize(cross(dir.N.zyx, dir.N));
  vec3 refl = d_gtr2_sample(roughness, x, y, dir.N, dir.V, 0.01) 
            + d_gtr2_sample(roughness, x, y, dir.N, dir.V, 0.11) 
            + d_gtr2_sample(roughness, x, y, dir.N, dir.V, 0.21)
            + d_gtr2_sample(roughness, x, y, dir.N, dir.V, 0.31)
            + d_gtr2_sample(roughness, x, y, dir.N, dir.V, 0.41)
            + d_gtr2_sample(roughness, x, y, dir.N, dir.V, 0.51)
            + d_gtr2_sample(roughness, x, y, dir.N, dir.V, 0.61)
            + d_gtr2_sample(roughness, x, y, dir.N, dir.V, 0.71)
            + d_gtr2_sample(roughness, x, y, dir.N, dir.V, 0.81)
            + d_gtr2_sample(roughness, x, y, dir.N, dir.V, 0.91);
       refl = refl * 1.0 * F;

  float G = min(
    1.0, 
    min(
      (2.0 * NdotH * NdotV) / VdotH, 
      (2.0 * NdotH * NdotL) / VdotH));
  float a = acos(NdotH);
  float D = d_gtr2(roughness, NdotH);

  return ((F * D * G) / (4.0 * NdotL * NdotV)) * vec3(1.0) + refl;
}

/*
  Computes the diffuse term.

  All vectors must be unit vectors.

  Nn  surface normal.
  L   incident light vector.
  F   fresnel coefficient.
*/
vec3 compute_diffuse(directions dir, float F)
{
  return (1.0 - F) * dot(dir.N, dir.L) * vec3(1.0);
}

void main(void) {
  vec3 color = vec3(78.0 / 255.0, 58.0 / 255.0, 49.0 / 255.0);
  vec3 light_colour = vec3(1.0, 1.0, 1.0);
  vec3 light_direction = normalize(vec3(1.0, 1.0, 1.0));
  vec3 light_pos = -light_direction;
  float metallic = 0.5;
  float roughness = 0.5;
  
  vec3 diffuse = clamp(dot(vNormal, light_direction), 0.0, 1.0) * light_colour;

  directions dir;
  vec3 p = vWorldPosition;
  vec3 N = vNormal;
  vec3 TN = tangent;
  vec3 BTN = normalize(cross(N, TN));

  dir.V = normalize((view * vec4(vEyePosition, 1.0)).xyz - p);
  vec3 Lp = (view * vec4(light_pos, 1.0)).xyz;
  dir.L = normalize(p - Lp);
  dir.H = normalize(dir.L + dir.V);
  // The normalized-normal, interpolated normals
  // might not be unit vectors.
  dir.N = normalize(N);
  dir.TN = normalize(TN);
  dir.BTN = normalize(BTN);

  float F = schlick_ior(ior, 1.0, dot(normalize(dir.V + dir.L), dir.V));

  vec3 diffuse = compute_diffuse(dir, F) * (color * (1.0 - metallic));
  vec3 spec    = compute_specular(ior, roughness, dir, F) * mix(vec3(1.0), color, metallic);

  gl_FragColor = vec4(diffuse + spec, 1.0);
  

}

""";

