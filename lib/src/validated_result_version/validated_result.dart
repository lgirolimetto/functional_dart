import 'package:basic_functional_dart/basic_functional_dart.dart';

/// Lift [value] to a valid ValidatedResult
ValidatedResult<T> ValidResult<T>(T value) => ValidatedResult._valid(value);

/// Lift [failure] to an invalid ValidatedResult.
/// Remember to specify the generic type like InvalidResult<double>.
ValidatedResult<T> InvalidResult<T>(Failure failure) => ValidatedResult._invalid(failure);

class ValidatedResult<T> {
  final Failure? _failure;
  final T? _value;
  bool get isValid => _failure == null;

  const ValidatedResult._valid(T value)
      : _value = value,
        _failure = null;

  const ValidatedResult._invalid(Failure failure)
      : _failure = failure,
        _value = null;

  /// Use [fold] to extract the result or the [Failure]
  TR fold<TR>(TR Function(Failure failure) invalid,
              TR Function(T val) valid) 
  {
    return isValid ? valid(_value!) : invalid(_failure!);
  }
      
  /// Extract valid result as an Iterable of one element
  Iterable<T> asIterable() sync* {
    if (isValid) {
      yield _value!;
    }
  }

  /// Extract failure as an Iterable of one element
  Iterable<Failure> asFailIterable() sync* {
    if (!isValid) {
      yield _failure!;
    }
  }

  bool forAll(bool Function(T t) f) => fold((fail) => true, (valid) => f(valid));
  bool exists(bool Function(T t) f) => fold((fail) => false, (valid) => f(valid));
  bool contains(T t) => fold((fail) => false, (valid) => valid == t);

  Option<T> where(bool Function(T t) f) => fold((invalid) => Option.none(),
          (valid) => f(valid) ? Some(valid) : None<T>());


  /// [orElse] allow to work outside ValidatedResult Abstraction and
  /// returns [defaultVal] if the previous result is a [Failure]
  T orElse(T defaultVal) => fold((invalid) => defaultVal, (some) => some);

  /// Like [orElse] but calls a fallback
  T orElseDo(T Function() fallback) =>
      fold((invalid) => fallback(), (some) => some);

  /// Use [orElseMap] to call a non fallible fallback when the previous result is a [Failure]
  ValidatedResult<T> orElseMap(T Function() f) =>
      fold((invalid) => ValidResult(f()), (some) => this);

  /// Use [orElseBind] to call a validated fallback when the previous result is a [Failure]
  ValidatedResult<T> orElseBind(ValidatedResult<T> Function() f) =>
      fold((invalid) => f(), (some) => this);

  /// Use [orElseMapFuture] to call a non fallible fallback that returns a [Future] when the previous result is a [Failure]
  Future<ValidatedResult<T>> orElseMapFuture(Future<T> Function() f) =>
      fold((invalid) => f().then((value) => ValidResult(value)), (valid) => Future.value(ValidResult(valid)));

  /// Use [orElseMapFuture] to call a validated fallback that returns a [Future<ValidatedResult>] when the previous result is a [Failure]
  Future<ValidatedResult<T>> orElseBindFuture(Future<ValidatedResult<T>> Function() fallback) =>
      fold((invalid) => fallback(), (valid) => Future.value(ValidResult(valid)));

  /// Use [orElseTry] to try a fallback when the previous result is a [Failure]
  /// [orElseTry] functions do not need map or bind: function [f] is always considered to be fallible
  ValidatedResult<T> orElseTry(T Function() f, {String? errorMessage, int? internalErrorCode}) =>
      fold((invalid) => f.try_(errorMessage: errorMessage, internalErrorCode: internalErrorCode), (some) => this);

  /// Use [orElseTryFuture] to try a fallback and the fallback returns a [Future]. Otherwise use [orElseTry]
  Future<ValidatedResult<T>> orElseTryFuture(Future<T> Function() f, {String? errorMessage, int? internalErrorCode}) =>
      fold((invalid) => f.try_(errorMessage: errorMessage, internalErrorCode: internalErrorCode), (some) => this.toValidFuture_());

  /// Use [orElseRetry] to retry a fallback when the previous result is a [Failure]
  Future<ValidatedResult<T>> orElseRetry(T Function() fallback, {RetryStrategy rs = const LinearRetry(), String? errorMessage, int? internalErrorCode}) =>
      fold(
        (failure) => fallback.retry(rs: rs),
        (val) => this.toFuture()
      );

  /// Use [orElseRetryFuture] to retry a fallback and the fallback returns a [Future]
  Future<ValidatedResult<T>> orElseRetryFuture(Future<T> Function() fallback, {RetryStrategy rs = const LinearRetry(), String? errorMessage, int? internalErrorCode}) =>
      fold(
        (failure) => fallback.retry(rs: rs),
        (val) => this.toFuture()
      );

