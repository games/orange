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
  DataProvider _provider;

  @override
  void onStart() {
    _provider = new DataProvider();
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
    var orange = Orange.instance;
    var graphics = orange.graphicsDevice;
    var camera = orange.mainCamera.camera;

    if (!pass.bind(graphics)) return;
    
    _provider.camera = camera;
    _provider.material = material;
    _provider.mesh = mesh;
    _provider.pass = pass;
    _provider.target = _target;

    var effect = pass.effect;
    // set uniforms
    effect.uniforms.forEach((String name, EffectParameter parameter) {
      parameter.bind(graphics, _provider);
    });

    // set attributes
    effect.attributes.forEach((String name, EffectParameter parameter) {
      parameter.bind(graphics, _provider);
    });

    // bind indices
    mesh.indexBuffer.upload(graphics);

    if (material.wireframe) {
      graphics.drawLines(mesh.vertexBuffer.numVertices);
    } else {
      graphics.drawTriangles(mesh.indexBuffer);
    }

    pass.unbind();
  }
}
