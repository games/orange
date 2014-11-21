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

class CubeGenerator {

  static Mesh create({num width: 1.0, num height: 1.0, num depth: 1.0}) {
    var w = width * 0.5;
    var h = height * 0.5;
    var d = depth * 0.5;

    var vertices = [],
        indices = [],
        texCoords = [];
    // Front
    vertices.addAll([w, h, d]);
    vertices.addAll([-w, h, d]);
    vertices.addAll([-w, -h, d]);
    vertices.addAll([w, -h, d]);
    // Back
    vertices.addAll([w, -h, -d]);
    vertices.addAll([-w, -h, -d]);
    vertices.addAll([-w, h, -d]);
    vertices.addAll([w, h, -d]);
    // Right
    vertices.addAll([w, -h, d]);
    vertices.addAll([w, -h, -d]);
    vertices.addAll([w, h, -d]);
    vertices.addAll([w, h, d]);
    // Left
    vertices.addAll([-w, h, d]);
    vertices.addAll([-w, h, -d]);
    vertices.addAll([-w, -h, -d]);
    vertices.addAll([-w, -h, d]);
    // Top
    vertices.addAll([w, h, d]);
    vertices.addAll([w, h, -d]);
    vertices.addAll([-w, h, -d]);
    vertices.addAll([-w, h, d]);
    // Bottom
    vertices.addAll([-w, -h, d]);
    vertices.addAll([-w, -h, -d]);
    vertices.addAll([w, -h, -d]);
    vertices.addAll([w, -h, d]);

    // Front
    texCoords.addAll([1.0, 0.0]);
    texCoords.addAll([0.0, 0.0]);
    texCoords.addAll([0.0, 1.0]);
    texCoords.addAll([1.0, 1.0]);

    // Back
    texCoords.addAll([0.0, 1.0]);
    texCoords.addAll([1.0, 1.0]);
    texCoords.addAll([1.0, 0.0]);
    texCoords.addAll([0.0, 0.0]);

    // Right
    texCoords.addAll([0.0, 1.0]);
    texCoords.addAll([1.0, 1.0]);
    texCoords.addAll([1.0, 0.0]);
    texCoords.addAll([0.0, 0.0]);

    // Left
    texCoords.addAll([1.0, 0.0]);
    texCoords.addAll([0.0, 0.0]);
    texCoords.addAll([0.0, 1.0]);
    texCoords.addAll([1.0, 1.0]);

    // Top
    texCoords.addAll([1.0, 1.0]);
    texCoords.addAll([1.0, 0.0]);
    texCoords.addAll([0.0, 0.0]);
    texCoords.addAll([0.0, 1.0]);

    // Bottom
    texCoords.addAll([0.0, 0.0]);
    texCoords.addAll([0.0, 1.0]);
    texCoords.addAll([1.0, 1.0]);
    texCoords.addAll([1.0, 0.0]);

    indices.addAll(
        [
            0,
            1,
            2,
            0,
            2,
            3,
            4,
            5,
            6,
            4,
            6,
            7,
            8,
            9,
            10,
            8,
            10,
            11,
            12,
            13,
            14,
            12,
            14,
            15,
            16,
            17,
            18,
            16,
            18,
            19,
            20,
            21,
            22,
            20,
            22,
            23]);

    var mesh = new Mesh();
    mesh.vertices = vertices;
    mesh.texCoords = texCoords;
    mesh.indices = indices;
    mesh.computeNormals();
    return mesh;
  }
  
}