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

  Future<({A a, B b})> zipFutureFn<B>(Future<B> Function() b) {
    return b().then((b) => (a: this, b: b));
  }

  ({A a, B b}) zip<B>(B b) {
    return (a: this, b: b);
  }

  ({A a, B b}) zipFn<B>(B Function() b) {
    return (a: this, b: b());
  }
}

extension ZipsAB<A, B> on ({A a, B b}) {
  Future<({A a, B b, C c})> zipFuture<C>(Future<C> c) {
    return c.then((c) => (a: a, b: b, c: c));
  }

  Future<({A a, B b, C c})> zipFutureFn<C>(Future<C> Function() c) {
    return c().then((c) => (a: a, b: b, c: c));
  }

  ({A a, B b, C c}) zip<C>(C c) {
    return (a: a, b: b, c: c);
  }

  ({A a, B b, C c}) zipFn<C>(C Function() c) {
    return (a: a, b: b, c: c());
  }
}

extension FutureZips<A> on Future<A> {
  Future<({A a, B b})> zip<B>(B b) {
    return then((a) => a.zip(b));
  }

  Future<({A a, B b})> zipFn<B>(B Function() b) {
    return then((a) => a.zipFn(b));
  }

  Future<({A a, B b})> zipFuture<B>(Future<B> b) {
    return then((a) => a.zipFuture(b));
  }

  Future<({A a, B b})> zipFutureFn<B>(Future<B> Function() b) {
    return then((a) => a.zipFutureFn(b));
  }
}