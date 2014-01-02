part of orange;


class Resources {
  Map _storage;
  
  Resources() : _storage = new Map();
  
  void operator []=(String key, value) {
    _storage[key] = value;
  }
  operator [](String key) => _storage[key];
}