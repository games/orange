part of orange;

typedef void EventHandler<T>(trigger, [T data]);

class EventSubscription<T> {
  bool _canceled = false;
  bool _once = false;
  EventDispatcher<T> _eventDispatcher;
  EventHandler<T> _handler;
  EventSubscription(this._eventDispatcher, this._handler);

  void _invoke(trigger, T data) {
    if(data != null)
      _handler(trigger, data);
    else
      _handler(trigger);
    if(_once){
      _canceled = true;
      cancel();
    }
  }

  void cancel() {
    _eventDispatcher.cancel(this);
  }
}