import 'package:lg_functional_dart/src/option.dart';

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

  Iterable<R> flatMap<R>(Iterable<R> Function(T) f) => expand<R>(f).toList();
}

extension FlatOptionIterable<T> on Iterable<Option<T>> {
  Iterable<T> flatten() => flatMap((v) => v.asIterable());
}