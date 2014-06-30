part of orange_examples;




// TODO :
//  http://d.hatena.ne.jp/hanecci/20140423/p1
//  http://www.filmicworlds.com/images/ggx-opt/optimized-ggx.hlsl

class TestPhysicallyBasedLighting extends Scene {
  TestPhysicallyBasedLighting(Camera camera) : super(camera);
  
  int type = 0;
  double roughness = 0.5;
  double specualerColor = 0.5;

  @override
  void enter() {
    var urls = [
                    "models/obj/head.obj", 
                    "models/obj/train.obj", 
                    "models/obj/female02/female02.obj", 
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
    var controllers = html.querySelector("#controllers");
    controllers.children.add(selector);
    controllers.children.add(new html.BRElement());
    
    
    var types = new html.SelectElement();
    for(var i = 0; i < 7; i++) {
      var option = new html.OptionElement(data: i.toString(), value: i.toString());
      types.children.add(option);
     }
    types.onChange.listen((e) {
      var opt = types.options[types.selectedIndex];
      type = int.parse(opt.value);
    });
    controllers.children.add(_labelFor(types, "types"));
    controllers.children.add(new html.BRElement());
    controllers.children.add(types);
    controllers.children.add(new html.BRElement());
    
    var roughnessSlider = new html.RangeInputElement();
    roughnessSlider.id = "roughness";
    roughnessSlider.min = "0";
    roughnessSlider.max = "1";
    roughnessSlider.step = "0.01";
    roughnessSlider.value = roughness.toString();
    roughnessSlider.onChange.listen((e) {
      roughness = double.parse(roughnessSlider.value);
    });
    controllers.children.add(_labelFor(roughnessSlider, "Roughness(0~1)"));
    controllers.children.add(new html.BRElement());
    controllers.children.add(roughnessSlider);
    controllers.children.add(new html.BRElement());
    
    var specualrSlider = new html.RangeInputElement();
    specualrSlider.id = "roughness";
    specualrSlider.min = "0";
    specualrSlider.max = "3";
    specualrSlider.step = "0.01";
    specualrSlider.value = specualerColor.toString();
    specualrSlider.onChange.listen((e) {
      specualerColor = double.parse(specualrSlider.value);
    });
    controllers.children.add(_labelFor(specualrSlider, "Specualer(0~3)"));
    controllers.children.add(new html.BRElement());
    controllers.children.add(specualrSlider);
    controllers.children.add(new html.BRElement());
    
    _loadModel(urls.first);
  }
  
  html.LabelElement _labelFor(html.Element element, String title) {
    var label = new html.LabelElement();
    label.htmlFor = element.id;
    label.text = title;
    return label;
  }

  void _loadModel(String url) {
    var loader = new ObjLoader();
    loader.load(url).then((m) {
      removeChildren();
      add(m);
      
      var envTexture = new CubeTexture("textures/cube/Bridge2/bridge");
      var texture = Texture.load(graphicsDevice.ctx, {
        "path": "models/obj/skin1.jpg"
      });
      var ggx = Texture.load(graphicsDevice.ctx, {
        "path": "textures/ggx-helper-dfv.png"
      });

      m.material = new ShaderMaterial(graphicsDevice, PhysicallyVS, PhysicallyFS);
      m.material.backFaceCulling = false;
      (m.material as ShaderMaterial).afterBinding = (ShaderMaterial material, Mesh mesh, Matrix4 worldMatrix) {
        graphicsDevice.bindTexture("GgxDFV", ggx);
        graphicsDevice.bindTexture("diffuseSampler", texture);
        graphicsDevice.bindInt("type", type);
        graphicsDevice.bindFloat("uRoughess", roughness);
        graphicsDevice.bindFloat("uSpecularColour", specualerColor);
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
attribute vec2 uv;
uniform mat4 world;
uniform mat4 view;
uniform mat4 viewProjection;
uniform mat4 worldViewProjection;
uniform vec3 vEyePosition;

varying vec3 vWorldPosition;
varying vec3 vNormal;
varying vec2 vUV;

void main(void) {
  vec4 wp = world * vec4(position, 1.0);
  vWorldPosition = wp.xyz; 
  vNormal = normalize(vec3(world * vec4(normal, 0.0)));
  vUV = uv;
 
  gl_Position = viewProjection * wp;
}
""";

// http://www.altdev.co/2011/08/23/shader-code-for-physically-based-lighting/
const PhysicallyFS = """
precision mediump float;
precision mediump int;

#define PI 3.1415926535897932384626433832795
#define PI_OVER_TWO 1.5707963267948966
#define PI_OVER_FOUR 0.7853981633974483

uniform vec3 vEyePosition;
uniform sampler2D GgxDFV;
uniform sampler2D diffuseSampler;
uniform int type;
uniform float uRoughess;
uniform float uSpecularColour;

varying vec3 vWorldPosition;
varying vec3 vNormal;
varying vec2 vUV;

float saturate(float d) {
  return clamp(d, 0.0, 1.0);
}

float G1V(float dotNV, float k) {
  return 1.0/(dotNV*(1.0-k)+k);
}

float LightingFuncGGX_REF(vec3 N, vec3 V, vec3 L, float roughness, float F0)
{
  float alpha = roughness*roughness;
  vec3 H = normalize(V+L);

  float dotNL = saturate(dot(N,L));
  float dotNV = saturate(dot(N,V));
  float dotNH = saturate(dot(N,H));
  float dotLH = saturate(dot(L,H));

  float F, D, vis;

  // D
  float alphaSqr = alpha*alpha;
  float pi = 3.14159;
  float denom = dotNH * dotNH *(alphaSqr-1.0) + 1.0;
  D = alphaSqr/(pi * denom * denom);

  // F
  float dotLH5 = pow(1.0-dotLH, 5.0);
  F = F0 + (1.0-F0)*(dotLH5);

  // V
  float k = alpha/2.0;
  vis = G1V(dotNL,k)*G1V(dotNV,k);

  float specular = dotNL * D * F * vis;
  return specular;
}

float LightingFuncGGX_OPT1(vec3 N, vec3 V, vec3 L, float roughness, float F0)
{
  float alpha = roughness*roughness;

  vec3 H = normalize(V+L);

  float dotNL = saturate(dot(N,L));
  float dotLH = saturate(dot(L,H));
  float dotNH = saturate(dot(N,H));

  float F, D, vis;

  // D
  float alphaSqr = alpha*alpha;
  float pi = 3.14159;
  float denom = dotNH * dotNH *(alphaSqr-1.0) + 1.0;
  D = alphaSqr/(pi * denom * denom);

  // F
  float dotLH5 = pow(1.0-dotLH,5.0);
  F = F0 + (1.0-F0)*(dotLH5);

  // V
  float k = alpha/2.0;
  vis = G1V(dotLH,k)*G1V(dotLH,k);

  float specular = dotNL * D * F * vis;
  return specular;
}

float LightingFuncGGX_OPT2(vec3 N, vec3 V, vec3 L, float roughness, float F0)
{
  float alpha = roughness*roughness;

  vec3 H = normalize(V+L);

  float dotNL = saturate(dot(N,L));

  float dotLH = saturate(dot(L,H));
  float dotNH = saturate(dot(N,H));

  float F, D, vis;

  // D
  float alphaSqr = alpha*alpha;
  float pi = 3.14159;
  float denom = dotNH * dotNH *(alphaSqr-1.0) + 1.0;
  D = alphaSqr/(pi * denom * denom);

  // F
  float dotLH5 = pow(1.0-dotLH,5.0);
  F = F0 + (1.0-F0)*(dotLH5);

  // V
  float k = alpha/2.0;
  float k2 = k*k;
  float invK2 = 1.0-k2;
  vis = inversesqrt(dotLH*dotLH*invK2 + k2);

  float specular = dotNL * D * F * vis;
  return specular;
}

vec2 LightingFuncGGX_FV(float dotLH, float roughness)
{
  float alpha = roughness*roughness;

  // F
  float F_a, F_b;
  float dotLH5 = pow(1.0-dotLH,5.0);
  F_a = 1.0;
  F_b = dotLH5;

  // V
  float vis;
  float k = alpha/2.0;
  float k2 = k*k;
  float invK2 = 1.0-k2;
  vis = inversesqrt(dotLH*dotLH*invK2 + k2);
  return vec2(F_a*vis,F_b*vis);
}

float LightingFuncGGX_D(float dotNH, float roughness)
{
  float alpha = roughness*roughness;
  float alphaSqr = alpha*alpha;
  float pi = 3.14159;
  float denom = dotNH * dotNH *(alphaSqr-1.0) + 1.0;
  float D = alphaSqr/(pi * denom * denom);
  return D;
}

float LightingFuncGGX_OPT3(vec3 N, vec3 V, vec3 L, float roughness, float F0)
{
  vec3 H = normalize(V+L);

  float dotNL = saturate(dot(N,L));
  float dotLH = saturate(dot(L,H));
  float dotNH = saturate(dot(N,H));

  float D = LightingFuncGGX_D(dotNH,roughness);
  vec2 FV_helper = LightingFuncGGX_FV(dotLH,roughness);
  float FV = F0*FV_helper.x + (1.0-F0)*FV_helper.y;
  float specular = dotNL * D * FV;
  return specular;
}

float Pow4(float x) {
  return x*x*x*x;
}

float LightingFuncGGX_OPT4(vec3 N, vec3 V, vec3 L, float roughness, float F0){
  vec3 H = normalize(V+L);

  float dotNL = saturate(dot(N,L));
  float dotLH = saturate(dot(L,H));
  float dotNH = saturate(dot(N,H));

  float D = texture2D(GgxDFV, vec2(Pow4(dotNH), roughness)).x;
  vec2 FV_helper = texture2D(GgxDFV, vec2(dotLH,roughness)).yz;
  float FV = F0*FV_helper.x + (1.0-F0)*FV_helper.y;
  float specular = dotNL * D * FV;

  return specular;
}

// This version includes Stephen Hill's optimization
float LightingFuncGGX_OPT5(vec3 N, vec3 V, vec3 L, float roughness, float F0) {
  vec3 H = normalize(V+L);

  float dotNL = saturate(dot(N,L));
  float dotLH = saturate(dot(L,H));
  float dotNH = saturate(dot(N,H));

  float D = texture2D(GgxDFV, vec2(Pow4(dotNH), roughness)).x;
  vec2 FV_helper = texture2D(GgxDFV, vec2(dotLH,roughness)).yz;

  float FV = F0*FV_helper.x + FV_helper.y;
  float specular = dotNL * D * FV;

  return specular;
}


void main(void) {
  vec3 color = vec3(78.0 / 255.0, 58.0 / 255.0, 49.0 / 255.0);
  color = texture2D(diffuseSampler, vUV).xyz;
  vec3 light_colour = vec3(1.0, 1.0, 1.0);
  vec3 light_direction = normalize(vec3(1.0, 1.0, 1.0));
  

  vec3 diffuse = clamp(dot(vNormal, light_direction), 0.0, 1.0) * light_colour;

  float specular_power = uRoughess;
  float specular_colour = uSpecularColour;
  vec3 specular = vec3(0.0, 0.0, 0.0);
  float specular_term = 0.0;
  vec3 viewDirection = normalize(vEyePosition - vWorldPosition);

  if(type == 0){
    specular_power = 32.0;
    specular_colour = 0.03;

    float normalisation_term = (specular_power + 2.0) / 2.0 * PI;
    vec3 halfVector = normalize(viewDirection + light_direction);
    float n_dot_h = clamp(dot(vNormal, halfVector), 0.0, 1.0);
    float blinn_phong = pow(n_dot_h, specular_power);    // n_dot_h is the saturated dot product of the normal and half vectors 
    specular_term = normalisation_term * blinn_phong;
  
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
  
    specular = (PI / 4.0) * specular_term * cosine_term * fresnel_term * visibility_term * light_colour;
  } else if(type == 1) {
    specular_term = LightingFuncGGX_REF(vNormal, viewDirection, light_direction, uRoughess, uSpecularColour);
    specular = specular_term * light_colour;
  } else if(type == 2) {
    specular_term = LightingFuncGGX_OPT1(vNormal, viewDirection, light_direction, uRoughess, uSpecularColour);
    specular = specular_term * light_colour;
  } else if(type == 3) {
    specular_term = LightingFuncGGX_OPT2(vNormal, viewDirection, light_direction, uRoughess, uSpecularColour);
    specular = specular_term * light_colour;
  } else if(type == 4) {
    specular_term = LightingFuncGGX_OPT3(vNormal, viewDirection, light_direction, uRoughess, uSpecularColour);
    specular = specular_term * light_colour;
  } else if(type == 5) {
    specular_term = LightingFuncGGX_OPT4(vNormal, viewDirection, light_direction, uRoughess, uSpecularColour);
    specular = specular_term * light_colour;
  } else if(type == 6) {
    specular_term = LightingFuncGGX_OPT5(vNormal, viewDirection, light_direction, uRoughess, uSpecularColour);
    specular = specular_term * light_colour;
  }

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

