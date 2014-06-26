part of orange;




class RenderingGroup {
  Map<Pass, List<Mesh>> _transparentPasses = {};
  Map<Pass, List<Mesh>> _opaquePasses = {};

  void register(Mesh mesh) {
    var material = mesh.material;
    if (material == null) return;
    if (!material.ready(mesh)) return;
    var pass = material.technique.pass;
    if (pass.blending) {
      _registerTo(_transparentPasses, pass, mesh);
    } else {
      _registerTo(_opaquePasses, pass, mesh);
    }
  }

  void _registerTo(Map<Pass, List<Mesh>> passes, Pass pass, Mesh mesh) {
    if (!passes.containsKey(pass)) passes[pass] = [];
    passes[pass].add(mesh);
  }

  void unregister(Mesh mesh) {
    var material = mesh.material;
    if (material == null) return;
    _transparentPasses.remove(material.technique.pass);
    _opaquePasses.remove(material.technique.pass);
  }

  void clear() {
    _transparentPasses.clear();
    _opaquePasses.clear();
  }
}
