precision highp float;
varying vec3 v_normal;
varying vec4 v_joint;
varying vec4 v_weight;
uniform vec3 u_light0Color;
varying vec3 v_light0Direction;
uniform float u_shininess;
uniform vec3 u_light1Color;
varying vec3 v_light1Direction;
uniform vec3 u_light2Color;
varying vec3 v_light2Direction;
uniform vec4 u_ambient;
varying vec2 v_texcoord0;
uniform sampler2D u_diffuse;
uniform vec4 u_emission;
uniform vec4 u_specular;
void main(void) {
vec3 normal = normalize(v_normal);
vec4 color = vec4(0., 0., 0., 0.);
vec4 diffuse = vec4(0., 0., 0., 1.);
vec3 diffuseLight = vec3(0., 0., 0.);
vec4 emission;
vec4 ambient;
vec4 specular;
vec3 specularLight = vec3(0., 0., 0.);
{
float diffuseIntensity;
float specularIntensity;
vec3 l = normalize(v_light0Direction);
vec3 h = normalize(l+vec3(0.,0.,1.));
diffuseIntensity = max(dot(normal,l), 0.);
specularIntensity = pow(max(0.0,dot(normal,h)),u_shininess);
specularLight += u_light0Color * specularIntensity;
diffuseLight += u_light0Color * diffuseIntensity;
}
{
float diffuseIntensity;
float specularIntensity;
vec3 l = normalize(v_light1Direction);
vec3 h = normalize(l+vec3(0.,0.,1.));
diffuseIntensity = max(dot(normal,l), 0.);
specularIntensity = pow(max(0.0,dot(normal,h)),u_shininess);
specularLight += u_light1Color * specularIntensity;
diffuseLight += u_light1Color * diffuseIntensity;
}
{
float diffuseIntensity;
float specularIntensity;
vec3 l = normalize(v_light2Direction);
vec3 h = normalize(l+vec3(0.,0.,1.));
diffuseIntensity = max(dot(normal,l), 0.);
specularIntensity = pow(max(0.0,dot(normal,h)),u_shininess);
specularLight += u_light2Color * specularIntensity;
diffuseLight += u_light2Color * diffuseIntensity;
}
ambient = u_ambient;
diffuse = texture2D(u_diffuse, v_texcoord0);
emission = u_emission;
specular = u_specular;
specular.xyz *= specularLight;
color.xyz += specular.xyz;
diffuse.xyz *= diffuseLight;
color.xyz += diffuse.xyz;
color.xyz += emission.xyz;
color = vec4(color.rgb * diffuse.a, diffuse.a);
gl_FragColor = color;
}
