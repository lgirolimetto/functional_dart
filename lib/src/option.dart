import 'package:basic_functional_dart/basic_functional_dart.dart';

const Empty = EmptyOption.none();

Option<T> None<T>() => Option.none();
Option<T> Some<T>(T value) => Option.some(value);

/// Classe che permette di gestire un valore o la sua assenza
class Option<T> {
  final T? _value;
  final bool isSome;

  const Option.some(this._value) : isSome = true;
  const Option.none()
      : _value = null,
        isSome = false;

  R fold<R>(R Function() none, R Function(T some) some) {
    return isSome ? some(_value!) : none();
  }

  Option<R> map<R>(R Function(T t) f) =>
      fold(() => Option.none(), (some) => Option.some(f(some)));

  Option<void> foreach(void Function(T t) f) => map((t) => f(t));

  bool forAll(bool Function(T t) f) => fold(() => true, (some) => f(some));
  bool exists(bool Function(T t) f) => fold(() => false, (some) => f(some));
  bool contains(T t) => fold(() => false, (some) => some == t);

  Option<R> bind<R>(Option<R> Function(T t) f) =>
      fold(() => Option.none(), (some) => f(some));

  Option<T> where(bool Function(T t) f) => fold(() => Option.none(),
      (some) => f(some) ? Option.some(some) : Option.none());

  Iterable<T> asIterable() sync* {
    if (isSome) {
      yield _value!;
    }
  }

  Iterable<R> flatMap<R>(Iterable<R> Function(T t) f) {
    return asIterable().bind(f);
  }

  T orElse(T defaultVal) => fold(() => defaultVal, (some) => some);

  T orElseDo(T Function() fallback) =>
      fold(() => fallback(), (some) => some);

  Option<T> orElseMap(T Function() f) =>
      fold(() => Some(f()), (some) => this);

  Option<T> orElseBind(Option<T> Function() f) =>
      fold(() => f(), (some) => this);

  Validation<T> toValidation() => isSome ? Valid(_value!) : Invalid<T>(Fail.withError(Error()));

  Future<Option<T>> toFutureOrElse(Future<Option<T>> future) =>
      fold(() => future, (some) => toFuture());
  Future<Option<T>> toFutureOrElseDo(Future<Option<T>> Function() futureF) =>
      fold(() => futureF(), (some) => toFuture());

  Future<Option<T>> toFuture() => Future(() => (this));
}

extension FutureOption<T> on Future<Option<T>> {
  Future<TR> fold<TR>(TR Function() noneF, TR Function(T val) someF) {
    return then((value) => value.fold(() => noneF(), (some) => someF(some)));
  }

  Future<T> orElse(T defaultVal) =>
      fold(() => defaultVal, (some) => some!);

  Future<T> orElseDo(T Function() fallback) =>
      fold(() => fallback(), (some) => some!);

  Future<T> orElseDoFuture(Future<T> Function() fallback) =>
      foldFuture(() => fallback(), (some) => Future.value(some!));

  Future<Option<T>> orElseMap(T defaultVal) =>
      fold(() => Some(defaultVal), (some) => Some(some!));

  Future<Option<T>> orElseMapFuture(Future<T> defaultVal) =>
      foldFuture(() => defaultVal.then((value) => Some(value)), (val) => Some(val).toFuture());

  Future<Option<T>> orElseBind(Option<T> Function() fallback) =>
      fold(() => fallback(), (some) => Some(some!));

  Future<Option<T>> orElseBindFuture(Future<Option<T>> Function() fallback) =>
      foldFuture(() => fallback(), (some) => Future.value(Some(some!)));

  Future<Option<R>> map<R>(R Function(T t) f) =>
      fold(() => None(), (v) => Some(f(v!)));

  Future<Option<R>> bind<R>(Option<R> Function(T t) f) =>
      fold(() => None(), (v) => f(v!));

  Future<TR> foldFuture<TR>(Future<TR> Function() noneF, Future<TR> Function(T val) someF) {
    return then((value) => value.fold(() => noneF().then((value) => value),
        (val) => someF(val).then((value) => value)));
  }

  Future<Option<R>> mapFuture<R>(Future<R> Function(T t) f) => foldFuture(
      () => None().toFuture() as Future<Option<R>>, (some) => f(some!).then((value) => Some(value)));

  Future<Option<R>> bindFuture<R>(Future<Option<R>> Function(T t) f) =>
      foldFuture(() => None().toFuture() as Future<Option<R>>, (v) => f(v!));
}

class EmptyOption extends Option{
  const EmptyOption.none() : super.none();
}

class NoValue extends Option{
  const NoValue.none() : super.none();
}

extension NoValueExtension on NoValue{
  Validation<NoValue> toValid() => Valid(this);
}
