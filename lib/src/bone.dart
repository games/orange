part of orange;


class Bone {
  int id;
  String name;
  Vector3 position;
  Quaternion rotation;
  Bone parent;
  List<Bone> children;
}