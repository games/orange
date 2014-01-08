part of orange;


const modelVS = """
attribute vec3 position;
attribute vec2 texture;
attribute vec3 normal;
uniform mat4 viewMat;
uniform mat4 modelMat;
uniform mat4 projectionMat;
uniform vec3 lightPos;
varying vec2 vTexture;
varying vec3 vNormal;
varying vec3 vLightDir;
varying vec3 vEyeDir;
// A manual rotation matrix transpose to get the normal matrix
mat3 getNormalMat(mat4 mat) {
    return mat3(mat[0][0], mat[1][0], mat[2][0], mat[0][1], mat[1][1], mat[2][1], mat[0][2], mat[1][2], mat[2][2]);
},

void main(void) {,
  mat4 modelViewMat = viewMat * modelMat;
  mat3 normalMat = getNormalMat(modelViewMat);
  vec4 vPosition = modelViewMat * vec4(position, 1.0);
  gl_Position = projectionMat * vPosition;
  vTexture = texture;
  vNormal = normalize(normal * normalMat);
  vLightDir = normalize(lightPos-vPosition.xyz);
  vEyeDir = normalize(-vPosition.xyz);
}
""";

const modelFS = """
uniform sampler2D diffuse;
varying vec2 vTexture;
varying vec3 vNormal;
varying vec3 vLightDir;
varying vec3 vEyeDir;
void main(void) {
 float shininess = 8.0;
 vec3 specularColor = vec3(1.0, 1.0, 1.0);
 vec3 lightColor = vec3(1.0, 1.0, 1.0);
 vec3 ambientLight = vec3(0.15, 0.15, 0.15);
 vec4 color = texture2D(diffuse, vTexture);
 vec3 normal = normalize(vNormal);
 vec3 lightDir = normalize(vLightDir);
 vec3 eyeDir = normalize(vEyeDir);
 vec3 reflectDir = reflect(-lightDir, normal);
 float specularLevel = color.a;
 float specularFactor = pow(clamp(dot(reflectDir, eyeDir), 0.0, 1.0), shininess) * specularLevel;
 float lightFactor = max(dot(lightDir, normal), 0.0);
 vec3 lightValue = ambientLight + (lightColor * lightFactor) + (specularColor * specularFactor);
 gl_FragColor = vec4(color.rgb * lightValue, 1.0);
}
""";


const lightmapVS = """
attribute vec3 position;
attribute vec2 texture;
attribute vec2 texture2;
uniform mat4 viewMat;
uniform mat4 modelMat;
uniform mat4 projectionMat;
uniform vec2 lightmapScale;
uniform vec2 lightmapOffset;
varying vec2 vTexCoord;
varying vec2 vLightCoord;
void main(void) {
 mat4 modelViewMat = viewMat * modelMat;
 vec4 vPosition = modelViewMat * vec4(position, 1.0);
 gl_Position = projectionMat * vPosition;
 vTexCoord = texture;
 vLightCoord = texture2 * lightmapScale + lightmapOffset;
}
""";


const lightmapFS = """
uniform sampler2D diffuse;
uniform sampler2D lightmap;
varying vec2 vTexCoord;
varying vec2 vLightCoord;
void main(void) {
 vec4 color = texture2D(diffuse, vTexCoord);
 vec4 lightValue = texture2D(lightmap, vLightCoord);
 float brightness = 9.0;
 gl_FragColor = vec4(color.rgb * lightValue.rgb * (lightValue.a * brightness), 1.0);
}
""";

class ModelVertexFormat {
  static const Position = 0x0001;
  static const UV = 0x0002;
  static const UV2 = 0x0004;
  static const Normal = 0x0008;
  static const Tangent = 0x0010;
  static const Color = 0x0020;
  static const BoneWeights = 0x0040;
}

Shader modelShader;
Shader lightmapShader;

String getLumpId(id) {
  return new String.fromCharCodes([id & 0xff,
                                   (id >> 8) & 0xff,
                                   (id >> 16) & 0xff,
                                   (id >> 24) & 0xff]);
}

class Model {
  int vertextFormat = 0;
  int vertexStride = 0;
  gl.Buffer vertexBuffer;
  gl.Buffer indexBuffer;
  List meshes;
  List _instances;
  int _visibleFlag = -1;
  bool complete = false;
  
  Future<Model> load(gl.RenderingContext ctx, String url) {
    var completer = new Completer();
    var vertComplete = false, modelComplete = false;
    html.HttpRequest.request(url, responseType: "arraybuffer").then((r){
      var bytes = _parseBinary(r.response);
      _compileBuffers(ctx, bytes);
      vertComplete = true;
      if(modelComplete) {
        complete = true;
        completer.complete(this);
      }
    });
    html.HttpRequest.request(url + ".wglmodel").then((r){
      var model = JSON.decode(r.response);
      _parseModel(model);
      _compileMaterials(ctx, meshes);
      modelComplete = true;
      if(vertComplete) {
        complete = true;
        completer.complete(this);
      }
    });
    if(modelShader == null) {
      modelShader = new Shader(ctx, modelVS, modelFS);
    }
    if(lightmapShader == null) {
      lightmapShader = new Shader(ctx, lightmapVS, lightmapFS);
    }
    return completer.future;
  }
  
  _parseBinary(Object buffer) {
    var vertexArray, indexArray;
    var header = new Uint32List.view(buffer, 0, 3);
    if(getLumpId(header[0]) != "wglv") {
      throw new ArgumentError("Binary file magic number does not match expected value.");
    }
    if(header[1] > 1) {
      throw new ArgumentError("Binary file version is not supported.");
    }
    var lumpCount = header[2];
    header = new Uint32List.view(buffer, 12, lumpCount * 3);
    for(var i = 0; i < lumpCount; i++) {
      var lumpId = getLumpId(header[i * 3]);
      var offset = header[(i * 3) + 1];
      var length = header[(i * 3) + 2];
      switch(lumpId) {
        case "vert":
          vertexArray = _parseVert(buffer, offset, length);
          break;
        case "indx":
          indexArray = _parseIndex(buffer, offset, length);
          break;
      }
    }
    return {"vertex": vertexArray, "index": indexArray};
  }
  
  _parseVert(Object buffer, int offset, int length) {
    var header = new Uint32List.view(buffer, offset, 2);
    vertextFormat = header[0];
    vertexStride = header[1];
    return new Uint8List.view(buffer, offset + 8, length - 8);
  }
  
  _parseIndex(Object buffer, int offset, int length) {
    return new Uint16List.view(buffer, offset, length ~/ 2);
  }
  
  _compileBuffers(gl.RenderingContext ctx, dynamic bytes) {
    vertexBuffer = ctx.createBuffer();
    ctx.bindBuffer(gl.ARRAY_BUFFER, vertexBuffer);
    ctx.bufferDataTyped(gl.ARRAY_BUFFER, bytes["vertex"], gl.STATIC_DRAW);
    
    indexBuffer = ctx.createBuffer();
    ctx.bindBuffer(gl.ELEMENT_ARRAY_BUFFER, indexBuffer);
    ctx.bufferDataTyped(gl.ELEMENT_ARRAY_BUFFER, bytes["index"], gl.STATIC_DRAW);
  }
  
  _parseModel(doc) {
    meshes = doc["meshes"];
  }
  
  _compileMaterials(gl.RenderingContext ctx, List meshes) {
    var textureManager = new TextureManager();
    meshes.forEach((mesh) {
      textureManager.load(ctx, mesh["defaultTexture"]).then((t) => mesh["diffuse"] = t);
    });
    
    
  }
  
}




































