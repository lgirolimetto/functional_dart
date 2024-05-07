import 'package:basic_functional_dart/basic_functional_dart.dart';

extension FunctionExtensions0<T1, R> on R Function(T1) {
  R Function() apply(T1 t1) => () => this(t1);
  R Function() Function(T1) curry() => (T1 t1) => () => this(t1);
}

extension FunctionExtensions<T1, T2, R> on R Function(T1, T2) {
  R Function(T2, T1) swapArgs() => (T2 t2, T1 t1) => this(t1, t2);
  R Function(T2) apply(T1 t1) => (T2 t2) => this(t1, t2);
  R Function(T2) Function(T1) curry() => (T1 t1) => (T2 t2) => this(t1, t2);

  R Function() applyAll(T1 t1, T2 t2) => () => this(t1, t2);
}

extension FunctionExtensions2<T1, T2, T3, R> on R Function(T1, T2, T3) {
  R Function(T2, T3) apply(T1 t1) => (T2 t2, T3 t3) => this(t1, t2, t3);
  R Function() applyAll(T1 t1, T2 t2, T3 t3) => () => this(t1, t2, t3);
}

extension FunctionExtensions2X<T1, R> on R Function(T1, {String? errorMessage, int? internalErrorCode}) {
  R Function({String? errorMessage, int? internalErrorCode}) apply(T1 t1)
  => ({String? errorMessage, int? internalErrorCode})
  => this(t1, errorMessage: errorMessage, internalErrorCode: internalErrorCode);

  R Function() applyAll(T1 t1, {RetryStrategy? rs, String? errorMessage, int? internalErrorCode})
  => () => this(t1, errorMessage: errorMessage, internalErrorCode: internalErrorCode);
}


extension FunctionExtensions3<T1, T2, T3, T4, R> on R Function(T1, T2, T3, T4) {
  R Function(T2, T3, T4) apply(T1 t1) => (T2 t2, T3 t3, T4 t4) => this(t1, t2, t3, t4);
  R Function() applyAll(T1 t1, T2 t2, T3 t3, T4 t4) => () => this(t1, t2, t3, t4);
}

extension FunctionExtensions3X<T1, R> on R Function(T1, {RetryStrategy? rs, String? errorMessage, int? internalErrorCode}) {
  R Function({RetryStrategy? rs, String? errorMessage, int? internalErrorCode}) apply(T1 t1)
    => ({RetryStrategy? rs, String? errorMessage, int? internalErrorCode})
    => this(t1, rs: rs, errorMessage: errorMessage, internalErrorCode: internalErrorCode);

  R Function() applyAll(T1 t1, {RetryStrategy? rs, String? errorMessage, int? internalErrorCode})
      => () => this(t1, rs: rs, errorMessage: errorMessage, internalErrorCode: internalErrorCode);
}

extension FunctionExtensions4<T1, T2, T3, T4, T5, R> on R Function(T1, T2, T3, T4, T5) {
  R Function(T2, T3, T4, T5) apply(T1 t1) => (T2 t2, T3 t3, T4 t4, T5 t5) => this(t1, t2, t3, t4, t5);
  R Function() applyAll(T1 t1, T2 t2, T3 t3, T4 t4, T5 t5) => () => this(t1, t2, t3, t4, t5);
}

extension FunctionExtensions5<T1, T2, T3, T4, T5, T6, R> on R Function(T1, T2, T3, T4, T5, T6) {
  R Function(T2, T3, T4, T5, T6) apply(T1 t1) => (T2 t2, T3 t3, T4 t4, T5 t5, T6 t6) => this(t1, t2, t3, t4, t5, t6);
  R Function() applyAll(T1 t1, T2 t2, T3 t3, T4 t4, T5 t5, T6 t6) => () => this(t1, t2, t3, t4, t5, t6);
}

extension FunctionExtensions6<T1, T2, T3, T4, T5, T6, T7, R> on R Function(T1, T2, T3, T4, T5, T6, T7) {
  R Function(T2, T3, T4, T5, T6, T7) apply(T1 t1) => (T2 t2, T3 t3, T4 t4, T5 t5, T6 t6, T7 t7) => this(t1, t2, t3, t4, t5, t6, t7);
  R Function() applyAll(T1 t1, T2 t2, T3 t3, T4 t4, T5 t5, T6 t6, T7 t7) => () => this(t1, t2, t3, t4, t5, t6, t7);
}