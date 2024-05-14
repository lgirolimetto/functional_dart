sealed class RetryStrategy {
  final int nRetries;
  const RetryStrategy({this.nRetries = 3});
}

class LinearRetry extends RetryStrategy {
  final Duration delayDuration;
  const LinearRetry({super.nRetries, this.delayDuration = const Duration(milliseconds: 300)});
}

class IncrementalRetry extends LinearRetry {
  final Duration Function(Duration initialDelay, int currentTry)? calcIncremental;
  const IncrementalRetry({
    super.nRetries,
    super.delayDuration,
    this.calcIncremental
  });
}

extension DoubleToDuration on int {
  Duration get ms => Duration(milliseconds: this);
  Duration get ss => Duration(seconds: this);
}