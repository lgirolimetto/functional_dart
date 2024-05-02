import 'package:basic_functional_dart/basic_functional_dart.dart';

ValidatedResult<T> _catchBlock<T>(Object err, {String? errorMessage, int? internalErrorCode}) {
  if (err is Exception) {
    return Failure
            .withException(err, message: errorMessage ?? '', internalErrorCode: internalErrorCode ?? -1)
            .toInvalid();
  } else if (err is Error) {
    return Failure
            .withError(err, message: errorMessage ?? '', internalErrorCode: internalErrorCode ?? -1)
            .toInvalid();
  }
  else if(err is String)
  {
    return Failure
            .withError(ArgumentError(err), message: errorMessage ?? '', internalErrorCode: internalErrorCode ?? -1)
            .toInvalid();
  }

  return Failure.withError(Error(), message: errorMessage ?? 'Unknown error').toInvalid();
}

ValidatedResult<T> try_<T>(T Function () tryBlock, {T? previousInputValue, String? errorMessage, int? internalErrorCode}) {
  try
  {
    return ValidResult<T>(tryBlock());
  }
  catch(err)
  {
    return _catchBlock<T>(err, errorMessage: errorMessage, internalErrorCode: internalErrorCode);
  }
}

Future<ValidatedResult<T>> tryFuture<T>(Future<T> Function () tryBlock, {String? errorMessage, int? internalErrorCode}) {
  try
  {
    return tryBlock().try_(errorMessage: errorMessage, internalErrorCode: internalErrorCode);
  }
  catch(err)
  {
    return _catchBlock<T>(err, errorMessage: errorMessage, internalErrorCode: internalErrorCode).toFuture();
  }
}


extension TryCatchExtFunction<T> on T Function() {
  ValidatedResult<T> try_({String? errorMessage, int? internalErrorCode}) {
    try
    {
      return ValidResult(this());
    }
    catch(err)
    {
      return _catchBlock(err, errorMessage: errorMessage, internalErrorCode: internalErrorCode);
    }
  }
}

extension TryCatchExtFutureFunction<T> on Future<T> Function() {
  Future<ValidatedResult<T>> try_({T? previousInputValue, String? errorMessage, int? internalErrorCode}) =>
      tryFuture(this, errorMessage: errorMessage, internalErrorCode: internalErrorCode);
}

extension TryCatchExt<T> on Future<T> {
  Future<ValidatedResult<T>> try_({T? previousInputValue, String? errorMessage, int? internalErrorCode}) =>
      then((value) => ValidResult<T>(value)).catchError((err) {
        return _catchBlock<T>(err, errorMessage: errorMessage, internalErrorCode: internalErrorCode);
      });
}