  /// Use [map] to chain a function that do not return a Future and cannot fail
  ValidatedResult<R> map<R>(R Function(T val) f) =>
      fold((err) => InvalidResult<R>(err), (v) => ValidResult(f(v)));

  /// Use [mapFuture] to chain a function that return a Future and cannot fail
  Future<ValidatedResult<R>> mapFuture<R>(Future<R> Function(T val) f) =>
      fold((err) => InvalidResult<R>(err).toFuture(), (v) => f(v).then((value) => ValidResult(value)));

  ValidatedResult<void> forEach(void Function(T val) action) => map(action);

  ValidatedResult<T> andThen(void Function(T t) action) {
    forEach(action);
    return this;
  }

  /// Use [bind] to chain a function that return a [ValidatedResult]
  ValidatedResult<R> bind<R>(ValidatedResult<R> Function(T val) f) =>
      fold((fails) => fails.toInvalid(), (v) => f(v));

  /// Use [bindFuture] to chain a function that return a Future<[ValidatedResult]>
  Future<ValidatedResult<R>> bindFuture<R>(Future<ValidatedResult<R>> Function(T val) f) =>
      fold((fails) => fails.toInvalid<R>().toFuture(), (v) => f(v));

  /// Use [try_] to chain a function that do not return a Future and that can fail
  ValidatedResult<R> try_<R>(R Function(T val) f, {String? errorMessage, int? internalErrorCode}) =>
      fold((fails) => fails.toInvalid<R>(), (v) => (() => f(v)).try_(errorMessage: errorMessage, internalErrorCode: internalErrorCode));

  /// Use [tryFuture] to chain a function that return a Future can fail
  Future<ValidatedResult<R>> tryFuture<R>(Future<R> Function(T val) f, {String? errorMessage, int? internalErrorCode}) =>
      fold((fails) => fails.toInvalid<R>().toFuture(), (v) => (() => f(v)).try_(errorMessage: errorMessage, internalErrorCode: internalErrorCode));

  /// Retry the function [f] as per [RetryStrategy]
  Future<ValidatedResult<R>> retry<R>(R Function(T) f, {RetryStrategy rs = const LinearRetry(), String? errorMessage, int? internalErrorCode}) {
    return bindFuture((val) => f.apply(val).retry(rs: rs, errorMessage: errorMessage, internalErrorCode: internalErrorCode));
  }

  /// Retry the function [f] as per [RetryStrategy]
  Future<ValidatedResult<R>> retryFuture<R>(Future<R> Function(T) f, {RetryStrategy rs = const LinearRetry(), String? errorMessage, int? internalErrorCode}) {
    return bindFuture((val) => f.apply(val).retry(rs: rs, errorMessage: errorMessage, internalErrorCode: internalErrorCode));
  }

  Future<ValidatedResult<T>> toFuture() => Future(() => this);

  Option<T> toOption() => isValid ? Some(_value!) : None<T>();
}

extension FunctionalsValidationExt on Object {
  Future<ValidatedResult<T>> toValidFuture_<T>() => ValidResult<T>(this as T).toFuture();
}

extension FutureValidatedResult<T> on Future<ValidatedResult<T>> {
  /// Extract [failure] or [valid] for a Future<ValidatedResult>>
  Future<TR> fold<TR>(TR Function(Failure failure) invalid,
              TR Function(T val) valid) 
  {
    return then(
            (value) => 
              value.fold(
                (failure) => invalid(failure),
                (val) => valid(val)));
  }

  /// Retry the function [f] as per [RetryStrategy] [rs]
  Future<ValidatedResult<R>> retry<R>(R Function(T) f, {RetryStrategy rs = const LinearRetry(), String? errorMessage, int? internalErrorCode}) {
    return then((value) => value.retry(f, rs: rs, errorMessage: errorMessage, internalErrorCode: internalErrorCode));
  }

  Future<ValidatedResult<R>> retryFuture<R>(Future<R> Function(T) f, {RetryStrategy rs = const LinearRetry(), String? errorMessage, int? internalErrorCode}) {
    return then((value) => value.retryFuture(f, rs: rs, errorMessage: errorMessage, internalErrorCode: internalErrorCode));
  }

  Future<T> orElse(T defaultVal) =>
      fold((invalid) => defaultVal, (valid) => valid);

  Future<T> orElseDo(T Function() fallback) =>
      fold((invalid) => fallback(), (valid) => valid);

  Future<T> orElseDoFuture(Future<T> Function() fallback) =>
      foldFuture((invalid) => fallback(), (valid) => Future.value(valid));

  Future<ValidatedResult<T>> orElseMap(T defaultVal) =>
      fold((invalid) => ValidResult(defaultVal), (valid) => ValidResult(valid));

