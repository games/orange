part of orange;


Shader modelShader;
Shader skinnedModelShader;


class Renderer {
  html.CanvasElement canvas;
  gl.RenderingContext ctx;
  ModelCamera camera;
  double fov;
  Matrix4 projectionMatrix;
  
  Renderer(html.CanvasElement canvas) {
    this.canvas = canvas;
    ctx = canvas.getContext3d();
    camera = new ModelCamera(canvas);
    camera.distance = 4.0;
    camera.center = new Vector3(0.0, -1.0, 0.0);
    fov = 45.0;
    projectionMatrix = new Matrix4.perspective(fov, canvas.width / canvas.height, 1.0, 4096.0);
    
    ctx.clearColor(0.0, 0.0, 0.2, 1.0);
    ctx.clearDepth(1.0);
    ctx.enable(gl.DEPTH_TEST);
    ctx.enable(gl.CULL_FACE);
    ctx.pixelStorei(gl.UNPACK_FLIP_Y_WEBGL, 1);
  }
  
  resize() {
    ctx.viewport(0, 0, canvas.width, canvas.height);
    projectionMatrix = new Matrix4.perspective(fov, canvas.width / canvas.height, 1.0, 4096.0);
  }
  
  draw(Node node) {
    ctx.clear(gl.COLOR_BUFFER_BIT | gl.DEPTH_BUFFER_BIT);
    
    Shader shader = _switchShader(node);
    if(shader.ready == false) {
      return;
    }
    
    ctx.useProgram(shader.program);
    
    node.updateMatrix();
    node.bindBuffer(ctx, shader);
    
    ctx.uniform3f(shader.uniforms["lightPos"].location, 16, -32, 32);
    ctx.uniformMatrix4fv(shader.uniforms["viewMat"].location, false, camera.viewMatrix.storage);
    ctx.uniformMatrix4fv(shader.uniforms["modelMat"].location, false, node.worldMatrix.storage);
    ctx.uniformMatrix4fv(shader.uniforms["projectionMat"].location, false, projectionMatrix.storage);
    
    if(node.skeleton != null) {
      node.skeleton.update();
    }
    node.meshes.forEach((mesh) {
      ctx.activeTexture(gl.TEXTURE0);
      ctx.bindTexture(gl.TEXTURE_2D, mesh.diffuse);
      ctx.uniform1i(shader.uniforms["diffuse"].location, 0);
      mesh.subMeshes.forEach((subMesh) {
        if(node.skeleton != null) {
          ctx.uniformMatrix4fv(shader.uniforms["boneMat"].location, false, node.skeleton.subBoneMatrices(subMesh));
        }
        ctx.drawElements(gl.TRIANGLES, subMesh.indicesAttrib.count, subMesh.indicesAttrib.type, subMesh.indicesAttrib.offset);
      });
    });
    node.children.forEach((child) => draw(child));
  }
  
  _switchShader(Node node) {
    var shader;
    if(node.skeleton != null) {
      if(skinnedModelShader == null) {
        skinnedModelShader = new Shader(ctx, skinnedModelVS, skinnedModelFS);
      }
      shader = skinnedModelShader;
    } else {
      if(modelShader == null) {
        modelShader = new Shader(ctx, modelVS, modelFS);
      }
      shader = modelShader;
    }
    return shader;
  }
}