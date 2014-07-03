part of orange;





class PhysicallyBasedMaterial extends Material {
  
  // Albedo is the base color input, commonly known as a diffuse map.
  // 0.0 ~ 1.0
  double albedo = 0.5;
  // defines how rough or smooth the surface of a material is.
  // 0.0 ~ 1.0
  double roughness = 0.5;
  // F0
  double reflectivity = 0.5;
  
  
  
}
