import 'package:basic_functional_dart/basic_functional_dart.dart';


extension FlatValidatedResultIterable<T> on Iterable<ValidatedResult<T>> {
  /// Wipe out failures and keep only successes
  /// To get failures use [flattenFailures]
  Iterable<T> flatten() => flatMap((v) => v.asIterable());

  /// Wipe out successes and keep only failures
  /// To get successes use [flatten]
  Iterable<Failure> flattenFailures() => flatMap((v) => v.asFailIterable());

  ValidatedResult<Iterable<T>> failsIfAllFailures({String? errorMessage, int? internalErrorCode})
    => flatten()
        .isEmpty
         ? Failure
            .withError(StateError(errorMessage ?? ''), message: errorMessage ?? '', internalErrorCode: internalErrorCode ?? -1)
            .toInvalid()
        : ValidResult(flatten());

  ValidatedResult<Iterable<T>> failsIfSomeFailures({String? errorMessage, int? internalErrorCode})
    => flattenFailures()
        .isNotEmpty
          ? Failure
            .withError(StateError(errorMessage ?? ''), message: errorMessage ?? '', internalErrorCode: internalErrorCode ?? -1)
            .toInvalid()
        : ValidResult(flatten());

  /// Extract failures in [Either.left] if at least one failure exists
  /// Extract successes int [Either.right] if there are only successes
  Either<Iterable<Failure>, Iterable<T>> toEither() {
    final iterable = where((o) => !o.isValid);
    if(iterable.isEmpty) {
      return Right(flatten());
    }
    else {
      return Left(iterable.flatMap((e) => e.asFailIterable()));
    }
  }

  TR fold_<TR>(TR Function(Iterable<Failure> failures) invalid,
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

extension FlatFutureValidatedResultIterable<T> on Future<Iterable<ValidatedResult<T>>> {
  /// Wipe out failures and keep only successes
  /// To get failures use [flattenFailures]
  Future<Iterable<T>> flatten() => then((fv) => fv.flatten());
  /// Wipe out failures and keep only successes
  /// To get failures use [flattenValidatedFailures]
  Future<ValidatedResult<Iterable<T>>> flattenValidated() => then((fv) => ValidResult(fv.flatten()));

  Future<ValidatedResult<Iterable<T>>> failsIfAllFailures({String? errorMessage, int? internalErrorCode})
        => then((fv) => fv.failsIfAllFailures(errorMessage: errorMessage, internalErrorCode: internalErrorCode));

  Future<ValidatedResult<Iterable<T>>> failsIfSomeFailures({String? errorMessage, int? internalErrorCode})
      => then((fv) => fv.failsIfSomeFailures(errorMessage: errorMessage, internalErrorCode: internalErrorCode));

  /// Wipe out successes and keep only failures
  /// To get successes use [flatten]
  Future<Iterable<Failure>> flattenFailures() => then((value) => value.flattenFailures());

  /// Wipe out successes and keep only failures
  /// To get successes use [flattenValidated]
  Future<ValidatedResult<Iterable<Failure>>> flattenValidatedFailures() => then((fv) => ValidResult(fv.flattenFailures()));

  /// Extract failures in [Either.left] if at least one failure exists
  /// Extract successes int [Either.right] if there are only successes
  Future<Either<Iterable<Failure>, Iterable<T>>> toEither() => then((value) => value.toEither());


  Future<TR> fold_<TR>(TR Function(Iterable<Failure> failures) invalid,
      TR Function(Iterable<T> values) valid) {
    return then((value) => value.fold_(invalid, valid));
  }
}

extension IterableValidatedResult<T> on ValidatedResult<Iterable<T>> {
  /// The current elements of this iterable modified by [toElement].
  ///
  /// Returns a new lazy [Iterable] with elements that are created by
  /// calling `toElement` on each element of this `Iterable` in
  /// iteration order.
  /// It is the equivalent of [Iterable.map]
  ///
  /// If you want to map another function that handle all the array at once
  /// use [ValidatedResult.map] instead
  ValidatedResult<Iterable<R>> map_<R>(R toElement(T e)) {
    return fold(
      (failure) => failure.toInvalid(),
      (val) => ValidResult(val.map((e) => toElement(e))));
  }

  /// The current elements of this iterable modified by [toElement].
  ///
  /// Returns a new lazy [Iterable] with elements that are created by
  /// calling `toElement` on each element of this `Iterable` in
  /// iteration order.
  /// Like [map_] with error handling
  ValidatedResult<Iterable<R>> tryMap<R>(R toElement(T e), {String? errorMessage, int? internalErrorCode}) {
    return fold(
            (failure) => failure.toInvalid(),
            (val) => try_(() => val.map((e) => toElement(e)), errorMessage: errorMessage, internalErrorCode: internalErrorCode));
  }

  /// Reduces a collection to a single value by iteratively combining each
  /// element of the collection with an existing value
  /// It is the equivalent of [Iterable.fold]
  ///
  /// If you want to extract either the result or the failure
  /// use [ValidatedResult.fold] instead
  ValidatedResult<R> fold_<R>(R initialValue, R combine(R previousValue, T element)) {
    return fold(
            (failure) => failure.toInvalid(),
            (val) {
          final r = val.fold(initialValue, combine);
          return ValidResult(r);
        });
  }

  /// Reduces a collection to a single value by iteratively combining each
  /// element of the collection with an existing value
  /// Like [fold_] with error handling
  ValidatedResult<R> tryFold<R>(R initialValue, R combine(R previousValue, T element), {String? errorMessage, int? internalErrorCode}) {
    return fold(
            (failure) => failure.toInvalid(),
            (val) {
              return (() => val.fold(initialValue, combine)).try_(errorMessage: errorMessage, internalErrorCode: internalErrorCode);
            });
  }
}

extension FutureIterableValidatedResult<T> on Future<ValidatedResult<Iterable<T>>> {
  /// The current elements of this iterable modified by [toElement].
  ///
  /// Returns a new lazy [Iterable] with elements that are created by
  /// calling `toElement` on each element of this `Iterable` in
  /// iteration order.
  /// It is the equivalent of [Iterable.map]
  ///
  /// If you want to map another function that handle all the array at once
  /// use [ValidatedResult.map] instead
  Future<ValidatedResult<Iterable<R>>> map_<R>(R toElement(T e)) {
    return then((value) => value.map_(toElement));
  }

  /// The current elements of this iterable modified by [toElement].
  ///
  /// Returns a new lazy [Iterable] with elements that are created by
  /// calling `toElement` on each element of this `Iterable` in
  /// iteration order.
  /// Like [map_] with error handling
  Future<ValidatedResult<Iterable<R>>> tryMap<R>(R toElement(T e), {String? errorMessage, int? internalErrorCode}) {
    return then((value) => value.tryMap(toElement));
  }

  /// Reduces a collection to a single value by iteratively combining each
  /// element of the collection with an existing value
  /// It is the equivalent of [Iterable.fold]
  ///
  /// If you want to extract either the result or the failure
  /// use [ValidatedResult.fold] instead
  Future<ValidatedResult<R>> fold_<R>(R initialValue, R combine(R previousValue, T element)) {
    return then((value) => value.fold_(initialValue, combine));
  }

  /// Reduces a collection to a single value by iteratively combining each
  /// element of the collection with an existing value
  /// Like [fold_] with error handling
  Future<ValidatedResult<R>> tryFold<R>(R initialValue, R combine(R previousValue, T element), {String? errorMessage, int? internalErrorCode}) {
    return then((value) => value.tryFold(initialValue, combine));
  }
}