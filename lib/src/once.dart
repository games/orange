part of orange;


class Once {
  bool _executed;
  Function _task;

  Once(this._task): _executed = false;

  execute() {
    if (!_executed) {
      _executed = true;
      _task();
    }
  }

  reset() => _executed = false;
}
