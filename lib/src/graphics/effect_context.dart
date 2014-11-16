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

class EffectContext {
  Camera camera;
  Node target;
  Mesh mesh;
  Material material;
  Pass pass;
  EffectParameter parameter;

  // TODO fix me!!!
  GetLights getLights = () {
    var lights = [];
    _findLights(Orange.instance.root, lights);
    return lights;
  };

  static void _findLights(Node node, List<Node> lights) {
    if (node.children != null) {
      node.children.forEach((c) {
        if (c.light != null) lights.add(c);
        _findLights(c, lights);
      });
    }
  }
}


typedef List<Node> GetLights();
