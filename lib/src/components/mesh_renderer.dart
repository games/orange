/*
  Orange : Simplified BSD License

  Copyright (c) 2014, Valor Zhong
  All rights reserved.
  
  Redistribution and use in source and binary forms, with or without modification, are permitted provided that the 
  following conditions are met:
  
  1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following 
     disclaimer.
    
  2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the 
     following disclaimer in the documentation and/or other materials provided with the distribution.
  
  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, 
  INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE 
  DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, 
  SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR 
  SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, 
  WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE 
  OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
  
 */

part of orange;


class MeshRenderer extends Component {
  
  List<Material> materials;

  @override
  void onStart() {
    // TODO: implement start
  }

  @override
  void onUpdate(GameTime time) {
    // TODO: implement update
  }

  void render() {
    if (materials == null ||
        _target.meshFilter == null ||
        _target.meshFilter.sharedMesh == null) return;

    var mesh = _target.meshFilter.sharedMesh;
    materials.forEach((m) => m.shader.technique.passes.forEach((p) => _renderInternal(mesh, m, p)));
  }

  void _renderInternal(Mesh mesh, Material material, Pass pass) {
    var graphicsDevice = Orange.instance.graphicsDevice;
    var camera = Orange.instance.mainCamera.camera;

    if (!pass.bind(graphicsDevice)) return;

    var effect = pass.effect;
    // set uniforms
    effect.uniforms.forEach((String name, EffectParameter parameter) {
      if (parameter.semantic == VertexFormat.WORLD_VIEW_PROJECTION) {
        graphicsDevice.setMatrix4(
            parameter.location,
            camera.projectionMatrix * camera.viewMatrix * _target.transform.worldMatrix);
      }
    });

    // set attributes
    effect.attributes.forEach((String name, EffectParameter parameter) {
      var buffer = mesh._buffers[parameter.semantic];
      buffer.upload(graphicsDevice);
      buffer.enable(graphicsDevice, parameter);
    });

    // bind indices
    mesh.indexBuffer.upload(graphicsDevice);

    if (material.wireframe) {
      graphicsDevice.drawLines(mesh.vertexBuffer.numVertices);
    } else {
      graphicsDevice.drawTriangles(mesh.indexBuffer);
    }

    pass.unbind();
  }
}
