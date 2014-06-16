part of orange;



class Material {
  String name;
  // TODO rename to 'diffuseTexture'
  Texture texture;
  double shininess;
  Color specularColor;
  Color diffuseColor;
  Color ambientColor;
  Color emissiveColor;

  // NEW
  Technique technique;
  bool wireframe = false;

  bool ready(Mesh mesh) {
    return true;
  }

  void bind(Renderer2 renderer, Scene scene, Mesh mesh) {

  }
}

class StandartMaterial extends Material {

  StandartMaterial(Renderer2 renderer) {
    technique = new Technique();
    technique.pass = new Pass();
    technique.pass.shader = new Shader(renderer.ctx, simpleModelVS, simpleModelFS);
  }


  bool ready(Mesh mesh) {
    return technique.pass.shader.ready;
  }

  @override
  void bind(Renderer2 renderer, Scene scene, Mesh mesh) {
    var pass = technique.pass;
    var shader = pass.shader;
    var ctx = renderer.ctx;
    var camera = scene.camera;

    renderer.use(pass);
    renderer.bindUniform(shader, Semantics.modelMat, mesh.worldMatrix.storage);
    renderer.bindUniform(shader, Semantics.viewMat, camera.viewMatrix.storage);
    renderer.bindUniform(shader, Semantics.projectionMat, camera.projectionMatrix.storage);
    renderer.bindUniform(shader, Semantics.normalMat, (camera.viewMatrix * mesh.worldMatrix).normalMatrix3().storage);

    //textures
    // TODO ambient, opacity, reflection, emissive, specular, bump
    if (texture != null) {
      renderer.bindTexture(shader, texture);
    }

    // colors
    renderer.bindUniform(shader, Semantics.cameraPosition, camera.position.storage);
    if (shininess != null) {
      renderer.bindUniform(shader, Semantics.shininess, shininess);
    }
    if (specularColor != null) {
      renderer.bindUniform(shader, Semantics.specularColor, specularColor.storage);
    }
    if (ambientColor != null) {
      renderer.bindUniform(shader, Semantics.ambientColor, ambientColor.storage);
    }
    if (diffuseColor != null) {
      renderer.bindUniform(shader, Semantics.diffuseColor, diffuseColor.storage);
    }
    if (emissiveColor != null) {
      renderer.bindUniform(shader, Semantics.emissiveColor, emissiveColor.storage);
    }

    //lights
    if (scene.lightsEnabled) {
      var lights = scene.lights;
      for (var i = 0; i < MAX_LIGHTS; i++) {
        var lt = "light${i}.type";
        if (!shader.uniforms.containsKey(lt)) continue;
        if (i < lights.length) {
          var light = lights[i];
          light.updateMatrix();
          light.bind(ctx, shader, i);
          //TODO shadows
          if (mesh.receiveShadows) {
            // light matrix
            // shadowSampler
            // darkness
          }
        } else {
          renderer.bindUniform(shader, lt, Light.NONE);
        }
      }
    }

    if (mesh.skeleton != null) {
      mesh.skeleton.updateMatrix();
      renderer.bindUniform(shader, Semantics.jointMat, mesh.skeleton.jointMatrices);
    }

    //TODO fog
  }




}









