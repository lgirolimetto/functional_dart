import 'package:basic_functional_dart/basic_functional_dart.dart';


extension FlatValidatedResultIterable<T> on Iterable<ValidatedResult<T>> {
  Iterable<T> flatten() => flatMap((v) => v.asIterable());
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