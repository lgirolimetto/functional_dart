import 'package:basic_functional_dart/basic_functional_dart.dart';

typedef EmptyValidationValue = String;
const EmptyValidationValue EmptyValue = '';

Validation<T> Valid<T>(T value) => Validation.valid(value);
Validation<T> Invalid<T>(Fail failure) => Validation.invalid(failure);

@Deprecated('Use [ValidatedResult]')
class Validation<T> {
  final Fail? _failure;
  final T? _value;
  bool get isValid => _failure == null;

  const Validation.valid(T value)
      : _value = value,
        _failure = null;

  const Validation.invalid(Fail failure)
      : _failure = failure,
        _value = null;

  TR fold<TR>(TR Function(Fail failure) invalid,
              TR Function(T val) valid) 
  {
    return isValid ? valid(_value!) : invalid(_failure!);
  }
      

  Iterable<T> asIterable() sync* {
    if (isValid) {
      yield _value!;
    }
  }

  Iterable<Fail> asFailIterable() sync* {
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

  Validation<T> orElseMap(T Function() f) =>
      fold((invalid) => Valid(f()), (some) => this);

  Validation<T> orElseBind(Validation<T> Function() f) =>
      fold((invalid) => f(), (some) => this);

  Future<Validation<T>> orElseMapFuture(Future<T> Function() f) =>
      fold((invalid) => f().then((value) => Valid(value)), (valid) => Future.value(Valid(valid)));

  Future<Validation<T>> orElseBindFuture(Future<Validation<T>> Function() fallback) =>
      fold((invalid) => fallback(), (valid) => Future.value(Valid(valid)));

  Validation<R> map<R>(R Function(T val) f) =>
      fold((err) => Invalid<R>(err), (v) => Valid(f(v)));

  Future<Validation<R>> mapFuture<R>(Future<R> Function(T val) f) =>
      fold((err) => Invalid<R>(err).toFuture(), (v) => f(v).then((value) => Valid(value)));

  Validation<void> forEach(void Function(T val) action) => map(action);

  Validation<T> andThen(void Function(T t) action) {
    forEach(action);
    return this;
  }

  Validation<R> bind<R>(Validation<R> Function(T val) f) =>
      fold((fails) => Invalid<R>(fails), (v) => f(v));

  Future<Validation<R>> bindFuture<R>(Future<Validation<R>> Function(T val) f) =>
      fold((fails) => Invalid<R>(fails).toFuture(), (v) => f(v));


  Future<Validation<T>> toFuture() => Future(() => this);

  Option<T> toOption() => isValid ? Some(_value!) : None<T>();

  @Deprecated('Use [tryCatch]')
  static Validation<T> Try<T>(T Function() f, {String failMessage = ''}) {
    try{
      return Valid(f());
    }
    catch (e)
    {
      final fail = e is Exception ? Fail.withException(e, message: failMessage) 
                                  : Fail.withError(e as Error, message: failMessage);
      return Invalid<T>(fail);
    }
  }

  @Deprecated('Use [tryCatch] on Future<T> extension')
 static Future<Validation<T>> tryFuture<T>(Future<T> Function() f) 
        => f().then(Valid)
              .catchError((err) {
                if (err is Exception) {
                  return Invalid<T>(Fail.withException(err));
                }
                else if (err is Error)
                {
                  return Invalid<T>(Fail.withError(err));
                }
              });
}

extension Functionals on Object {
  Future<Validation<T>> toValidFuture<T>() => Valid<T>(this as T).toFuture();
  Future<T> toFuture<T>() => Future<T>.value(this as T);
}

extension FutureValidation<T> on Future<Validation<T>> {
  Future<TR> fold<TR>(TR Function(Fail failure) invalid,
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

  Future<Validation<T>> orElseMap(T defaultVal) =>
      fold((invalid) => Valid(defaultVal), (valid) => Valid(valid));

  Future<Validation<T>> orElseMapFuture(Future<T> defaultVal) =>
      foldFuture((invalid) => defaultVal.then((value) => Valid(value)), (val) => Valid(val).toFuture());

  Future<Validation<T>> orElseBind(Validation<T> Function() fallback) =>
      fold((invalid) => fallback(), (valid) => Valid(valid));

  Future<Validation<T>> orElseBindFuture(Future<Validation<T>> Function() fallback) =>
      foldFuture((invalid) => fallback(), (valid) => Future.value(Valid(valid)));

  Future<Validation<R>> map<R>(R Function(T t) f) =>
      fold((err) => Invalid<R>(err), (v) => Valid(f(v)));

  Future<Validation<R>> bind<R>(Validation<R> Function(T t) f) =>
      fold((fail) => Invalid<R>(fail), (v) => f(v));

  Future<TR> foldFuture<TR>(Future<TR> Function(Fail failure) invalid,
                                                  Future<TR> Function(T val) valid) 
  {
    
    return then((value) => value.fold((failure) => invalid(failure).then((value) => value),
                                      (val)       => valid(val).then((value) => value)));
  }


  Future<Validation<R>> mapFuture<R>(Future<R> Function(T t) f) =>
      foldFuture((err) => Invalid<R>(err).toFuture(), 
                 (v)   => f(v).then((value) => Valid(value)));

  Future<Validation<R>> bindFuture<R>(Future<Validation<R>> Function(T t) f) =>
      foldFuture((fail) => Invalid<R>(fail).toFuture(), (v) => f(v));
}

