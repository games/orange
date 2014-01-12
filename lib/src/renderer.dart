part of orange;


class Renderer {
  html.CanvasElement canvas;
  gl.RenderingContext ctx;
  ModelCamera camera;
  double fov;
  Matrix4 projectionMatrix;
  
  Renderer(html.CanvasElement canvas, [bool flipTexture = false]) {
    this.canvas = canvas;
    ctx = canvas.getContext3d();
    camera = new ModelCamera(canvas);
    camera.distance = 4.0;
    camera.center = new Vector3.zero();
    fov = 45.0;
    projectionMatrix = new Matrix4.perspective(fov, canvas.width / canvas.height, 1.0, 4096.0);
    
    ctx.clearColor(0.0, 0.0, 0.2, 1.0);
    ctx.clearDepth(1.0);
    ctx.enable(gl.DEPTH_TEST);
    ctx.enable(gl.CULL_FACE);
    if(flipTexture) {
      ctx.pixelStorei(gl.UNPACK_FLIP_Y_WEBGL, 1);
    }
  }
  
  resize() {
    ctx.viewport(0, 0, canvas.width, canvas.height);
    projectionMatrix = new Matrix4.perspective(fov, canvas.width / canvas.height, 1.0, 4096.0);
  }
  
  prepare() {
    ctx.clear(gl.COLOR_BUFFER_BIT | gl.DEPTH_BUFFER_BIT);
  }
  
  draw(Node node, Pass pass) {
    if(node.mesh != null) {
      Shader shader = pass.shader;
      if(shader.ready == false) {
        return;
      }
      pass.prepare(ctx);
      ctx.useProgram(shader.program);

      node.updateMatrix();
      if(node.mesh != null) {
        node.bindBuffer(ctx, shader);
        ctx.uniform3f(shader.uniforms["lightPos"].location, 16, -32, 32);
        ctx.uniformMatrix4fv(shader.uniforms["viewMat"].location, false, camera.viewMatrix.storage);
        ctx.uniformMatrix4fv(shader.uniforms["modelMat"].location, false, node.worldMatrix.storage);
        ctx.uniformMatrix4fv(shader.uniforms["projectionMat"].location, false, projectionMatrix.storage);
        if(node.skeleton != null) {
          node.skeleton.update();
        }
        _drawMesh(node.mesh, shader);
      }
    }
    node.children.forEach((child) => draw(child, pass));
  }
  
  _drawMesh(Mesh mesh, Shader shader) {
    if(mesh.attributes != null) {
      mesh.attributes.forEach((sementic, accessor) {
        if(shader.attributes.containsKey(sementic)) {
          var attrib = shader.attributes[sementic];
          ctx.enableVertexAttribArray(attrib.location);
          ctx.vertexAttribPointer(attrib.location, accessor.size, accessor.type, accessor.normalized, accessor.stride, accessor.offset);
        }
      });
    }
    
    if(mesh.diffuse != null) {
      ctx.activeTexture(gl.TEXTURE0);
      ctx.bindTexture(mesh.diffuse.target, mesh.diffuse.data);
      ctx.uniform1i(shader.uniforms["diffuse"].location, 0);
    }

    if(mesh.skeleton != null) {
      var boneMat = mesh.skeleton.subBoneMatrices(mesh);
      ctx.uniformMatrix4fv(shader.uniforms["boneMat"].location, false, boneMat);
    }
    
    if(mesh.indicesAttrib != null) {
      ctx.drawElements(gl.TRIANGLES, mesh.indicesAttrib.count, mesh.indicesAttrib.type, mesh.indicesAttrib.offset);
    }
    
    mesh.subMeshes.forEach((subMesh) => _drawMesh(subMesh, shader));
  }
}
