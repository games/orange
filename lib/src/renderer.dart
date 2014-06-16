part of orange;

const int MAX_LIGHTS = 4;

class Renderer {
  html.CanvasElement canvas;
  gl.RenderingContext ctx;
  PerspectiveCamera camera;
  Pass pass;
  Color backgroundColor = new Color.fromHex(0x84A6EE);
  List<Light> lights = [];
  int _textureIndex = -1;
  int _newMaxEnabledArray = -1;
  int _lastMaxEnabledArray = -1;

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
    _textureIndex = -1;
    _newMaxEnabledArray = -1;
    if (node is Light) {
      _drawLight(node);
    } else if (node is Mesh) {
      _drawMesh(node);
    }
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
        light.bind(ctx, shader, i);
      } else {
        shader.uniform(ctx, lt, Light.NONE);
      }
    }
  }

  _drawLight(Light light) {
    _drawMesh(light.view);
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
          if (attrib.location > _newMaxEnabledArray) {
            _newMaxEnabledArray = attrib.location;
          }
        }
      });
    }
    for (var i = (_newMaxEnabledArray + 1); i < _lastMaxEnabledArray; i++) {
      ctx.disableVertexAttribArray(i);
    }
    _lastMaxEnabledArray = _newMaxEnabledArray;

    if (mesh.material != null) {
      var material = mesh.material;
      if (mesh.material.texture != null) {
        _textureIndex++;
        ctx.activeTexture(gl.TEXTURE0 + _textureIndex);
        ctx.bindTexture(material.texture.target, material.texture.data);
        shader.uniform(ctx, Semantics.texture, _textureIndex);
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
      ctx.uniformMatrix4fv(shader.uniforms[Semantics.jointMat].location, false, jointMat);
      shader.uniform(ctx, Semantics.jointMat, jointMat);
    }
    if (mesh.faces != null) {
      mesh.faces.bindBuffer(ctx);
      if (mesh.material != null && mesh.material.wireframe) {
        ctx.drawArrays(gl.LINE_LOOP, 0, mesh.geometry.buffers[Semantics.position].count);
      } else {
        ctx.drawElements(gl.TRIANGLES, mesh.faces.count, mesh.faces.type, mesh.faces.offset);
      }
    }
    mesh.children.forEach(_drawMesh);
  }

}





