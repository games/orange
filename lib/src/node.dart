// Copyright (c) 2014, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

part of orange;



class Node {
  String name;
  Node root;
  Node parent;
  List<Node> children;
  bool enabled;
  bool visible;

  List<Component> components;

  Transform _transform;
  Transform get transform => _transform;

  Camera _camera;
  Camera get camera => _camera;

  Light _light;
  Light get light => _light;

  MeshFilter _meshFilter;
  MeshFilter get meshFilter => _meshFilter;

  MeshRenderer _renderer;
  MeshRenderer get renderer => _renderer;

  Node(this.name, {this.visible: true, this.enabled: true});

  initialize() {
    if (components != null) components.forEach((c) => c.start());
    if (children != null) children.forEach((c) => c.initialize());
  }

  update(GameTime time) {
    if (components != null) components.forEach((c) => c.update(time));
    if (children != null) children.forEach((c) => c.update(time));
  }

  render() {
    if(!visible) return;
    if(_renderer != null) renderer.render();
    if (children != null) children.forEach((c) => c.render());
  }

  void addChild(Node child) {
    if (children == null) children = [];

    children.add(child);
    child.removeFromParent();
    child.root = root == null ? this : root;
    child.parent = this;
  }

  void removeFromParent() {
    if (parent != null) {
      parent.removeChild(this);
    }
  }

  void removeChild(Node child) {
    if (child.parent != this || children != null) return;
    children.remove(child);
    _removeChild(child);
  }

  void removeChildren() {
    if (children != null) {
      children.forEach(_removeChild);
      children.clear();
    }
  }

  void _removeChild(Node child) {
    child.root = null;
    child.parent = null;
  }

  bool contains(Node child) {
    if (children != null) return children.contains(child);
    return false;
  }

  void addComponent(Component component) {
    _setSpecialComponent(component, component);
    components.add(component);
    component.attached(this);
  }

  void removeComponent(Component component) {
    if (!components.contains(component)) throw new Exception("This component is not belong the node");
    _setSpecialComponent(component, null);
    components.remove(component);
    component.detached(this);
  }

  void _setSpecialComponent(Component component, value) {
    if (component is MeshFilter) {
      _meshFilter = value;
    } else if (component is MeshRenderer) {
      _renderer = value;
    } else if (component is Transform) {
      _transform = value;
    } else if (component is Camera) {
      _camera = value;
    } else if (component is Light) {
      _light = value;
    }
  }

  Component findComponent(Type t) => components.firstWhere((c) => c.runtimeType == t, orElse: () => null);

  bool hasComponent(Component component) => components.contains(component);

}
