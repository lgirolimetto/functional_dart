import 'package:basic_functional_dart/basic_functional_dart.dart';

ValidatedResult<T> ValidResult<T>(T value) => ValidatedResult.valid(value);
ValidatedResult<T> InvalidResult<T>(Failure failure) => ValidatedResult.invalid(failure);

class ValidatedResult<T> {
  final Failure? _failure;
  final T? _value;
  bool get isValid => _failure == null;

  const ValidatedResult.valid(T value)
      : _value = value,
        _failure = null;

  const ValidatedResult.invalid(Failure failure)
      : _failure = failure,
        _value = null;

  TR fold<TR>(TR Function(Failure failure) invalid,
              TR Function(T val) valid) 
  {
    return isValid ? valid(_value!) : invalid(_failure!);
  }
      

  Iterable<T> asIterable() sync* {
    if (isValid) {
      yield _value!;
    }
  }

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


  T orElse(T defaultVal) => fold((invalid) => defaultVal, (some) => some);

  T orElseDo(T Function() fallback) =>
      fold((invalid) => fallback(), (some) => some);

  ValidatedResult<T> orElseMap(T Function() f) =>
      fold((invalid) => ValidResult(f()), (some) => this);

  ValidatedResult<T> orElseBind(ValidatedResult<T> Function() f) =>
      fold((invalid) => f(), (some) => this);

  Future<ValidatedResult<T>> orElseMapFuture(Future<T> Function() f) =>
      fold((invalid) => f().then((value) => ValidResult(value)), (valid) => Future.value(ValidResult(valid)));

  Future<ValidatedResult<T>> orElseBindFuture(Future<ValidatedResult<T>> Function() fallback) =>
      fold((invalid) => fallback(), (valid) => Future.value(ValidResult(valid)));

  // orElseTry versions Do not need map or bind: function f is always considered to be fallible
  ValidatedResult<T> _orElseTry(T Function() f, {String? errorMessage, int? internalErrorCode}) =>
      fold((invalid) => f.try_(errorMessage: errorMessage, internalErrorCode: internalErrorCode), (some) => this);

  Future<ValidatedResult<T>> _orElseTryFuture(Future<T> Function() f, {String? errorMessage, int? internalErrorCode}) =>
      fold((invalid) => f.try_(errorMessage: errorMessage, internalErrorCode: internalErrorCode), (some) => this.toValidFuture_());
  /////////////////

  ValidatedResult<R> map<R>(R Function(T val) f) =>
      fold((err) => InvalidResult<R>(err), (v) => ValidResult(f(v)));

  Future<ValidatedResult<R>> mapFuture<R>(Future<R> Function(T val) f) =>
      fold((err) => InvalidResult<R>(err).toFuture(), (v) => f(v).then((value) => ValidResult(value)));

  ValidatedResult<void> forEach(void Function(T val) action) => map(action);

  ValidatedResult<T> andThen(void Function(T t) action) {
    forEach(action);
    return this;
  }

  ValidatedResult<R> bind<R>(ValidatedResult<R> Function(T val) f) =>
      fold((fails) => fails.toInvalid(), (v) => f(v));

  Future<ValidatedResult<R>> bindFuture<R>(Future<ValidatedResult<R>> Function(T val) f) =>
      fold((fails) => fails.toInvalid<R>().toFuture(), (v) => f(v));

  ValidatedResult<R> try_<R>(R Function(T val) f, {String? errorMessage, int? internalErrorCode}) =>
      fold((fails) => fails.toInvalid<R>(), (v) => (() => f(v)).try_(errorMessage: errorMessage, internalErrorCode: internalErrorCode));

  Future<ValidatedResult<R>> tryFuture<R>(Future<R> Function(T val) f, {String? errorMessage, int? internalErrorCode}) =>
      fold((fails) => fails.toInvalid<R>().toFuture(), (v) => (() => f(v)).try_(errorMessage: errorMessage, internalErrorCode: internalErrorCode));

  Future<ValidatedResult<T>> toFuture() => Future(() => this);

