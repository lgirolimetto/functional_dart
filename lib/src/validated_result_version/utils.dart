import 'package:basic_functional_dart/basic_functional_dart.dart';
import 'package:basic_functional_dart/src/validated_result_version/internal_extensions.dart';

extension DurationExts on Duration {
  Future<void> delay() {
    return Future.delayed(this);
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
  Future<ValidatedResult<T>> retry({RetryStrategy rs = const LinearRetry(), String? errorMessage, int? internalErrorCode}) {
    return rs.nRetries
        .getActionIndexed(this)
        .fold(
          startInvalidResult(),
          (previousValue, tuple) => rs
                                    .delay(tuple.nTry)
                                    .then((_) => previousValue.orElseTry(tuple.action, errorMessage: errorMessage, internalErrorCode: internalErrorCode))
        );
  }
}

extension RetryStrategyOnFuture<T> on Future<T> Function() {
  Future<ValidatedResult<T>> retry({RetryStrategy rs = const LinearRetry(), String? errorMessage, int? internalErrorCode}) {
    return rs.nRetries
        .getActionIndexed(this)
        .fold(
          startInvalidResult(),
          (previousValue, tuple) => rs
                                      .delay(tuple.nTry)
                                      .then((_) => previousValue.orElseTryFuture(tuple.action, errorMessage: errorMessage, internalErrorCode: internalErrorCode))
        );
  }
}

extension RetryStrategyValidatedResult<T> on ValidatedResult<T> Function() {
  Future<ValidatedResult<T>> retry({RetryStrategy rs = const LinearRetry()}) {
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
  Future<ValidatedResult<T>> retry({RetryStrategy rs = const LinearRetry()}) {
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

extension RetryStrategyFunctionValidatedResult<T> on ValidatedResult<T Function()> {
  Future<ValidatedResult<T>> retry({RetryStrategy rs = const LinearRetry(), String? errorMessage, int? internalErrorCode}) {
    return fold(
      (failure) => failure.toInvalid<T>().toFuture(),
      (val) => val.retry(rs: rs, errorMessage: errorMessage, internalErrorCode: internalErrorCode)
    );
  }
}

extension RetryStrategyFunctionValidatedResultF<T> on ValidatedResult<Future<T> Function()> {
  Future<ValidatedResult<T>> retry({RetryStrategy rs = const LinearRetry(), String? errorMessage, int? internalErrorCode}) {
    return fold(
            (failure) => failure.toInvalid<T>().toFuture(),
            (val) => val.retry(rs: rs, errorMessage: errorMessage, internalErrorCode: internalErrorCode)
    );
  }
}

extension RetryStrategyFutureFunctionValidatedResult<T> on Future<ValidatedResult<T Function()>> {
  Future<ValidatedResult<T>> retry({RetryStrategy rs = const LinearRetry()}) {
    return foldFuture(
            (failure) => failure.toInvalid<T>().toFuture(),
            (val) => val.retry(rs: rs)
    );
  }
}

extension RetryStrategyFutureFunctionValidatedResultFF<T> on Future<ValidatedResult<Future<T> Function()>> {
  Future<ValidatedResult<T>> retry({RetryStrategy rs = const LinearRetry(), String? errorMessage, int? internalErrorCode}) {
    return foldFuture(
            (failure) => failure.toInvalid<T>().toFuture(),
            (val) => val.retry(rs: rs, errorMessage: errorMessage, internalErrorCode: internalErrorCode)
    );
  }
}