module orange {
  export class Mesh {
    vertexBuffer: VertexBuffer;
    indexBuffer: IndexBuffer;
    primitive: any[];
    skin;
    aabb;
    boneAabb;

    constructor() {
      this.primitive = [{
            type: 0,
            base: 0,
            count: 0
        }];
    }
  }

  export class MeshInstance {
    mesh: Mesh;
    material;

    constructor() {}
  }
}
