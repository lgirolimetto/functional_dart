Either<L, R> Left<L, R>(L left) => Either._left(left);
Either<L, R> Right<L, R>(R right) => Either._right(right);

/// Classe che permette di avere un risultato di un tipo oppure di un altro.
/// Un left solitamente va messo un risultato di errore
class Either<L, R> {
  final L? _l;
  final R? _r;

  bool get isLeft => _l != null;
  bool get isRight => !isLeft;

  /// Inizializza l'oggetto con il tipo L
  Either._left(L left)
      : _l = left,
        _r = null;

  /// Inizializza l'oggetto con il tipo R
  Either._right(R right)
      : _r = right,
        _l = null;

  /// Estrae il tipo contenuto da `Either` (L o R) e chiama la funzione corrispondente
  /// che dovranno essere passate come closures
  TR fold<TR>(TR Function(L l) leftF, TR Function(R r) rightF) =>
    isLeft ? leftF(_l!) : rightF(_r!);
      
  /// Concatena il risultato Either con un'altra funzione che non ritorna un Either.
  /// Se Either contiene L, allora la funzione non viene chiamata (L è considerato in stato di errore)
  /// e ritorna semplicemente l'Either che contiene L
  Either<L, RR> map<RR>(RR Function(R r) f) =>
      fold((l) => Left(l), (right) => Right(f(right)));

  /// Come la `map`, con la differenza che chiama la lf o rf in base al tipo contenuto. 
  /// Quindi non considera L come errore
  Either<LL, RR> biMap<LL, RR>(LL Function(L l) lf, RR Function(R r) rf) =>
      fold((l) => Left(lf(l)), (right) => Right(rf(right)));

  Either<L, void> foreEach(void Function(R r) f) => map(f);

  /// Concatena il risultato Either con un'altra funzione che ritorna un `Either`.
  /// Se Either contiene L, allora la funzione non viene chiamata (L è considerato in stato di errore)
  /// e ritorna semplicemente l'Either che contiene L
  Either<L, RR> bind<RR>(Either<L, RR> Function(R r) f) =>
      fold((l) => Left(l), (right) => f(right));

  /// Extract left result as an Iterable of 0|1 elements
  Iterable<L> asLeft() sync* {
    if (isLeft) {
      yield _l!;
    }
  }

  /// Extract right result as an Iterable of 0|1 elements
  Iterable<R> asRight() sync* {
    if (isRight) {
      yield _r!;
    }
  }
}


extension EitherOnT<T> on T {
  Either<T, R> toLeft<R>() => Left<T, R>(this);
  Either<L, T> toRight<L>() => Right<L, T>(this);
}