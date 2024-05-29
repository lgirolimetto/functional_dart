import 'package:basic_functional_dart/basic_functional_dart.dart';

/// Classe di errore usata nella [ValidatedResult] e può contenere un [Error] o una [Exception]
/// Molto simile come concetto a [Either]
class Failure {
  final String errorMessage;
  final int internalErrorCode;
  final Either<Error, Exception> _failedWith;
  
  Failure.withError(Error error, {
    String? errorMessage,
    int? internalErrorCode}
  ) : errorMessage = errorMessage ?? defaultErrorMessage,
      internalErrorCode = internalErrorCode ?? defaultInternalErrorCode,
      _failedWith = Left<Error, Exception>(error);
      
  Failure.withException(Exception exception, {
    String? errorMessage,
    int? internalErrorCode
  }) : errorMessage = errorMessage ?? defaultErrorMessage,
        internalErrorCode = internalErrorCode ?? defaultInternalErrorCode,
        _failedWith = Right<Error, Exception>(exception);

  /// Restituisce il messaggio dell'[Error] o dell'[Exception]
  @override
  String toString () {
    var innerMessage = _failedWith.fold((l) => l.toString(), (r) => r.toString());
    if (errorMessage.isNotEmpty)
    {
      return '$errorMessage - $innerMessage';
    }

    return innerMessage;
  }
      

  /// Estrae il possibile [Error] o [Exception].
  R fold<R>(R Function(Error err) errF,
      R Function(Exception exc) excF) {
    return _failedWith.fold((error) => errF(error), (exc) => excF(exc));
  }

  /// Se `Fail`contiene un eccezione e quell'eccezione è del tipo passato allora ritorna `true`, altrimenti `false`
  bool isExceptionOfType(Type t) =>
      fold((err) => false, (exc) => exc.runtimeType == t);  

  /// Crea un Iterable con un solo elemento contenente il Fail corrente
  Iterable<Failure> toIterable() => [this];

  ValidatedResult<T> toInvalid<T>() => InvalidResult(this);
}

extension ExceptionToFailureExtension on Exception {
  Failure toFailure<T>({String? errorMessage, int? internalErrorCode})
        => Failure.withException(this, errorMessage: errorMessage, internalErrorCode: internalErrorCode);

  ValidatedResult<T> toInvalid<T>({String? errorMessage, int? internalErrorCode})
        => toFailure(errorMessage: errorMessage, internalErrorCode: internalErrorCode).toInvalid();
}

extension ErrorToFailureExtension on Error {
  Failure toFailure<T>({String? errorMessage, int? internalErrorCode})
        => Failure.withError(this, errorMessage: errorMessage, internalErrorCode: internalErrorCode);

  ValidatedResult<T> toInvalid<T>({String? errorMessage, int? internalErrorCode})
        => toFailure(errorMessage: errorMessage, internalErrorCode: internalErrorCode).toInvalid();
}