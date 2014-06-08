part of orange;

const int MAX_LIGHTS = 4;

class Renderer {
  html.CanvasElement canvas;
  gl.RenderingContext ctx;
  PerspectiveCamera camera;
  Pass pass;
  Color backgroundColor = new Color.fromHex(0x84A6EE);
  List<Light> lights = [];

  Renderer(html.CanvasElement canvas) {
    this.canvas = canvas;
    ctx = canvas.getContext3d();
    camera = new PerspectiveCamera(canvas.width / canvas.height);

    ctx.clearColor(backgroundColor.red, backgroundColor.green, backgroundColor.blue, backgroundColor.alpha);
    ctx.clearDepth(1.0);
    //    ctx.pixelStorei(gl.UNPACK_FLIP_Y_WEBGL, 1);

    //    pass = new Pass();
    //    pass.shader = new Shader(ctx, skinnedModelVS, skinnedModelFS);
  }

  resize() {
    ctx.viewport(0, 0, canvas.width, canvas.height);
    camera.aspect = canvas.width / canvas.height;
    camera.updateProjection();
  }

  bool prepare() {
    ctx.clear(gl.COLOR_BUFFER_BIT | gl.DEPTH_BUFFER_BIT);
    var shader = pass.shader;
    if (!shader.ready) return false;
    pass.prepare(ctx);
    shader.uniform(ctx, Semantics.viewMat, camera.viewMatrix.storage);
    shader.uniform(ctx, Semantics.projectionMat, camera.projectionMatrix.storage);
    _setupLights();
    return true;
  }

  draw(Node node) {
    node.updateMatrix();

    var shader = pass.shader;
    shader.uniform(ctx, Semantics.useTextures, false);

    if (node is Light) {
      _drawLight(node);
    } else if (node is Mesh) {
      _drawMesh(node);
    }

    // TODO : every node should have a pass itself.
    ctx.activeTexture(gl.TEXTURE0);
    ctx.bindTexture(gl.TEXTURE_2D, null);
  }

  _setupLights() {
    var shader = pass.shader;
    shader.uniform(ctx, Semantics.cameraPosition, camera.position.storage);
    for (var i = 0; i < MAX_LIGHTS; i++) {
      var lt = "light${i}.type";
      if (!shader.uniforms.containsKey(lt)) continue;
      if (i < lights.length) {
        var light = lights[i];
        light.updateMatrix();
        shader.uniform(ctx, lt, light.type);
        shader.uniform(ctx, "light${i}.intensity", light.intensity);
        shader.uniform(ctx, "light${i}.direction", light.direction.storage);
        shader.uniform(ctx, "light${i}.color", light.color.storage);
        shader.uniform(ctx, "light${i}.position", light.position.storage);
        shader.uniform(ctx, "light${i}.constantAttenuation", light.constantAttenuation);
        shader.uniform(ctx, "light${i}.linearAttenuation", light.linearAttenuation);
        shader.uniform(ctx, "light${i}.quadraticAttenuation", light.quadraticAttenuation);
        shader.uniform(ctx, "light${i}.spotExponent", light.spotExponent);
        if (light.spotCutoff != null) shader.uniform(ctx, "light${i}.spotCosCutoff", light.spotCosCutoff);
      } else {
        shader.uniform(ctx, lt, Light.NONE);
      }
    }
  }

  _drawLight(Light light) {
    var coordinate = new Coordinate();
    coordinate.position = light.position;
    coordinate.rotation = light.rotation;
    coordinate.updateMatrix();
    coordinate.worldMatrix.invert();
    _drawMesh(coordinate);
  }

  _drawMesh(Mesh mesh) {
    var shader = pass.shader;
    shader.uniform(ctx, Semantics.modelMat, mesh.worldMatrix.storage);
    var nm = (camera.viewMatrix * mesh.worldMatrix).normalMatrix3();
    if (nm != null) shader.uniform(ctx, Semantics.normalMat, nm.storage);

    if (mesh.geometry != null) {
      var geometry = mesh.geometry;
      shader.attributes.forEach((semantic, attrib) {
        if (geometry.buffers.containsKey(semantic)) {
          var bufferView = geometry.buffers[semantic];
          bufferView.bindBuffer(ctx);
          ctx.enableVertexAttribArray(attrib.location);
          ctx.vertexAttribPointer(attrib.location, bufferView.size, bufferView.type, bufferView.normalized, bufferView.stride, bufferView.offset);
        }
      });
    }

    if (mesh.material != null) {
      var material = mesh.material;
      if (mesh.material.texture != null) {
        ctx.activeTexture(gl.TEXTURE0);
        ctx.bindTexture(material.texture.target, material.texture.data);
        shader.uniform(ctx, Semantics.texture, 0);
        shader.uniform(ctx, Semantics.useTextures, true);
      } else {
        shader.uniform(ctx, Semantics.useTextures, false);
      }
      if (material.shininess != null) {
        shader.uniform(ctx, Semantics.shininess, material.shininess);
      }
      if (material.specularColor != null) {
        shader.uniform(ctx, Semantics.specularColor, material.specularColor.storage);
      }
      if (material.ambientColor != null) {
        shader.uniform(ctx, Semantics.ambientColor, material.ambientColor.storage);
      }
      if (material.diffuseColor != null) {
        shader.uniform(ctx, Semantics.diffuseColor, material.diffuseColor.storage);
      }
      if (material.emissiveColor != null) {
        shader.uniform(ctx, Semantics.emissiveColor, material.emissiveColor.storage);
      }
    }
    if (mesh.skeleton != null) {
      mesh.skeleton.updateMatrix();
      var jointMat = mesh.skeleton.jointMatrices;
      ctx.uniformMatrix4fv(shader.uniforms["uJointMat"].location, false, jointMat);
      shader.uniform(ctx, "uJointMat", jointMat);
    }
    if (mesh.faces != null) {
      mesh.faces.bindBuffer(ctx);
      if (mesh.wireframe) {
        ctx.drawArrays(gl.LINE_LOOP, 0, mesh.geometry.buffers[Semantics.position].count);
      } else {
        ctx.drawElements(gl.TRIANGLES, mesh.faces.count, mesh.faces.type, mesh.faces.offset);
      }
    }
    mesh.children.forEach(_drawMesh);
  }

}









