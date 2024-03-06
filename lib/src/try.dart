import 'package:basic_functional_dart/basic_functional_dart.dart';

Validation<T> _catchBlock<T>(Object err, {String? errorMessage, int? internalErrorCode}) {
  if (err is Exception) {
    return Invalid<T>(Fail.withException(err, message: errorMessage ?? '', internalErrorCode: internalErrorCode ?? -1));
  } else if (err is Error) {
    return Invalid<T>(Fail.withError(err, message: errorMessage ?? '', internalErrorCode: internalErrorCode ?? -1));
  }
  else if(err is String)
  {
    return Invalid<T>(Fail.withError(ArgumentError(err), message: errorMessage ?? '', internalErrorCode: internalErrorCode ?? -1));
  }

  return Fail.withError(Error(), message: errorMessage ?? 'Unknown error').toInvalid<T>();
}

Validation<T> tryCatch<T>(T Function () tryBlock, {String? errorMessage, int? internalErrorCode}) {
  try
  {
    return Valid<T>(tryBlock());
  }
  catch(err)
  {
    return _catchBlock<T>(err, errorMessage: errorMessage, internalErrorCode: internalErrorCode);
  }
} 

extension TryExt<T> on Future<T> {
  Future<Validation<T>> tryCatch({String? errorMessage, int? internalErrorCode}) =>
      then((value) => Valid<T>(value)).catchError((err) {
        return _catchBlock<T>(err, errorMessage: errorMessage, internalErrorCode: internalErrorCode);
      });
}

extension TryFutureValidation<T> on Future<Validation<T>> {
  Future<Validation<T>> tryCatch({String? errorMessage, int? internalErrorCode}) =>
      then((value) => value).catchError((err) {
        return _catchBlock<T>(err, errorMessage: errorMessage, internalErrorCode: internalErrorCode);
      });
}
