part of orange;


class Sampler {
  int _magFilter;
  int _minFilter;
  int _wrapS;
  int _wrapT;
  
  set magFilter(int val) => _magFilter = val == null ? gl.LINEAR : val; 
  int get magFilter => _magFilter;
  
  set minFilter(int val) => _minFilter = val == null ? gl.LINEAR : val;
  int get minFilter => _minFilter;
  
  set wrapS(int val) => _wrapS = val == null ? gl.REPEAT : val;
  int get wrapS => _wrapS;
  
  set wrapT(int val) => _wrapT = val == null ? gl.REPEAT : val;
  int get wrapT => _wrapT;
}




