part of orange;



Matrix4 _newMatrix4FromSQT(List s, List r, List t) {
  var m = new Matrix4.zero();
  m.setFromTranslationRotation(new Vector3.fromFloat32List(new Float32List.fromList(t)), new Quaternion.fromFloat32List(new Float32List.fromList(r)));
  m.scale(s[0].toDouble(), s[1].toDouble(), s[2].toDouble());
  return m;
}

Matrix4 _newMatrix4FromList(List l) {
  var tl = new Float32List(l.length);
  for (var i = 0; i < l.length; i++) {
    tl[i] = l[i].toDouble();
  }
  return new Matrix4.fromFloat32List(tl);
}

_newVec3FromList(List l) {
  return new Vector3(l[0].toDouble(), l[1].toDouble(), l[2].toDouble());
}

Float32List _toFloat32List(List l) {
  var result = new Float32List(l.length);
  for (var i = 0; i < l.length; i++) result[i] = l[i].toDouble();
  return result;
}

Quaternion _newQuatFromEuler(List l) {
  var quat = new Quaternion.identity();
  quat.setEuler(l[0].toDouble(), l[1].toDouble(), l[2].toDouble());
  return quat;
}

Quaternion _newQuatFromList(List l) {
  return new Quaternion(l[0].toDouble(), l[1].toDouble(), l[2].toDouble(), l[3].toDouble());
}
