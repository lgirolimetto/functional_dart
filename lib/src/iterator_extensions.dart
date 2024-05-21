import 'package:basic_functional_dart/basic_functional_dart.dart';

extension FunctionalIterable<T> on Iterable<T> {
  Iterable<R> bind<R>(Iterable<R> Function(T t) f) sync* {
    for (var e in this) {
      for (var r in f(e)) {
        yield r;
      }
    }
  }

  Iterable<R> flatMapOption<R>(Option<R> Function(T t) f) =>
      bind((t) => f(t).asIterable());

  Iterable<R> flatMap<R>(Iterable<R> Function(T) f) => expand<R>(f);

  bool forAll(bool Function(T t) f) => where((e) => f(e) == false).isEmpty;
}

extension FlatOptionIterable<T> on Iterable<Option<T>> {
  Iterable<T> flatten() => flatMap((v) => v.asIterable());
  Option<Iterable<T>> fold() {
    final iterable = where((o) => !o.isSome);
    if(iterable.isEmpty) {
      return Some(flatten());
    }
    else {
      return None<Iterable<T>>();
    }
  }
}

extension FlatvalidationIterable<T> on Iterable<ValidatedResult<T>> {
  Either<Iterable<Failure>, Iterable<T>> foldEither() {
    final iterable = where((o) => !o.isValid);
    if(iterable.isEmpty) {
      return Right(flatten());
    }
    else {
      return Left(iterable.flatMap((e) => e.asFailIterable()));
    }
  }

  TR fold<TR>(TR Function(Iterable<Failure> failures) invalid,
              TR Function(Iterable<T> values) valid) {
    final iterable = where((o) => !o.isValid);
    if(iterable.isEmpty) {
      return valid(flatten());
    }
    else {
      return invalid(iterable.flatMap((e) => e.asFailIterable()));
    }
  }
}

extension FlatNestedIterable<T> on Iterable<Iterable<T>> {
  Iterable<T> flatten() => expand<T>((t) => t);
}