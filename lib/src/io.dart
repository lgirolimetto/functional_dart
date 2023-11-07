// public static IO<T> Pure<T>([NotNull] T? pure)
// => new(pure ?? throw new ArgumentNullException(nameof(pure)));
//
// public static IO<T> Pure<T>([NotNull] Func<T>? pure)
// => new(pure != null ? pure() : throw new ArgumentNullException(nameof(pure)));
//
// public static IO<T> Delay<T>([NotNull] Func<T>? fToDelay)
// => new(fToDelay ?? throw new ArgumentNullException(nameof(fToDelay)));
//
// public static IO<T> Delay<T>([NotNull] Try<T>? @try)
// => new(@try ?? throw new ArgumentNullException(nameof(@try)));
//
// public static IO<Unit> DelayAction([NotNull] Action? aToDelay)
// => new(aToDelay?.ToFunc() ?? throw new ArgumentNullException(nameof(aToDelay)));

import 'package:lg_functional_dart/lg_functional_dart.dart';

IO<T> Pure<T>(T value) => IO.pure(value);
IO<T> Delay<T>(T Function() f) => IO.delay(f);


class IO<T> {
  final T? _pure;
  final T Function()? _delayedFunction;
  final bool isPure;

  bool get isDelay => !isPure;

  const IO.pure(T t)
      : _pure = t,
        _delayedFunction = null,
        isPure = true;

  const IO.delay(T Function() f)
      : _pure = null,
        _delayedFunction = f,
        isPure = false;

  Validation<T> Run()
  {
    if (isPure)
    {
      return Valid(_pure!);
    }
    else
    {
      return Try(_delayedFunction!);
    }
  }
}