import 'package:basic_functional_dart/basic_functional_dart.dart';

Validation<T> retry<T>(Validation<T> Function() action, {required int maxRetries}) {
  return [for (var i = 1; i <= maxRetries; i++) i]
      .map((e) => action)
      .fold(Invalid<T>(Fail.withError(Error())), (previousValue, action) => previousValue.orElseBind(action));
}

Future<Validation<T>> retryFuture<T>(Future<Validation<T>> Function() action, {required int maxRetries}) {
  return [for (var i = 1; i <= maxRetries; i++) i]
      .map((e) => action)
      .fold(Future.value(Invalid<T>(Fail.withError(Error()))), (previousValue, action) => previousValue.orElseBindFuture(action));
}