import 'package:basic_functional_dart/basic_functional_dart.dart';

/// Classe di errore usata nella `Validation` e può contenere un `Error` o un'`Exception`
/// Molto simile come concetto a `Either`
class Fail {
  final String message;
  final Either<Error, Exception> _failedWith;
  
  Fail.withError(Error error, {String message = ''}) : message = message,
                                                      _failedWith = Left<Error, Exception>(error);
      
  Fail.withException(Exception exception, {String message = ''}) : message = message,
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
  T fold<T>(T Function(Error err) errF,
      T Function(Exception exc) excF) {
    return _failedWith.fold((error) => errF(error), (exc) => excF(exc));
  }

  /// Se `Fail`contiene un eccezione e quell'eccezione è del tipo passato allora ritorna `true`, altrimenti `false`
  bool isExceptionOfType(Type t) =>
      fold((err) => false, (exc) => exc.runtimeType == t);  

  /// Crea un Iterable con un solo elemento contenente il Fail corrente
  Iterable<Fail> toIterable () => [this];

  Validation<T> toInvalid<T> () => Invalid<T>(this);
}

extension ExceptionToFailExtension on Exception {
  Fail toFail([String message = '']) => Fail.withException(this, message: message);
  Validation<T> toInvalid<T> () => toFail ().toInvalid<T>();
}

extension ErrorToFailExtension on Error {
  Fail toFail([String message = '']) => Fail.withError(this, message: message);
  Validation<T> toInvalid<T> () => toFail ().toInvalid<T>();
}