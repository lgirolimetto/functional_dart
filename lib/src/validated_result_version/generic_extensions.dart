import 'package:basic_functional_dart/basic_functional_dart.dart';

extension FutureOnT<T> on T {
  Future<T> toFuture() => Future.value(this);
  ValidatedResult<T> toValid() => ValidResult(this);

  R map<R>(R toElement(T)) => toElement(this);
  Future<R> mapFuture<R>(Future<R> toElement(T)) => toElement(this);
}

extension MapOnFutureT<T> on Future<T> {
  Future<T> toFuture() => Future.value(this);
  Future<ValidatedResult<T>> toValid() => then((value) => value.toValid());

  Future<R> map<R>(R toElement(T)) => then((value) => toElement(value));
  Future<R> mapFuture<R>(Future<R> toElement(T)) => then((value) => toElement(value));
}