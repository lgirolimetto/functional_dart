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

extension Zips<A> on A {
  Future<({A a, B b})> zipFuture<B>(Future<B> b) {
    return b.then((b) => (a: this, b: b));
  }

  ({A a, B b}) zip<B>(B b) {
    return (a: this, b: b);
  }
}

extension FutureZips<A> on Future<A> {
  Future<({A a, B b})> zip<B>(B b) {
    return then((a) => (a: a, b: b));
  }

  Future<({A a, B b})> zipFuture<B>(Future<B> b) {
    return Future
            .wait([this, b])
            .then((fs) => (a: fs[0] as A, b: fs[1] as B));
    return then((a) => b.then((b) => (a: a, b: b)));
  }
}