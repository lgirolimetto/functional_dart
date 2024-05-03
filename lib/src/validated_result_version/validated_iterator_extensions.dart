import 'package:basic_functional_dart/basic_functional_dart.dart';


extension FlatValidatedResultIterable<T> on Iterable<ValidatedResult<T>> {
  /// Wipe out failures and keep only successes
  /// To get failures use [flatFailures]
  Iterable<T> flatten() => flatMap((v) => v.asIterable());

  /// Extract failures in [Either.left] if at least one failure exists
  /// Extract successes int [Either.right] if there are only successes
  Either<Iterable<Failure>, Iterable<T>> fold() {
    final iterable = where((o) => !o.isValid);
    if(iterable.isEmpty) {
      return Right(flatten());
    }
    else {
      return Left(iterable.flatMap((e) => e.asFailIterable()));
    }
  }

  /// Wipe out successes and keep only failures
  /// To get successes use [flatten]
  TR flatFailures<TR>(TR Function(Iterable<Failure> failures) invalid,
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