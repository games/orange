part of orange;




class RenderingGroup {
  Map<Pass, List<Mesh>> _meshesPerPass = {};

  void register(Mesh mesh) {
    var material = mesh.material;
    if (material == null) return;
    if(!material.ready(mesh)) return;
    if (!_meshesPerPass.containsKey(material.technique.pass)) _meshesPerPass[material.technique.pass] = [];
    _meshesPerPass[material.technique.pass].add(mesh);
  }

  void unregister(Mesh mesh) {
    var material = mesh.material;
    if (material == null) return;
    _meshesPerPass.remove(material.technique.pass);
  }

  void clear() {
    _meshesPerPass.clear();
  }
}
