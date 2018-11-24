import 'package:rxdart/rxdart.dart';

/// A typical property of some bloc logic that can be set and read, but also
/// provides a stream to listen for changes to the value.
/// That's very handy for Flutter's reactive UI.
/// 
/// # Usage:
/// 
/// In this example, the game state can be set and read by other classes, and
/// other classes can also retrieve a stream of the value.
/// 
/// ```dart
/// StreamedProperty<GameState> _state = StreamedProperty(initial: GameState.RUNNING);
/// GameState get state => _state.value;
/// set state(GameState state) => _state.value = state;
/// get stateStream => _state.stream;
/// ```
class StreamedProperty<T> {
  StreamedProperty({ T initial }) :
    _value = initial,
    _subject = BehaviorSubject<T>(seedValue: initial);

  T _value;
  T get value => _value;
  set value(T newValue) {
    _value = newValue;
    _subject.add(_value);
  }

  BehaviorSubject _subject;
  ValueObservable<T> get stream => _subject.stream; // TODO: .distinct()

  void dispose() {
    _subject.close();
  }
}
