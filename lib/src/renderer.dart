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
  
  draw(Mesh mesh) {
    var shader = pass.shader;
    if(shader.ready == false)
      return;
    pass.prepare(ctx);
    
    mesh.updateMatrix();
    
    ctx.uniformMatrix4fv(shader.uniforms["uViewMat"].location, false, camera.worldMatrix.storage);
    ctx.uniformMatrix4fv(shader.uniforms["uModelMat"].location, false, mesh.worldMatrix.storage);
    ctx.uniformMatrix4fv(shader.uniforms["uProjectionMat"].location, false, camera.projectionMatrix.storage);
    shader.uniform(ctx, "uNormalMat", (camera.worldMatrix * mesh.worldMatrix).normalMatrix3().transpose());
    
    _setupLights(shader);
    
    _drawMesh(mesh);
    
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
    shader.uniform(ctx, "cameraPosition", camera.position.storage);
    for(var i = 0; i < MAX_LIGHTS; i++) {
      if(i < lights.length) {
        var light = lights[i];
        light.updateMatrix();
        ctx.uniform1i(shader.uniforms["light${i}.type"].location, light.type);
        ctx.uniform1f(shader.uniforms["light${i}.intensity"].location, light.intensity);
        ctx.uniform3fv(shader.uniforms["light${i}.direction"].location, light.direction.storage);
        ctx.uniform3fv(shader.uniforms["light${i}.color"].location, light.color.rgb.storage);
        ctx.uniform3fv(shader.uniforms["light${i}.position"].location, light.position.storage);
        ctx.uniform1f(shader.uniforms["light${i}.constantAttenuation"].location, light.constantAttenuation);
        ctx.uniform1f(shader.uniforms["light${i}.linearAttenuation"].location, light.linearAttenuation);
        ctx.uniform1f(shader.uniforms["light${i}.quadraticAttenuation"].location, light.quadraticAttenuation);
        if(light.spotExponent != null)
          ctx.uniform1f(shader.uniforms["light${i}.spotExponent"].location, light.spotExponent);
        if(light.spotCutoff != null)
          ctx.uniform1f(shader.uniforms["light${i}.spotCosCutoff"].location, light.spotCosCutoff);
      } else {
        shader.uniform(ctx, "light${i}.type", Light.NONE);
      }
    }
  }
  
  _drawMesh(Mesh mesh) {
    var shader = pass.shader;
    if(mesh.geometry != null) {
      var geometry = mesh.geometry;
      shader.attributes.forEach((semantic, attrib) {
        if(geometry.buffers.containsKey(semantic)) {
          var bufferView = geometry.buffers[semantic];
          bufferView.bindBuffer(ctx);
          ctx.enableVertexAttribArray(attrib.location);
          ctx.vertexAttribPointer(attrib.location, 
              bufferView.size, bufferView.type, bufferView.normalized, bufferView.stride, bufferView.offset);
        }
      });
    }
    if(mesh.material != null) {
      var material = mesh.material;
      if(mesh.material.texture != null) {
        ctx.activeTexture(gl.TEXTURE0);
        ctx.bindTexture(material.texture.target, material.texture.data);
        shader.uniform(ctx, "diffuse", 0);
      }
      shader.uniform(ctx, "shininess", material.shininess);
      shader.uniform(ctx, "specularColor", material.specularColor);
      shader.uniform(ctx, "ambientColor", material.ambientColor);
      shader.uniform(ctx, "diffuseColor", material.diffuseColor);
      shader.uniform(ctx, "emissiveColor", material.emissiveColor);
    }
    if(mesh.skeleton != null) {
      mesh.skeleton.updateMatrix();
      var jointMat = mesh.skeleton.jointMatrices;
      ctx.uniformMatrix4fv(shader.uniforms["uJointMat"].location, false, jointMat);
      shader.uniform(ctx, "uJointMat", jointMat);
    }
    if(mesh.faces != null) {
      mesh.faces.bindBuffer(ctx);
      ctx.drawElements(gl.TRIANGLES, mesh.faces.count, mesh.faces.type, mesh.faces.offset);
//      ctx.drawArrays(gl.LINE_STRIP, 0, mesh.geometry.buffers[Semantics.position].count);
    }
    mesh.children.forEach(_drawMesh);
  }
  
}























