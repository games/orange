part of orange;


class MeshParser {
  static Mesh parse(String jsonStr) {
    var jsonObj = JSON.decode(jsonStr);
    var mesh = new Mesh();
    mesh._geometry = parseGeometry(jsonObj["sharedgeometry"]);
    mesh.material = parseMaterial(jsonObj["material"]);
    mesh._faces = parseFaces(jsonObj["faces"]);
    
    var submeshes = jsonObj["submeshes"];
    mesh._subMeshes = new List.generate(submeshes.length, (index) {
      var submesh = submeshes[index];
      var sub =  new Mesh();
      sub.useSharedVertices = submesh['usesharedvertices'];
      if(!sub.useSharedVertices) {
        sub._geometry = parseGeometry(submesh["geometry"]);
      }
      sub.material = parseMaterial(submesh["material"]);
      sub._faces = parseFaces(submesh["faces"]);
      return sub;
    });
    
    return mesh;
  }

  static Material parseMaterial(materialJson) {
    if(materialJson == null)
      return null;
    
    var material = new Material();
    material.textureSource = materialJson["texture"];
    material.shader = Shader.simpleShader;
    
    var ambient = materialJson["ambient"];
    material.ambient = new List.generate(ambient.length, (i) {
      return ambient[i].toDouble();
    });

    var diffuse = materialJson["diffuse"];
    material.diffuse = new List.generate(diffuse.length, (i) {
      return diffuse[i].toDouble();
    });
    
    var specular = materialJson["specular"];
    material.specular = new List.generate(specular.length, (i) {
      return specular[i].toDouble();
    });
    
    var emissive = materialJson["emissive"];
    material.emissive = new List.generate(emissive.length, (i) {
      return emissive[i].toDouble();
    });
    
    return material;
  }

  static List parseFaces(faceJson) {
    if(faceJson == null)
      return null;
    return new List.generate(faceJson.length, (i) {
      return faceJson[i].toInt();
    });
  }

  static Geometry parseGeometry(geo_dict) {
    if(geo_dict == null)
      return null;
    var geometry = new Geometry();
    var vertices = geo_dict["vertices"];
    geometry.vertices = new List.generate(vertices.length, (index) {
      return vertices[index].toDouble();
    });
    var normals = geo_dict["normals"];
    geometry.normals = new List.generate(normals.length, (index) {
      return normals[index].toDouble();
    });
    var textureCoords = geo_dict["texturecoords"];
    geometry.textureCoords = new List.generate(textureCoords.length, (index) {
      return textureCoords[index].toDouble();
    });
    return geometry;
  }
}