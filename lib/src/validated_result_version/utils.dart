import 'package:basic_functional_dart/basic_functional_dart.dart';

extension DurationExts on Duration {
  Future<void> delay() {
    return Future.delayed(this);
  }
}

extension _IntToListOfInt on int {
  List<int> toList() => [for (var i = 1; i <= this; i++) i];

  Iterable<({int nTry, T Function() action})> getActionIndexed<T>(T Function() action) {
    return toList()
        .map((i) => (nTry: i, action: action));
  }
}

Future<ValidatedResult<T>> startInvalidResult<T>() => Failure.withError(Error()).toInvalid<T>().toFuture();

extension RetryDelayCalc on RetryStrategy {
  Future delay(int nTry) {
    switch(this) {
      case IncrementalRetry ir:
        final calcIncremental = ir.calcIncremental ?? (initialDelay, nTry) {
          return Duration(milliseconds: initialDelay.inMilliseconds * nTry);
        };

        return calcIncremental(ir.delayDuration, nTry).delay();
      case LinearRetry lr:
        return lr.delayDuration.delay();
    }
  }
}


extension RetryStrategyExt<T> on T Function() {
  Future<ValidatedResult<T>> retry(RetryStrategy rs) {
    return rs.nRetries
        .getActionIndexed(this)
        .fold(
          startInvalidResult(),
          (previousValue, tuple) => rs
                                    .delay(tuple.nTry)
                                    .then((_) => previousValue.orElseTry(tuple.action))
        );
  }
}

extension RetryStrategyOnFuture<T> on Future<T> Function() {
  Future<ValidatedResult<T>> retry(RetryStrategy rs) {
    return rs.nRetries
        .getActionIndexed(this)
        .fold(
          startInvalidResult(),
          (previousValue, tuple) => rs
                                      .delay(tuple.nTry)
                                      .then((_) => previousValue.orElseTryFuture(tuple.action))
        );
  }
}

extension RetryStrategyValidatedResult<T> on ValidatedResult<T> Function() {
  Future<ValidatedResult<T>> retry(RetryStrategy rs) {
    return rs.nRetries
        .getActionIndexed(this)
        .fold(
          startInvalidResult(),
          (previousValue, tuple) => rs
                                      .delay(tuple.nTry)
                                      .then((_) => previousValue.orElseBind(tuple.action))
        );
  }
}

extension RetryStrategyValidatedResultFuture<T> on Future<ValidatedResult<T>> Function() {
  Future<ValidatedResult<T>> retry(RetryStrategy rs) {
    return rs.nRetries
        .getActionIndexed(this)
        .fold(
            startInvalidResult(),
            (previousValue, tuple) => rs
                                        .delay(tuple.nTry)
                                        .then((value) => previousValue.orElseBindFuture(tuple.action))
        );
  }
}