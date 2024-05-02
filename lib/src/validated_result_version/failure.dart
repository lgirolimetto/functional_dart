import 'package:basic_functional_dart/basic_functional_dart.dart';

/// Classe di errore usata nella `Validation` e può contenere un `Error` o un'`Exception`
/// Molto simile come concetto a `Either`
class Failure {
  final String message;
  final int internalErrorCode;
  final Either<Error, Exception> _failedWith;
  
  Failure.withError(Error error, {
    String message = '',
    int internalErrorCode = -1}
  ) : message = message,
      internalErrorCode = internalErrorCode,
      _failedWith = Left<Error, Exception>(error);
      
  Failure.withException(Exception exception, {
    String message = '',
    int internalErrorCode = -1
  }) : message = message,
        internalErrorCode = internalErrorCode,
        _failedWith = Right<Error, Exception>(exception);

  /// Restituisce il messaggio dell'Error o dell'Exception
  @override
  String toString () {
    var innerMessage = _failedWith.fold((l) => l.toString(), (r) => r.toString());
    if (message.isNotEmpty)
    {
      return '$message - $innerMessage';
    }

    return innerMessage;
  }
      

  /// Estrae il possibile Error o Exception.
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
  Failure toFailure<T>({String message = '', int internalErrorCode = -1})
        => Failure.withException(this, message: message, internalErrorCode: internalErrorCode);

  ValidatedResult<T> toInvalid<T>({String message = '', int internalErrorCode = -1})
        => toFailure(message: message, internalErrorCode: internalErrorCode).toInvalid();
}

extension ErrorToFailureExtension on Error {
  Failure toFailure<T>({String message = '', int internalErrorCode = -1})
        => Failure.withError(this, message: message, internalErrorCode: internalErrorCode);

  ValidatedResult<T> toInvalid<T>({String message = '', int internalErrorCode = -1})
        => toFailure(message: message, internalErrorCode: internalErrorCode).toInvalid();
}