  Future<ValidatedResult<T>> orElseMapFuture(Future<T> defaultVal) =>
      foldFuture((invalid) => defaultVal.then((value) => ValidResult(value)), (val) => ValidResult(val).toFuture());

  Future<ValidatedResult<T>> orElseBind(ValidatedResult<T> Function() fallback) =>
      fold((invalid) => fallback(), (valid) => ValidResult(valid));

  Future<ValidatedResult<T>> orElseBindFuture(Future<ValidatedResult<T>> Function() fallback) =>
      foldFuture((invalid) => fallback(), (valid) => Future.value(ValidResult(valid)));

  Future<ValidatedResult<T>> orElseTry(T Function() fallback, {String? errorMessage, int? internalErrorCode}) =>
      fold((invalid) => fallback.try_(errorMessage: errorMessage, internalErrorCode: internalErrorCode), (valid) => ValidResult(valid));

  Future<ValidatedResult<T>> orElseTryFuture(Future<T> Function() fallback, {String? errorMessage, int? internalErrorCode}) =>
      foldFuture((invalid) => fallback.try_(errorMessage: errorMessage, internalErrorCode: internalErrorCode), (valid) => Future.value(ValidResult(valid)));

  /// Use [orElseRetry] to retry a fallback when the previous result is a [Failure]
  Future<ValidatedResult<T>> orElseRetry(T Function() fallback, {RetryStrategy rs = const LinearRetry(), String? errorMessage, int? internalErrorCode}) =>
      then((value) => value.orElseRetry(fallback, rs: rs, errorMessage: errorMessage, internalErrorCode: internalErrorCode));

  /// Use [orElseRetryFuture] to retry a fallback that returns a [Future] when the previous result is a [Failure]
  Future<ValidatedResult<T>> orElseRetryFuture(Future<T> Function() fallback, {RetryStrategy rs = const LinearRetry(), String? errorMessage, int? internalErrorCode}) =>
    then((value) => value.orElseRetryFuture(fallback, rs: rs, errorMessage: errorMessage, internalErrorCode: internalErrorCode));

  /// Use [map] to chain a function that do not return a Future and cannot fail
  Future<ValidatedResult<R>> map<R>(R Function(T t) f) =>
      fold((err) => InvalidResult<R>(err), (v) => ValidResult(f(v)));

  /// Use [bind] to chain a function that return a [ValidatedResult]
  Future<ValidatedResult<R>> bind<R>(ValidatedResult<R> Function(T t) f) =>
      fold((fail) => InvalidResult<R>(fail), (v) => f(v));

  /// Use [try_] to chain a function that do not return a Future and that can fail
  Future<ValidatedResult<R>> try_<R>(R Function(T t) f, {String? errorMessage, int? internalErrorCode}) =>
      fold((fail) => InvalidResult<R>(fail), (v) => (() => f(v)).try_(errorMessage: errorMessage, internalErrorCode: internalErrorCode));

  /// Use [foldFuture] to extract the result or the [Failure] and return a [Future]
  Future<TR> foldFuture<TR>(Future<TR> Function(Failure failure) invalid,
                                                  Future<TR> Function(T val) valid) 
  {
    
    return then((value) => value.fold((failure) => invalid(failure).then((value) => value),
                                      (val)       => valid(val).then((value) => value)));
  }


  Future<ValidatedResult<R>> mapFuture<R>(Future<R> Function(T t) f) =>
      foldFuture((err) => InvalidResult<R>(err).toFuture(),
                 (v)   => f(v).then((value) => ValidResult(value)));

  Future<ValidatedResult<R>> bindFuture<R>(Future<ValidatedResult<R>> Function(T t) f) =>
      foldFuture((fail) => InvalidResult<R>(fail).toFuture(), (v) => f(v));

  Future<ValidatedResult<R>> tryFuture<R>(Future<R> Function(T t) f, {String? errorMessage, int? internalErrorCode}) =>
      foldFuture((fail) => InvalidResult<R>(fail).toFuture(), (v) => (() => f(v)).try_(errorMessage: errorMessage, internalErrorCode: internalErrorCode));
}

extension OrElseFunction<T> on T Function() {
  /// Use [orElseTry] to use a fallback when the previous result is a [Failure]
  ValidatedResult<T> orElseTry(T Function() fallback, {String? errorMessage, int? internalErrorCode}) =>
      this.try_(errorMessage: errorMessage, internalErrorCode: internalErrorCode)
          .orElseTry(() => fallback(), errorMessage: errorMessage, internalErrorCode: internalErrorCode);


  /// Use [orElseTryFuture] to use a fallback when the previous result is a [Failure]
  /// and the fallback returns a [Future]
  Future<ValidatedResult<T>> orElseTryFuture(Future<T> Function() fallback, {String? errorMessage, int? internalErrorCode}) =>
      this.try_(errorMessage: errorMessage, internalErrorCode: internalErrorCode)
          .orElseTryFuture(fallback, errorMessage: errorMessage, internalErrorCode: internalErrorCode);

