part of orange;



class OnlyOnce {
  bool _executed;
  Function _task;
  
  OnlyOnce(this._task) : _executed = false;
  
  execute() {
    if(!_executed) _task();
    _executed = true;
  }
  
  reset() => _executed = false;
}