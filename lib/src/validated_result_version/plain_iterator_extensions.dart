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

  Future<Iterable<R>> flatMap<R>(R Function(T) fn) {
    return map_(fn).flatten();
  }

  Future<Iterable<R>> flatMapFuture<R>(Future<R> Function(T) fn) {
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
  Future<Iterable<T>> asParallel() {
    return Future.wait(
        fold(<Future<T>>[], (previousValue, function) => previousValue.toIList().add(Isolate.run(function)))
    );
  }

  /// Run functions in isolates and wait the results, collecting successes and failures
  /// If functions cannot be run in an Isolate, use [tryWaitAll] instead.
  Future<Iterable<ValidatedResult<T>>> tryAsParallel({String? errorMessage, int? internalErrorCode}) {
    return Future.wait(
        fold(
          <Future<ValidatedResult<T>>>[],
          (previousValue, function) => previousValue
                                        .toIList()
                                        .add(Isolate.run(() => function.try_(errorMessage: errorMessage, internalErrorCode: internalErrorCode))))
    );
  }

  /// Run functions and wait the results
  /// Use this function if functions to be waited cannot be run (or you don't want them to run) in an isolate
  /// Otherwise use [asParallel]
  Future<Iterable<T>> waitAll() {
    return Future.wait(
        fold(<Future<T>>[], (previousValue, function) => previousValue.toIList().add(function()))
    );
  }

  /// Run functions and wait the results, collecting successes ir failures
  /// Use this function if functions to be waited cannot be run (or you don't want them to run) in an isolate
  /// Otherwise use [tryAsParallel]
  Future<Iterable<ValidatedResult<T>>> tryWaitAll({String? errorMessage, int? internalErrorCode}) {
    return Future.wait(
        fold(<Future<ValidatedResult<T>>>[], (previousValue, function) => previousValue.toIList().add(function.try_(errorMessage: errorMessage, internalErrorCode: internalErrorCode)))
    );
  }
}

extension Parallel<T> on Iterable<T Function()> {
  /// Run functions in isolates and wait the results
  /// If functions cannot be run in an Isolate, use [waitAll] instead.
  Future<Iterable<T>> asParallel() {
    return Future.wait(
        fold(<Future<T>>[], (previousValue, function) => previousValue.toIList().add(Isolate.run(function)))
    );
  }

  /// Run functions in isolates and wait the results, collecting successes and failures
  /// If functions cannot be run in an Isolate, use [tryWaitAll] instead.
  Future<Iterable<ValidatedResult<T>>> tryAsParallel({String? errorMessage, int? internalErrorCode}) {
    return Future.wait(
        fold(
          <Future<ValidatedResult<T>>>[],
          (previousValue, function) => previousValue.toIList().add(Isolate.run(() => function.try_(errorMessage: errorMessage, internalErrorCode: internalErrorCode)))
        )
    );
  }
}

extension FutureIterableFuture<T> on Future<Iterable<Future<T>>> {
  Future<Iterable<T>> flatten() {
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
  Future<Iterable<T>> asParallel() {
    return then((value) => value.asParallel());
  }

  /// Run functions in isolates and wait the results, collecting successes and failures
  /// If functions cannot be run in an Isolate, use [tryWaitAll] instead.
  Future<Iterable<ValidatedResult<T>>> tryAsParallel({String? errorMessage, int? internalErrorCode}) {
    return then((value) => value.tryAsParallel(errorMessage: errorMessage, internalErrorCode: internalErrorCode));
  }

  /// Run functions and wait the results
  /// Use this function if functions to be waited cannot be run (or you don't want them to run) in an isolate
  /// Otherwise use [asParallel]
  Future<Iterable<T>> waitAll() {
    return then((value) => value.waitAll());
  }

  /// Run functions and wait the results, collecting successes ir failures
  /// Use this function if functions to be waited cannot be run (or you don't want them to run) in an isolate
  /// Otherwise use [tryAsParallel]
  Future<Iterable<ValidatedResult<T>>> tryWaitAll({String? errorMessage, int? internalErrorCode}) {
    return then((value) => value.tryWaitAll(errorMessage: errorMessage, internalErrorCode: internalErrorCode));
  }
}

extension FutureParallelFuturesEx<T> on Future<Iterable<T Function()>> {
  /// Run functions in isolates and wait the results
  /// If functions cannot be run in an Isolate, use [waitAll] instead.
  Future<Iterable<T>> asParallel() {
    return then((value) => value.asParallel());
  }

  /// Run functions in isolates and wait the results, collecting successes and failures
  /// If functions cannot be run in an Isolate, use [tryWaitAll] instead.
  Future<Iterable<ValidatedResult<T>>> tryAsParallel({String? errorMessage, int? internalErrorCode}) {
    return then((value) => value.tryAsParallel(errorMessage: errorMessage, internalErrorCode: internalErrorCode));
  }
}

extension ToList<T> on Future<IList<T>> {
  Future<List<T>> mapAsList() {
    return then((value) => value.toList());
  }
}