abstract class Clock {
  DateTime now();
}

class SystemClock implements Clock {
  const SystemClock();

  @override
  DateTime now() => DateTime.now().toUtc();
}

class FixedClock implements Clock {
  final DateTime _fixedInstant;

  FixedClock(this._fixedInstant);

  @override
  DateTime now() => _fixedInstant.toUtc();
}