  /// Use [orElseRetry] to retry a fallback when the previous result is a [Failure]
  Future<ValidatedResult<T>> orElseRetry(T Function() fallback, {RetryStrategy? rs, String? errorMessage, int? internalErrorCode}) =>
      this.try_(errorMessage: errorMessage, internalErrorCode: internalErrorCode)
          .orElseRetry(fallback, rs: rs ?? const LinearRetry(), errorMessage: errorMessage, internalErrorCode: internalErrorCode);

  /// Use [orElseRetryFuture] to retry a fallback when the previous result is a [Failure]
  /// and the fallback returns a [Future]
  Future<ValidatedResult<T>> orElseRetryFuture(Future<T> Function() fallback, {RetryStrategy? rs, String? errorMessage, int? internalErrorCode}) =>
      this.try_(errorMessage: errorMessage, internalErrorCode: internalErrorCode)
          .orElseRetryFuture(fallback, rs: rs ?? const LinearRetry(), errorMessage: errorMessage, internalErrorCode: internalErrorCode);
}

extension OrElseFutureFunction<T> on Future<T> Function() {
  /// Use [orElseTry] to use a fallback when the previous result is a [Failure]
  Future<ValidatedResult<T>> orElseTry(T Function() fallback, {String? errorMessage, int? internalErrorCode}) =>
      this.try_(errorMessage: errorMessage, internalErrorCode: internalErrorCode)
          .orElseTry(fallback, errorMessage: errorMessage, internalErrorCode: internalErrorCode);


  /// Use [orElseTryFuture] to use a fallback when the previous result is a [Failure]
  /// and the fallback returns a [Future]
  Future<ValidatedResult<T>> orElseTryFuture(Future<T> Function() fallback, {String? errorMessage, int? internalErrorCode}) =>
      this.try_(errorMessage: errorMessage, internalErrorCode: internalErrorCode)
          .orElseTryFuture(fallback, errorMessage: errorMessage, internalErrorCode: internalErrorCode);

  /// Use [orElseRetry] to retry a fallback when the previous result is a [Failure]
  Future<ValidatedResult<T>> orElseRetry(T Function() fallback, {RetryStrategy rs = const LinearRetry(), String? errorMessage, int? internalErrorCode}) =>
      this.try_(errorMessage: errorMessage, internalErrorCode: internalErrorCode)
          .orElseBindFuture(() => fallback.retry(rs: rs, errorMessage: errorMessage, internalErrorCode: internalErrorCode));


  /// Use [orElseRetryFuture] to retry a fallback when the previous result is a [Failure]
  /// and the fallback returns a [Future]
  Future<ValidatedResult<T>> orElseRetryFuture(Future<T> Function() fallback, {RetryStrategy rs = const LinearRetry(), String? errorMessage, int? internalErrorCode}) =>
      this.try_(errorMessage: errorMessage, internalErrorCode: internalErrorCode)
          .orElseBindFuture(() => fallback.retry(rs: rs, errorMessage: errorMessage, internalErrorCode: internalErrorCode));
}

extension OrElseFutureValidatedFunction<T> on Future<ValidatedResult<T>> Function() {
  /// Use [orElseTry] to use a fallback when the previous result is a [Failure]
  Future<ValidatedResult<T>> orElseTry(T Function() fallback, {String? errorMessage, int? internalErrorCode}) =>
      this().orElseTry(fallback, errorMessage: errorMessage, internalErrorCode: internalErrorCode);


  /// Use [orElseTryFuture] to use a fallback when the previous result is a [Failure]
  /// and the fallback returns a [Future]
  Future<ValidatedResult<T>> orElseTryFuture(Future<T> Function() fallback, {String? errorMessage, int? internalErrorCode}) =>
      this().orElseTryFuture(fallback, errorMessage: errorMessage, internalErrorCode: internalErrorCode);

  /// Use [orElseRetry] to retry a fallback when the previous result is a [Failure]
  Future<ValidatedResult<T>> orElseRetry(T Function() fallback, {RetryStrategy rs = const LinearRetry(), String? errorMessage, int? internalErrorCode}) =>
      this().orElseBindFuture(() => fallback.retry(rs: rs, errorMessage: errorMessage, internalErrorCode: internalErrorCode));


  /// Use [orElseRetryFuture] to retry a fallback when the previous result is a [Failure]
  /// and the fallback returns a [Future]
  Future<ValidatedResult<T>> orElseRetryFuture(Future<T> Function() fallback, {RetryStrategy rs = const LinearRetry(), String? errorMessage, int? internalErrorCode}) =>
      this().orElseBindFuture(() => fallback.retry(rs: rs, errorMessage: errorMessage, internalErrorCode: internalErrorCode));
}