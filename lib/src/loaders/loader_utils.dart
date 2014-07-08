part of orange;



Matrix4 _newMatrix4FromSQT(List scale, List quaternion, List translation) {
  var m = new Matrix4.zero();
  m.setFromTranslationRotation(_newVec3FromList(translation), _newQuatFromAxisAngle(quaternion));
  m.scale(scale[0].toDouble(), scale[1].toDouble(), scale[2].toDouble());
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

Quaternion _newQuatFromAxisAngle(List l) {
  return new Quaternion.axisAngle(_newVec3FromList(l), l[3].toDouble());
}

Quaternion _newQuatFromEuler(List l) {
  var quat = new Quaternion.identity();
  quat.setEuler(l[0].toDouble(), l[1].toDouble(), l[2].toDouble());
  return quat;
}

Quaternion _newQuatFromList(List l) {
  return new Quaternion(l[0].toDouble(), l[1].toDouble(), l[2].toDouble(), l[3].toDouble());
}