  Option<T> toOption() => isValid ? Some(_value!) : None<T>();
}

extension FunctionalsValidationExt on Object {
  Future<ValidatedResult<T>> toValidFuture_<T>() => ValidResult<T>(this as T).toFuture();
}

extension FutureValidatedResult<T> on Future<ValidatedResult<T>> {
  Future<TR> fold<TR>(TR Function(Failure failure) invalid,
              TR Function(T val) valid) 
  {
    return then(
            (value) => 
              value.fold(
                (failure) => invalid(failure),
                (val) => valid(val)));
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

  Future<ValidatedResult<T>> _orElseTry(T Function() fallback, {String? errorMessage, int? internalErrorCode}) =>
      fold((invalid) => fallback.try_(errorMessage: errorMessage, internalErrorCode: internalErrorCode), (valid) => ValidResult(valid));

  Future<ValidatedResult<T>> _orElseTryFuture(Future<T> Function() fallback, {String? errorMessage, int? internalErrorCode}) =>
      foldFuture((invalid) => fallback.try_(errorMessage: errorMessage, internalErrorCode: internalErrorCode), (valid) => Future.value(ValidResult(valid)));

  Future<ValidatedResult<R>> map<R>(R Function(T t) f) =>
      fold((err) => InvalidResult<R>(err), (v) => ValidResult(f(v)));

  Future<ValidatedResult<R>> bind<R>(ValidatedResult<R> Function(T t) f) =>
      fold((fail) => InvalidResult<R>(fail), (v) => f(v));

  Future<ValidatedResult<R>> try_<R>(R Function(T t) f, {String? errorMessage, int? internalErrorCode}) =>
      fold((fail) => InvalidResult<R>(fail), (v) => (() => f(v)).try_(errorMessage: errorMessage, internalErrorCode: internalErrorCode));

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

extension OrElseFunctionTuple<T, R> on ValidatedResult<(T Function(), R lastValidInput)> {
  ValidatedResult<T> orElseTry(T Function(R) fallback, {String? errorMessage, int? internalErrorCode}) =>
      fold(
        (failure) => failure.toInvalid(),
        (val) => try_(val.$1)._orElseTry(() => fallback(val.$2))
      );

  Future<ValidatedResult<T>> orElseTryFuture(Future<T> Function(R) fallback, {String? errorMessage, int? internalErrorCode}) =>
      fold(
        (failure) => failure.toInvalid<T>().toFuture(),
        (val) => try_(val.$1)._orElseTryFuture(() => fallback(val.$2))
      );

  Future<ValidatedResult<T>> orElseRetry(T Function(R) fallback, {String? errorMessage, int? internalErrorCode}) =>
      fold(
        (failure) => failure.toInvalid<T>().toFuture(),
        (val) => try_(val.$1).orElseBindFuture(() => fallback.apply(val.$2).retryLinear())
      );

  Future<ValidatedResult<T>> orElseRetryFuture(T Function(R) fallback, {String? errorMessage, int? internalErrorCode}) =>
      fold(
        (failure) => failure.toInvalid<T>().toFuture(),
        (val) => try_(val.$1).orElseBindFuture(() => fallback.apply(val.$2).retryLinear())
      );
}

extension OrElseFutureFunctionTuple<T, R> on ValidatedResult<(Future<T> Function(), R lastValidInput)> {
  Future<ValidatedResult<T>> orElseTry(T Function(R) fallback, {String? errorMessage, int? internalErrorCode}) =>
      fold(
        (failure) => failure.toInvalid<T>().toFuture(),
        (val) => tryFuture(val.$1)._orElseTry(() => fallback(val.$2))
      );

  Future<ValidatedResult<T>> orElseTryFuture(Future<T> Function(R) fallback, {String? errorMessage, int? internalErrorCode}) =>
      fold(
        (failure) => failure.toInvalid<T>().toFuture(),
        (val) => tryFuture(val.$1)._orElseTryFuture(() => fallback(val.$2))
      );
}
