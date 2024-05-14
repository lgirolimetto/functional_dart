class _FPAnnotation {
  final String message;
  const _FPAnnotation({this.message = ''});

  String toString() => message;
}

class _Pure extends _FPAnnotation{
  const _Pure({super.message = 'Pure'});
}

const Object pure = _Pure();

class _Impure extends _FPAnnotation{
  const _Impure({super.message = 'Impure'});
}


const Object impure = _Impure();