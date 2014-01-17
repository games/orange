part of orange;

const int MAX_LIGHTS = 4;

class Renderer {
  html.CanvasElement canvas;
  gl.RenderingContext ctx;
  ModelCamera camera;
  double fov;
  Matrix4 projectionMatrix;
  Pass pass;
  Color backgroundColor = new Color.fromHex(0x84A6EE);
  List<Light> lights = [];
  
  Renderer(html.CanvasElement canvas, [bool flipTexture = false]) {
    this.canvas = canvas;
    ctx = canvas.getContext3d();
    camera = new ModelCamera(canvas);
    camera.distance = 4.0;
    camera.center = new Vector3.zero();
    fov = 45.0;
    projectionMatrix = new Matrix4.perspective(fov, canvas.width / canvas.height, 1.0, 4096.0);
    
    ctx.clearColor(backgroundColor.red, backgroundColor.green, backgroundColor.blue, backgroundColor.alpha);
    ctx.clearDepth(1.0);
    if(flipTexture) {
      ctx.pixelStorei(gl.UNPACK_FLIP_Y_WEBGL, 1);
    }
    
    pass = new Pass();
    pass.shader = new Shader(ctx, skinnedModelVS, skinnedModelFS);
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
    
    ctx.uniform3f(shader.uniforms["uLightPos"].location, 16, -32, 32);
    ctx.uniformMatrix4fv(shader.uniforms["uViewMat"].location, false, camera.viewMatrix.storage);
    ctx.uniformMatrix4fv(shader.uniforms["uModelMat"].location, false, mesh.worldMatrix.storage);
    ctx.uniformMatrix4fv(shader.uniforms["uProjectionMat"].location, false, projectionMatrix.storage);
    
    _setupLights(shader);
    _drawMesh(mesh);
    
    // TODO : should be disable all attributes and uniforms in the end draw.
  }
  
  _setupLights(Shader shader) {
    ctx.uniform3fv(shader.uniforms["cameraPosition"].location, camera.center.storage);
    for(var i = 0; i < MAX_LIGHTS; i++) {
      var lightSource = shader.uniforms["light$i"];
      if(i < lights.length) {
        var light = lights[i];
        ctx.uniform1i(shader.uniforms["light${i}.type"].location, light.type);
        ctx.uniform3fv(shader.uniforms["light${i}.direction"].location, light.direction.storage);
        ctx.uniform3fv(shader.uniforms["light${i}.color"].location, light.color.rgb.storage);
        ctx.uniform3fv(shader.uniforms["light${i}.position"].location, light.position.storage);
        ctx.uniform1f(shader.uniforms["light${i}.intensity"].location, light.intensity);
        ctx.uniform1f(shader.uniforms["light${i}.constantAttenuation"].location, light.constantAttenuation);
        ctx.uniform1f(shader.uniforms["light${i}.linearAttenuation"].location, light.linearAttenuation);
        ctx.uniform1f(shader.uniforms["light${i}.quadraticAttenuation"].location, light.quadraticAttenuation);
        if(light.spotExponent != null)
          ctx.uniform1f(shader.uniforms["light${i}.spotExponent"].location, light.spotExponent);
        if(light.spotCutoff != null)
          ctx.uniform1f(shader.uniforms["light${i}.spotCosCutoff"].location, light.spotCosCutoff);
      } else {
        ctx.uniform1i(shader.uniforms["light${i}.type"].location, Light.NONE);
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
          ctx.bindBuffer(gl.ARRAY_BUFFER, bufferView.buffer);
          ctx.enableVertexAttribArray(attrib.location);
          ctx.vertexAttribPointer(attrib.location, bufferView.size, bufferView.type, bufferView.normalized, bufferView.stride, bufferView.offset);
        }
      });
    }
    if(mesh.material != null && mesh.material.texture != null) {
      var material = mesh.material;
      ctx.activeTexture(gl.TEXTURE0);
      ctx.bindTexture(material.texture.target, material.texture.data);
      ctx.uniform1i(shader.uniforms["diffuse"].location, 0);
      ctx.uniform4fv(shader.uniforms["specularColor"].location, material.specularColor);
      ctx.uniform3fv(shader.uniforms["ambientColor"].location, material.ambientColor);
      ctx.uniform3fv(shader.uniforms["diffuseColor"].location, material.diffuseColor);
      ctx.uniform3fv(shader.uniforms["emissiveColor"].location, material.emissiveColor);
    }
    if(mesh.skeleton != null) {
      mesh.skeleton.updateMatrix();
      var jointMat = mesh.skeleton.jointMatrices;
      ctx.uniformMatrix4fv(shader.uniforms["uJointMat"].location, false, jointMat);
    }
    if(mesh.faces != null) {
      ctx.bindBuffer(gl.ELEMENT_ARRAY_BUFFER, mesh.faces.buffer);
      ctx.drawElements(gl.TRIANGLES, mesh.faces.count, mesh.faces.type, mesh.faces.offset);
    }
    mesh.children.forEach(_drawMesh);
  }
  
}























