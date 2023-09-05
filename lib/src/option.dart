import 'package:lg_functional_dart/src/iterator_extensions.dart';
import 'package:lg_functional_dart/src/validation.dart';

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

  T getOrElse(T defaultVal) => fold(() => defaultVal, (some) => some);

  T getOrElseDo(T Function() fallback) =>
      fold(() => fallback(), (some) => some);

  Option<T> getOrElseMap(T Function() f) =>
      fold(() => Some(f()), (some) => this);

  Option<T> getOrElseBind(Option<T> Function() f) =>
      fold(() => f(), (some) => this);

  Validation<Option<T>> toValidation() => Valid(this);

  Future<Option<T>> toFutureOrElse(Future<Option<T>> future) =>
      fold(() => future, (some) => toFuture());
  Future<Option<T>> toFutureOrElseDo(Future<Option<T>> Function() futureF) =>
      fold(() => futureF(), (some) => toFuture());

  Future<Option<T>> toFuture() => Future(() => (this));
}

extension FutureOption on Future<Option> {
  Future<TR> fold<TR, T>(TR Function() noneF, TR Function(T val) someF) {
    return then((value) => value.fold(() => noneF(), (some) => someF(some)));
  }

  Future<T> getOrElse<T>(T defaultVal) =>
      fold(() => defaultVal, (some) => some! as T);

  Future<T> getOrElseDo<T>(T Function() fallback) =>
      fold(() => fallback(), (some) => some! as T);

  Future<Option<R>> map<R, T>(R Function(T t) f) =>
      fold(() => None(), (v) => Some(f(v! as T)));

  Future<Option<R>> bind<R, T>(Option<R> Function(T t) f) =>
      fold(() => None(), (v) => f(v! as T));

  Future<TR> foldFuture<TR, T>(
      Future<TR> Function() noneF, Future<TR> Function(T val) someF) {
    return then((value) => value.fold(() => noneF().then((value) => value),
        (val) => someF(val).then((value) => value)));
  }

  Future<Option<R>> mapFuture<R, T>(Future<R> Function(T t) f) => foldFuture(
      () => None().toFuture() as Future<Option<R>>, (some) => f(some! as T).then((value) => Some(value)));

  Future<Option<R>> bindFuture<R, T>(Future<Option<R>> Function(T t) f) =>
      foldFuture(() => None().toFuture() as Future<Option<R>>, (v) => f(v! as T));
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
