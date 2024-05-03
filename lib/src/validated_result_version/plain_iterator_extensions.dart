import 'dart:isolate';

import 'package:basic_functional_dart/basic_functional_dart.dart';
import 'package:fast_immutable_collections/fast_immutable_collections.dart';

extension Futures<T> on Iterable<Future<T>> {
  Iterable<Future<R>> map_<R>(R Function(T) fn) {
    return map((f) => f.then((v) => fn(v)));
  }

  Iterable<Future<R>> mapFuture<R>(Future<R> Function(T) fn) {
    return map((f) => f.then((v) => fn(v)));
  }

  Future<Iterable<R>> flatMap<R>(Future<R> Function(T) fn) {
    return mapFuture(fn).flatten();
  }

  Future<Iterable<T>> flatten() {
    return Future.wait(this);
  }

  Future<R> fold_<R>(R initialValue, R Function(R previousValue, T element) combine) {
    return fold(Future.value(initialValue), (r, e) => e.then((v) => r.then((value) => combine(value, v))));
  }

  Future<R> foldFuture<R>(R initialValue, Future<R> Function(R previousValue, T element) combine) {
    return fold(Future.value(initialValue), (r, e) => e.then((v) => r.then((value) => combine(value, v))));
  }
}

extension FutureIterable<T> on Future<Iterable<T>> {
  Future<Iterable<R>> map<R>(R Function(T) fn) {
    return then((value) => value.map((v) => fn(v)));
  }

  Future<Iterable<Future<R>>> mapFuture<R>(Future<R> Function(T) fn) {
    return then((value) => value.map((v) => fn(v)));
  }

  Future<Iterable<R>> flatMap<R>(Future<R> Function(T) fn) {
    return then((value) => value.map((v) => fn(v))).flatten();
  }

  Future<R> fold<R>(R initialValue, R Function(R previousValue, T element) combine) {
    final r = then((v) => v.fold(initialValue, (p, e) => combine(p, e)));
    return r;
  }
}

extension FutureList<T> on Future<List<T>> {
  Future<Iterable<R>> map<R>(R Function(T) fn) {
    return then((value) => value.map((v) => fn(v)));
  }

  Future<R> fold<R>(R initialValue, R Function(R previousValue, T element) combine) {
    final r = then((v) => v.fold(initialValue, combine));
    return r;
  }
}

extension ParallelFutures<T> on Iterable<Future<T> Function()> {
  /// Run functions in isolates and wait the results
  /// If functions cannot be run in an Isolate, use [waitAll] instead.
  Future<List<T>> asParallel() {
    return Future.wait(
        fold(<Future<T>>[], (previousValue, function) => previousValue.toIList().add(Isolate.run(function)))
    );
  }

  /// Run functions in isolates and wait the results, collecting successes and failures
  /// If functions cannot be run in an Isolate, use [tryWaitAll] instead.
  Future<List<ValidatedResult<T>>> tryAsParallel() {
    return Future.wait(
        fold(<Future<ValidatedResult<T>>>[], (previousValue, function) => previousValue.toIList().add(Isolate.run(function.try_)))
    );
  }

  /// Run functions and wait the results
  /// Use this function if functions to be waited cannot be run (or you don't want them to run) in an isolate
  /// Otherwise use [asParallel]
  Future<List<T>> waitAll() {
    return Future.wait(
        fold(<Future<T>>[], (previousValue, function) => previousValue.toIList().add(function()))
    );
  }

  /// Run functions and wait the results, collecting successes ir failures
  /// Use this function if functions to be waited cannot be run (or you don't want them to run) in an isolate
  /// Otherwise use [tryAsParallel]
  Future<List<ValidatedResult<T>>> tryWaitAll() {
    return Future.wait(
        fold(<Future<ValidatedResult<T>>>[], (previousValue, function) => previousValue.toIList().add(function.try_()))
    );
  }
}

extension Parallel<T> on Iterable<T Function()> {
  /// Run functions in isolates and wait the results
  /// If functions cannot be run in an Isolate, use [waitAll] instead.
  Future<List<T>> asParallel() {
    return Future.wait(
        fold(<Future<T>>[], (previousValue, function) => previousValue.toIList().add(Isolate.run(function)))
    );
  }

  /// Run functions in isolates and wait the results, collecting successes and failures
  /// If functions cannot be run in an Isolate, use [tryWaitAll] instead.
  Future<List<ValidatedResult<T>>> tryAsParallel() {
    return Future.wait(
        fold(<Future<ValidatedResult<T>>>[], (previousValue, function) => previousValue.toIList().add(Isolate.run(function.try_)))
    );
  }
}

extension FutureIterableFuture<T> on Future<Iterable<Future<T>>> {
  Future<List<T>> flatten() {
    return then((l) => Future.wait(l));
  }

  Future<R> fold<R>(R initialValue, R Function(R previousValue, T element) combine) {
    return then((value) => value.fold_(initialValue, combine));
  }
}

extension FutureLFuture<T> on Future<List<Future<T>>> {
  Future<R> fold<R>(R initialValue, R Function(R previousValue, T element) combine) {
    return then((value) => value.fold_(initialValue, combine));
  }
}

extension ParallelFuturesEx<T> on Future<Iterable<Future<T> Function()>> {
  /// Run functions in isolates and wait the results
  /// If functions cannot be run in an Isolate, use [waitAll] instead.
  Future<List<T>> asParallel() {
    return then((value) => value.asParallel());
  }

  /// Run functions in isolates and wait the results, collecting successes and failures
  /// If functions cannot be run in an Isolate, use [tryWaitAll] instead.
  Future<List<ValidatedResult<T>>> tryAsParallel() {
    return then((value) => value.tryAsParallel());
  }

  /// Run functions and wait the results
  /// Use this function if functions to be waited cannot be run (or you don't want them to run) in an isolate
  /// Otherwise use [asParallel]
  Future<List<T>> waitAll() {
    return then((value) => value.waitAll());
  }

  /// Run functions and wait the results, collecting successes ir failures
  /// Use this function if functions to be waited cannot be run (or you don't want them to run) in an isolate
  /// Otherwise use [tryAsParallel]
  Future<List<ValidatedResult<T>>> tryWaitAll() {
    return then((value) => value.tryWaitAll());
  }
}

extension FutureParallelFuturesEx<T> on Future<Iterable<T Function()>> {
  /// Run functions in isolates and wait the results
  /// If functions cannot be run in an Isolate, use [waitAll] instead.
  Future<List<T>> asParallel() {
    return then((value) => value.asParallel());
  }

  /// Run functions in isolates and wait the results, collecting successes and failures
  /// If functions cannot be run in an Isolate, use [tryWaitAll] instead.
  Future<List<ValidatedResult<T>>> tryAsParallel() {
    return then((value) => value.tryAsParallel());
  }
}

extension ToList<T> on Future<IList<T>> {
  Future<List<T>> mapAsList() {
    return then((value) => value.toList());
  }
}