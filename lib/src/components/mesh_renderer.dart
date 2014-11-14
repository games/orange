// Copyright (c) 2014, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

part of orange;


class MeshRenderer extends Component {

  @override
  void start() {
    // TODO: implement start
  }

  @override
  void update(GameTime time) {
    // TODO: implement update
  }

  void render() {
    if (_target.meshFilter == null || 
        _target.meshFilter.sharedMesh == null || 
        _target.meshFilter.sharedMesh.materials == null) return;

    var mesh = _target.meshFilter.sharedMesh;
    mesh.materials.forEach((m) => m.shader.technique.passes.forEach((p) => _renderInternal(mesh, m, p)));
  }

  void _renderInternal(Mesh mesh, Material material, Pass pass) {
    var graphicsDevice = Orange.instance.graphicsDevice;
    
    pass.bind();
    
    // set uniforms

    // set attributes
    pass.effect.attributes.forEach((String name, ProgramInput input) {
      
    });
    
    // bind indices
    mesh._indexBuffer.upload(graphicsDevice);
    
    if(material.wireframe) {
      graphicsDevice.drawLines();
    } else {
      graphicsDevice.drawTriangles(mesh._indexBuffer);
    }

    pass.unbind();
  }
}
