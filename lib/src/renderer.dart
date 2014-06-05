part of orange;

const int MAX_LIGHTS = 4;

class Renderer {
  html.CanvasElement canvas;
  gl.RenderingContext ctx;
  PerspectiveCamera camera;
  double fov;
  Matrix4 projectionMatrix;
  Pass pass;
  Color backgroundColor = new Color.fromHex(0x84A6EE);
  List<Light> lights = [];

  Renderer(html.CanvasElement canvas) {
    this.canvas = canvas;
    ctx = canvas.getContext3d();
    camera = new PerspectiveCamera(canvas.width / canvas.height);
    //    camera.distance = 4.0;
    //    camera.center = new Vector3.zero();
    fov = 45.0;
    //    projectionMatrix = new Matrix4.perspective(fov, canvas.width / canvas.height, 1.0, 4096.0);

    ctx.clearColor(backgroundColor.red, backgroundColor.green, backgroundColor.blue, backgroundColor.alpha);
    ctx.clearDepth(1.0);
    //    ctx.pixelStorei(gl.UNPACK_FLIP_Y_WEBGL, 1);

    //    pass = new Pass();
    //    pass.shader = new Shader(ctx, skinnedModelVS, skinnedModelFS);
  }

  resize() {
    ctx.viewport(0, 0, canvas.width, canvas.height);
    projectionMatrix = new Matrix4.perspective(fov, canvas.width / canvas.height, 1.0, 4096.0);
  }

  prepare() {
    ctx.clear(gl.COLOR_BUFFER_BIT | gl.DEPTH_BUFFER_BIT);
  }

  draw(Node node) {
    var shader = pass.shader;
    if (shader.ready == false) return;
    pass.prepare(ctx);
    ctx.uniformMatrix4fv(shader.uniforms[Semantics.viewMat].location, false, camera.viewMatrix.storage);
    ctx.uniformMatrix4fv(shader.uniforms[Semantics.projectionMat].location, false, camera.projectionMatrix.storage);

    _setupLights(shader);

    node.updateMatrix();
    if (node is Light) {
      _drawLight(node);
    } else if (node is Mesh) {
      _drawMesh(node);
    }

    // TODO : should be disable all attributes and uniforms in the end draw.
    //    shader.attributes.forEach((semantic, attrib) {
    //      ctx.disableVertexAttribArray(attrib.location);
    //    });
    //    shader.uniforms.forEach((semantic, uniform) {
    //      shader.uniform(ctx, semantic, null);
    //    });
    ctx.activeTexture(gl.TEXTURE0);
    ctx.bindTexture(gl.TEXTURE_2D, null);
  }

  _setupLights(Shader shader) {
    shader.uniform(ctx, Semantics.cameraPosition, camera.position.storage);
    for (var i = 0; i < MAX_LIGHTS; i++) {
      var lt = "light${i}.type";
      if (!shader.uniforms.containsKey(lt)) continue;
      if (i < lights.length) {
        var light = lights[i];
        light.updateMatrix();
        ctx.uniform1i(shader.uniforms[lt].location, light.type);
        ctx.uniform1f(shader.uniforms["light${i}.intensity"].location, light.intensity);
        ctx.uniform3fv(shader.uniforms["light${i}.direction"].location, light.direction.storage);
        ctx.uniform3fv(shader.uniforms["light${i}.color"].location, light.color.storage);
        ctx.uniform3fv(shader.uniforms["light${i}.position"].location, light.position.storage);
        ctx.uniform1f(shader.uniforms["light${i}.constantAttenuation"].location, light.constantAttenuation);
        ctx.uniform1f(shader.uniforms["light${i}.linearAttenuation"].location, light.linearAttenuation);
        ctx.uniform1f(shader.uniforms["light${i}.quadraticAttenuation"].location, light.quadraticAttenuation);
        if (light.spotExponent != null) ctx.uniform1f(shader.uniforms["light${i}.spotExponent"].location, light.spotExponent);
        if (light.spotCutoff != null) ctx.uniform1f(shader.uniforms["light${i}.spotCosCutoff"].location, light.spotCosCutoff);
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
    shader.uniform(ctx, Semantics.normalMat, (camera.viewMatrix * mesh.worldMatrix).normalMatrix3().transpose());
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




















